const bcrypt = require("bcrypt");
const saltRounds = 10;

const express = require("express");
var session = require("express-session");
function isAuthenticated(req, res, next) {
    console.log(req.session);
    if (req.session.user) next();
    else res.redirect("/admin/login");
}
module.exports = function (expressServer, logger, postgresClient, dataSanitization, getPostgresConnected) {
    expressServer.get("/admin/home", isAuthenticated, (req, res) => {
        // send web/index.html
        // load web files as static
        res.sendFile("web/export_camp_info.html", { root: "./" });
        logger.info("admin/home loaded");
    });

    expressServer.get("/admin/login", (req, res) => {
        // send web/index.html
        // load web files as static
        res.sendFile("web/login.html", { root: "./" });
        logger.info("admin/login loaded");
    });

    expressServer.post("/admin/login", express.urlencoded({ extended: false }), (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }

        //default to failed login
        let success = false;
        let message = "Login failed";
        let user = req.body.username;
        let pass = req.body.password;
        console.log(pass);
        console.log(req.body);
        // url encode user and pass
        user = encodeURIComponent(user);
        pass = encodeURIComponent(pass);
        // use datacleaning
        user = dataSanitization(user);
        pass = dataSanitization(pass);

        let query = `SELECT * FROM app_user WHERE email = $1;`;
        let values = [user];

        postgresClient.query(query, values, (err, result) => {
            if (err) {
                logger.error("e", err);
                res.status(500).send({ message: "Error fetching user" });
                return;
            }
            if (result.rows.length == 0) {
                // res.status(401).send({ message: "Login failed" });
                // return;
                result.rows[0] = { user_password: "" };
                logger.info("User not found");
            }
            let res1 = result;
            bcrypt.compare(pass, result.rows[0].user_password, function (err, result) {
                // result == true
                // let user = result.rows[0].email;
                if (result) {
                    success = true;
                    message = "Login successful";

                    //check if user is an admin on any camp
                    let query = `SELECT * FROM camp_user_role WHERE user_id = $1;`;
                    let values = [res1.rows[0].user_id];

                    postgresClient.query(query, values, (err, result) => {
                        if (err) {
                            logger.error("e", err);
                            res.status(500).send({ message: "Error fetching user" });
                            return;
                        }
                        let full_time = [];
                        let director = [];
                        let supervisor = [];

                        for (let i = 0; i < result.rows.length; i++) {
                            if (result.rows[i].role_id == 1) {
                                full_time.push(result.rows[i].camp_id);
                            }
                            if (result.rows[i].role_id == 2) {
                                director.push(result.rows[i].camp_id);
                            }
                            supervisor.push(result.rows[i].camp_id);
                        }

                        if (full_time.length + director.length == 0) {
                            // res.status(401).send({ message: "Login failed" }); // TODO display message on login page
                            console.log(res1.rows[0].user_id);
                            res.status(401).redirect("/admin/login");
                            logger.info("Login failed");
                            return;
                        }

                        // res.cookie('user', result.rows[0].email, {signed: true})
                        req.session.regenerate(function (err) {
                            if (err) {
                                logger.error("Error regenerating session");
                                res.status(500).send({ message: "Error logging in" });
                                return err; //del next
                            }

                            // store user information in session, typically a user id
                            req.session.user = req.body.username;
                            req.session.userId = res1.rows[0].user_id;
                            req.session.camp_full_time = full_time;
                            req.session.camp_director = director;
                            req.session.camps = supervisor;
                            logger.info("User logged in: " + req.session.user);

                            // save the session before redirection to ensure page
                            // load does not happen before session is saved
                            req.session.save(function (err) {
                                if (err) {
                                    logger.error("Error saving session");
                                    res.status(500).send({ message: "Error logging in" });
                                    return err; // delted next
                                }
                                // res.status(200).send({ message: message }); // todo cookie stuff
                                res.redirect("/admin/home");
                                logger.info("Login successful");
                            });
                        });
                    });
                } else {
                    // res.status(401).send({ message: "Login failed" });
                    res.status(401).redirect("/admin/login");
                    logger.info("Login failed");
                }
            });
        });
    });

    expressServer.get("/admin/logout", function (req, res, next) {
        // logout logic

        // clear the user from the session object and save.
        // this will ensure that re-using the old session id
        // does not have a logged in user
        req.session.user = null;
        req.session.save(function (err) {
            if (err) {
                logger.error("Error saving session");
                res.status(500).send({ message: "Error logging out" });
            }

            // regenerate the session, which is good practice to help
            // guard against forms of session fixation
            req.session.regenerate(function (err) {
                if (err) {
                    logger.error("Error regenerating session");
                    res.status(500).send({ message: "Error logging out" });
                }
                res.redirect("/admin/login");
            });
        }); // TODO replace with destroy?
    });

    // expressServer.get("/api/weekly_summary", (req, res) => {
    //     // get weekly summary
    //     // return json
    //     let postgresConnected = getPostgresConnected();
    //     if (!postgresConnected) {
    //         res.status(500).send({ message: "Database not connected" });
    //         logger.error("Database not connected");
    //         return;
    //     }
    //     logger.debug(`GET /api/weekly_summary`);
    //
    //     // Incident reports, absent campers, and parent comment count for the week
    //     let startOfWeek = new Date();
    //     startOfWeek.setHours(0, 0, 0, 0);
    //     startOfWeek.setDate(startOfWeek.getDate() - startOfWeek.getDay()); // TODO check if this is even correct
    //
    //     let incident_note_count = `SELECT COUNT(*) AS incident_reports FROM incident_note WHERE in_note_date >= $1;`
    //     let absent_campers_count = `SELECT COUNT(*) AS absent_campers FROM absence WHERE absence_date >= $1;`
    //     let parent_comments_count = `SELECT COUNT(*) AS parent_comments FROM parent_note WHERE pa_note_date >= $1;`
    //     let values = [startOfWeek];
    //
    //     logger.error("weekly_summary not implemented");
    //     res.status(501).send({ message: "Not implemented" }); // TODO implement
    // })

    // expressServer.get("/api/admin_statistics", (req, res) => {
    //     // get admin statistics
    //     // return json
    //     let postgresConnected = getPostgresConnected();
    //     if (!postgresConnected) {
    //         res.status(500).send({ message: "Database not connected" });
    //         logger.error("Database not connected");
    //         return;
    //     }
    //     logger.debug(`GET /api/admin_statistics`);
    //
    //     logger.error("admin_statistics not implemented");
    //     res.status(501).send({ message: "Not implemented" }); // TODO implement
    // })

    expressServer.get("/api/admin/fetch_camps", isAuthenticated, (req, res) => {
        // fetch camps
        // return json
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(`GET /api/admin/fetch_camps`);

        // fetch camps, associated supervisors, director, and location of facility
        let query = `SELECT * FROM camp LEFT JOIN markham_rec.camp_facility cf on camp.facility_id = cf.facility_id LEFT JOIN markham_rec.camp_location cl on cf.location_id = cl.location_id;`;
        postgresClient.query(query, async (err, result) => {
            if (err) {
                logger.error("e", err);
                res.status(500).send({ message: "Error fetching camps" });
                return;
            }

            //for each camp make sure the user has access to it TODO
            let query1 = `SELECT * FROM camp_user_role WHERE user_id = $1 AND (role_id = 2 OR role_id = 1);`;
            let values = [req.session.userId];
            let result1 = await postgresClient.query(query1, values);
            //check if any are role type 1 (full time)
            let found = false;
            for (let i = 0; i < result1.rows.length; i++) {
                if (result1.rows[i].role_id == 1) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                for (let i = 0; i < result.rows.length; i++) {
                    let campId = result.rows[i].camp_id;
                    let found = false;
                    for (let j = 0; j < result1.rows.length; j++) {
                        if (result1.rows[j].camp_id == campId) {
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        result.rows.splice(i, 1);
                        i--;
                    }
                }
            }

            let query = `SELECT * FROM camp_user_role LEFT JOIN app_user on camp_user_role.user_id = app_user.user_id WHERE role_id = 3 OR role_id = 2;`;
            postgresClient.query(query, (err, result2) => {
                if (err) {
                    logger.error("e", err);
                    res.status(500).send({ message: "Error fetching camps" });
                    return;
                }
                for (let i = 0; i < result.rows.length; i++) {
                    let supervisorNames = [];
                    let directorNames = [];
                    for (let j = 0; j < result2.rows.length; j++) {
                        if (result.rows[i].camp_id == result2.rows[j].camp_id) {
                            if (result2.rows[j].role_id == 3) {
                                supervisorNames.push(result2.rows[j].first_name + " " + result2.rows[j].last_name);
                            } else if (result2.rows[j].role_id == 2) {
                                directorNames.push(result2.rows[j].first_name + " " + result2.rows[j].last_name);
                            }
                        }
                    }
                    result.rows[i]["supervisor_names"] = supervisorNames;
                    result.rows[i]["director_names"] = directorNames;

                    //format dates
                    let start_date = result.rows[i].start_date;
                    let end_date = result.rows[i].end_date;
                    start_date = start_date.toISOString().split("T")[0];
                    end_date = end_date.toISOString().split("T")[0];
                    result.rows[i]["start_date"] = start_date;
                    result.rows[i]["end_date"] = end_date;
                }
                res.json(result.rows);
            });
        });
    });

    expressServer.get("/api/admin/fetch_locations", isAuthenticated, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(`GET /api/admin/fetch_locations`);

        let query = `SELECT * FROM camp_location;`;
        postgresClient.query(query, (err, result) => {
            if (err) {
                logger.error("e", err);
                res.status(500).send({ message: "Error fetching locations" });
                return;
            }
            res.json(result.rows);
        });
    });

    expressServer.get("/api/admin/fetch_facilities", isAuthenticated, (req, res) => {
        let postgresConnected = getPostgresConnected();
        if (!postgresConnected) {
            res.status(500).send({ message: "Database not connected" });
            logger.error("Database not connected");
            return;
        }
        logger.debug(`GET /api/admin/fetch_facilities`);

        let query = `SELECT * FROM camp_facility LEFT JOIN markham_rec.camp_location cl on camp_facility.location_id = cl.location_id;`;
        postgresClient.query(query, (err, result) => {
            if (err) {
                logger.error("e", err);
                res.status(500).send({ message: "Error fetching facilities" });
                return;
            }
            res.json(result.rows);
        });
    });

    expressServer.get("/api/admin/fetch_csv/:campId", isAuthenticated, async (req, res) => {
        // fetch csv
        // return csv

        //make sure that the user has access to the camp
        let query = `SELECT * FROM camp_user_role WHERE user_id = $1 AND camp_id = $2 AND (role_id = 2 OR role_id = 1);`;
        let values = [req.session.userId, req.params.campId];
        let result = await postgresClient.query(query, values);
        if (result.rows.length == 0) {
            res.status(401).send({ message: "Unauthorized" });
            return;
        }

        await require("./csvExportHelper")(
            logger,
            postgresClient,
            getPostgresConnected,
            req,
            res,
            parseInt(dataSanitization(req.params.campId)),
        );
    });

    expressServer.get("/api/admin/user_info", isAuthenticated, (req, res) => {
        //fetch it from the req.session.user
        let user = req.session.user;
        //send user
        res.send({ user: user });
    });

    logger.warn("adminRoutes.js not implemented");
};
