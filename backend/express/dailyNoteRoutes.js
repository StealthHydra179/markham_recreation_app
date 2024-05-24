const authenticate = require("./helper/authentication");

module.exports = function (expressServer, logger, postgresClient, dataSanitization, getPostgresConnected) {
    expressServer.get("/api/get_daily_notes/:camp_id", authenticate, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(`GET /api/get_daily_notes/:camp_id ${dataSanitization(req.params.camp_id)}`);

        // Rewriting using a join statement
        const query = `SELECT e.*, u.first_name, u.last_name
                   FROM daily_note AS e LEFT JOIN app_user AS u ON e.daily_note_upd_by = u.user_id
                   WHERE camp_id = $1
                   ORDER BY daily_note_date DESC`;
        const values = [dataSanitization(req.params.camp_id)];

        postgresClient.query(query, values, (err, result) => {
            if (err) {
                logger.error("Get daily notes error: ", err);
                return;
            }
            res.json(result.rows);
        });
    });

    expressServer.post("/api/new_daily_note/:camp_id", authenticate, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/new_daily_note/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.daily_note)} ${dataSanitization(req.body.daily_note_date)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // Add to database
        const addQuery =
            "INSERT INTO daily_note (camp_id, daily_note, daily_note_date, daily_note_upd_date, daily_note_upd_by) VALUES ($1, $2, $3, $4, $5)";
        const addQueryValues = [
            dataSanitization(req.params.camp_id),
            dataSanitization(req.body.daily_note),
            dataSanitization(req.body.daily_note_date),
            new Date().toISOString(),
            0, //TODO equie_note_upd_by
        ];

        postgresClient.query(addQuery, addQueryValues, (err, res) => {
            if (err) {
                logger.error("New daily note error: ", err); // TODO send an error to the client // TODO figure out why logger.error gave undefined?
                return;
            }
            logger.info("Added new daily note to database");
        });
        res.json(req.body);
    });

    // TODO sanitize before putting into logger
    expressServer.post("/api/edit_daily_note/:camp_id", authenticate, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/edit_daily_note/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.daily_note)} ${dataSanitization(req.body.daily_note_date)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // update specific query
        const updateQuery =
            "UPDATE daily_note SET daily_note = $1, daily_note_upd_date = $2, daily_note_upd_by = $3, daily_note_date = $5 WHERE daily_note_id = $4";
        const updateQueryValues = [
            dataSanitization(req.body.daily_note),
            new Date().toISOString(),
            0, //TODO equie_note_upd_by
            dataSanitization(req.body.daily_note_id),
            dataSanitization(req.body.daily_note_date),
        ];

        postgresClient
            .query(updateQuery, updateQueryValues)
            .then((res) => {
                logger.info("Updated daily note in database");
            })
            .catch((e) => {
                logger.error("Edit daily note error: ", e);
            });
        res.json(req.body);
    });

    expressServer.post("/api/delete_daily_note/:camp_id", authenticate, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/delete_daily_note/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.daily_note_id)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // delete specific query
        const deleteQuery = "DELETE FROM daily_note WHERE daily_note_id = $1";
        const deleteQueryValues = [dataSanitization(req.body.daily_note_id)];

        postgresClient
            .query(deleteQuery, deleteQueryValues)
            .then((res) => {
                logger.info("Deleted daily note from database");
            })
            .catch((e) => {
                logger.error("Delete daily note error: ", e);
            });
        res.json(req.body);
    });

    logger.info("dailyNoteRoutes.js loaded");
};