const express = require("express");
const { Client: postgres_client } = require("pg");
const winston = require("winston");
const DailyRotateFile = require("winston-daily-rotate-file");
// Load environment variables
require("dotenv").config();

// Express Server
const expressServer = express();
const serverPort = 3000;
expressServer.use(express.json());

// Database Connection
const postgresClient = new postgres_client({
    application_name: "Markham Recreation Summer Camp Server",
});
let postgresConnected = false;

const loggerFormat = winston.format.printf(({ level, message, label, timestamp, ...args }) => {
    let dateTime = new Date(timestamp).toLocaleString();
    dateTime = dateTime.split(",")[0] + dateTime.split(",")[1];

    return `${dateTime} [${label}] ${level}: ${message} ${Object.keys(args).length ? JSON.stringify(args, null, 2) : ""}`;
})
// Logger setup
// Winston Log with logging to console and file, rotating logs
// TODO setup a format function to log the date and time and the application name
const logger = winston.createLogger({
    level: "debug",
    format: winston.format.json(),
    defaultMeta: { service: "Markham Recreation Summer Camp Server" },
});
logger.configure({
    format: winston.format.combine(
        winston.format.colorize(),
        winston.format.label({ label: "Server" }),
        winston.format.timestamp(),
        loggerFormat
    ),
    transports: [
        new DailyRotateFile({
            filename: "logs/markham_rec_server-%DATE%-error.log",
            datePattern: "YYYY-MM-DD",
            zippedArchive: false,
            maxSize: "20m",
            level: "error",
        }),
        new DailyRotateFile({
            filename: "logs/markham_rec_server-%DATE%-info.log",
            datePattern: "YYYY-MM-DD",
            zippedArchive: false,
            maxSize: "20m",
            level: "info",
        }),
    ],
});
if (process.env.NODE_ENV !== "production" || process.env.NODE_ENV == null) {
    console.log("Logging to console");
    logger.add(
        new winston.transports.Console({
            format: winston.format.combine(
                winston.format.colorize(),
                winston.format.label({ label: "Server" }),
                winston.format.timestamp(),
                loggerFormat
            ),
            level: "debug",
        }),
    );
}
logger.info("Server started");

async function postgresConnect() {
    await postgresClient.connect();
    postgresConnected = true;
}

postgresConnect()
    .then((r) => {
        logger.info("Connected to database");
    })
    .catch((e) => {
        logger.error("Error connecting to database");
        logger.error(e);
    });

expressServer.get("/", (req, res) => {
    res.send("Hello World");
});

expressServer.get("/api", (req, res) => {
    if (!postgresConnected) {
        res.status(500).send({ message: "Database not connected" });
        logger.warn("Database not connected");
        return;
    }
    res.send({ message: "Hello World" });
});

expressServer.get("/api/weekly_checklist", async (req, res) => {
    if (!postgresConnected) {
        res.status(500).send({ message: "Database not connected" });
        logger.warn("Database not connected");
        return;
    }
    const { rows } = await postgresClient.query("SELECT * FROM checklist");
    res.json(rows);
    console.log(rows);
});
expressServer.post("/api/weekly_checklist/:camp_id", async (req, res) => {
    if (!postgresConnected) {
        res.status(500).send({ message: "Database not connected" });
        logger.warn("Database not connected");
        return;
    }
    logger.debug("POST /api/weekly_checklist/:camp_id"); // TODO, add camp ID and request body to the log
    console.log(req.body);

    const { rows } = await postgresClient.query(
        "SELECT * FROM checklist WHERE camp_id = " + req.params.camp_id,
    );
    res.json(req.body);
});

// app.post("/api/new_absence", (req, res) => {
//     if (!connected) {
//         res.status(500).send({ message: "Database not connected" });
//         logger.warn("Database not connected");
//         return;
//     }
//     // let camp_id = req.params.camp_id
//     // console.log(camp_id)
//     console.log(req.body);
//     res.json(req.body);
//     logger.warn("soon to be deprecated new_absence: use get_absence instead");
// });

expressServer.get("/api/get_absences/:camp_id", (req, res) => {
    if (!postgresConnected) {
        res.status(500).send({ message: "Database not connected" });
        logger.warn("Database not connected");
        return;
    }
    const camp_id = req.params.camp_id;

    const query = "SELECT * FROM absent WHERE camp_id = $1 ORDER BY date DESC";
    const values = [camp_id];
    postgresClient.query(query, values, async (err, result) => {
        if (err) {
            logger.error(err);
            return;
        }

        // for every row change the upd_by to the name of the person who updated it
        for (let i = 0; i < result.rows.length; i++) {
            const query = "SELECT * FROM users WHERE user_id = $1";
            const values = [result.rows[i].upd_by];
            const res = await postgresClient.query(query, values);
            result.rows[i]["absent_upd_by"] =
                res.rows[0].first_name + " " + res.rows[0].last_name;
        }
        res.json(result.rows);
    });
});

function dataSanitization(input) {
    return input
}

expressServer.post("/api/new_absence/:camp_id", (req, res) => {
    if (!connected) {
        res.status(500).send({ message: "Database not connected" });
        logger.warn("Database not connected");
        return;
    }
    logger.debug(
        "POST /api/new_absence/:camp_id " +
            dataSanitization(req.params.camp_id) +
            " " +
            dataSanitization(req.body.camper_first_name) +
            " " +
            dataSanitization(req.body.camper_last_name) +
            " " +
            dataSanitization(req.body.absent_date) +
            " " +
            dataSanitization(req.body.followed_Up) +
            " " +
            dataSanitization(req.body.reason),
    );
    logger.warn("TODO do input data validation"); // TODO

    // if followed up is false, change notes to empty string
    if (dataSanitization(req.body.followed_Up) === "false") {
        dataSanitization(req.body.reason) = "";
    }

    // TODO check if values are correct

    // Add to database
    const addQuery =
        "INSERT INTO absent (camp_id, camper_first_name, camper_last_name, absent_date, followed_up, reason, absent_date_modified, absent_upd_by) VALUES ($1, $2, $3, $4, $5, $6, $7,$8)";
    const addQueryValues = [
        dataSanitization(req.params.camp_id),
        dataSanitization(req.body.camper_first_name),
        dataSanitization(req.body.camper_last_name),
        dataSanitization(req.body.absent_date),
        dataSanitization(req.body.followed_Up),
        dataSanitization(req.body.reason),
        new Date().toISOString(),
        dataSanitization(req.body.absent_upd_by),
    ];
    console.log(addQueryValues);
    postgresClient.query(addQuery, addQueryValues, (err, res) => {
        if (err) {
            logger.error(err); // TODO send an error to the client // TODO figure out why logger.error gave undefined?
            console.log(err);
            return;
        }
        logger.info("Added new absence to database");
    });
    res.json(req.body);
});

// TODO sanitize before putting into logger
expressServer.post("/api/edit_absence/:camp_id", (req, res) => {
    if (!postgresConnected) {
        res.status(500).send({ message: "Database not connected" });
        logger.warn("Database not connected");
        return;
    }
    logger.debug(
        "POST /api/edit_absence/:camp_id " +
            dataSanitization(req.params.camp_id) +
            " " +
            dataSanitization(req.body.camper_first_name) +
            " " +
            dataSanitization(req.body.camper_last_name) +
            " " +
            dataSanitization(req.body.absent_date) +
            " " +
            dataSanitization(req.body.followed_up) +
            " " +
            dataSanitization(req.body.reason),
    );
    logger.warn("TODO do input data validation"); // TODO

    // if followed up is false, change notes to empty string
    if (req.body.followed_up === "false") {
        req.body.reason = "";
    }
    // update specific query
    const updateQuery =
        "UPDATE absent SET camper_first_name = $1, camper_last_name = $2, absent_date = $3, followed_up = $4, reason = $5, absent_date_modified = $6, absent_upd_by = $7 WHERE absent_id = $8";
    const updateQueryValues = [
        dataSanitization(req.body.camper_first_name),
        dataSanitization(req.body.camper_last_name),
        dataSanitization(req.body.absent_date),
        dataSanitization(req.body.followed_up),
        dataSanitization(req.body.reason),
        new Date().toISOString(),
        0, //TODO absent_upd_by
        dataSanitization(req.body.absent_id),
    ];
    console.log(updateQueryValues);
    postgresClient
        .query(updateQuery, updateQueryValues)
        .then((res) => {
            console.log("Updated");
        })
        .catch((e) => {
            console.error(e.stack);
        });
    res.json(req.body);
});

expressServer.post("/api/delete_absence/:camp_id", (req, res) => {
    if (!postgresConnected) {
        res.status(500).send({ message: "Database not connected" });
        logger.warn("Database not connected");
        return;
    }
    logger.debug(
        `POST /api/delete_absence/:camp_id ${req.params.camp_id} ${req.body.absent_id}`,
    );
    logger.warn("TODO do input data validation"); // TODO

    // delete specific query
    const deleteQuery = "DELETE FROM absent WHERE absent_id = $1";
    const deleteQueryValues = [req.body.absent_id];
    console.log(deleteQueryValues);
    postgresClient
        .query(deleteQuery, deleteQueryValues)
        .then((res) => {
            console.log("Deleted");
        })
        .catch((e) => {
            console.error(e.stack);
        });
    res.json(req.body);
});

expressServer.listen(serverPort, () => {
    logger.info(`Server running on port ${serverPort}`);
});
