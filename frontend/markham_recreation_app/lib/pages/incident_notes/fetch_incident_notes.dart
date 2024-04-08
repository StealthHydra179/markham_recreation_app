library weekly_checklist;

import 'package:flutter/material.dart';

import 'package:markham_recreation_app/globals.dart' as globals;
import 'package:markham_recreation_app/drawer.dart' as drawer;

class FetchIncidentNotes extends StatefulWidget {
  const FetchIncidentNotes({Key? key}) : super(key: key);

  @override
  State<FetchIncidentNotes> createState() => _FetchIncidentNotesState();
}

class _FetchIncidentNotesState extends State<FetchIncidentNotes> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Incident Notes', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
        actions: <Widget>[
          // New incident note button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO add new incident note page
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the list of incident notes
              // TODO add a refresh state
              setState(() {});
            },
          ),
        ],
      ),
      drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          // Display incident notes in a list view, future builder waits for the server to return the data
          
        ],
      ),
    );
  }
}