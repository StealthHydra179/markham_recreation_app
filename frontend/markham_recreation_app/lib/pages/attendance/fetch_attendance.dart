import 'package:flutter/material.dart';

import 'package:markham_recreation_app/drawer.dart' as drawer;
import 'package:markham_recreation_app/globals.dart' as globals;

class FetchAttendance extends StatefulWidget {
  const FetchAttendance({Key? key}) : super(key: key);

  @override
  State<FetchAttendance> createState() => _FetchAttendanceState();
}

class _FetchAttendanceState extends State<FetchAttendance> {
  // Fetch list of attendance from the server
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Attendance', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
        actions: <Widget>[
          // New attendance button
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the list of attendance
              // TODO add a refresh state
              setState(() {});
            },
          ),
        ],
      ),
      drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          // Display attendance in a list view, future builder waits for the server to return the data
          
        ],
      ),
    );
  }
}