module.exports = function(expressServer, logger, postgresClient, dataSanitization, getPostgresConnected) {

    expressServer.get("/api/weekly_checklist/:camp_id", async (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({message: "Database not connected"});
            logger.warn("Database not connected");
            return;
        }
        logger.debug(`GET /api/weekly_checklist/:camp_id ${dataSanitization(req.params.camp_id)}`);

        const {rows} = await postgresClient.query(
            `SELECT *
         FROM checklist
         WHERE camp_id = ${dataSanitization(req.params.camp_id)}`,
        );
        if (rows.length === 0) {
            // create a new checklist
            logger.debug(`Creating new checklist ${dataSanitization(req.params.camp_id)}`);
            const insertQuery = "INSERT INTO checklist (camp_id) VALUES ($1)";
            const insertValues = [dataSanitization(req.params.camp_id)];
            await postgresClient.query(insertQuery, insertValues);
            const {rows} = await postgresClient.query(
                `SELECT *
             FROM checklist
             WHERE camp_id = ${dataSanitization(req.params.camp_id)}`,
            );
            res.json(rows[0]);
        } else {
            res.json(rows[0]);
        }

    });

    expressServer.post("/api/weekly_checklist/:camp_id", async (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({message: "Database not connected"});
            logger.warn("Database not connected");
            return;
        }
        logger.debug(`POST /api/weekly_checklist/:camp_id ${dataSanitization(req.params.camp_id)}`);

        const updateQuery = `UPDATE checklist
                         SET camper_info_form              = $1,
                             camper_info_form_upd_by       = $2,
                             camper_info_form_upd_date     = $3,
                             allergy_medical_info          = $4,
                             allergy_medical_info_upd_by   = $5,
                             allergy_medical_info_upd_date = $6,
                             swim_test_records             = $7,
                             swim_test_records_upd_by      = $8,
                             swim_test_records_upd_date    = $9,
                             weekly_plans                  = $10,
                             weekly_plans_upd_by           = $11,
                             weekly_plans_upd_date         = $12,
                             director_check                = $13,
                             director_check_upd_by         = $14,
                             director_check_upd_date       = $15,
                             counsellor_check              = $16,
                             counsellor_check_upd_by       = $17,
                             counsellor_check_upd_date     = $18
                         WHERE camp_id = $19`;
        let user_id = 0; // TODO get user id
        const updateValues = [
            dataSanitization(req.body.camper_info_form),
            user_id,
            new Date().toISOString(),
            dataSanitization(req.body.allergy_medical_info),
            user_id,
            new Date().toISOString(),
            dataSanitization(req.body.swim_test_records),
            user_id,
            new Date().toISOString(),
            dataSanitization(req.body.weekly_plans),
            user_id,
            new Date().toISOString(),
            dataSanitization(req.body.director_check),
            user_id,
            new Date().toISOString(),
            dataSanitization(req.body.counsellor_check),
            user_id,
            new Date().toISOString(),
            dataSanitization(req.params.camp_id),
        ];
        await postgresClient.query(updateQuery, updateValues);
        res.json({});

    });

    logger.log("info", "weeklyChecklistRoutes.js loaded");
}