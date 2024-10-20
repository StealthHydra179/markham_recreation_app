const express = require("express");
const bcrypt = require("bcrypt");

module.exports = function (expressServer, logger, postgresClient, dataSanitization, getPostgresConnected) {
    expressServer.post("/api/login", express.urlencoded({ extended: false }), (req, res) => {
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
            bcrypt.compare(pass, result.rows[0].user_password, function(err, result) {
                // result == true
                // let user = result.rows[0].email;
                if (result) {
                    success = true;
                    message = "Login successful";

                    let query = `SELECT * FROM camp_user_role LEFT JOIN app_user ON camp_user_role.user_id = app_user.user_id WHERE email = $1;`;
                    let values = [user];
                    postgresClient.query(query, values, (err, res1) => {
                        if (err) {
                            logger.error("e", err);
                            res.status(500).send({ message: "Error fetching user" });
                            return;
                        }

                        let full_time = [];
                        let director = [];
                        let supervisor = [];

                        for (let i = 0; i < res1.rows.length; i++) {
                            if (res1.rows[i].role_id == 1) {
                                full_time.push(res1.rows[i].camp_id);
                            }
                            if (res1.rows[i].role_id == 2) {
                                director.push(res1.rows[i].camp_id);
                            }
                            supervisor.push(res1.rows[i].camp_id);
                        }


                        if (full_time.length + director.length +supervisor.length == 0) {
                            // res.status(401).send({ message: "Login failed" }); // TODO display message on login page
                            res.status(401).send({ message: "Login failed" });
                            logger.info("Login failed");
                            return;
                        }


                        // res.cookie('user', result.rows[0].email, {signed: true})
                        req.session.regenerate(function (err) {
                            if (err) {
                                logger.error("Error regenerating session");
                                res.status(500).send({message: "Error logging in"});
                                return err; //del next
                            }

                            // store user information in session, typically a user id
                            req.session.user = req.body.username
                            req.session.userId = res1.rows[0].user_id

                            req.session.camp_full_time = full_time
                            req.session.camp_director = director
                            req.session.camps = supervisor
                            logger.info("User logged in: " + req.session.user)

                            // save the session before redirection to ensure page
                            // load does not happen before session is saved
                            req.session.save(function (err) {
                                if (err) {
                                    logger.error("Error saving session");
                                    res.status(500).send({message: "Error logging in"});
                                    return err; // delted next
                                }
                                // res.status(200).send({ message: message }); // todo cookie stuff
                                res.send({ "ID": req.session.userId, "username": req.session.user })
                                logger.info("Mobile Login successful");
                                logger.info("User logged in: ",req.session.user)
                            })
                        })
                    });



                } else {
                    res.status(401).send({ message: "Login failed" });
                    logger.info("Login failed");
                }
            });
        });
    })

    expressServer.post("/api/logout", (req, res) => {
        req.session.destroy(function (err) {
            if (err) {
                res.status(500).send({ message: "Error logging out" });
                return;
            }
            res.status(200).send({ message: "Logged out" });
        });
    })
}