const express = require("express");
let cookie_parser = require("cookie-parser");
const { Client: postgres_client } = require("pg");
const winston = require("winston");
const DailyRotateFile = require("winston-daily-rotate-file");
const uuid = require("uuid");
var session = require("express-session");

// Load environment variables
require("dotenv").config();

// Express Server
const expressServer = express();
const serverPort = process.env.PORT || 3000;
expressServer.use(express.json());
expressServer.use(cookie_parser("mark_rec_cjkw3as"));
// expressServer.set('trust proxy', 1)
expressServer.use(
    session({
        genid: function (req) {
            let id = uuid.v4(); // use UUIDs for session IDs
            // console.log("Session ID: " + id);
            return id; // use UUIDs for session IDs
        },
        secret: "mark_rec_cjkw3as",
        resave: false,
        saveUninitialized: true,
        cookie: {
            secure: false, //TODO when on https, set to true
            maxAge: 600000,
        },
    }),
);

// Database Connection
const postgresClient = new postgres_client({
    application_name: "Markham Recreation Summer Camp Server",
    ssl: process.env.db_SSL ? false : { rejectUnauthorized: false },
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
        new DailyRotateFile({
            filename: "logs/markham_rec_server-%DATE%-all.log",
            datePattern: "YYYY-MM-DD",
            zippedArchive: false,
            maxSize: "20m",
            level: "debug",
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
    // res.send("Hello World");
    // redirect to admin/home
    res.redirect("/admin/home");
});

expressServer.get("/admin", (req, res) => {
    res.redirect("/admin/home");
});

expressServer.get("/api", (req, res) => {
    if (!postgresConnected) {
        res.status(500).send({ message: "Database not connected" });
        logger.error("Database not connected");
        return;
    }
    res.send({ message: "Hello World" });
});

expressServer.get("/privacy", (req, res) => {
    res.send(
        "Privacy: All data is confidential and will not be shared with any third parties except for Markham Recreation. All data is encrypted and stored securely. If you have any questions, please contact Markham Recreation.",
    );
});

expressServer.use("/admin", express.static("web"));

let routePassthrough = [expressServer, logger, postgresClient, dataSanitization, getPostgresConnected];

// Authentication Routes
require("./express/helper/authenticationRoutes")(...routePassthrough);

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

// const bcrypt = require("bcrypt");
// const saltRounds = 10;
//
// function addUser() {
//     let email = "user@example.com";
//     let plainTextPassword = "hello";
//
//
//     email = encodeURIComponent(email);
//     plainTextPassword = encodeURIComponent(plainTextPassword);
//     // use datacleaning
//     email = dataSanitization(email);
//     plainTextPassword = dataSanitization(plainTextPassword);
//
//     bcrypt.hash(plainTextPassword, saltRounds, function(err, hash) {
//         // Store hash in your password DB.
//
//         let query = `INSERT INTO app_user (email, user_password) VALUES ($1, $2);`;
//         let values = [email, hash];
//         postgresClient.query(query, values, (err, result) => {
//             if (err) {
//                 logger.error("e", err);
//                 // res.status(500).send({ message: "Error adding user" });
//                 return;
//             } else {
//                 // res.status(200).send({ message: "User added" });
//                 logger.info("User added");
//             }
//         });
//     });
// }
// addUser()
//
//
// function isAuthenticated (req, res, next) {
//     if (req.session.user) next()
//     else next('route')
// }
//
// expressServer.get('/a', isAuthenticated, function (req, res) {
//     // this is only called when there is an authentication user due to isAuthenticated
//     res.send('hello, ' + escapeHtml(req.session.user) + '!' +
//         ' <a href="/logout">Logout</a>')
// })
//
// expressServer.get('/a', function (req, res) {
//     res.send('<form action="/login" method="post">' +
//         'Username: <input name="user"><br>' +
//         'Password: <input name="pass" type="password"><br>' +
//         '<input type="submit" text="Login"></form>')
// })
