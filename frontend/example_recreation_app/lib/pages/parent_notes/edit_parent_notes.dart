import 'dart:convert';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:example_recreation_app/pages/parent_notes/parent_notes_details.dart';
import 'package:example_recreation_app/pages/parent_notes/fetch_parent_notes.dart';
import 'package:example_recreation_app/globals.dart' as globals;

import 'package:example_recreation_app/pages/parent_notes/parent_notes.dart';

// Edit an parent_notes
class EditParentNote extends StatefulWidget {
  final ParentNote parentNote;

  const EditParentNote({super.key, required this.parentNote});

  @override
  State<EditParentNote> createState() => _EditParentNoteState();
}

// Edit parent note page content
class _EditParentNoteState extends State<EditParentNote> {
  bool followedUp = false;
  DateTime? selectedDate;

  final TextEditingController _notesController = TextEditingController();

  // Initialize the text fields with the parent note's data
  @override
  void initState() {
    super.initState();
    _notesController.text = widget.parentNote.parentNote;
      selectedDate = DateTime.parse(widget.parentNote.parentNoteDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Edit Parent Note', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
      ),
      body: Column(
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
                  labelText: 'Parent Notes',
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

              if (followedUp && _notesController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a note'),
                    duration: Duration(seconds: 3),
                  ),
                );
                return;
              }

              // TODO check if date is out of bounds

              // Send the checklist to the server
              Future<http.Response> response = globals.session.post(
                Uri.parse('${globals.serverUrl}/api/edit_parent_notes/${globals.campId}'),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(<String, String>{
                  'parent_note_id': widget.parentNote.parentNoteId.toString(),
                  'camp_id': widget.parentNote.campId.toString(),
                  'parent_note_date': selectedDate.toString(),
                  'parent_note': _notesController.text,
                  'pa_note_upd_date': DateTime.now().toString(),
                }),
              );
              response.then((http.Response response) {
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edited Parent Note'),
                      duration: Duration(seconds: 3),
                    ),
                  );

                  futureFetchParentNotes(context).then((parentNotes) {
                    // move back 2 pages
                    Navigator.pop(context);
                    Navigator.pop(context);
                    //readd the current parent note page (refreshing it's contents)
                    ParentNote parentNote = const ParentNote(parentNoteId: 0, campId: 0, parentNoteDate: '', parentNote: '', updatedDate: '', updatedBy: '');
                    //find the parent note in the list
                    for (int i = 0; i < parentNotes.length; i++) {
                      if (parentNotes[i].parentNoteId == widget.parentNote.parentNoteId) {
                        parentNote = parentNotes[i];
                        break;
                      }
                    }
                    // Navigate to the page
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ParentNoteDetails(parentNote: parentNote)));
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Edit Parent Note'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }).catchError((error, stackTrace) {
                // Runs when the server is down
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to Edit Parent Note'),
                    duration: Duration(seconds: 3),
                  ),
                );
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
