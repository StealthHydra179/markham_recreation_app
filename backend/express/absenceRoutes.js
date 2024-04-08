module.exports = function (expressServer, logger, postgresClient, dataSanitization, getPostgresConnected) {
    expressServer.get("/api/get_absences/:camp_id", (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(`GET /api/get_absences/:camp_id ${dataSanitization(req.params.camp_id)}`);

        // Rewriting using a join statement
        const query = `SELECT absence.*, app_user.first_name, app_user.last_name
                   FROM absence LEFT JOIN app_user ON absence.absence_upd_by = app_user.user_id
                   WHERE camp_id = $1
                   ORDER BY absence_date DESC`;
        const values = [dataSanitization(req.params.camp_id)];

        postgresClient.query(query, values, (err, result) => {
            if (err) {
                logger.error(err);
                return;
            }
            res.json(result.rows);
        });
    });

    expressServer.post("/api/new_absence/:camp_id", (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/new_absence/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.camper_first_name)} ${dataSanitization(req.body.camper_last_name)} ${dataSanitization(req.body.absence_date)} ${dataSanitization(req.body.followed_up)} ${dataSanitization(req.body.reason)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // if followed up is false, change notes to empty string
        if (dataSanitization(req.body.followed_up) === "false") {
            req.body.reason = "";
        }

        // TODO check if values are correct

        // Add to database
        const addQuery =
            "INSERT INTO absence (camp_id, camper_first_name, camper_last_name, absence_date, followed_up, reason, absence_upd_date, absence_upd_by) VALUES ($1, $2, $3, $4, $5, $6, $7,$8)";
        const addQueryValues = [
            dataSanitization(req.params.camp_id),
            dataSanitization(req.body.camper_first_name),
            dataSanitization(req.body.camper_last_name),
            dataSanitization(req.body.absence_date),
            dataSanitization(req.body.followed_up),
            dataSanitization(req.body.reason),
            new Date().toISOString(),
            0, // dataSanitization(req.body.absence_upd_by),
        ];
        // console.log(addQueryValues);
        postgresClient.query(addQuery, addQueryValues, (err, res) => {
            if (err) {
                logger.error("New absence error: ", err); // TODO send an error to the client // TODO figure out why logger.error gave undefined?
                // console.log(err);
                return;
            }
            logger.info("Added new absence to database");
        });
        res.json(req.body);
    });

    // TODO sanitize before putting into logger
    expressServer.post("/api/edit_absence/:camp_id", (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/edit_absence/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.camper_first_name)} ${dataSanitization(req.body.camper_last_name)} ${dataSanitization(req.body.absence_date)} ${dataSanitization(req.body.followed_up)} ${dataSanitization(req.body.reason)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // if followed up is false, change notes to empty string
        if (req.body.followed_up === "false") {
            req.body.reason = "";
        }
        // update specific query
        const updateQuery =
            "UPDATE absence SET camper_first_name = $1, camper_last_name = $2, absence_date = $3, followed_up = $4, reason = $5, absence_upd_date = $6, absence_upd_by = $7 WHERE absence_id = $8";
        const updateQueryValues = [
            dataSanitization(req.body.camper_first_name),
            dataSanitization(req.body.camper_last_name),
            dataSanitization(req.body.absence_date),
            dataSanitization(req.body.followed_up),
            dataSanitization(req.body.reason),
            new Date().toISOString(),
            0, //TODO absence_upd_by
            dataSanitization(req.body.absence_id),
        ];
        console.log(updateQueryValues);
        postgresClient
            .query(updateQuery, updateQueryValues)
            .then((res) => {
                logger.info("Updated absence in database");
            })
            .catch((e) => {
                logger.error("Edit absence error: ", e);
            });
        res.json(req.body);
    });

    expressServer.post("/api/delete_absence/:camp_id", (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/delete_absence/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.absence_id)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // delete specific query
        const deleteQuery = "DELETE FROM absence WHERE absence_id = $1";
        const deleteQueryValues = [dataSanitization(req.body.absence_id)];
        console.log(deleteQueryValues);
        postgresClient
            .query(deleteQuery, deleteQueryValues)
            .then((res) => {
                logger.info("Deleted absence from database");
            })
            .catch((e) => {
                logger.error("Delete absence error: ", e);
            });
        res.json(req.body);
    });

    logger.log("info", "absenceRoutes.js loaded");
};
