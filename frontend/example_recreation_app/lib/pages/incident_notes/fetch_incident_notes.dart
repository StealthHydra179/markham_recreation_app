

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:example_recreation_app/drawer.dart' as drawer;
import 'package:example_recreation_app/globals.dart' as globals;

import 'package:example_recreation_app/pages/incident_notes/incident_note.dart';
import 'package:example_recreation_app/pages/incident_notes/new_incident_note.dart';
import 'package:example_recreation_app/pages/incident_notes/incident_note_details.dart';

// global variable to store the request to the server (for FutureBuilder)
late Future<List<IncidentNote>> futureIncidentNotes;

// Fetch incident notes from the server
Future<List<IncidentNote>> futureFetchIncidentNotes(context) async {
  final response = await globals.session.get(
    Uri.parse('${globals.serverUrl}/api/get_incident_notes/${globals.campId}'),
  );

  // Create List of incident notes
  List<IncidentNote> incidentNotes = [];

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON and store the Incident Notes
    List<dynamic> incidentNotesJson = jsonDecode(response.body);
    incidentNotes = incidentNotesJson.map((dynamic json) => IncidentNote.fromJson(json)).toList();
    return incidentNotes;
  } else if (response.statusCode == 401) {
        //redirect to /
    globals.loggedIn = false;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    return incidentNotes;
  
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load incident notes');
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

// List incident notes page wrapper
class FetchIncidentNotes extends StatefulWidget {
  const FetchIncidentNotes({super.key});

  @override
  State<FetchIncidentNotes> createState() => _FetchIncidentNotesState();
}

// List incident notes page content
class _FetchIncidentNotesState extends State<FetchIncidentNotes> {
  // Fetch list of incident notes from the server
  @override
  void initState() {
    super.initState();
    futureIncidentNotes = futureFetchIncidentNotes(context);
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewIncidentNote()),
              ).then((value) {
                // Refresh the list of incident notes after returning from the new incident note page
                futureIncidentNotes = futureFetchIncidentNotes(context);
                setState(() {});
              });
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the list of incident notes
              futureIncidentNotes = futureFetchIncidentNotes(context);
              setState(() {});
            },
          ),
        ],
      ),
      drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          // Display incident notes in a list view, future builder waits for the server to return the data
          FutureBuilder<List<IncidentNote>>(
            future: futureIncidentNotes,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      // For each incident note, display the camper name, date, and a chevron icon
                      return ListTile(
                        title: Text("${dateFormatter(snapshot.data![index].inNoteDate)}"),
                        subtitle: Text(snapshot.data![index].inNote),
                        trailing: const Icon(Icons.chevron_right),

                        // If not followed up change the background color to a light red
                        onTap: () {
                          // Display the absence details page when the absence is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => IncidentNoteDetails(incidentNote: snapshot.data![index])),
                          ).then((value) {
                            // Refresh the list of absences after returning from the absence details page
                            futureIncidentNotes = futureFetchIncidentNotes(context);
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







// 

// import 'package:flutter/material.dart';

// import 'package:markham_recreation_app/globals.dart' as globals;
// import 'package:markham_recreation_app/drawer.dart' as drawer;

// class FetchIncidentNotes extends StatefulWidget {
//   const FetchIncidentNotes({super.key});

//   @override
//   State<FetchIncidentNotes> createState() => _FetchIncidentNotesState();
// }

// class _FetchIncidentNotesState extends State<FetchIncidentNotes> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         title: const Text('Incident Notes', style: TextStyle(color: globals.secondaryColor)),
//         iconTheme: const IconThemeData(color: globals.secondaryColor),
//         actions: <Widget>[
//           // New incident note button
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               // TODO add new incident note page
//             },
//           ),
//           // Refresh button
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               // Refresh the list of incident notes
//               // TODO add a refresh state
//               setState(() {});
//             },
//           ),
//         ],
//       ),
//       drawer: drawer.drawer(context),
//       body: Column(
//         children: <Widget>[
//           // Display incident notes in a list view, future builder waits for the server to return the data
          
//         ],
//       ),
//     );
//   }
// }