const authenticate = require("./helper/authentication");

module.exports = function (expressServer, logger, postgresClient, dataSanitization, getPostgresConnected) {
    expressServer.get('/api/attendance/:camp_id', authenticate, async function (req, res) {
        logger.info("GET /api/attendance");

        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug("GET /api/attendance");

        let retrieve_attendance = `SELECT * FROM attendance LEFT JOIN camp ON attendance.camp_id = camp.camp_id WHERE camp.camp_id = $1 ORDER BY attendance_date ASC `;
        let values = [dataSanitization(req.params.camp_id)];
        const { rows } = await postgresClient.query(retrieve_attendance, values);
        console.log(rows.length)
        res.json(rows);
    });

    logger.warn("attendanceRoutes.js not implemented");
}