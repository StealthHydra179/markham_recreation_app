import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:markham_recreation_app/globals.dart' as globals;
import 'package:markham_recreation_app/pages/daily_notes/fetch_daily_notes.dart';

import 'daily_note.dart';
import 'edit_daily_note.dart';

// Details of an Daily Note
class DailyNoteDetails extends StatelessWidget {
  final DailyNote dailyNote;

  const DailyNoteDetails({super.key, required this.dailyNote});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        
        title: const Text(
          'Daily Note Details',
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
          // Edit current Daily Note
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditDailyNote(dailyNote: dailyNote)),
              );
            },
          ),
          // Delete current Daily Note
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Send a request to the server to delete the Daily Note
              Future<http.Response> response = http.post(
                Uri.parse('${globals.serverUrl}/api/delete_daily_note/${globals.campId}'),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(<String, String>{
                  'daily_note_id': dailyNote.inNoteId.toString(),
                }),
              );

              response.then((http.Response response) {
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deleted Daily Note'),
                      duration: Duration(seconds: 3),
                    ),
                  );

                  // go back to the previous page and force a refresh
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Delete Daily Note'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }).catchError((error, stackTrace) {
                // Runs when the server is down
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to Delete Daily Note'),
                    duration: Duration(seconds: 3),
                  ),
                );
              });
            },
          ),
        ],
      ),

      // Display Daily Note details
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('Date: ${dateFormatter(dailyNote.inNoteDate)}'),
          ),
          ListTile(
            title: Text("Note:"),
            subtitle: Text(dailyNote.inNote),
          ),
          ListTile(
            title: Text('Date Modified: ${dateTimeFormatter(dailyNote.updDate)}'),
          ),
          ListTile(
            title: Text('Modified By: ${dailyNote.updBy}'),
          ),
        ],
      ),
    );
  }
}
