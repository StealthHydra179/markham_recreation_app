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
                const query =
                    "SELECT * FROM camp LEFT JOIN camp_facility ON camp.facility_id = camp_facility.facility_id WHERE camp_id = $1";
                const values = [result.rows[i].camp_id];
                const res = await postgresClient.query(query, values);
                result.rows[i]["camp_name"] = res.rows[0].camp_name;
                result.rows[i]["start_date"] = res.rows[0].start_date;
                result.rows[i]["facility_name"] = res.rows[0].facility_name;
            }
            res.json(result.rows);
        });
    });

    expressServer.get("/api/campers/:camp_id", authenticate, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }

        logger.debug(`GET /api/campers/:camp_id ${dataSanitization(req.params.camp_id)}`);

        const query = "SELECT * FROM camp WHERE camp_id = $1";
        const values = [dataSanitization(req.params.camp_id)];
        postgresClient.query(query, values, (err, result) => {
            if (err) {
                logger.error("e", err);
                return;
            }
            if (result.rows.length == 0) {
                res.status(404).send({ message: "Camp not found" });
                return;
            }
            res.json(result.rows[0]);
        });
    });

    expressServer.post("/api/campers/:camp_id", authenticate, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }

        logger.debug(`POST /api/camp ${dataSanitization(req.params.camp_id)}`);

        // const query = "UPDATE camp (camper_count) VALUES ($1) WHERE camp_id = $2";
        const query = "UPDATE camp SET camper_count = $1 WHERE camp_id = $2";
        const values = [dataSanitization(req.body.campers), dataSanitization(req.params.camp_id)];
        postgresClient.query(query, values, (err, result) => {
            if (err) {
                logger.error("e", err);
                return;
            }
            res.json({ message: "Camp updated" });
        });
    });

    logger.info("campRoutes.js loaded");
};
