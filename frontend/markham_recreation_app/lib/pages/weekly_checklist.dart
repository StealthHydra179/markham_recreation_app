library weekly_checklist;

import 'package:flutter/material.dart';
import 'package:markham_recreation_app/drawer.dart' as drawer;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Checklist'),
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
        ],
      ),
    );
  }
}
