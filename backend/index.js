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
// Development environment
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

function dataSanitization(input) {
    return input
}

// Webserver/API Routes
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

expressServer.get("/api/weekly_checklist/:camp_id", async (req, res) => {
    if (!postgresConnected) {
        res.status(500).send({ message: "Database not connected" });
        logger.warn("Database not connected");
        return;
    }
    logger.debug(`GET /api/weekly_checklist/:camp_id ${dataSanitization(req.params.camp_id)}`);

    const { rows } = await postgresClient.query(
        `SELECT * FROM checklist WHERE camp_id = ${dataSanitization(req.params.camp_id)}`,
    );
    if (rows.length === 0) {
        // create a new checklist
        logger.debug(`Creating new checklist ${dataSanitization(req.params.camp_id)}`);
        const insertQuery = "INSERT INTO checklist (camp_id) VALUES ($1)";
        const insertValues = [dataSanitization(req.params.camp_id)];
        await postgresClient.query(insertQuery, insertValues);
        const { rows } = await postgresClient.query(
            `SELECT * FROM checklist WHERE camp_id = ${dataSanitization(req.params.camp_id)}`,
        );
        res.json(rows[0]);
    } else {
        res.json(rows[0]);
    }

});
expressServer.post("/api/weekly_checklist/:camp_id", async (req, res) => {
    if (!postgresConnected) {
        res.status(500).send({ message: "Database not connected" });
        logger.warn("Database not connected");
        return;
    }
    logger.debug(`POST /api/weekly_checklist/:camp_id ${dataSanitization(req.params.camp_id)}`);

    const updateQuery = `UPDATE checklist SET camper_info_form = $1, camper_info_form_upd_by = $2, camper_info_form_upd_date = $3, allergy_medical_info = $4, allergy_medical_info_upd_by = $5, allergy_medical_info_upd_date = $6, swim_test_records = $7, swim_test_records_upd_by = $8, swim_test_records_upd_date = $9, weekly_plans = $10, weekly_plans_upd_by = $11, weekly_plans_upd_date = $12, director_check = $13, director_check_upd_by = $14, director_check_upd_date = $15, counsellor_check = $16, counsellor_check_upd_by = $17, counsellor_check_upd_date = $18 WHERE camp_id = $19`;
    let user_id = 0; // TODO get user id
    const updateValues = [
        dataSanitization(req.body.camper_info_form),
        user_id,
        new Date().toISOString(),
        dataSanitization(req.body.allergy_medical_info),
        user_id,
        new Date().toISOString(),
        dataSanitization(req.body.swim_test_records),
        user_id,
        new Date().toISOString(),
        dataSanitization(req.body.weekly_plans),
        user_id,
        new Date().toISOString(),
        dataSanitization(req.body.director_check),
        user_id,
        new Date().toISOString(),
        dataSanitization(req.body.counsellor_check),
        user_id,
        new Date().toISOString(),
        dataSanitization(req.params.camp_id),
    ];
    await postgresClient.query(updateQuery, updateValues);
    res.json({});

});

expressServer.get("/api/get_absences/:camp_id", (req, res) => {
    if (!postgresConnected) {
        res.status(500).send({ message: "Database not connected" });
        logger.warn("Database not connected");
        return;
    }
    logger.debug(`GET /api/get_absences/:camp_id ${dataSanitization(req.params.camp_id)}`);

    const query = "SELECT * FROM absent WHERE camp_id = $1 ORDER BY absent_date DESC";
    const values = [dataSanitization(req.params.camp_id)];
    postgresClient.query(query, values, async (err, result) => {
        if (err) {
            logger.error(err);
            return;
        }

        // for every row change the upd_by to the name of the person who updated it
        for (let i = 0; i < result.rows.length; i++) {
            const query = "SELECT * FROM users WHERE user_id = $1";
            const values = [result.rows[i].absent_upd_by];
            const res = await postgresClient.query(query, values);
            result.rows[i]["absent_upd_by"] =
                res.rows[0].first_name + " " + res.rows[0].last_name;
        }
        res.json(result.rows);
    });
});

expressServer.post("/api/new_absence/:camp_id", (req, res) => {
    if (!postgresConnected) {
        res.status(500).send({ message: "Database not connected" });
        logger.warn("Database not connected");
        return;
    }
    logger.debug(
        `POST /api/new_absence/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.camper_first_name)} ${dataSanitization(req.body.camper_last_name)} ${dataSanitization(req.body.absent_date)} ${dataSanitization(req.body.followed_Up)} ${dataSanitization(req.body.reason)}`,
    );
    logger.warn("TODO do input data validation"); // TODO

    // if followed up is false, change notes to empty string
    if (dataSanitization(req.body.followed_Up) === "false") {
        req.body.reason = "";
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
        0, // dataSanitization(req.body.absent_upd_by),
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
        `POST /api/edit_absence/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.camper_first_name)} ${dataSanitization(req.body.camper_last_name)} ${dataSanitization(req.body.absent_date)} ${dataSanitization(req.body.followed_up)} ${dataSanitization(req.body.reason)}`,
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
            logger.info("Updated absence in database");
        })
        .catch((e) => {
            logger.error(e.stack);
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
        `POST /api/delete_absence/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.absent_id)}`,
    );
    logger.warn("TODO do input data validation"); // TODO

    // delete specific query
    const deleteQuery = "DELETE FROM absent WHERE absent_id = $1";
    const deleteQueryValues = [
        dataSanitization(req.body.absent_id)
    ];
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
