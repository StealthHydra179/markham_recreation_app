const authenticate = require("./helper/authentication");

module.exports = function (expressServer, logger, postgresClient, dataSanitization, getPostgresConnected) {
    expressServer.get("/api/get_staff_performance_notes/:camp_id", authenticate, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(`GET /api/get_staff_performance_notes/:camp_id ${dataSanitization(req.params.camp_id)}`);

        // Rewriting using a join statement
        const query = `SELECT e.*, u.first_name, u.last_name
                   FROM staff_performance_note AS e LEFT JOIN app_user AS u ON e.st_note_upd_by = u.user_id
                   WHERE camp_id = $1
                   ORDER BY st_note_date DESC`;
        const values = [dataSanitization(req.params.camp_id)];

        postgresClient.query(query, values, (err, result) => {
            if (err) {
                logger.error("Get staff performance notes error: ", err);
                return;
            }
            res.json(result.rows);
        });
    });

    expressServer.post("/api/new_staff_performance_note/:camp_id", authenticate, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/new_staff_performance_note/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.st_note)} ${dataSanitization(req.body.st_note_date)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // Add to database
        const addQuery =
            "INSERT INTO staff_performance_note (camp_id, st_note, st_note_date, st_note_upd_date, st_note_upd_by) VALUES ($1, $2, $3, $4, $5)";
        const addQueryValues = [
            dataSanitization(req.params.camp_id),
            dataSanitization(req.body.st_note),
            dataSanitization(req.body.st_note_date),
            new Date().toISOString(),
            0, //TODO equie_note_upd_by
        ];

        postgresClient.query(addQuery, addQueryValues, (err, res) => {
            if (err) {
                logger.error("New staff performance note error: ", err); // TODO send an error to the client // TODO figure out why logger.error gave undefined?
                return;
            }
            logger.info("Added new staff performance note to database");
        });
        res.json(req.body);
    });

    // TODO sanitize before putting into logger
    expressServer.post("/api/edit_staff_performance_note/:camp_id", authenticate, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/edit_staff_performance_note/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.st_note)} ${dataSanitization(req.body.st_note_date)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // update specific query
        const updateQuery =
            "UPDATE staff_performance_note SET st_note = $1, st_note_upd_date = $2, st_note_upd_by = $3 WHERE st_note_id = $4";
        const updateQueryValues = [
            dataSanitization(req.body.st_note),
            new Date().toISOString(),
            0, //TODO equie_note_upd_by
            dataSanitization(req.body.st_note_id),
        ];

        postgresClient
            .query(updateQuery, updateQueryValues)
            .then((res) => {
                logger.info("Updated staff performance note in database");
            })
            .catch((e) => {
                logger.error("Edit staff performance note error: ", e);
            });
        res.json(req.body);
    });

    expressServer.post("/api/delete_staff_performance_note/:camp_id", authenticate, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/delete_staff_performance_note/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.staff_performance_note_id)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // delete specific query
        const deleteQuery = "DELETE FROM staff_performance_note WHERE st_note_id = $1";
        const deleteQueryValues = [dataSanitization(req.body.staff_performance_note_id)];

        postgresClient
            .query(deleteQuery, deleteQueryValues)
            .then((res) => {
                logger.info("Deleted staff performance note from database");
            })
            .catch((e) => {
                logger.error("Delete staff performance note error: ", e);
            });
        res.json(req.body);
    });

    logger.info("staffPerformanceNoteRoutes.js loaded");
};