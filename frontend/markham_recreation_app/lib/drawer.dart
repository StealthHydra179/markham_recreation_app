import 'package:flutter/material.dart';

import 'package:markham_recreation_app/pages/weekly_checklist.dart';
import 'package:markham_recreation_app/pages/new_absence.dart';
import 'package:markham_recreation_app/pages/fetch_absences.dart';


Drawer drawer(BuildContext context) {
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
          accountEmail: const Text(
            "stealth@shydra.dev",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          currentAccountPicture: FlutterLogo(),
        ),
        ListTile(
          leading: const Icon(
            Icons.checklist,
          ),
          title: const Text('Weekly Checklist'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WeeklyChecklist()),
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Attendance'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Absent Campers'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FetchAbsences()),
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.add,
          ),
          title: const Text('New Absence'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewAbsence()),
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Daily Notes'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Incident/Accident Report'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Parent Comments/Concerns'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Equipment and Supplies'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Staff Performance'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.chevron_right,
          ),
          title: const Text('Weekly Meeting Notes'),
          onTap: () {
            Navigator.pop(context);
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