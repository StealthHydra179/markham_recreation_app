const authenticate = require("./helper/authentication");

module.exports = function (expressServer, logger, postgresClient, dataSanitization, getPostgresConnected) {
    expressServer.get("/api/camp/:user_id", authenticate, (req, res) => {
        let postgresConnected = getPostgresConnected();

        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(`GET /api/camp/:user_id ${dataSanitization(req.params.user_id)}`);


        // TODO replace with join
        const query = "SELECT * FROM camp_user_role WHERE user_id = $1";
        const values = [dataSanitization(req.params.user_id)];
        postgresClient.query(query, values, async (err, result) => {
            if (err) {
                logger.error("e", err);
                return;
            }
            // get name of camp
            for (let i = 0; i < result.rows.length; i++) {
                const query = "SELECT * FROM camp WHERE camp_id = $1";
                const values = [result.rows[i].camp_id];
                const res = await postgresClient.query(query, values);
                result.rows[i]["camp_name"] = res.rows[0].camp_name;
                result.rows[i]["start_date"] = res.rows[0].start_date;
            }
            res.json(result.rows);
        });
    });

    logger.info("campRoutes.js loaded");
};
