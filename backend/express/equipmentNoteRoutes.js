module.exports = function (expressServer, logger, postgresClient, dataSanitization, getPostgresConnected) {
    expressServer.get("/api/get_equipment_notes/:camp_id", (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(`GET /api/get_equipment_notes/:camp_id ${dataSanitization(req.params.camp_id)}`);

        // Rewriting using a join statement
        const query = `SELECT e.*, u.first_name, u.last_name
                   FROM equipment_note AS e LEFT JOIN app_user AS u ON e.equip_note_upd_by = u.user_id
                   WHERE camp_id = $1
                   ORDER BY equip_note_date DESC`;
        const values = [dataSanitization(req.params.camp_id)];

        postgresClient.query(query, values, (err, result) => {
            if (err) {
                logger.error("Get equipment notes error: ", err);
                return;
            }
            res.json(result.rows);
        });
    });

    expressServer.post("/api/new_equipment_note/:camp_id", (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/new_equipment_note/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.equip_note)} ${dataSanitization(req.body.equip_note_date)} ${dataSanitization(req.body.absence_date)} ${dataSanitization(req.body.followed_up)} ${dataSanitization(req.body.reason)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // Add to database
        const addQuery =
            "INSERT INTO equipment_note (camp_id, equip_note, equip_note_date, equip_note_upd_date, equip_note_upd_by) VALUES ($1, $2, $3, $4, $5)";
        const addQueryValues = [
            dataSanitization(req.params.camp_id),
            dataSanitization(req.body.equip_note),
            dataSanitization(req.body.equip_note_date),
            new Date().toISOString(),
            0, //TODO equie_note_upd_by
        ];

        postgresClient.query(addQuery, addQueryValues, (err, res) => {
            if (err) {
                logger.error("New equipment note error: ", err); // TODO send an error to the client // TODO figure out why logger.error gave undefined?
                return;
            }
            logger.info("Added new equipment note to database");
        });
        res.json(req.body);
    });

    // TODO sanitize before putting into logger
    expressServer.post("/api/edit_equipment_note/:camp_id", (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/edit_equipment_note/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.equip_note)} ${dataSanitization(req.body.equip_note_date)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // update specific query
        const updateQuery =
            "UPDATE equipment_note SET equip_note = $1, equip_note_upd_date = $2, equip_note_upd_by = $3 WHERE equip_note_id = $4";
        const updateQueryValues = [
            dataSanitization(req.body.equip_note),
            new Date().toISOString(),
            0, //TODO equie_note_upd_by
            dataSanitization(req.body.equip_note_id),
        ];

        postgresClient
            .query(updateQuery, updateQueryValues)
            .then((res) => {
                logger.info("Updated equipment note in database");
            })
            .catch((e) => {
                logger.error("Edit equipment note error: ", e);
            });
        res.json(req.body);
    });

    expressServer.post("/api/delete_equipment_note/:camp_id", (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/delete_equipment_note/:camp_id ${dataSanitization(req.params.camp_id)} ${dataSanitization(req.body.equipment_note_id)}`,
        );
        logger.warn("TODO do input data validation"); // TODO

        // delete specific query
        const deleteQuery = "DELETE FROM equipment_note WHERE equip_note_id = $1";
        const deleteQueryValues = [dataSanitization(req.body.equipment_note_id)];

        postgresClient
            .query(deleteQuery, deleteQueryValues)
            .then((res) => {
                logger.info("Deleted equipment note from database");
            })
            .catch((e) => {
                logger.error("Delete equipment note error: ", e);
            });
        res.json(req.body);
    });

    logger.info("equipmentNoteRoutes.js loaded");
};