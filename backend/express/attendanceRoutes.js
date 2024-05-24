const authenticate = require("./helper/authentication");

module.exports = function (expressServer, logger, postgresClient, dataSanitization, getPostgresConnected) {
    expressServer.get("/api/attendance/:camp_id", authenticate, async function (req, res) {
        logger.info("GET /api/attendance");

        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug("GET /api/attendance");

        let retrieve_attendance = `SELECT * FROM attendance LEFT JOIN camp ON attendance.camp_id = camp.camp_id WHERE camp.camp_id = $1 ORDER BY attendance_date ASC `;
        let values = [dataSanitization(req.params.camp_id)];
        const { rows } = await postgresClient.query(retrieve_attendance, values);
        console.log(rows.length);
        res.json(rows);
    });

    expressServer.post("/api/attendance/:camp_id", authenticate, async function (req, res) {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }

        logger.debug("POST /api/attendance");

        // passes all the attendance data as a list, only update those that are different
        let update_attendance_present = `UPDATE attendance
            SET present = $1, present_upd_by = $2, present_upd_date = $3 WHERE attendance_id = $4;`;
        let update_attendance_before = `UPDATE attendance
            SET before_care = $1, before_care_upd_by = $2, before_care_upd_date = $3 WHERE attendance_id = $4;`;
        let update_attendance_after = `UPDATE attendance
            SET after_care = $1, after_care_upd_by = $2, after_care_upd_date = $3 WHERE attendance_id = $4;`;

        //get the current state
        let retrieve_attendance = `SELECT * FROM attendance LEFT JOIN camp ON attendance.camp_id = camp.camp_id WHERE camp.camp_id = $1 ORDER BY attendance_date ASC `;
        let values = [dataSanitization(req.params.camp_id)];
        const { rows } = await postgresClient.query(retrieve_attendance, values);

        //compare both the req content and the rows
        //if they are different, update the database for that day and for that specific field
        //if they are the same, do nothing
        //if the req content is empty, do nothing
        try {
            if (req.body["attendance"].length != rows.length) {
                throw "The length of the attendance data is different";
            }
        } catch (e) {
            res.status(500).send({ message: e });
            logger.error(e);
            return;
        }

        logger.debug("attendance", req.body["attendance"][0]);

        for (let i = 0; i < req.body["attendance"].length; i++) {
            // console.log(values)
            if (req.body["attendance"][i].present != rows[i].present) {
                console.log("present", req.body["attendance"][i].present, rows[i].present);
                console.log(dataSanitization(req.body["attendance"][i].present));
                let values = [
                    dataSanitization(req.body["attendance"][i].present),
                    0, //TODO get user id
                    new Date().toISOString(),
                    dataSanitization(req.body["attendance"][i].attendance_id),
                ];
                await postgresClient.query(update_attendance_present, values);
            }
            if (req.body["attendance"][i].before_care != rows[i].before_care) {
                let values = [
                    dataSanitization(req.body["attendance"][i].before_care),
                    0, //TODO get user id
                    new Date().toISOString(),
                    dataSanitization(req.body["attendance"][i].attendance_id),
                ];
                await postgresClient.query(update_attendance_before, values);
            }
            if (req.body["attendance"][i].after_care != rows[i].after_care) {
                let values = [
                    dataSanitization(req.body["attendance"][i].after_care),
                    0, //TODO get user id
                    new Date().toISOString(),
                    dataSanitization(req.body["attendance"][i].attendance_id),
                ];
                await postgresClient.query(update_attendance_after, values);
            }
            // await postgresClient.query(update_attendance_present, values);
            // await postgresClient.query(update_attendance_before, values);
            // await postgresClient.query(update_attendance_after, values);
        }

        //check if the data is different

        res.send({});
    });

    logger.warn("attendanceRoutes.js not implemented");
};
