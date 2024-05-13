import 'dart:convert';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:markham_recreation_app/pages/equipment_notes/equipment_note_details.dart';
import 'package:markham_recreation_app/pages/equipment_notes/fetch_equipment_notes.dart';
import 'package:markham_recreation_app/globals.dart' as globals;

import 'package:markham_recreation_app/pages/equipment_notes/equipment_note.dart';

// Edit an equipment note
class EditEquipmentNote extends StatefulWidget {
  final EquipmentNote equipmentNote;

  const EditEquipmentNote({super.key, required this.equipmentNote});

  @override
  State<EditEquipmentNote> createState() => _EditEquipmentNoteState();
}

// Edit equipment note page content
class _EditEquipmentNoteState extends State<EditEquipmentNote> {
  DateTime? selectedDate;

  final TextEditingController _notesController = TextEditingController();

  // Initialize the text fields with the equipment note's data
  @override
  void initState() {
    super.initState();
    _notesController.text = widget.equipmentNote.equipNote;
    selectedDate = DateTime.parse(widget.equipmentNote.equipNoteDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Edit Equipment Note', style: TextStyle(color: globals.secondaryColor)),
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
                      labelText: 'Equipment Note',
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
                  Uri.parse('${globals.serverUrl}/api/edit_equipment_note/${globals.campId}'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, String>{
                    'equip_note_id': widget.equipmentNote.equipNoteId.toString(),
                    'camp_id': widget.equipmentNote.campId.toString(),
                    'equip_note_date': selectedDate.toString(),
                    'equip_note': _notesController.text,
                    'equip_note_upd_date': DateTime.now().toString(),
                  }),
                );
                response.then((http.Response response) {
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edited Equipment Note'),
                        duration: Duration(seconds: 3),
                      ),
                    );

                    futureFetchEquipmentNotes(context).then((equipmentNotes) {
                      // move back 2 pages
                      Navigator.pop(context);
                      Navigator.pop(context);
                      //readd the current equipment note page (refreshing it's contents)
                      EquipmentNote equipmentNote = const EquipmentNote(equipNoteId: 0, campId: 0, equipNote: '', equipNoteDate: '', updDate: '', updBy: '');
                      //find the equipment note in the list
                      for (int i = 0; i < equipmentNotes.length; i++) {
                        if (equipmentNotes[i].equipNoteId == widget.equipmentNote.equipNoteId) {
                          equipmentNote = equipmentNotes[i];
                          break;
                        }
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EquipmentNoteDetails(equipmentNote: equipmentNote)));
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to Edit Equipment Note'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }).catchError((error, stackTrace) {
                  // Runs when the server is down
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Edit Equipment Note'),
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
