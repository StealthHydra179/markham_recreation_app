module.exports = function (expressServer, logger, postgresClient, dataSanitization, getPostgresConnected) {
    expressServer.get("/api/get_parent_notes/:camp_id", (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({message: "Database not connected"});
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `GET /api/get_parent_notes/:camp_id ${dataSanitization(req.params.camp_id)}`,
        );

        const query = `SELECT parent_note.*, app_user.first_name, app_user.last_name
                       FROM parent_note
                                LEFT JOIN app_user ON parent_note.pa_note_upd_by = app_user.user_id
                       WHERE camp_id = $1
                       ORDER BY pa_note_date DESC`;
        const values = [dataSanitization(req.params.camp_id)];

        postgresClient.query(query, values, (err, result) => {
            if (err) {
                logger.error(err);
                return;
            }
            console.log(result.rows);
            res.json(result.rows);
        });
    });

    expressServer.post("/api/new_parent_notes/:camp_id", (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({message: "Database not connected"});
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/new_parent_note/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.parent_note_date)} ${dataSanitization(req.body.parent_note)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // if followed up is false, change notes to empty string
        if (dataSanitization(req.body.followed_Up) === "false") {
            req.body.reason = "";
        }

        // TODO check if values are correct

        // Add to database
        const addQuery =
            "INSERT INTO parent_note (camp_id, pa_note_date, pa_note, pa_note_upd_date, pa_note_upd_by) VALUES ($1, $2, $3, $4, $5)";
        const addQueryValues = [
            dataSanitization(req.params.camp_id),
            dataSanitization(req.body.parent_note_date),
            dataSanitization(req.body.parent_note),
            new Date().toISOString(),
            0, // dataSanitization(req.body.pa_note_upd_by),
        ];
        console.log(addQueryValues);
        postgresClient.query(addQuery, addQueryValues, (err, res) => {
            if (err) {
                logger.error("Add parent notes error: ", err); // TODO send an error to the client
                return;
            }
            logger.info("Added new parent note to database");
        });
        res.json(req.body);
    });

    // TODO sanitize before putting into logger
    expressServer.post("/api/edit_parent_notes/:camp_id", (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({message: "Database not connected"});
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/edit_parent_note/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.parent_note_date)} ${dataSanitization(req.body.parent_note)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // update specific query
        const updateQuery =
            "UPDATE parent_note SET pa_note_date = $1, pa_note = $2, pa_note_upd_date = $3, pa_note_upd_by = $4 WHERE pa_note_id = $5";
        const updateQueryValues = [
            dataSanitization(req.body.parent_note_date),
            dataSanitization(req.body.parent_note),
            new Date().toISOString(),
            0, //TODO pa_note_upd_by
            dataSanitization(req.body.parent_note_id),
        ];
        console.log(updateQueryValues);
        postgresClient
            .query(updateQuery, updateQueryValues)
            .then((res) => {
                logger.info("Updated parent note in database");
                logger.debug("Parent note update: ", res);
            })
            .catch((e) => {
                logger.error("Edit parent note error: ", e);
            });
        res.json(req.body);
    });

    expressServer.post("/api/delete_parent_notes/:camp_id", (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({message: "Database not connected"});
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/delete_parent_notes/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.parent_note_id)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // delete specific query
        const deleteQuery = "DELETE FROM parent_note WHERE pa_note_id = $1";
        const deleteQueryValues = [dataSanitization(req.body.parent_note_id)];
        console.log(deleteQueryValues);
        postgresClient
            .query(deleteQuery, deleteQueryValues)
            .then((res) => {
                console.log("Deleted parent note");
            })
            .catch((e) => {
                logger.error("Delete parent notes error:", e);
            });
        res.json(req.body);
    });

    logger.log("info", "parentNoteRoutes.js loaded");
};
