library weekly_checklist;

import 'package:flutter/material.dart';
import 'package:markham_recreation_app/drawer.dart' as drawer;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:markham_recreation_app/globals.dart' as globals;
import 'package:date_field/date_field.dart';

class Absence extends StatefulWidget {
  const Absence({super.key});

  @override
  State<Absence> createState() => _AbsenceState();
}

class _AbsenceState extends State<Absence> {
  bool followedUp = false;
  DateTime? selectedDate;

  final TextEditingController _name_controller = TextEditingController();
  final TextEditingController _notes_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Update checkbox state


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        
        title: const Text(
          'New Absence',
          style: TextStyle(color: globals.secondaryColor) 
        ),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
      ),
      drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          Container( 
            margin: const EdgeInsets.all(10),
            child:  SizedBox(
              child: TextField(
                controller: _name_controller,
                decoration: InputDecoration(
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
                  firstDate: DateTime.now().add(const Duration(days: 10)),
                  lastDate: DateTime.now().add(const Duration(days: 40)),
                  initialPickerDateTime: DateTime.now().add(const Duration(days: 20)),
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
                  decoration: InputDecoration(
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
              // Send the checklist to the server
              Future<http.Response> response = http.post(
                Uri.parse('${globals.serverUrl}/api/new_absence/'+globals.camp_id.toString()),//+globals.camp_id.toString()
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(<String, String>{
                  'name': _name_controller.text,
                  'date': selectedDate.toString(),
                  'followedUp': followedUp.toString(),
                  'notes': _notes_controller.text,
                }),
              );
              response.then((http.Response response) {
                if (response.statusCode == 200) {
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
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
