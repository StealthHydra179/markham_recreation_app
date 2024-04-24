import 'dart:convert';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:markham_recreation_app/pages/incident_notes/incident_note_details.dart';
import 'package:markham_recreation_app/pages/incident_notes/fetch_incident_notes.dart';
import 'package:markham_recreation_app/globals.dart' as globals;

import 'incident_note.dart';

// Edit an incident note
class EditIncidentNote extends StatefulWidget {
  final IncidentNote incidentNote;

  const EditIncidentNote({super.key, required this.incidentNote});

  @override
  State<EditIncidentNote> createState() => _EditIncidentNoteState();
}

// Edit incident note page content
class _EditIncidentNoteState extends State<EditIncidentNote> {
  DateTime? selectedDate;

  final TextEditingController _notesController = TextEditingController();

  // Initialize the text fields with the incident note's data
  @override
  void initState() {
    super.initState();
    _notesController.text = widget.incidentNote.inNote;
    selectedDate = DateTime.parse(widget.incidentNote.inNoteDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Edit Incident Note', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
             Container(
              margin: const EdgeInsets.all(10),
              child: SizedBox(
                child: DateTimeFormField(
                  decoration: const InputDecoration(
                    labelText: 'Enter Date',
                  ),
                  mode: DateTimeFieldPickerMode.date,
                  // TODO replace with week processing
                  // firstDate: DateTime.now().add(const Duration(days: -7)),
                  // lastDate: DateTime.now().add(const Duration(days: 7)),
                  initialPickerDateTime: selectedDate,
                  initialValue: selectedDate,
                  onChanged: (DateTime? value) {
                    selectedDate = value;
                  },
                ),
              ),
            ),
             Container(
                margin: const EdgeInsets.all(10),
                child: SizedBox(
                  child: TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Incident Note',
                    ),
                  ),
                ),
              ),
            const Divider(height: 0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
              ),
              onPressed: () {
 
                if (selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a date'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                if (_notesController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a reason'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                // TODO check if date is out of bounds

                // Send the checklist to the server
                Future<http.Response> response = http.post(
                  Uri.parse('${globals.serverUrl}/api/edit_incident_note/${globals.campId}'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, String>{
                    'in_note_id': widget.incidentNote.inNoteId.toString(),
                    'camp_id': widget.incidentNote.campId.toString(),
                    'in_note_date': selectedDate.toString(),
                    'in_note': _notesController.text,
                    'in_note_upd_date': DateTime.now().toString(),
                  }),
                );
                response.then((http.Response response) {
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edited Incident Note'),
                        duration: Duration(seconds: 3),
                      ),
                    );

                    futureFetchIncidentNotes().then((incidentNotes) {
                      // move back 2 pages
                      Navigator.pop(context);
                      Navigator.pop(context);
                      //readd the current incident note page (refreshing it's contents)
                      IncidentNote incidentNote = const IncidentNote(inNoteId: 0, campId: 0, inNote: '', inNoteDate: '', updDate: '', updBy: '');
                      //find the incident note in the list
                      for (int i = 0; i < incidentNotes.length; i++) {
                        if (incidentNotes[i].inNoteId == widget.incidentNote.inNoteId) {
                          incidentNote = incidentNotes[i];
                          break;
                        }
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (context) => IncidentNoteDetails(incidentNote: incidentNote)));

                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to Edit Incident Note'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }).catchError((error, stackTrace) {
                  // Runs when the server is down
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Edit Incident Note'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
