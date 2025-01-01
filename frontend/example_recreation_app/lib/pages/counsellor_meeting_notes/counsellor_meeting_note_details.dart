import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:example_recreation_app/globals.dart' as globals;
import 'package:example_recreation_app/pages/counsellor_meeting_notes/fetch_counsellor_meeting_notes.dart';

import 'package:example_recreation_app/pages/counsellor_meeting_notes/counsellor_meeting_note.dart';
import 'package:example_recreation_app/pages/counsellor_meeting_notes/edit_counsellor_meeting_note.dart';

// Details of an Counsellor Meeting Note
class CounsellorMeetingNoteDetails extends StatelessWidget {
  final CounsellorMeetingNote counsellorMeetingNote;

  const CounsellorMeetingNoteDetails({super.key, required this.counsellorMeetingNote});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        
        title: const Text(
          'Counsellor Meeting Note Details',
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
          // Edit current Counsellor Meeting Note
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditCounsellorMeetingNote(counsellorMeetingNote: counsellorMeetingNote)),
              );
            },
          ),
          // Delete current Counsellor Meeting Note
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Send a request to the server to delete the Counsellor Meeting Note
              Future<http.Response> response = globals.session.post(
                Uri.parse('${globals.serverUrl}/api/delete_counsellor_meeting_note/${globals.campId}'),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(<String, String>{
                  'counsellor_meeting_note_id': counsellorMeetingNote.stNoteId.toString(),
                }),
              );

              response.then((http.Response response) {
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deleted Counsellor Meeting Note (Reload List to View Updates)'),
                      duration: Duration(seconds: 3),
                    ),
                  );

                  // go back to the previous page and force a refresh
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Delete Counsellor Meeting Note'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }).catchError((error, stackTrace) {
                // Runs when the server is down
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to Delete Counsellor Meeting Note'),
                    duration: Duration(seconds: 3),
                  ),
                );
              });
            },
          ),
        ],
      ),

      // Display Counsellor Meeting Note details
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('Date: ${dateFormatter(counsellorMeetingNote.stNoteDate)}'),
          ),
          ListTile(
            title: Text("Note:"),
            subtitle: Text(counsellorMeetingNote.stNote),
          ),
          ListTile(
            title: Text('Date Modified: ${dateTimeFormatter(counsellorMeetingNote.updDate)}'),
          ),
          ListTile(
            title: Text('Modified By: ${counsellorMeetingNote.updBy}'),
          ),
        ],
      ),
    );
  }
}
