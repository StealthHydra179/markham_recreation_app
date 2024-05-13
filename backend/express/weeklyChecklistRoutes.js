const authenticate = require("./helper/authentication");

module.exports = function (
    expressServer,
    logger,
    postgresClient,
    dataSanitization,
    getPostgresConnected,
) {
    expressServer.get("/api/weekly_checklist/:camp_id", authenticate, async (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(`GET /api/weekly_checklist/:camp_id ${dataSanitization(req.params.camp_id)}`);

        let retrieve_checklist = `SELECT checklist_status.*, checklist_item.checklist_name, checklist_item.checklist_active, checklist_item.checklist_description 
            FROM checklist_status RIGHT JOIN checklist_item 
                ON checklist_status.checklist_id = checklist_item.checklist_id 
            WHERE checklist_status.camp_id = $1 AND checklist_item.checklist_active = true
            ORDER BY checklist_item.checklist_id`
        let values = [dataSanitization(req.params.camp_id)];
        const { rows } = await postgresClient.query(retrieve_checklist, values);

        res.json(rows);
    });

    expressServer.post("/api/weekly_checklist/:camp_id", authenticate, async (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(`POST /api/weekly_checklist/:camp_id ${dataSanitization(req.params.camp_id)}`);

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
