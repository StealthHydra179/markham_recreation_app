module.exports = function (expressServer, logger, postgresClient, dataSanitization, getPostgresConnected) {
    expressServer.get("/admin", (req, res) => {
        // send web/index.html
        res.sendFile("web/index.html", { root: "./" });
    })

    expressServer.get("/api/weekly_summary", (req, res) => {
        // get weekly summary
        // return json
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(`GET /api/weekly_summary`);

        // Incident reports, absent campers, and parent comment count for the week
        let startOfWeek = new Date();
        startOfWeek.setHours(0, 0, 0, 0);
        startOfWeek.setDate(startOfWeek.getDate() - startOfWeek.getDay()); // TODO check if this is even correct

        let incident_note_count = `SELECT COUNT(*) AS incident_reports FROM incident_note WHERE in_note_date >= $1;`
        let absent_campers_count = `SELECT COUNT(*) AS absent_campers FROM absence WHERE absence_date >= $1;`
        let parent_comments_count = `SELECT COUNT(*) AS parent_comments FROM parent_note WHERE pa_note_date >= $1;`
        let values = [startOfWeek];

        logger.error("weekly_summary not implemented");
        res.status(501).send({ message: "Not implemented" }); // TODO implement
    })

    expressServer.get("api/admin_statistics", (req, res) => {
        // get admin statistics
        // return json
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(`GET /api/admin_statistics`);

        logger.error("admin_statistics not implemented");
        res.status(501).send({ message: "Not implemented" }); // TODO implement
    })

    logger.warn("adminRoutes.js not implemented");
}