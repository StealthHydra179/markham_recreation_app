library weekly_checklist;

import 'package:flutter/material.dart';

import 'package:markham_recreation_app/globals.dart' as globals;
import 'package:markham_recreation_app/drawer.dart' as drawer;

class FetchStaffPerformanceNotes extends StatefulWidget {
  const FetchStaffPerformanceNotes({Key? key}) : super(key: key);

  @override
  State<FetchStaffPerformanceNotes> createState() => _FetchStaffPerformanceNotesState();
}

class _FetchStaffPerformanceNotesState extends State<FetchStaffPerformanceNotes> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Staff Performance Notes', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
        actions: <Widget>[
          // New staff performance note button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO add new staff performance note page
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the list of staff performance notes
              // TODO add a refresh state
              setState(() {});
            },
          ),
        ],
      ),
      drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          // Display staff performance notes in a list view, future builder waits for the server to return the data
          
        ],
      ),
    );
  }
}