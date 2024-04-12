module.exports = function (
    expressServer,
    logger,
    postgresClient,
    dataSanitization,
    getPostgresConnected,
) {
    // expressServer.get("/api/weekly_checklist/:camp_id", async (req, res) => {
    //     let postgresConnected = getPostgresConnected();
    //     if (!postgresConnected) {
    //         res.status(500).send({ message: "Database not connected" });
    //         logger.error("Database not connected");
    //         return;
    //     }
    //     logger.debug(
    //         `GET /api/weekly_checklist/:camp_id ${dataSanitization(req.params.camp_id)}`,
    //     );
    //
    //     const { rows } = await postgresClient.query(
    //         `SELECT *
    //      FROM checklist
    //      WHERE camp_id = ${dataSanitization(req.params.camp_id)}`,
    //     );
    //     if (rows.length === 0) {
    //         // create a new checklist
    //         logger.debug(
    //             `Creating new checklist ${dataSanitization(req.params.camp_id)}`,
    //         );
    //         const insertQuery = "INSERT INTO checklist (camp_id) VALUES ($1)";
    //         const insertValues = [dataSanitization(req.params.camp_id)];
    //         await postgresClient.query(insertQuery, insertValues);
    //         const { rows } = await postgresClient.query(
    //             `SELECT *
    //          FROM checklist
    //          WHERE camp_id = ${dataSanitization(req.params.camp_id)}`,
    //         );
    //         res.json(rows[0]);
    //     } else {
    //         res.json(rows[0]);
    //     }
    // });
    //
    // expressServer.post("/api/weekly_checklist/:camp_id", async (req, res) => {
    //     let postgresConnected = getPostgresConnected();
    //     if (!postgresConnected) {
    //         res.status(500).send({ message: "Database not connected" });
    //         logger.error("Database not connected");
    //         return;
    //     }
    //     logger.debug(
    //         `POST /api/weekly_checklist/:camp_id ${dataSanitization(req.params.camp_id)}`,
    //     );
    //
    //     const updateQuery = `UPDATE checklist
    //                      SET camper_info_form              = $1,
    //                          camper_info_form_upd_by       = $2,
    //                          camper_info_form_upd_date     = $3,
    //                          allergy_medical_info          = $4,
    //                          allergy_medical_info_upd_by   = $5,
    //                          allergy_medical_info_upd_date = $6,
    //                          swim_test_records             = $7,
    //                          swim_test_records_upd_by      = $8,
    //                          swim_test_records_upd_date    = $9,
    //                          weekly_plans                  = $10,
    //                          weekly_plans_upd_by           = $11,
    //                          weekly_plans_upd_date         = $12,
    //                          director_check                = $13,
    //                          director_check_upd_by         = $14,
    //                          director_check_upd_date       = $15,
    //                          counsellor_check              = $16,
    //                          counsellor_check_upd_by       = $17,
    //                          counsellor_check_upd_date     = $18
    //                      WHERE camp_id = $19`;
    //     let user_id = 0; // TODO get user id
    //     let today = new Date().toISOString();
    //     const updateValues = [
    //         dataSanitization(req.body.camper_info_form),
    //         user_id,
    //         new Date().toISOString(),
    //         dataSanitization(req.body.allergy_medical_info),
    //         user_id,
    //         new Date().toISOString(),
    //         dataSanitization(req.body.swim_test_records), // TODO ask if every camp has swim test records
    //         user_id,
    //         new Date().toISOString(),
    //         dataSanitization(req.body.weekly_plans),
    //         user_id,
    //         new Date().toISOString(),
    //         dataSanitization(req.body.director_check),
    //         user_id,
    //         new Date().toISOString(),
    //         dataSanitization(req.body.counsellor_check),
    //         user_id,
    //         new Date().toISOString(),
    //         dataSanitization(req.params.camp_id),
    //     ];
    //     // TODO only update fields that have changed (and the associated user/date fields)
    //     await postgresClient.query(updateQuery, updateValues);
    //     res.json({});
    // });

    expressServer.get("/api/weekly_checklist/:camp_id", async (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `GET /api/weekly_checklist/:camp_id ${dataSanitization(req.params.camp_id)}`,
        );

        let retrieve_checklist = `SELECT checklist_status.*, checklist_item.checklist_name, checklist_item.checklist_active, checklist_item.checklist_description 
            FROM checklist_status RIGHT JOIN checklist_item 
                ON checklist_status.checklist_id = checklist_item.checklist_id 
            WHERE checklist_status.camp_id = $1 AND checklist_item.checklist_active = true
            ORDER BY checklist_item.checklist_id`
        let values = [dataSanitization(req.params.camp_id)];
        const { rows } = await postgresClient.query(retrieve_checklist, values);

        res.json(rows);
    });

    expressServer.post("/api/weekly_checklist/:camp_id", async (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(
            `POST /api/weekly_checklist/:camp_id ${dataSanitization(req.params.camp_id)}`,
        );

        let update_checklist = `UPDATE checklist_status
            SET checklist_status = $1, checklist_upd_by = $2, checklist_upd_date = $3
            WHERE camp_id = $4 AND checklist_id = $5`
        let user_id = 0; // TODO get user id
        let today = new Date().toISOString();
        // console.log(req.body)
        for (let i = 0; i < req.body["checklist"].length; i++) {
            let values = [
                dataSanitization(req.body["checklist"][i].checklist_status),
                user_id,
                today,
                dataSanitization(req.params.camp_id),
                dataSanitization(req.body["checklist"][i].checklist_id)
            ];
            // console.log(values)
            await postgresClient.query(update_checklist, values);
        }

        res.json({});
    });

    logger.info("weeklyChecklistRoutes.js loaded");
    logger.debug("weeklyChecklistRoutes.js rewrite incomplete");
};
