

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:example_recreation_app/drawer.dart' as drawer;
import 'package:example_recreation_app/globals.dart' as globals;

import 'package:example_recreation_app/pages/parent_notes/parent_notes.dart';
import 'package:example_recreation_app/pages/parent_notes/parent_notes_details.dart';
import 'package:example_recreation_app/pages/parent_notes/new_parent_note.dart';

// global variable to store the request to the server (for FutureBuilder)
late Future<List<ParentNote>> futureParentNotes;

// Fetch parent notes from the server
Future<List<ParentNote>> futureFetchParentNotes(context) async {
  final response = await globals.session.get(
    Uri.parse('${globals.serverUrl}/api/get_parent_notes/${globals.campId}'),
  );

  // Create List of parent notes
  List<ParentNote> parentNotes = [];

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON and store the parent notes
    List<dynamic> parentNotesJson = jsonDecode(response.body);
    parentNotes = parentNotesJson.map((dynamic json) => ParentNote.fromJson(json)).toList();
    return parentNotes;
  } else if (response.statusCode == 401) {
    //redirect to /
    globals.loggedIn = false;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    return parentNotes;
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load parent notes');
  }
}
// Format datetime string into a date and a time
String dateTimeFormatter(String date) {
  // Import form yyyy-mm-ddThh:mm:ss.000Z to mm/dd/yyyy hh:mm
  final DateFormat formatter = DateFormat('MM/dd/yyyy HH:mm');
  return formatter.format(DateTime.parse(date).add(DateTime.now().timeZoneOffset));
}

// Format datetime string into a date
String dateFormatter(String date) {
  // Import form yyyy-mm-ddThh:mm:ss.000Z to mm/dd/yyyy
  return '${date.substring(5, 7)}/${date.substring(8, 10)}/${date.substring(0, 4)}';
}

// List parent notes page wrapper
class FetchParentNotes extends StatefulWidget {
  const FetchParentNotes({super.key});

  @override
  State<FetchParentNotes> createState() => _FetchParentNotesState();
}

// List parent notes page content
class _FetchParentNotesState extends State<FetchParentNotes> {
  // Fetch list of parent notes from the server
  @override
  void initState() {
    super.initState();
    futureParentNotes = futureFetchParentNotes(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Parent notes', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
        actions: <Widget>[
          // New parent note button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewParentNote()),
              ).then((value) {
                // Refresh the list of parent notes after returning from the new parent note page
                futureParentNotes = futureFetchParentNotes(context);
                setState(() {});
              });
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the list of parent notes
              futureParentNotes = futureFetchParentNotes(context);
              setState(() {});
            },
          ),
        ],
      ),
      drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          // Display parent notes in a list view, future builder waits for the server to return the data
          FutureBuilder<List<ParentNote>>(
            future: futureParentNotes,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      // For each parent note, display the camper name, date, and a chevron icon
                      return ListTile(
                        title: Text("${snapshot.data![index].parentNote}"),
                        trailing: const Icon(Icons.chevron_right),
                     
                        onTap: () {
                          // Display the parent note details page when the parent note is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ParentNoteDetails(parentNote: snapshot.data![index])),
                          ).then((value) {
                            // Refresh the list of parent notes after returning from the parent note details page
                            futureParentNotes = futureFetchParentNotes(context);
                            setState(() {});
                          });
                        },
                      );
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }
}
