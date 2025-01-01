import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:example_recreation_app/main.dart';
import 'package:example_recreation_app/globals.dart' as globals;
import 'package:example_recreation_app/pages/attendance/fetch_attendance.dart';
import 'package:example_recreation_app/pages/counsellor_meeting_notes/fetch_counsellor_meeting_notes.dart';
import 'package:example_recreation_app/pages/daily_notes/fetch_daily_notes.dart';
import 'package:example_recreation_app/pages/equipment_notes/fetch_equipment_notes.dart';
import 'package:example_recreation_app/pages/incident_notes/fetch_incident_notes.dart';
import 'package:example_recreation_app/pages/parent_notes/fetch_parent_notes.dart';
import 'package:example_recreation_app/pages/staff_performance_notes/fetch_staff_performance_notes.dart';
import 'package:example_recreation_app/pages/supervisor_meeting_notes/fetch_supervisor_meeting_notes.dart';
import 'package:example_recreation_app/pages/message_board/fetch_messages.dart';
import 'package:example_recreation_app/pages/weekly_checklist/fetch_weekly_checklist.dart';
import 'package:example_recreation_app/pages/absences/fetch_absences.dart';
import 'package:example_recreation_app/pages/camp_information/fetch_camp_information.dart';


// Drawer widget that is displayed on the left side of the app
Drawer drawer(BuildContext context) {
  // Fetch the camp information from the server
  globals.fetchcamp(0);

  // Return the drawer widget
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [

        // Header of the drawer that displays the user's name, camp name
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
          accountName: Text(
            globals.username,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          accountEmail: Text(
            globals.campName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          currentAccountPicture: const CircleAvatar(
            backgroundColor: Colors.white,
            foregroundImage: AssetImage('lib/camp.png'),
          ),

          // Selecting a different camp
          onDetailsPressed: () {
            //List the camp from the global variable in a small dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Select Camp'),
                  content: Container(
                      width: double.maxFinite,

                      // Build the list of camps
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: globals.campList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            
                            // For each camp, display the camp name and the start date, and set the onTap action to change the camp
                            title: Text("Week ${globals.campList[index].weekNumber} - ${globals.campList[index].name} @ ${globals.campList[index].facilityName}"), // TODO fix the arrow changing directions on tap but not changing back
                            subtitle: Text("${globals.dateFormatter(globals.campList[index].startDate.toString())} to ${globals.dateFormatter(globals.campList[index].startDate.add(const Duration(days: 7)).toString())}"),
                            onTap: () {
                              // Set the global variables to the selected camp
                              globals.campId = globals.campList[index].id;
                              globals.campName = globals.campList[index].name;
                              globals.startDate = globals.campList[index].startDate;
                              globals.facilityName = globals.campList[index].facilityName;
                              globals.weekNumber = globals.campList[index].weekNumber;

                              // Close the dialog and reload the app to show the new camp
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.popUntil(context, (_) => false);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LandingPage(title: globals.title)),
                              );
                            },
                          );
                        },
                      )),
                );
              },
            );
          },
        ),

        // Different options for the pages that can be navigated to
        ListTile(
          leading: const Icon(
            Icons.warning,
          ),
          title: const Text('Camper Information'),
          onTap: () {
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FetchCampInformation()),
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.checklist,
          ),
          title: const Text('Weekly Checklist'),
          onTap: () {
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FetchWeeklyChecklist()),
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Message Board'),
          onTap: () {
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FetchMessageBoards()),
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Attendance'),
          onTap: () {
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FetchAttendance()),
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Absences'),
          onTap: () {
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FetchAbsences()),
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Daily Notes'),
          onTap: () {
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FetchDailyNotes()),
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Incident/Accident Report'),
          onTap: () {
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FetchIncidentNotes()),
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Parent Comments/Concerns'),
          onTap: () {
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FetchParentNotes()),
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Equipment and Supplies'),
          onTap: () {
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FetchEquipmentNotes()),
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Staff Performance'),
          onTap: () {
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FetchStaffPerformanceNotes()),
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Counsellor Weekly Meeting Notes'),
          onTap: () {
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FetchCounsellorMeetingNotes()),
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Supervisor Weekly Meeting Notes'),
          onTap: () {
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FetchSupervisorMeetingNotes()),
            );
          },
        ),

        // Sign out option
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Sign Out'),
          onTap: () {
            // Send a POST request to the server to logout
            Future<http.Response> response = globals.session.post(
              Uri.parse('${globals.serverUrl}/api/logout'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
            );

            // If the request is successful, set the loggedIn variable to false and reload the app
            response.then((value) {
              if (value.statusCode == 200) {
                globals.loggedIn = false;
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                //reload app
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to logout'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            });
            //reload app
          },
        ),
      ],
    ),
  );
}
