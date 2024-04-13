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