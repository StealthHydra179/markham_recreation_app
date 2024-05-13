import 'dart:convert';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:markham_recreation_app/pages/staff_performance_notes/staff_performance_note_details.dart';
import 'package:markham_recreation_app/pages/staff_performance_notes/fetch_staff_performance_notes.dart';
import 'package:markham_recreation_app/globals.dart' as globals;

import 'package:markham_recreation_app/pages/staff_performance_notes/staff_performance_note.dart';

// Edit an staff performance note
class EditStaffPerformanceNote extends StatefulWidget {
  final StaffPerformanceNote staffPerformanceNote;

  const EditStaffPerformanceNote({super.key, required this.staffPerformanceNote});

  @override
  State<EditStaffPerformanceNote> createState() => _EditStaffPerformanceNoteState();
}

// Edit staff performance note page content
class _EditStaffPerformanceNoteState extends State<EditStaffPerformanceNote> {
  DateTime? selectedDate;

  final TextEditingController _notesController = TextEditingController();

  // Initialize the text fields with the staff performance note's data
  @override
  void initState() {
    super.initState();
    _notesController.text = widget.staffPerformanceNote.stNote;
    selectedDate = DateTime.parse(widget.staffPerformanceNote.stNoteDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Edit Staff performance Note', style: TextStyle(color: globals.secondaryColor)),
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
                      labelText: 'Staff performance Note',
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
                  Uri.parse('${globals.serverUrl}/api/edit_staff_performance_note/${globals.campId}'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, String>{
                    'st_note_id': widget.staffPerformanceNote.stNoteId.toString(),
                    'camp_id': widget.staffPerformanceNote.campId.toString(),
                    'st_note_date': selectedDate.toString(),
                    'st_note': _notesController.text,
                    'st_note_upd_date': DateTime.now().toString(),
                  }),
                );
                response.then((http.Response response) {
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edited Staff performance Note'),
                        duration: Duration(seconds: 3),
                      ),
                    );

                    futureFetchStaffPerformanceNotes(context).then((staffPerformanceNotes) {
                      // move back 2 pages
                      Navigator.pop(context);
                      Navigator.pop(context);
                      //readd the current staff performance note page (refreshing it's contents)
                      StaffPerformanceNote staffPerformanceNote = const StaffPerformanceNote(stNoteId: 0, campId: 0, stNote: '', stNoteDate: '', updDate: '', updBy: '');
                      //find the staff performance note in the list
                      for (int i = 0; i < staffPerformanceNotes.length; i++) {
                        if (staffPerformanceNotes[i].stNoteId == widget.staffPerformanceNote.stNoteId) {
                          staffPerformanceNote = staffPerformanceNotes[i];
                          break;
                        }
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (context) => StaffPerformanceNoteDetails(staffPerformanceNote: staffPerformanceNote)));
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to Edit Staff performance Note'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }).catchError((error, stackTrace) {
                  // Runs when the server is down
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Edit Staff performance Note'),
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
