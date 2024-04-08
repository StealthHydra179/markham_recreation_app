library weekly_checklist;

import 'package:flutter/material.dart';

import 'package:markham_recreation_app/globals.dart' as globals;
import 'package:markham_recreation_app/drawer.dart' as drawer;

class FetchDailyNotes extends StatefulWidget {
  const FetchDailyNotes({Key? key}) : super(key: key);

  @override
  State<FetchDailyNotes> createState() => _FetchDailyNotesState();
}

class _FetchDailyNotesState extends State<FetchDailyNotes> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Daily Notes', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
        actions: <Widget>[
          // New daily note button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO add new daily note page
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the list of daily notes
              // TODO add a refresh state
              setState(() {});
            },
          ),
        ],
      ),
      drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          // Display daily notes in a list view, future builder waits for the server to return the data
          
        ],
      ),
    );
  }
}