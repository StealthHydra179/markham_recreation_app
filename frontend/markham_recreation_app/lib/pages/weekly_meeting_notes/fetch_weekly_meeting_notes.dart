library weekly_checklist;

import 'package:flutter/material.dart';

import 'package:markham_recreation_app/globals.dart' as globals;
import 'package:markham_recreation_app/drawer.dart' as drawer;

class FetchWeeklyMeetingNotes extends StatefulWidget {
  const FetchWeeklyMeetingNotes({Key? key}) : super(key: key);

  @override
  State<FetchWeeklyMeetingNotes> createState() => _FetchWeeklyMeetingNotesState();
}

class _FetchWeeklyMeetingNotesState extends State<FetchWeeklyMeetingNotes> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Weekly Meeting Notes', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
        actions: <Widget>[
          // New weekly meeting note button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO add new weekly meeting note page
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the list of weekly meeting notes
              // TODO add a refresh state
              setState(() {});
            },
          ),
        ],
      ),
      drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          // Display weekly meeting notes in a list view, future builder waits for the server to return the data
          
        ],
      ),
    );
  }
}