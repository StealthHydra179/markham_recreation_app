const authenticate = require("./helper/authentication");

module.exports = function (expressServer, logger, postgresClient, dataSanitization, getPostgresConnected) {
    expressServer.get("/api/get_messages/:camp_id", authenticate, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(`GET /api/get_messages/:camp_id ${dataSanitization(req.params.camp_id)}`);

        // Rewriting using a join statement
        const query = `SELECT e.*, u.first_name, u.last_name
                   FROM message_board AS e LEFT JOIN app_user AS u ON e.app_message_upd_by = u.user_id
                   WHERE camp_id = $1
                   ORDER BY app_message_date DESC`;
        const values = [dataSanitization(req.params.camp_id)];

        postgresClient.query(query, values, (err, result) => {
            if (err) {
                logger.error("Get messages error: ", err);
                return;
            }
            res.json(result.rows);
        });
    });

    expressServer.post("/api/new_message/:camp_id", authenticate, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/new_message/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.app_message)} ${dataSanitization(req.body.app_message_date)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // Add to database
        const addQuery =
            "INSERT INTO message_board (camp_id, app_message, app_message_date, app_message_upd_date, app_message_upd_by) VALUES ($1, $2, $3, $4, $5)";
        const addQueryValues = [
            dataSanitization(req.params.camp_id),
            dataSanitization(req.body.app_message),
            dataSanitization(req.body.app_message_date),
            new Date().toISOString(),
            0, //TODO equie_note_upd_by
        ];

        postgresClient.query(addQuery, addQueryValues, (err, res) => {
            if (err) {
                logger.error("New message error: ", err); // TODO send an error to the client // TODO figure out why logger.error gave undefined?
                return;
            }
            logger.info("Added new message to database");
        });
        res.json(req.body);
    });

    // TODO sanitize before putting into logger
    expressServer.post("/api/edit_message/:camp_id", authenticate, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/edit_message/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.app_message)} ${dataSanitization(req.body.app_message_date)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // update specific query
        const updateQuery =
            "UPDATE message_board SET app_message = $1, app_message_upd_date = $2, app_message_upd_by = $3, app_message_date = $5 WHERE app_message_id = $4";
        const updateQueryValues = [
            dataSanitization(req.body.app_message),
            new Date().toISOString(),
            0, //TODO equie_note_upd_by
            dataSanitization(req.body.app_message_id),
            dataSanitization(req.body.app_message_date),
        ];

        postgresClient
            .query(updateQuery, updateQueryValues)
            .then((res) => {
                logger.info("Updated message in database");
            })
            .catch((e) => {
                logger.error("Edit message error: ", e);
            });
        res.json(req.body);
    });

    expressServer.post("/api/delete_message/:camp_id", authenticate, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/delete_message/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.app_message_id)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // delete specific query
        const deleteQuery = "DELETE FROM message_board WHERE app_message_id = $1";
        const deleteQueryValues = [dataSanitization(req.body.app_message_id)];

        postgresClient
            .query(deleteQuery, deleteQueryValues)
            .then((res) => {
                logger.info("Deleted message from database");
            })
            .catch((e) => {
                logger.error("Delete message error: ", e);
            });
        res.json(req.body);
    });

    logger.info("messageBoardRoutes.js loaded");
};