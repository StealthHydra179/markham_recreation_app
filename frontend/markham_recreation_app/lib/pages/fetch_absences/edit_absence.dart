import 'dart:convert';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:markham_recreation_app/pages/fetch_absences/absence_details.dart';
import 'package:markham_recreation_app/pages/fetch_absences/fetch_absences.dart';
import 'package:markham_recreation_app/globals.dart' as globals;

import 'absence.dart';

class EditAbsence extends StatefulWidget {
  final Absence absence;

  const EditAbsence({super.key, required this.absence});

  @override
  State<EditAbsence> createState() => _EditAbsenceState();
}

class _EditAbsenceState extends State<EditAbsence> {
  bool followedUp = false;
  DateTime? selectedDate;

  final TextEditingController _name_controller = TextEditingController();
  final TextEditingController _notes_controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name_controller.text = widget.absence.camper_name;
    _notes_controller.text = widget.absence.reason;
    followedUp = widget.absence.followed_up;
    selectedDate = DateTime.parse(widget.absence.date);
  }

  @override
  Widget build(BuildContext context) {
    // Update checkbox state

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        
        title: const Text(
          'Edit Absence',
          style: TextStyle(color: globals.secondaryColor) 
        ),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
      ),
      // drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          Container( 
            margin: const EdgeInsets.all(10),
            child:  SizedBox(
              child: TextField(
                controller: _name_controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Camper Name',
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
              child:  SizedBox(
                child: TextField(
                  controller: _notes_controller,
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
              if (_name_controller.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a name'),
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

              if (followedUp && _notes_controller.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter notes'),
                    duration: Duration(seconds: 3),
                  ),
                );
                return;
              }

              print(widget.absence.absent_id);

              // Send the checklist to the server
              Future<http.Response> response = http.post(
                Uri.parse('${globals.serverUrl}/api/edit_absence/${globals.camp_id}'),//+globals.camp_id.toString()
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                /*
                'absent_id': int absent_id,
            'camp_id': int camp_id,
            'camper_name': String camper_name,
            'date': String date,
            'followed_up': bool followed_up,
            'reason': String reason,
            'date_modified': String date_modified,
            */
                body: jsonEncode(<String, String>{
                  'absent_id': widget.absence.absent_id.toString(), 
                  'camp_id': widget.absence.camp_id.toString(),
                  'camper_name': _name_controller.text,
                  'date': selectedDate.toString(),
                  'followed_up': followedUp.toString(),
                  'reason': _notes_controller.text,
                  'date_modified': DateTime.now().toString(),
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

                  futureFetchAbsences().then((absences) {
                    Navigator.pop(context); //TODO not sure if this works yet
                    Navigator.pop(context);
                    //readd the current absence page
                    Absence absence = new Absence(absent_id: 0, camp_id: 0, camper_name: '', date: '', followed_up: false, reason: '', date_modified: '', modified_by: '');
                    //find the absence in the list
                    for (int i = 0; i < absences.length; i++) {
                      if (absences[i].absent_id == widget.absence.absent_id) {
                        absence = absences[i];
                        break;
                      }
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AbsenceDetails(absence: absence)),);
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
    );
  }
}