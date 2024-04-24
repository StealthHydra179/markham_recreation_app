let excel = require("excel4node");
// TODO remove newline characters in all given strings
module.exports = async function csvExportHelper(logger, postgresClient, getPostgresConnected, req, res) {
    let postgresConnected = getPostgresConnected();
    if (!postgresConnected) {
        res.status(500).send({message: "Database not connected"});
        logger.error("Database not connected");
        return;
    }
    logger.debug(`CSV Export Function`);

    let campId = 1;                                // TODO

    let wb = new excel.Workbook({
        author: "Markham Rec Online Application",            // REVISIT THIS (move to globals)
    });
    let ws = wb.addWorksheet(`${campId}`, {
        "sheetFormat": {
            'baseColWidth': 15,
            'defaultColWidth': 15,
        }
    });

    let commonStyle = wb.createStyle({
        font: {
            color: '#000000',
            size: 9,
        },
        alignment: {
            wrapText: true,
        }
    });

    let titleStyle = wb.createStyle({
        font: {
            color: '#000000',
            size: 10,
            bold: true,
        },
        alignment: {
            horizontal: 'center',
            vertical: 'center',
            wrapText: true,
        },
        border: {
            left: {
                style: 'thick',
                color: '#000000',
            },
            right: {
                style: 'thick',
                color: '#000000',
            },
            top: {
                style: 'thick',
                color: '#000000',
            },
            bottom: {
                style: 'thick',
                color: '#000000',
            },
        },
        fill: {
            type: 'pattern',
            patternType: 'solid',
            fgColor: '#d9d9d9',
        },
    })

    //TODO figure out how to make this modify previous
    // TODO refactor headings to use the box code
    let titleNoBorderStyle = wb.createStyle({
        font: {
            color: '#000000',
            size: 10,
            bold: true,
        },
        alignment: {
            horizontal: 'center',
            vertical: 'center',
            wrapText: true,
        },
        fill: {
            type: 'pattern',
            patternType: 'solid',
            fgColor: '#d9d9d9',
        },
    })

    let subTitleNoBorderStyle = wb.createStyle({
        font: {
            color: '#000000',
            size: 8,
            bold: true,
        },
        alignment: {
            horizontal: 'center',
            vertical: 'center',
            wrapText: true,
        },
        fill: {
            type: 'pattern',
            patternType: 'solid',
            fgColor: '#d9d9d9',
        },
    })

    let titleNoBorderWhiteBackgroundStyle = wb.createStyle({
        font: {
            color: '#000000',
            size: 10,
            bold: true,
        },
        alignment: {
            horizontal: 'center',
            vertical: 'center',
            wrapText: true,
        },
    })

    let titleNoBorderWhiteBackgroundLeftStyle = wb.createStyle({
        font: {
            color: '#000000',
            size: 10,
            bold: true,
        },
        alignment: {
            horizontal: 'left',
            vertical: 'center',
            wrapText: true,
        },
    })

    let trueDescriptionStyle = wb.createStyle({
        font: {
            color: '#000000',
            size: 9, // TODO should be in commonStyle but idk why it doesn't work
        },
        fill: {
            type: 'pattern',
            patternType: 'solid',
            fgColor: '#ffe5e5',
        },
        alignment: {
            horizontal: 'left',
            vertical: 'top',
        }
    });

    let trueStyle = wb.createStyle({
        font: {
            color: '#000000',
            size: 10, // TODO should be in commonStyle but idk why it doesn't work
        },
        fill: {
            type: 'pattern',
            patternType: 'solid',
            fgColor: '#ffe5e5',
        },
        alignment: {
            horizontal: 'center',
            vertical: 'center',
        }
    });

    let falseStyle = wb.createStyle({
        font: {
            color: '#000000',
            size: 10, // TODO should be in commonStyle but idk why it doesn't work
        },
        fill: {
            type: 'pattern',
            patternType: 'solid',
            fgColor: '#F4CCCC',
        },
        alignment: {
            horizontal: 'center',
            vertical: 'center',
        }

    });

    let descriptionStyle = wb.createStyle({
        font: {
            color: '#000000',
            size: 9,
        },
        alignment: {
            vertical: 'center',
        }
    });

    /*
     Do data export here
     */
    let charMap = {"A": 1, "B": 2, "C": 3, "D": 4, "E": 5, "F": 6, "G": 7, "H": 8, "I": 9, "J": 10, "K": 11, "L": 12, "M": 13, "N": 14, "O": 15, "P": 16, "Q": 17, "R": 18, "S": 19, "T": 20, "U": 21, "V": 22, "W": 23, "X": 24, "Y": 25, "Z": 26};
    // TODO check if ever exceed 26 columns (shouldn't)

    function writeMergeCell(ws, startCol, startRow, endCol, endRow, value, style) {
        ws.cell(startRow, charMap[startCol], endRow, charMap[endCol], true).string(value).style(commonStyle).style(style);
    }

    function writeCell(ws, col, row, value, style) {
        if (typeof value === "number") {
            ws.cell(row, charMap[col]).number(value).style(commonStyle).style(style);
        } else {
            ws.cell(row, charMap[col]).string(value).style(commonStyle).style(style);
        }
    }

    function thickOutlineRange(ws, startCol, startRow, endCol, endRow, thin = true) {
        if (thin) {
            // Thin outline for the rest
            ws.cell(startRow, charMap[startCol], endRow, charMap[endCol], false).style({
                border: {
                    left: {style: 'thin', color: '#000000'},
                    right: {style: 'thin', color: '#000000'},
                    top: {style: 'thin', color: '#000000'},
                    bottom: {style: 'thin', color: '#000000'}
                }
            });
        }

        //Thick for outside
        ws.cell(startRow, charMap[startCol], endRow, charMap[startCol], false).style({border: {left: {style: 'thick', color: '#000000'}}});
        ws.cell(startRow, charMap[endCol], endRow, charMap[endCol], false).style({border: {right: {style: 'thick', color: '#000000'}}});
        ws.cell(startRow, charMap[startCol], startRow, charMap[endCol], false).style({border: {top: {style: 'thick', color: '#000000'}}});
        ws.cell(endRow, charMap[startCol], endRow, charMap[endCol], false).style({border: {bottom: {style: 'thick', color: '#000000'}}});
    }

    // // Row 1
    let row1End = 1;

    // Week
    writeCell(ws, "A", 1, "Week:", titleStyle);
    // TODO week number

    // Dates
    writeCell(ws, "E", 1, "Dates:", titleStyle);
    // TODO dates

    // Total Number of Campers
    writeMergeCell(ws, "I", 1, "J", 1, "Total Number of Campers:", titleStyle);
    // TODO total number of campers
    let totalCampers = 20;
    writeCell(ws, "K", 1, totalCampers, trueStyle);
    thickOutlineRange(ws, "K", 1, "K", 1);

    // // Row 2
    let row2End = -1;

    // Weekly Checklist
    writeMergeCell(ws, "A", row1End+2, "C", row1End+2, "Weekly Checklist", titleStyle);
    let weeklyCheckListQuery = `SELECT * FROM checklist_status LEFT JOIN checklist_item ON checklist_status.checklist_id = checklist_item.checklist_id WHERE camp_id = $1;`;
    let weeklyCheckListValues = [campId];
    let weeklyCheckListRes = await postgresClient.query(weeklyCheckListQuery, weeklyCheckListValues);
    // TODO write checklist
    row2End = row1End + 2 + weeklyCheckListRes.rows.length*2;
    let skipped = 0;
    for (let i = 0; i < weeklyCheckListRes.rows.length; i++) {
        if (weeklyCheckListRes.rows[i].checklist_active === false) {
            skipped += 1;
            row2End -= 2;
            continue;
        }
        // console.log(weeklyCheckListRes.rows[i].checklist_status)
        // TODO for some reason for the first cell the font size does not apply?
        writeMergeCell(ws, "A", row1End+2+i*2+1-skipped*2, "A", row1End+2+i*2+1-skipped*2+1,("" + (weeklyCheckListRes.rows[i].checklist_status ? "submitted" : "missing")).toUpperCase(), weeklyCheckListRes.rows[i].checklist_status ? trueStyle : falseStyle);
        writeMergeCell(ws, "B", row1End+2+i*2+1-skipped*2, "C", row1End+2+i*2+1-skipped*2+1, weeklyCheckListRes.rows[i].checklist_description, descriptionStyle);
    }
    thickOutlineRange(ws, "A", row1End+2, "C", row2End);

    // Daily Attendance
    writeMergeCell(ws, "E", row1End+2, "K", row1End+2, "Daily Attendance", titleStyle);
    writeMergeCell(ws, "E", row1End+2+1, "F", row1End+2+1, "", titleNoBorderStyle);
    writeCell(ws, "G", row1End+2+1, "Monday", titleNoBorderWhiteBackgroundStyle);
    writeCell(ws, "H", row1End+2+1, "Tuesday", titleNoBorderWhiteBackgroundStyle);
    writeCell(ws, "I", row1End+2+1, "Wednesday", titleNoBorderWhiteBackgroundStyle);
    writeCell(ws, "J", row1End+2+1, "Thursday", titleNoBorderWhiteBackgroundStyle);
    writeCell(ws, "K", row1End+2+1, "Friday", titleNoBorderWhiteBackgroundStyle);
    writeMergeCell(ws, "E", row1End+2+2, "F", row1End+2+2, "Number of Campers Present", titleNoBorderWhiteBackgroundLeftStyle);
    writeMergeCell(ws, "E", row1End+2+3, "F", row1End+2+3, "Number of Campers Absent", titleNoBorderWhiteBackgroundLeftStyle);
    writeMergeCell(ws, "E", row1End+2+4, "F", row1End+2+4, "Number of Campers in Before Care", titleNoBorderWhiteBackgroundLeftStyle);
    writeMergeCell(ws, "E", row1End+2+5, "F", row1End+2+5, "Number of Campers in After Care", titleNoBorderWhiteBackgroundLeftStyle);
    let dailyAttendanceQuery = `SELECT * FROM attendance WHERE camp_id = $1 ORDER BY attendance_date;`;
    let dailyAttendanceValues = [campId];
    let dailyAttendanceRes = await postgresClient.query(dailyAttendanceQuery, dailyAttendanceValues);
    // present, before care, after_care
    let initalCol = "G";
    for (let i = 0; i < dailyAttendanceRes.rows.length; i++) {
        let col = initalCol;
        let row = row1End+2+2;
        let attendanceDate = dailyAttendanceRes.rows[i].attendance_date; // TODO undefined checks
        let present = dailyAttendanceRes.rows[i].present;
        let absent = present ? totalCampers - dailyAttendanceRes.rows[i].present : undefined;
        let beforeCare = dailyAttendanceRes.rows[i].before_care;
        let afterCare = dailyAttendanceRes.rows[i].after_care;
        writeCell(ws, col, row, present ? present : "", present == null ? falseStyle : trueStyle);
        writeCell(ws, col, row+1, absent ? absent : "", absent == null ? falseStyle : trueStyle);
        writeCell(ws, col, row+2, beforeCare ? beforeCare : "", beforeCare == null ? falseStyle : trueStyle);
        writeCell(ws, col, row+3, afterCare ? afterCare : "", afterCare == null ? falseStyle : trueStyle);
        initalCol = String.fromCharCode(initalCol.charCodeAt(0) + 1);
    }
    thickOutlineRange(ws, "E", row1End+2, "K", row1End+2+5);
    row2End = Math.max(row2End, row1End+2+5);

    // // Row 3
    let row3End = -1;

    // Message Board
    writeMergeCell(ws, "A", row2End+2, "C", row2End+2, "Message Board", titleNoBorderStyle);
    writeMergeCell(ws, "A", row2End+2+1, "C", row2End+2+1, "Any comments or concerns about anything at all?", subTitleNoBorderStyle);
    thickOutlineRange(ws, "A", row2End+2, "C", row2End+2+1, false);
    //TODO add messages
    let messageBoardQuery = `SELECT * FROM message_board WHERE camp_id = $1 ORDER BY app_message_date;`;
    let messageBoardValues = [campId];
    let messageBoardRes = await postgresClient.query(messageBoardQuery, messageBoardValues);
    let length = 0;
    for (let i = 0; i < messageBoardRes.rows.length; i++) {
        // for each message determine the number of rows needed
        let message = messageBoardRes.rows[i].app_message;
        let linesPerRow = 18/14;
        let charPerLine = 57;
        let rowsNeeded = Math.ceil(message.length/charPerLine/linesPerRow);
        length += rowsNeeded;
        writeMergeCell(ws, "A", row2End+2+2+length-rowsNeeded, "C", row2End+2+2+length-1, message, trueDescriptionStyle);
    }
    thickOutlineRange(ws, "A", row2End+2, "C", row2End+2+2+length-1);
    row3End = row2End+2+2+length-1;
    // TODO should there be a date of the message on the exported CSV as well?

    // Absent Campers
    writeMergeCell(ws, "E", row2End+2, "K", row2End+2+1, "Absent Campers", titleNoBorderStyle);
    thickOutlineRange(ws, "E", row2End+2, "K", row2End+2+1);
    writeMergeCell(ws, "E", row2End+2+2, "F", row2End+2+2, "Date", titleNoBorderWhiteBackgroundStyle);
    thickOutlineRange(ws, "E", row2End+2+2, "F", row2End+2+2);
    writeCell(ws, "G", row2End+2+2, "Camper Name", titleNoBorderWhiteBackgroundStyle);
    thickOutlineRange(ws, "G", row2End+2+2, "G", row2End+2+2);
    writeCell(ws, "H", row2End+2+2, "Followed Up?", titleNoBorderWhiteBackgroundStyle);
    thickOutlineRange(ws, "H", row2End+2+2, "H", row2End+2+2);
    writeMergeCell(ws, "I", row2End+2+2, "K", row2End+2+2, "Reason", titleNoBorderWhiteBackgroundStyle);
    thickOutlineRange(ws, "I", row2End+2+2, "K", row2End+2+2);
    let absentCampersQuery = `SELECT * FROM absence WHERE camp_id = $1 ORDER BY absence_date;`;
    let absentCampersValues = [campId];
    let absentCampersRes = await postgresClient.query(absentCampersQuery, absentCampersValues);
    let absentLength = 0;
    for (let i = 0; i < absentCampersRes.rows.length; i++) {
        let absenceDate = absentCampersRes.rows[i].absence_date;
        let camperName = absentCampersRes.rows[i].camper_first_name + " " + absentCampersRes.rows[i].camper_last_name;
        let followedUp = absentCampersRes.rows[i].followed_up;
        let reason = absentCampersRes.rows[i].reason ? absentCampersRes.rows[i].reason : " ";

        writeMergeCell(ws, "E", row2End+2+3+absentLength, "F", row2End+2+3+absentLength, absenceDate.toLocaleString(), trueStyle);
        writeCell(ws, "G", row2End+2+3+absentLength, camperName, trueStyle);
        writeCell(ws, "H", row2End+2+3+absentLength, followedUp ? "Yes" : "No", followedUp ? trueStyle : falseStyle);

        let linesPerRow = 18/14;
        let charPerLine = 57;
        let rowsNeeded = Math.ceil(reason.length/charPerLine/linesPerRow);
        writeMergeCell(ws, "I", row2End+2+3+absentLength, "K", row2End+2+3+absentLength+rowsNeeded-1, reason, followedUp ? trueDescriptionStyle : falseStyle);
        absentLength += 1;
    }
    thickOutlineRange(ws, "E", row2End+2+2, "K", row2End+2+3+absentLength-1);
    row3End = Math.max(row3End, row2End+2+3+absentLength-1);
    console.log(row3End)

    // // Row 4
    // // Left Side
    let currentLeftSideEnd = -1;


    // // Right Side


    wb.write(campId + ".xlsx", res);
    // wb.write(campId + ".xlsx");
    // res.send("Exported")
}
