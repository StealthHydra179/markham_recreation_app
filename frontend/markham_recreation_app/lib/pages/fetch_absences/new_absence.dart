library weekly_checklist;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:date_field/date_field.dart';

import 'package:markham_recreation_app/globals.dart' as globals;

class NewAbsence extends StatefulWidget {
  const NewAbsence({super.key});

  @override
  State<NewAbsence> createState() => _NewAbsenceState();
}

class _NewAbsenceState extends State<NewAbsence> {
  bool followedUp = false;
  DateTime? selectedDate;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Update checkbox state

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('New Absence', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(10),
              child: SizedBox(
                child: TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Camper First Name',
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: SizedBox(
                child: TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Camper Last Name',
                  ),
                ),
              ),
            ),
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
            CheckboxListTile(
              value: followedUp,
              onChanged: (bool? value) {
                setState(() {
                  followedUp = value!;
                });
              },
              // TODO add descriptions to make it clear what each checkbox is for?
              title: const Text('Followed Up?'),
            ),
            if (followedUp)
              //Text entry widget
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
                if (_firstNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter first name'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                if (_lastNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter last name'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }

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
                      content: Text('Please enter a reason'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                // Send the checklist to the server
                Future<http.Response> response = http.post(
                  Uri.parse('${globals.serverUrl}/api/new_absence/${globals.campId}'), //+globals.camp_id.toString()
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, String>{
                    'camper_first_name': _firstNameController.text,
                    'camper_last_name': _lastNameController.text,
                    'absence_date': selectedDate.toString(),
                    'followed_up': followedUp.toString(),
                    'reason': _notesController.text,
                  }),
                );
                response.then((http.Response response) {
                  if (response.statusCode == 200) {
                    Navigator.pop(context, true); // go back to the previous page and force a refresh
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('New Absence Saved'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to Save New Absence'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }).catchError((error, stackTrace) {
                  // Runs when the server is down
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Save New Absence'),
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
