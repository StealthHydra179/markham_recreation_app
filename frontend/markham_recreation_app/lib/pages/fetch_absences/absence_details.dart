import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:markham_recreation_app/globals.dart' as globals;
import 'package:markham_recreation_app/pages/fetch_absences/fetch_absences.dart';

import 'absence.dart';
import 'edit_absence.dart';

class AbsenceDetails extends StatelessWidget {
  final Absence absence;

  const AbsenceDetails({super.key, required this.absence});

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        
        title: const Text(
          'Absence Details',
          style: TextStyle(color: globals.secondaryColor) 
        ),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
        //add edit and delete buttons
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);// TODO figure out why it doesnt force build anymore
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // edit page
              // open a new version of new_absence but with the fields filled in and the error messages be tailored towards editing
              // send put request to server
              // if successful, update the page
              // if not, show error message 

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditAbsence(absence: absence)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              //post request to delete_absence
              Future<http.Response> response = http.post(
                Uri.parse('${globals.serverUrl}/api/delete_absence/${globals.camp_id}'),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(<String, String>{
                  'absent_id': absence.absentId.toString(),
                }),
              );

              response.then((http.Response response) {
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deleted Absence'),
                      duration: Duration(seconds: 3),
                    ),
                  );

                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Delete Absence'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }).catchError((error, stackTrace) {
                // Runs when the server is down
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to Delete Absence'),
                    duration: Duration(seconds: 3),
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('Camper Name: ${absence.camperName}'),
          ),
          ListTile(
            title: Text('Date: ${dateFormatter(absence.date)}'),
          ),
          ListTile(
            title: Text('Followed Up: ${absence.followedUp ? 'yes' : 'no'}'),
            // if not followed up change the background color to a light red
            tileColor: absence.followedUp ? null : Color.fromARGB(255, 255, 230, 233),
          ),
          if (absence.followedUp)
            ListTile(
              title: Text('Reason: ${absence.reason}'),
            ),
          ListTile(
            title: Text('Date Modified: ${dateTimeFormatter(absence.dateModified)}'),
          ),
          ListTile(
            title: Text('Modified By: ${absence.modifiedBy}'),
          ),
        ],
      ),
    );
  }
}
