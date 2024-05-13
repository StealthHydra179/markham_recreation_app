import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:markham_recreation_app/globals.dart' as globals;
import 'package:markham_recreation_app/pages/supervisor_meeting_notes/fetch_supervisor_meeting_notes.dart';

import 'package:markham_recreation_app/pages/supervisor_meeting_notes/supervisor_meeting_note.dart';
import 'package:markham_recreation_app/pages/supervisor_meeting_notes/edit_supervisor_meeting_note.dart';

// Details of an Supervisor Meeting Note
class SupervisorMeetingNoteDetails extends StatelessWidget {
  final SupervisorMeetingNote supervisorMeetingNote;

  const SupervisorMeetingNoteDetails({super.key, required this.supervisorMeetingNote});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Supervisor Meeting Note Details', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // go back to the previous page and force a refresh
            Navigator.pop(context, true);
          },
        ),
        actions: <Widget>[
          // Edit current Supervisor Meeting Note
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditSupervisorMeetingNote(supervisorMeetingNote: supervisorMeetingNote)),
              );
            },
          ),
          // Delete current Supervisor Meeting Note
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Send a request to the server to delete the Supervisor Meeting Note
              Future<http.Response> response = globals.session.post(
                Uri.parse('${globals.serverUrl}/api/delete_supervisor_meeting_note/${globals.campId}'),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(<String, String>{
                  'supervisor_meeting_note_id': supervisorMeetingNote.stNoteId.toString(),
                }),
              );

              response.then((http.Response response) {
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deleted Supervisor Meeting Note'),
                      duration: Duration(seconds: 3),
                    ),
                  );

                  // go back to the previous page and force a refresh
                  Navigator.pop(context, true);
                } else if (response.statusCode == 401) {
                  //redirect to /
                  globals.loggedIn = false;
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Delete Supervisor Meeting Note'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }).catchError((error, stackTrace) {
                // Runs when the server is down
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to Delete Supervisor Meeting Note'),
                    duration: Duration(seconds: 3),
                  ),
                );
              });
            },
          ),
        ],
      ),

      // Display Supervisor Meeting Note details
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('Date: ${dateFormatter(supervisorMeetingNote.stNoteDate)}'),
          ),
          ListTile(
            title: Text("Note:"),
            subtitle: Text(supervisorMeetingNote.stNote),
          ),
          ListTile(
            title: Text('Date Modified: ${dateTimeFormatter(supervisorMeetingNote.updDate)}'),
          ),
          ListTile(
            title: Text('Modified By: ${supervisorMeetingNote.updBy}'),
          ),
        ],
      ),
    );
  }
}
