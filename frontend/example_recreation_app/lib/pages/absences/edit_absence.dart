import 'dart:convert';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:example_recreation_app/pages/absences/absence_details.dart';
import 'package:example_recreation_app/pages/absences/fetch_absences.dart';
import 'package:example_recreation_app/globals.dart' as globals;

import 'package:example_recreation_app/pages/absences/absence.dart';

// Edit an absence
class EditAbsence extends StatefulWidget {
  final Absence absence;

  const EditAbsence({super.key, required this.absence});

  @override
  State<EditAbsence> createState() => _EditAbsenceState();
}

// Edit absence page content
class _EditAbsenceState extends State<EditAbsence> {
  bool followedUp = false;
  DateTime? selectedDate;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Initialize the text fields with the absence's data
  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.absence.camperFirstName;
    _lastNameController.text = widget.absence.camperLastName;
    _notesController.text = widget.absence.reason;
    followedUp = widget.absence.followedUp;
    selectedDate = DateTime.parse(widget.absence.absenceDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Edit Absence', style: TextStyle(color: globals.secondaryColor)),
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
            CheckboxListTile(
              value: followedUp,
              onChanged: (bool? value) {
                setState(() {
                  followedUp = value!;
                });
              },
              title: const Text('Followed Up?'),
            ),
            if (followedUp)
              Container(
                margin: const EdgeInsets.all(10),
                child: SizedBox(
                  child: TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Reason',
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

                // TODO check if date is out of bounds

                // Send the checklist to the server
                Future<http.Response> response = globals.session.post(
                  Uri.parse('${globals.serverUrl}/api/edit_absence/${globals.campId}'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, String>{
                    'absence_id': widget.absence.absenceId.toString(),
                    'camp_id': widget.absence.campId.toString(),
                    'camper_first_name': _firstNameController.text,
                    'camper_last_name': _lastNameController.text,
                    'absence_date': selectedDate.toString(),
                    'followed_up': followedUp.toString(),
                    'reason': _notesController.text,
                    'absence_upd_date': DateTime.now().toString(),
                  }),
                );
                response.then((http.Response response) {
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edited Absence'),
                        duration: Duration(seconds: 3),
                      ),
                    );

                    futureFetchAbsences(context).then((absences) {
                      // move back 2 pages
                      Navigator.pop(context);
                      Navigator.pop(context);
                      //readd the current absence page (refreshing it's contents)
                      Absence absence = const Absence(absenceId: 0, campId: 0, camperFirstName: '', camperLastName: '', absenceDate: '', followedUp: false, reason: '', updDate: '', updBy: '');
                      //find the absence in the list
                      for (int i = 0; i < absences.length; i++) {
                        if (absences[i].absenceId == widget.absence.absenceId) {
                          absence = absences[i];
                          break;
                        }
                      }
                      // Navigate to the page
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AbsenceDetails(absence: absence)));
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to Edit Absence'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }).catchError((error, stackTrace) {
                  // Runs when the server is down
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Edit Absence'),
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
