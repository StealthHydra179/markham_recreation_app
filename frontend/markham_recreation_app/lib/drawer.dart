import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:markham_recreation_app/main.dart';
import 'package:markham_recreation_app/pages/attendance/fetch_attendance.dart';
import 'package:markham_recreation_app/pages/counsellor_meeting_notes/fetch_counsellor_meeting_notes.dart';
import 'package:markham_recreation_app/pages/daily_notes/fetch_daily_notes.dart';
import 'package:markham_recreation_app/pages/equipment_notes/fetch_equipment_notes.dart';
import 'package:markham_recreation_app/pages/incident_notes/fetch_incident_notes.dart';
import 'package:markham_recreation_app/pages/parent_notes/fetch_parent_notes.dart';
import 'package:markham_recreation_app/pages/staff_performance_notes/fetch_staff_performance_notes.dart';
import 'package:markham_recreation_app/pages/supervisor_meeting_notes/fetch_supervisor_meeting_notes.dart';
import 'package:markham_recreation_app/pages/message_board/fetch_messages.dart';
import 'package:markham_recreation_app/pages/weekly_checklist/fetch_weekly_checklist.dart';
import 'package:markham_recreation_app/pages/absences/fetch_absences.dart';
import 'package:markham_recreation_app/pages/camp_information/fetch_camp_information.dart';
import 'package:markham_recreation_app/globals.dart' as globals;


// TODO move dateformatter to globals file
String dateFormatter(String date) {
  // Import form yyyy-mm-ddThh:mm:ss.000Z to mm/dd/yyyy
  return '${date.substring(5, 7)}/${date.substring(8, 10)}/${date.substring(0, 4)}';
}

// TODO so when a page openned pop both the drawer and the previous page before navigating to a new page
// TODO figure out why when restart server this doesnt open until the server responds
Drawer drawer(BuildContext context) {
  globals.fetchcamp(0);
  return Drawer(
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
         UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary), // Can use global color here, and make the whole header constant for performance
          accountName: Text(
            globals.username,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          accountEmail: Text(
            globals.campName, // TODO add current camp
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          //image markham_icon.png

          currentAccountPicture: const CircleAvatar(
            backgroundColor: Colors.white,
            foregroundImage: AssetImage('lib/markham_icon.png'),
            // radius: 100,
          ),
          onDetailsPressed: () {
            //List the camp from the global variable in a small dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Select Camp'),
                  content: Container(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: globals.campList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(globals.campList[index].name), // TODO fix the arrow changing directions on tap but not changing back
                          subtitle: Text("${dateFormatter(globals.campList[index].startDate.toString())} to ${dateFormatter(globals.campList[index].startDate.add(const Duration(days: 7)).toString())}"),
                          onTap: () {
                            globals.campId = globals.campList[index].id;
                            globals.campName = globals.campList[index].name;
                            globals.startDate = globals.campList[index].startDate;
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.popUntil(context, (_) => false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LandingPage(title: globals.title)),
                            );
                            //update drawer widget with new camp name
                          },
                        );
                      },
                    )
                    //TODO add reload action (for when a new camp is added)
                  ),
                );
              },
            );

            //reset show details arrow
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.warning,
          ),
          title: const Text('Camper Information'),
          onTap: () {
            //Pop until at landing page
            Navigator.popUntil(context, (route)=>route.isFirst);
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
            //Pop until at landing page
            Navigator.popUntil(context, (route)=>route.isFirst);
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
            Navigator.popUntil(context, (route)=>route.isFirst);
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
            Navigator.popUntil(context, (route)=>route.isFirst);
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
            Navigator.popUntil(context, (route)=>route.isFirst);
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
            Navigator.popUntil(context, (route)=>route.isFirst);
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
            Navigator.popUntil(context, (route)=>route.isFirst);
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
            Navigator.popUntil(context, (route)=>route.isFirst);
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
            Navigator.popUntil(context, (route)=>route.isFirst);
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
            Navigator.popUntil(context, (route)=>route.isFirst);
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
            Navigator.popUntil(context, (route)=>route.isFirst);
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
            Navigator.popUntil(context, (route)=>route.isFirst);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FetchSupervisorMeetingNotes()),
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Sign Out'),
          onTap: () {
            Future<http.Response> response = globals.session.post(
              Uri.parse('${globals.serverUrl}/api/logout'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
            );

            response.then((value) {
              if (value.statusCode == 200) {
                globals.loggedIn = false;
                Navigator.pushNamedAndRemoveUntil(context,'/',(_) => false);
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
        // const AboutListTile(
        //   icon: Icon(
        //     Icons.info,
        //   ),
        //   applicationIcon: Icon(
        //     Icons.local_play,
        //   ),
        //   applicationName: 'Markham Recreation Summer Camp App',
        //   applicationVersion: '0.0.0',
        //   applicationLegalese: '© 2024 StealthTech',
        //   aboutBoxChildren: [
        //     ///Content goes here...
        //   ],
        //   child: Text('About app'),
        // ),
      ],
    ),
  );
}