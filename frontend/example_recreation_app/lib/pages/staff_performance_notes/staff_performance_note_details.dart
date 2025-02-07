import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:example_recreation_app/globals.dart' as globals;
import 'package:example_recreation_app/pages/staff_performance_notes/fetch_staff_performance_notes.dart';

import 'package:example_recreation_app/pages/staff_performance_notes/staff_performance_note.dart';
import 'package:example_recreation_app/pages/staff_performance_notes/edit_staff_performance_note.dart';

// Details of an Staff Performance Note
class StaffPerformanceNoteDetails extends StatelessWidget {
  final StaffPerformanceNote staffPerformanceNote;

  const StaffPerformanceNoteDetails({super.key, required this.staffPerformanceNote});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        
        title: const Text(
          'Staff Performance Note Details',
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
          // Edit current Staff Performance Note
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditStaffPerformanceNote(staffPerformanceNote: staffPerformanceNote)),
              );
            },
          ),
          // Delete current Staff Performance Note
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Send a request to the server to delete the Staff Performance Note
              Future<http.Response> response = globals.session.post(
                Uri.parse('${globals.serverUrl}/api/delete_staff_performance_note/${globals.campId}'),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(<String, String>{
                  'staff_performance_note_id': staffPerformanceNote.stNoteId.toString(),
                }),
              );

              response.then((http.Response response) {
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deleted Staff Performance Note (Reload List to View Updates)'),
                      duration: Duration(seconds: 3),
                    ),
                  );

                  // go back to the previous page and force a refresh
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Delete Staff Performance Note'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }).catchError((error, stackTrace) {
                // Runs when the server is down
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to Delete Staff Performance Note'),
                    duration: Duration(seconds: 3),
                  ),
                );
              });
            },
          ),
        ],
      ),

      // Display Staff Performance Note details
      body: SingleChildScrollView(
        child: Column(
        children: <Widget>[
          ListTile(
            title: Text('Date: ${dateFormatter(staffPerformanceNote.stNoteDate)}'),
          ),
          ListTile(
            title: Text("Note:"),
            subtitle: Text(staffPerformanceNote.stNote),
          ),
          ListTile(
            title: Text('Date Modified: ${dateTimeFormatter(staffPerformanceNote.updDate)}'),
          ),
          ListTile(
            title: Text('Modified By: ${staffPerformanceNote.updBy}'),
          ),
        ],
      ),
      ),
    );
  }
}
