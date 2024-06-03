import 'dart:convert';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:markham_recreation_app/pages/daily_notes/daily_note_details.dart';
import 'package:markham_recreation_app/pages/daily_notes/fetch_daily_notes.dart';
import 'package:markham_recreation_app/globals.dart' as globals;

import 'package:markham_recreation_app/pages/daily_notes/daily_note.dart';

// Edit an daily note
class EditDailyNote extends StatefulWidget {
  final DailyNote dailyNote;

  const EditDailyNote({super.key, required this.dailyNote});

  @override
  State<EditDailyNote> createState() => _EditDailyNoteState();
}

// Edit daily note page content
class _EditDailyNoteState extends State<EditDailyNote> {
  DateTime? selectedDate;

  final TextEditingController _notesController = TextEditingController();

  // Initialize the text fields with the daily note's data
  @override
  void initState() {
    super.initState();
    _notesController.text = widget.dailyNote.inNote;
    selectedDate = DateTime.parse(widget.dailyNote.inNoteDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Edit Daily Note', style: TextStyle(color: globals.secondaryColor)),
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
                      labelText: 'Daily Note',
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
                  Uri.parse('${globals.serverUrl}/api/edit_daily_note/${globals.campId}'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, String>{
                    'daily_note_id': widget.dailyNote.inNoteId.toString(),
                    'camp_id': widget.dailyNote.campId.toString(),
                    'daily_note_date': selectedDate.toString(),
                    'daily_note': _notesController.text,
                    'daily_note_upd_date': DateTime.now().toString(),
                  }),
                );
                response.then((http.Response response) {
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edited Daily Note'),
                        duration: Duration(seconds: 3),
                      ),
                    );

                    futureFetchDailyNotes(context).then((dailyNotes) {
                      // move back 2 pages
                      Navigator.pop(context);
                      Navigator.pop(context);
                      //readd the current daily note page (refreshing it's contents)
                      DailyNote dailyNote = const DailyNote(inNoteId: 0, campId: 0, inNote: '', inNoteDate: '', updDate: '', updBy: '');
                      //find the daily note in the list
                      for (int i = 0; i < dailyNotes.length; i++) {
                        if (dailyNotes[i].inNoteId == widget.dailyNote.inNoteId) {
                          dailyNote = dailyNotes[i];
                          break;
                        }
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DailyNoteDetails(dailyNote: dailyNote)));

                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to Edit Daily Note'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }).catchError((error, stackTrace) {
                  // Runs when the server is down
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Edit Daily Note'),
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
