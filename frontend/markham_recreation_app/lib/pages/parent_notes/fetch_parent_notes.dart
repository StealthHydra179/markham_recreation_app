library weekly_checklist;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:markham_recreation_app/drawer.dart' as drawer;
import 'package:markham_recreation_app/globals.dart' as globals;

import 'package:markham_recreation_app/pages/parent_notes/parent_notes.dart';
import 'package:markham_recreation_app/pages/parent_notes/parent_notes_details.dart';
import 'package:markham_recreation_app/pages/parent_notes/new_parent_note.dart';

// global variable to store the request to the server (for FutureBuilder)
late Future<List<ParentNote>> futureParentNotes;

// Fetch parent notes from the server
Future<List<ParentNote>> futureFetchParentNotes() async {
  final response = await http.get(
    Uri.parse('${globals.serverUrl}/api/get_parent_notes/${globals.campId}'),
  );

  // Create List of parent notes
  List<ParentNote> parentNotes = [];

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON and store the parent notes
    List<dynamic> parentNotesJson = jsonDecode(response.body);
    parentNotes = parentNotesJson.map((dynamic json) => ParentNote.fromJson(json)).toList();
    return parentNotes;
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load parent notes');
  }
}

// Format datetime string into a date and a time
String dateTimeFormatter(String date) {
  // Import form yyyy-mm-ddThh:mm:ss.000Z to mm/dd/yyyy hh:mm

  // timzone offset
  int offset = DateTime.now().timeZoneOffset.inHours;
  // adjust time
  int hour = int.parse(date.substring(11, 13)) + offset;
  int day = int.parse(date.substring(8, 10));
  int month = int.parse(date.substring(5, 7));
  int year = int.parse(date.substring(0, 4));

  if (hour > 23) {
    hour -= 24;
    day++;
  }
  if (day > 31) {
    day -= 31;
    month++;
  }
  if (month > 12) {
    month -= 12;
    year++;
  }
  return '$month/$day/$year $hour:${date.substring(14, 16)}';
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
    futureParentNotes = futureFetchParentNotes();
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
                futureParentNotes = futureFetchParentNotes();
                setState(() {});
              });
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the list of parent notes
              futureParentNotes = futureFetchParentNotes();
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
                            futureParentNotes = futureFetchParentNotes();
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
