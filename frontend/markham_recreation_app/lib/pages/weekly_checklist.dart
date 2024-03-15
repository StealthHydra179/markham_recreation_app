library weekly_checklist;

import 'package:flutter/material.dart';
import 'package:markham_recreation_app/drawer.dart' as drawer;
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:markham_recreation_app/globals.dart' as globals;

class WeeklyChecklist extends StatefulWidget {
  const WeeklyChecklist({super.key});

  @override
  State<WeeklyChecklist> createState() => _WeeklyChecklistState();
}

class _WeeklyChecklistState extends State<WeeklyChecklist> {
  bool camperInformationForms = false;
  bool allergyAndMedicalInformation = false;
  bool swimTest = false;
  bool programPlans = false;
  bool campDirectorMeeting = false;
  bool campCounsellorMeeting = false;

  void _fetch_checklist() async {
    Future<http.Response> response = http.get(
      Uri.parse('${globals.serverUrl}/api/weekly_checklist'),
    );
    response.then((http.Response response) {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weekly Checklist Loaded'),
            duration: Duration(seconds: 3),
            //TODO edit the state of the checkboxes to match the response
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to Load Weekly Checklist'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }).catchError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to Load Weekly Checklist'),
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _fetch_checklist();
  }

  @override
  Widget build(BuildContext context) {
    // Update checkbox state

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        
        title: const Text(
          'Weekly Checklist',
          style: TextStyle(color: globals.secondaryColor) 
        ),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
      ),
      drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          CheckboxListTile(
            value: camperInformationForms,
            onChanged: (bool? value) {
              setState(() {
                camperInformationForms = value!;
              });
            },
            // TODO add descriptions to make it clear what each checkbox is for?
            title: const Text('Collect and Alphebetize Camper Information Forms'),
          ),
          const Divider(height: 0),
          CheckboxListTile(
            value: allergyAndMedicalInformation,
            onChanged: (bool? value) {
              setState(() {
                allergyAndMedicalInformation = value!;
              });
            },
            title: const Text('Share Allergy and Medical Information with Camp Counsellors'),
          ),
          const Divider(height: 0),
          CheckboxListTile(
            value: swimTest,
            onChanged: (bool? value) {
              setState(() {
                swimTest = value!;
              });
            },
            title: const Text('Track and Record Swim Test Pass/Fail of Each Camper'),
          ),
          const Divider(height: 0),
          CheckboxListTile(
            value: programPlans,
            onChanged: (bool? value) {
              setState(() {
                programPlans = value!;
              });
            },
            title: const Text('Review and Update Weekly Program Plans'),
          ),
          const Divider(height: 0),
          CheckboxListTile(
            value: campDirectorMeeting,
            onChanged: (bool? value) {
              setState(() {
                campDirectorMeeting = value!;
              });
            },
            title: const Text('Meet and Check-in with Camp Director'),
          ),
          const Divider(height: 0),
          CheckboxListTile(
            value: campCounsellorMeeting,
            onChanged: (bool? value) {
              setState(() {
                campCounsellorMeeting = value!;
              });
            },
            title: const Text('Meet and Check-in with Camp Counsellors'),
          ),
          const Divider(height: 0),
        
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(10),
            ),
            onPressed: () {
              // Send the checklist to the server
              Future<http.Response> response = http.post(
                Uri.parse('${globals.serverUrl}/api/weekly_checklist/'+globals.camp_id.toString()),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(<String, bool>{
                  'camperInformationForms': camperInformationForms,
                  'allergyAndMedicalInformation': allergyAndMedicalInformation,
                  'swimTest': swimTest,
                  'programPlans': programPlans,
                  'campDirectorMeeting': campDirectorMeeting,
                  'campCounsellorMeeting': campCounsellorMeeting,
                }),
              );
              response.then((http.Response response) {
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Weekly Checklist Saved'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Save Weekly Checklist'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }).catchError((error, stackTrace) {
                // Runs when the server is down
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to Load Weekly Checklist'),
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
