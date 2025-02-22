const authenticate = require("./helper/authentication");

module.exports = function (expressServer, logger, postgresClient, dataSanitization, getPostgresConnected) {
    expressServer.get("/api/get_supervisor_meeting_notes/:camp_id", authenticate, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(`GET /api/get_supervisor_meeting_notes/:camp_id ${dataSanitization(req.params.camp_id)}`);

        // Rewriting using a join statement
        const query = `SELECT e.*, u.first_name, u.last_name
                   FROM supervisor_meeting_note AS e LEFT JOIN app_user AS u ON e.smeet_note_upd_by = u.user_id
                   WHERE camp_id = $1
                   ORDER BY smeet_note_date DESC`;
        const values = [dataSanitization(req.params.camp_id)];

        postgresClient.query(query, values, (err, result) => {
            if (err) {
                logger.error("Get supervisor meeting notes error: ", err);
                return;
            }
            res.json(result.rows);
        });
    });

    expressServer.post("/api/new_supervisor_meeting_note/:camp_id", authenticate, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/new_supervisor_meeting_note/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.smeet_note)} ${dataSanitization(req.body.smeet_note_date)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // Add to database
        const addQuery =
            "INSERT INTO supervisor_meeting_note (camp_id, smeet_note, smeet_note_date, smeet_note_upd_date, smeet_note_upd_by) VALUES ($1, $2, $3, $4, $5)";
        const addQueryValues = [
            dataSanitization(req.params.camp_id),
            dataSanitization(req.body.smeet_note),
            dataSanitization(req.body.smeet_note_date),
            new Date().toISOString(),
            req.session.userId,
        ];

        postgresClient.query(addQuery, addQueryValues, (err, res1) => {
            if (err) {
                logger.error("New supervisor meeting note error: ", err);
                res.status(500).send({ message: "New supervisor meeting note error" });
                return;
            }
            logger.info("Added new supervisor meeting note to database");
        });
        res.json(req.body);
    });

    // TODO sanitize before putting into logger
    expressServer.post("/api/edit_supervisor_meeting_note/:camp_id", authenticate, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/edit_supervisor_meeting_note/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.smeet_note)} ${dataSanitization(req.body.smeet_note_date)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // update specific query
        const updateQuery =
            "UPDATE supervisor_meeting_note SET smeet_note = $1, smeet_note_upd_date = $2, smeet_note_upd_by = $3, smeet_note_date = $5 WHERE smeet_note_id = $4";
        const updateQueryValues = [
            dataSanitization(req.body.smeet_note),
            new Date().toISOString(),
            req.session.userId,
            dataSanitization(req.body.smeet_note_id),
            dataSanitization(req.body.smeet_note_date),
        ];

        postgresClient
            .query(updateQuery, updateQueryValues)
            .then((res) => {
                logger.info("Updated supervisor meeting note in database");
            })
            .catch((e) => {
                logger.error("Edit supervisor meeting note error: ", e);
            });
        res.json(req.body);
    });

    expressServer.post("/api/delete_supervisor_meeting_note/:camp_id", authenticate, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/delete_supervisor_meeting_note/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.supervisor_meeting_note_id)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // delete specific query
        const deleteQuery = "DELETE FROM supervisor_meeting_note WHERE smeet_note_id = $1";
        const deleteQueryValues = [dataSanitization(req.body.supervisor_meeting_note_id)];

        postgresClient
            .query(deleteQuery, deleteQueryValues)
            .then((res) => {
                logger.info("Deleted supervisor meeting note from database");
            })
            .catch((e) => {
                logger.error("Delete supervisor meeting note error: ", e);
            });
        res.json(req.body);
    });

    logger.info("supervisorMeetingNoteRoutes.js loaded");
};