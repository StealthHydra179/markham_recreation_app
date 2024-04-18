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

    return `${dateTime} [${label}] ${level}: ${message} ${Object.keys(args).length ? "\n" + JSON.stringify(args, null, 2) : ""}`;
});

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
        loggerFormat,
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
                loggerFormat,
            ),
            level: "debug",
        }),
    );
}
logger.info("Server started");

async function postgresConnect() {
    await postgresClient.connect();
    await postgresClient.query("SET SCHEMA 'markham_rec';");
    postgresConnected = true;
}
function getPostgresConnected() {
    return postgresConnected;
}

postgresConnect()
    .then((r) => {
        logger.info("Connected to database");
    })
    .catch((e) => {
        logger.error("Error connecting to database", e);
    });

function dataSanitization(input) {
    return input;
}

// Webserver/API Routes
expressServer.get("/", (req, res) => {
    res.send("Hello World");
    logger.info("json", { test: "json" });
});

expressServer.get("/api", (req, res) => {
    if (!postgresConnected) {
        res.status(500).send({ message: "Database not connected" });
        logger.error("Database not connected");
        return;
    }
    res.send({ message: "Hello World" });
});

expressServer.use("/admin", express.static("web"));

let routePassthrough = [expressServer, logger, postgresClient, dataSanitization, getPostgresConnected];

// Mobile Routes
require("./express/campRoutes")(...routePassthrough);
require("./express/weeklyChecklistRoutes")(...routePassthrough);
require("./express/messageBoardRoutes")(...routePassthrough);
require("./express/attendanceRoutes")(...routePassthrough);
require("./express/absenceRoutes")(...routePassthrough);
require("./express/dailyNoteRoutes")(...routePassthrough);
require("./express/incidentNoteRoutes")(...routePassthrough);
require("./express/parentNoteRoutes")(...routePassthrough);
require("./express/equipmentNoteRoutes")(...routePassthrough);
require("./express/staffPerformanceRoutes")(...routePassthrough);
require("./express/supervisorMeetingNoteRoutes")(...routePassthrough);
require("./express/counsellorMeetingNoteRoutes")(...routePassthrough);

// Admin Website Routes
require("./express/admin/adminRoutes")(...routePassthrough);

expressServer.listen(serverPort, () => {
    logger.info(`Server running on port ${serverPort}`);
});
