import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:markham_recreation_app/globals.dart' as globals;
import 'package:markham_recreation_app/pages/parent_notes/fetch_parent_notes.dart';

import 'package:markham_recreation_app/pages/parent_notes/parent_notes.dart';
import 'package:markham_recreation_app/pages/parent_notes/edit_parent_notes.dart';

// Details of an parent notes
class ParentNoteDetails extends StatelessWidget {
  final ParentNote parentNote;

  const ParentNoteDetails({super.key, required this.parentNote});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        
        title: const Text(
          'Parent Note Details',
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
          // Edit current parentNote
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditParentNote(parentNote: parentNote)),
              );
            },
          ),
          // Delete current parent note
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Send a request to the server to delete the parent note
              Future<http.Response> response = globals.session.post(
                Uri.parse('${globals.serverUrl}/api/delete_parent_notes/${globals.campId}'),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(<String, String>{
                  'parent_note_id': parentNote.parentNoteId.toString(),
                }),
              );

              response.then((http.Response response) {
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deleted Parent Note (Reload List to View Updates)'),
                      duration: Duration(seconds: 3),
                    ),
                  );

                  // go back to the previous page and force a refresh
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Delete Parent Note'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }).catchError((error, stackTrace) {
                // Runs when the server is down
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to Delete Parent Note'),
                    duration: Duration(seconds: 3),
                  ),
                );
              });
            },
          ),
        ],
      ),

      // Display parent note details
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('Date: ${dateFormatter(parentNote.parentNoteDate)}'),
          ),
          ListTile(
              title: Text('Parent Note: ${parentNote.parentNote}'),
            ),
          ListTile(
            title: Text('Date Modified: ${dateTimeFormatter(parentNote.updatedDate)}'),
          ),
          ListTile(
            title: Text('Modified By: ${parentNote.updatedBy}'),
          ),
        ],
      ),
    );
  }
}
