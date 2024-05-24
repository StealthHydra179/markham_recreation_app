const express = require("express");
const bcrypt = require("bcrypt");

function isAuthenticated (req, res, next) {
    if (req.session.user) {
        if (req.params.camp_id) {
            if (req.params.camp_id in req.session.camps) {
                next()
                return
            }
        } else {
            next()
            return
        }
    }

    res.status(401).send({ message: "Unauthorized" });
}


module.exports = isAuthenticated;
