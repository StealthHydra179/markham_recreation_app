import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:markham_recreation_app/globals.dart' as globals;
import 'package:markham_recreation_app/pages/equipment_notes/fetch_equipment_notes.dart';

import 'package:markham_recreation_app/pages/equipment_notes/equipment_note.dart';
import 'package:markham_recreation_app/pages/equipment_notes/edit_equipment_note.dart';

// Details of an Equipment Note
class EquipmentNoteDetails extends StatelessWidget {
  final EquipmentNote equipmentNote;

  const EquipmentNoteDetails({super.key, required this.equipmentNote});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        
        title: const Text(
          'Equipment Note Details',
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
          // Edit current Equipment Note
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditEquipmentNote(equipmentNote: equipmentNote)),
              );
            },
          ),
          // Delete current Equipment Note
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Send a request to the server to delete the Equipment Note
              Future<http.Response> response = globals.session.post(
                Uri.parse('${globals.serverUrl}/api/delete_equipment_note/${globals.campId}'),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(<String, String>{
                  'equipment_note_id': equipmentNote.equipNoteId.toString(),
                }),
              );

              response.then((http.Response response) {
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deleted Equipment Note (Reload List to View Updates)'),
                      duration: Duration(seconds: 3),
                    ),
                  );

                  // go back to the previous page and force a refresh
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Delete Equipment Note'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }).catchError((error, stackTrace) {
                // Runs when the server is down
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to Delete Equipment Note'),
                    duration: Duration(seconds: 3),
                  ),
                );
              });
            },
          ),
        ],
      ),

      // Display Equipment Note details
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('Date: ${dateFormatter(equipmentNote.equipNoteDate)}'),
          ),
          ListTile(
            title: Text("Note:"),
            subtitle: Text(equipmentNote.equipNote),
          ),
          ListTile(
            title: Text('Date Modified: ${dateTimeFormatter(equipmentNote.updDate)}'),
          ),
          ListTile(
            title: Text('Modified By: ${equipmentNote.updBy}'),
          ),
        ],
      ),
    );
  }
}
