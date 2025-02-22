

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:date_field/date_field.dart';

import 'package:example_recreation_app/globals.dart' as globals;

class NewStaffPerformanceNote extends StatefulWidget {
  const NewStaffPerformanceNote({super.key});

  @override
  State<NewStaffPerformanceNote> createState() => _NewStaffPerformanceNoteState();
}

class _NewStaffPerformanceNoteState extends State<NewStaffPerformanceNote> {
  DateTime? selectedDate;

  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Update checkbox state

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('New Staff Performance Note', style: TextStyle(color: globals.secondaryColor)),
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
                  firstDate: DateTime.now().add(const Duration(days: -7)),
                  lastDate: DateTime.now().add(const Duration(days: 7)),
                  initialPickerDateTime: DateTime.now().add(const Duration(days: 0)),
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
                    // TODO make the box expand vertically when new information is added
                    controller: _notesController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Notes',
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
                // TODO input validation

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
                      content: Text('Please enter a note'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                // Send the checklist to the server
                Future<http.Response> response = globals.session.post(
                  Uri.parse('${globals.serverUrl}/api/new_staff_performance_note/${globals.campId}'), //+globals.camp_id.toString()
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, String>{
                    'st_note_date': selectedDate.toString(),
                    'st_note': _notesController.text,
                  }),
                );
                response.then((http.Response response) {
                  if (response.statusCode == 200) {
                    Navigator.pop(context, true); // go back to the previous page and force a refresh
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('New Staff Performance Note Saved'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to Save New Staff Performance Note'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }).catchError((error, stackTrace) {
                  // Runs when the server is down
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Save Staff Performance Note'),
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
