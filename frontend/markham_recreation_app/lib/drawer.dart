import 'package:flutter/material.dart';
import 'package:markham_recreation_app/main.dart';
import 'package:markham_recreation_app/pages/fetch_attendance/fetch_attendance.dart';
import 'package:markham_recreation_app/pages/fetch_daily_notes/fetch_daily_notes.dart';
import 'package:markham_recreation_app/pages/fetch_equipment_notes/fetch_equipment_notes.dart';
import 'package:markham_recreation_app/pages/fetch_incident_notes/fetch_incident_notes.dart';
import 'package:markham_recreation_app/pages/fetch_parent_notes/fetch_parent_notes.dart';
import 'package:markham_recreation_app/pages/fetch_staff_performance_notes/fetch_staff_performance_notes.dart';

import 'package:markham_recreation_app/pages/fetch_weekly_checklist/fetch_weekly_checklist.dart';
import 'package:markham_recreation_app/pages/fetch_absences/fetch_absences.dart';
import 'package:markham_recreation_app/globals.dart' as globals;
import 'package:markham_recreation_app/pages/fetch_weekly_meeting_notes/fetch_weekly_meeting_notes.dart';

// TODO so when a page openned pop both the drawer and the previous page before navigating to a new page
// TODO figure out why when restart server this doesnt open until the server responds
Drawer drawer(BuildContext context) {
  globals.fetchcamp();
  return Drawer(
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
         UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary), // Can use global color here, and make the whole header constant for performance
          accountName: const Text(
            "User Name",
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
          currentAccountPicture: FlutterLogo(),
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
                          title: Text(globals.campList[index].name),
                          onTap: () {
                            globals.camp_id = globals.campList[index].id;
                            globals.campName = globals.campList[index].name;
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
          title: const Text('Weekly Meeting Notes'),
          onTap: () {
            Navigator.popUntil(context, (route)=>route.isFirst);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FetchWeeklyMeetingNotes()),
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Sign Out'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        const AboutListTile(
          icon: Icon(
            Icons.info,
          ),
          applicationIcon: Icon(
            Icons.local_play,
          ),
          applicationName: 'Markham Recreation Summer Camp App',
          applicationVersion: '0.0.0',
          applicationLegalese: '© 2024 StealthTech',
          aboutBoxChildren: [
            ///Content goes here...
          ],
          child: Text('About app'),
        ),
      ],
    ),
  );
}