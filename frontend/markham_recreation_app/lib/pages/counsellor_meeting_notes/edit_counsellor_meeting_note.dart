import 'dart:convert';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:markham_recreation_app/pages/counsellor_meeting_notes/counsellor_meeting_note_details.dart';
import 'package:markham_recreation_app/pages/counsellor_meeting_notes/fetch_counsellor_meeting_notes.dart';
import 'package:markham_recreation_app/globals.dart' as globals;

import 'package:markham_recreation_app/pages/counsellor_meeting_notes/counsellor_meeting_note.dart';

// Edit an counsellor meeting note
class EditCounsellorMeetingNote extends StatefulWidget {
  final CounsellorMeetingNote counsellorMeetingNote;

  const EditCounsellorMeetingNote({super.key, required this.counsellorMeetingNote});

  @override
  State<EditCounsellorMeetingNote> createState() => _EditCounsellorMeetingNoteState();
}

// Edit counsellor meeting note page content
class _EditCounsellorMeetingNoteState extends State<EditCounsellorMeetingNote> {
  DateTime? selectedDate;

  final TextEditingController _notesController = TextEditingController();

  // Initialize the text fields with the counsellor meeting note's data
  @override
  void initState() {
    super.initState();
    _notesController.text = widget.counsellorMeetingNote.stNote;
    selectedDate = DateTime.parse(widget.counsellorMeetingNote.stNoteDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Edit Counsellor Meeting Note', style: TextStyle(color: globals.secondaryColor)),
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
                      labelText: 'Counsellor Meeting Note',
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
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
                  Uri.parse('${globals.serverUrl}/api/edit_counsellor_meeting_note/${globals.campId}'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, String>{
                    'cmeet_note_id': widget.counsellorMeetingNote.stNoteId.toString(),
                    'camp_id': widget.counsellorMeetingNote.campId.toString(),
                    'cmeet_note_date': selectedDate.toString(),
                    'cmeet_note': _notesController.text,
                    'cmeet_note_upd_date': DateTime.now().toString(),
                  }),
                );
                response.then((http.Response response) {
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edited Counsellor Meeting Note'),
                        duration: Duration(seconds: 3),
                      ),
                    );

                    futureFetchCounsellorMeetingNotes(context).then((counsellorMeetingNotes) {
                      // move back 2 pages
                      Navigator.pop(context);
                      Navigator.pop(context);
                      //readd the current counsellor meeting note page (refreshing it's contents)
                      CounsellorMeetingNote counsellorMeetingNote = const CounsellorMeetingNote(stNoteId: 0, campId: 0, stNote: '', stNoteDate: '', updDate: '', updBy: '');
                      //find the counsellor meeting note in the list
                      for (int i = 0; i < counsellorMeetingNotes.length; i++) {
                        if (counsellorMeetingNotes[i].stNoteId == widget.counsellorMeetingNote.stNoteId) {
                          counsellorMeetingNote = counsellorMeetingNotes[i];
                          break;
                        }
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CounsellorMeetingNoteDetails(counsellorMeetingNote: counsellorMeetingNote)));
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to Edit Counsellor Meeting Note'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }).catchError((error, stackTrace) {
                  // Runs when the server is down
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Edit Counsellor Meeting Note'),
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
