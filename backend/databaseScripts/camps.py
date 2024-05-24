import pandas as pd
import numpy as np

df = pd.read_excel("Summer Camps 2024.xlsx")

df[["Start Date", "End Date"]] = df["Dates"].str.split(' - ', n=1, expand=True)
df = df.drop(columns='Dates')

#Create list of unique locations, create list of unique area
uniqueLocation = df.drop_duplicates(subset="Location")[["Location", "Area "]]
uniqueArea = df["Area "].unique()

outputFile =  open("SQL_update.txt", "w")

"""
INSERT INTO checklist_item VALUES
(1,1, 'Camper Information Forms', true, 'Collect and Alphabetize Camper Information Forms'),
(2,2, 'Allergy and Medical Information', true, 'Share Allergy and Medical Information with Camp Counsellors'),
(3,3, 'Swim Test Pass/Fail', true, 'Track and Record Swim Test Pass/Fail of Each Camper'),
(4,4, 'Weekly Program Plans', true, 'Review and Update Weekly Program Plans'),
(5,5, 'Check-in with Camp Director', true, 'Meet and Check-in with Camp Director'),
(6,6, 'Check-in with Camp Counsellors', true, 'Meet and Check-in with Camp Counsellors'),
(7,7, 'Review Camper Profiles', true, 'Review Camper Profiles For Inclusion Campers');
"""

outputFile.write("INSERT INTO markham_rec.checklist_item VALUES\n")
outputFile.write("(1,1, 'Camper Information Forms', true, 'Collect and Alphabetize Camper Information Forms'),\n")
outputFile.write("(2,2, 'Allergy and Medical Information', true, 'Share Allergy and Medical Information with Camp Counsellors'),\n")
outputFile.write("(3,3, 'Swim Test Pass/Fail', true, 'Track and Record Swim Test Pass/Fail of Each Camper'),\n")
outputFile.write("(4,4, 'Weekly Program Plans', true, 'Review and Update Weekly Program Plans'),\n")
outputFile.write("(5,5, 'Check-in with Camp Director', true, 'Meet and Check-in with Camp Director'),\n")
outputFile.write("(6,6, 'Check-in with Camp Counsellors', true, 'Meet and Check-in with Camp Counsellors'),\n")
outputFile.write("(7,7, 'Review Camper Profiles', true, 'Review Camper Profiles For Inclusion Campers');\n")
outputFile.write("\n\n")



userFile = open("user.txt", "w")

#password function (write previous js code in python)
import bcrypt
saltRounds = 10

def addUser(userid, email, plainTextPassword):
    email = email
    plainTextPassword = plainTextPassword

    email = email
    plainTextPassword = plainTextPassword

    hashedPassword = bcrypt.hashpw(plainTextPassword.encode('utf-8'), bcrypt.gensalt(saltRounds))
    print(hashedPassword)
    outputString = "INSERT INTO markham_rec.app_user (user_id, email, user_password) VALUES ("+str(userid)+",'" + email + "','" + str(hashedPassword)[2:-1] + "');\n"
    outputFile.write(outputString)
    print(outputString)
    userFile.write("Name: '" + email + "' Password: '" + plainTextPassword + "'\n")

#user 0 (has identity) [random password]
#gen random password (10 letters 5 numbers 2 symbols in random order)
import random
import string

def randomPassword():
    letters = string.ascii_letters
    numbers = string.digits
    symbols = string.punctuation

    password = ''.join(random.choice(letters) for i in range(10)) + ''.join(random.choice(numbers) for i in range(5)) #+ ''.join(random.choice(symbols) for i in range(2))

    #randomize order of password
    password = ''.join(random.sample(password, len(password)))

    # URI encode like in js if using symbols



    return password

rP = randomPassword()
addUser(0, "admin", rP)
print(rP)


# Location dictionary/map
locationMap = {}

for index, item in enumerate(uniqueArea):
    #Camp location index for some reason is not an identity
    outputString = "INSERT INTO markham_rec.camp_location VALUES (" + str(index+1) + ",'" + str(item) + "');\n"
    #str(item["Location"]) + " " +
    outputFile.write(outputString)
    print(outputString)
    # Add the location to a dictionary
    locationMap[item] = index+1

outputFile.write("\n\n")

# Camp Facility dictionary/map
campFacilityMap = {}

counter = 0
for index, row in uniqueLocation.iterrows():
    outputString = "INSERT INTO markham_rec.camp_facility VALUES ("+ str(counter+1)+ ",'" + str(row["Location"]) + "'," + str(locationMap[row["Area "]]) + ");\n"
    outputFile.write(outputString)
    print(outputString)
    counter += 1
    campFacilityMap[row["Location"]] = {"Facility ID": counter, "Location ID": locationMap[row["Area "]]}

# Camps
outputFile.write("\n\n")

for index, row in df.iterrows():
    # camp id, camp name, start date, end date, camp room ("empty string"), camper count (0), camp facility id, camp description (blank)
    #camp id is not an identity
    name = str(row["Subject"]) #escape single quotes
    name = name.replace("'", "''")
    outputString = "INSERT INTO markham_rec.camp VALUES (" + str(index+1) + ",'" + name + "','" + str(row["Start Date"]) + "','" + str(row["End Date"]) + "','','0'," + str(campFacilityMap[row["Location"]]["Facility ID"]) + ",'" + "" + "');\n"
    outputFile.write(outputString)
    print(outputString)

    # for each camp output: checklist_status and attendance filler data
    # camp_id, checklist_id (1 through 7), checklist_status (bool false), checklist_upd_date (date 0), checklist_upd_by (0)
    for i in range(1, 8):
        outputString = "INSERT INTO markham_rec.checklist_status VALUES (" + str(index+1) + "," + str(i) + ",false,CURRENT_TIMESTAMP,0);\n"
        outputFile.write(outputString)
        print(outputString)

    # for each camp output: attendance filler data
    # for each day of the week between start and end date, output: camp_id, attendance_date
    for i in pd.date_range(start=row["Start Date"], end=row["End Date"]):
        outputString = "INSERT INTO markham_rec.attendance (camp_id, attendance_date) VALUES (" + str(index+1) + ",'" + str(i) + "');\n"
        outputFile.write(outputString)
        print(outputString)

    outputFile.write("\n")


outputFile.write("\n\n")

# Users
# USER ID 0 Temporary User
'''
Areas

# of Logins

East & Chimo

Camp Supervisor 1 to 15

Inclusion

Camp Supervisor 16 to 20

North

Camp Supervisor 21 to 30

South East

Camp Sueprvisor 31 to 39

South West

Camp Supervisor 40 to 49

West

Camp Supervsior 50 to 60
'''
"""
Role 1 Full Time Staff
Role 2 Director
Role 3 Supervisor
"""


"""

// const bcrypt = require("bcrypt");
// const saltRounds = 10;
//
// function addUser() {
//     let email = "user@example.com";
//     let plainTextPassword = "hello";
//
//
//     email = encodeURIComponent(email);
//     plainTextPassword = encodeURIComponent(plainTextPassword);
//     // use datacleaning
//     email = dataSanitization(email);
//     plainTextPassword = dataSanitization(plainTextPassword);
//
//     bcrypt.hash(plainTextPassword, saltRounds, function(err, hash) {
//         // Store hash in your password DB.
//
//         let query = `INSERT INTO app_user (email, user_password) VALUES ($1, $2);`;
//         let values = [email, hash];
//         postgresClient.query(query, values, (err, result) => {
//             if (err) {
//                 logger.error("e", err);
//                 // res.status(500).send({ message: "Error adding user" });
//                 return;
//             } else {
//                 // res.status(200).send({ message: "User added" });
//                 logger.info("User added");
//             }
//         });
//     });
// }
// addUser()
"""

# the user is also full time staff on every camp
# user id camp id role id
for i in range(1, len(df)+1):
    outputString = "INSERT INTO markham_rec.camp_user_role VALUES (0," + str(i) + ",1);\n"
    outputFile.write(outputString)
    print(outputString)
outputFile.write("\n")
# Camp Supervisors
# Areas
# East & Chimo
# Camp Supervisor 1 to 15

for i in range(1, 16):
    rP = randomPassword()
    addUser(i, "CampSupervisor" + str(i), rP)
    print(rP)
    # Add camp supervisor to camp_user_role for all the camps in the East & Chimo area
    for index, item in df.iterrows():
        if item["Area "] == "East & Chimo":
            outputString = "INSERT INTO markham_rec.camp_user_role VALUES (" + str(i) + "," + str(index+1) + ",3);\n"
            outputFile.write(outputString)
            print(outputString)
    outputFile.write("\n")

# Inclusion
# Camp Supervisor 16 to 20
for i in range(16, 21):
    rP = randomPassword()
    addUser(i, "CampSupervisor" + str(i), rP)
    print(rP)
    # Add camp supervisor to camp_user_role for all the camps in the Inclusion area
    for index, item in df.iterrows():
        if item["Area "] == "Inclusion":
            outputString = "INSERT INTO markham_rec.camp_user_role VALUES (" + str(i) + "," + str(index+1) + ",3);\n"
            outputFile.write(outputString)
            print(outputString)

# North
# Camp Supervisor 21 to 30
for i in range(21, 31):
    rP = randomPassword()
    addUser(i, "CampSupervisor" + str(i), rP)
    print(rP)
    # Add camp supervisor to camp_user_role for all the camps in the North area
    for index, item in df.iterrows():
        if item["Area "] == "North":
            outputString = "INSERT INTO markham_rec.camp_user_role VALUES (" + str(i) + "," + str(index+1) + ",3);\n"
            outputFile.write(outputString)
            print(outputString)

# South East
# Camp Sueprvisor 31 to 39
for i in range(31, 40):
    rP = randomPassword()
    addUser(i, "CampSupervisor" + str(i), rP)
    print(rP)
    # Add camp supervisor to camp_user_role for all the camps in the South East area
    for index, item in df.iterrows():
        if item["Area "] == "South East Area":
            outputString = "INSERT INTO markham_rec.camp_user_role VALUES (" + str(i) + "," + str(index+1) + ",3);\n"
            outputFile.write(outputString)
            print(outputString)

# South West
# Camp Supervisor 40 to 49
for i in range(40, 50):
    rP = randomPassword()
    addUser(i, "CampSupervisor" + str(i), rP)
    print(rP)
    # Add camp supervisor to camp_user_role for all the camps in the South West area
    for index, item in df.iterrows():
        if item["Area "] == "South West Area":
            outputString = "INSERT INTO markham_rec.camp_user_role VALUES (" + str(i) + "," + str(index+1) + ",3);\n"
            outputFile.write(outputString)
            print(outputString)

# West
# Camp Supervsior 50 to 60
for i in range(50, 61):
    rP = randomPassword()
    addUser(i, "CampSupervisor" + str(i), rP)
    print(rP)
    # Add camp supervisor to camp_user_role for all the camps in the West area
    for index, item in df.iterrows():
        if item["Area "] == "West Area":
            outputString = "INSERT INTO markham_rec.camp_user_role VALUES (" + str(i) + "," + str(index+1) + ",3);\n"
            outputFile.write(outputString)
            print(outputString)

offset = 100
# Add 1 full time staff for each area
for i in range(1, len(uniqueArea)+1):
    rP = randomPassword()
    addUser(i+offset, "FullTimeStaff" + uniqueArea[i-1], rP)
    print(rP)
    # Add full time staff to camp_user_role for all the camps in the area
    for index, item in df.iterrows():
        if item["Area "] == uniqueArea[i-1]:
            outputString = "INSERT INTO markham_rec.camp_user_role VALUES (" + str(i+offset) + "," + str(index+1) + ",1);\n"
            outputFile.write(outputString)
            print(outputString)


# add a verif login
#user id 201
# email: playLogin
# password: playLoginExample123
addUser(201, "playLogin", "playLoginExample123")
#full time staff
for i in range(1, len(df)+1):
    outputString = "INSERT INTO markham_rec.camp_user_role VALUES (201," + str(i) + ",1);\n"
    outputFile.write(outputString)
    print(outputString)

#user names
#admin
output = "UPDATE markham_rec.app_user SET first_name = 'admin' WHERE user_id = 0;\n"
output2 = "UPDATE markham_rec.app_user SET last_name = 'user' WHERE user_id = 0;\n"
outputFile.write(output)
outputFile.write(output2)

#playLogin
output = "UPDATE markham_rec.app_user SET first_name = 'play' WHERE user_id = 201;\n"
output2 = "UPDATE markham_rec.app_user SET last_name = 'login' WHERE user_id = 201;\n"
outputFile.write(output)
outputFile.write(output2)

#camp supervisors
for i in range(1, 61):
    output = "UPDATE markham_rec.app_user SET first_name = 'Camp' WHERE user_id = " + str(i) + ";\n"
    output2 = "UPDATE markham_rec.app_user SET last_name = 'Supervisor "+str(i)+"' WHERE user_id = " + str(i) + ";\n"
    outputFile.write(output)
    outputFile.write(output2)

#full time staff
for i in range(101, 107):
    output = "UPDATE markham_rec.app_user SET first_name = 'Full Time' WHERE user_id = " + str(i) + ";\n"
    output2 = "UPDATE markham_rec.app_user SET last_name = 'Staff "+str(i-100)+"' WHERE user_id = " + str(i) + ";\n"
    outputFile.write(output)
    outputFile.write(output2)


userFile.close()
outputFile.close()