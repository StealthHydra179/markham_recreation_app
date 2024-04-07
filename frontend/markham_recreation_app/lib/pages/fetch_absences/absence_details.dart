import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:markham_recreation_app/globals.dart' as globals;
import 'package:markham_recreation_app/pages/fetch_absences/fetch_absences.dart';

import 'absence.dart';
import 'edit_absence.dart';

// Details of an absence
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
        
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // go back to the previous page and force a refresh
            Navigator.pop(context, true);
          },
        ),
        actions: <Widget>[
          // Edit current absence
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditAbsence(absence: absence)),
              );
            },
          ),
          // Delete current absence
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Send a request to the server to delete the absence
              Future<http.Response> response = http.post(
                Uri.parse('${globals.serverUrl}/api/delete_absence/${globals.camp_id}'),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(<String, String>{
                  'absence_id': absence.absenceId.toString(),
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

                  // go back to the previous page and force a refresh
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

      // Display absence details
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('Camper Name: ${absence.camperFirstName} ${absence.camperLastName}'),
          ),
          ListTile(
            title: Text('Date: ${dateFormatter(absence.absenceDate)}'),
          ),
          ListTile(
            title: Text('Followed Up: ${absence.followedUp ? 'yes' : 'no'}'),
            
            // if not followed up change the background color to a light red
            tileColor: absence.followedUp ? null : const Color.fromARGB(255, 255, 230, 233),
          ),
          if (absence.followedUp)
            ListTile(
              title: Text('Reason: ${absence.reason}'),
            ),
          ListTile(
            title: Text('Date Modified: ${dateTimeFormatter(absence.updDate)}'),
          ),
          ListTile(
            title: Text('Modified By: ${absence.updBy}'),
          ),
        ],
      ),
    );
  }
}
