import 'dart:convert';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:markham_recreation_app/pages/supervisor_meeting_notes/supervisor_meeting_note_details.dart';
import 'package:markham_recreation_app/pages/supervisor_meeting_notes/fetch_supervisor_meeting_notes.dart';
import 'package:markham_recreation_app/globals.dart' as globals;

import 'package:markham_recreation_app/pages/supervisor_meeting_notes/supervisor_meeting_note.dart';

// Edit an supervisor meeting note
class EditSupervisorMeetingNote extends StatefulWidget {
  final SupervisorMeetingNote supervisorMeetingNote;

  const EditSupervisorMeetingNote({super.key, required this.supervisorMeetingNote});

  @override
  State<EditSupervisorMeetingNote> createState() => _EditSupervisorMeetingNoteState();
}

// Edit supervisor meeting note page content
class _EditSupervisorMeetingNoteState extends State<EditSupervisorMeetingNote> {
  DateTime? selectedDate;

  final TextEditingController _notesController = TextEditingController();

  // Initialize the text fields with the supervisor meeting note's data
  @override
  void initState() {
    super.initState();
    _notesController.text = widget.supervisorMeetingNote.stNote;
    selectedDate = DateTime.parse(widget.supervisorMeetingNote.stNoteDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Edit Supervisor Meeting Note', style: TextStyle(color: globals.secondaryColor)),
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
                      labelText: 'Supervisor Meeting Note',
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
                Future<http.Response> response = globals.session.post(
                  Uri.parse('${globals.serverUrl}/api/edit_supervisor_meeting_note/${globals.campId}'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, String>{
                    'smeet_note_id': widget.supervisorMeetingNote.stNoteId.toString(),
                    'camp_id': widget.supervisorMeetingNote.campId.toString(),
                    'smeet_note_date': selectedDate.toString(),
                    'smeet_note': _notesController.text,
                    'smeet_note_upd_date': DateTime.now().toString(),
                  }),
                );
                response.then((http.Response response) {
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edited Supervisor Meeting Note'),
                        duration: Duration(seconds: 3),
                      ),
                    );

                    futureFetchSupervisorMeetingNotes(context).then((supervisorMeetingNotes) {
                      // move back 2 pages
                      Navigator.pop(context);
                      Navigator.pop(context);
                      //readd the current supervisor meeting note page (refreshing it's contents)
                      SupervisorMeetingNote supervisorMeetingNote = const SupervisorMeetingNote(stNoteId: 0, campId: 0, stNote: '', stNoteDate: '', updDate: '', updBy: '');
                      //find the supervisor meeting note in the list
                      for (int i = 0; i < supervisorMeetingNotes.length; i++) {
                        if (supervisorMeetingNotes[i].stNoteId == widget.supervisorMeetingNote.stNoteId) {
                          supervisorMeetingNote = supervisorMeetingNotes[i];
                          break;
                        }
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SupervisorMeetingNoteDetails(supervisorMeetingNote: supervisorMeetingNote)));
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to Edit Supervisor Meeting Note'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }).catchError((error, stackTrace) {
                  // Runs when the server is down
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Edit Supervisor Meeting Note'),
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
