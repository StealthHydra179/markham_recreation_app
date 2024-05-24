

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:markham_recreation_app/drawer.dart' as drawer;
import 'package:markham_recreation_app/globals.dart' as globals;

import 'package:markham_recreation_app/pages/supervisor_meeting_notes/supervisor_meeting_note.dart';
import 'package:markham_recreation_app/pages/supervisor_meeting_notes/new_supervisor_meeting_note.dart';
import 'package:markham_recreation_app/pages/supervisor_meeting_notes/supervisor_meeting_note_details.dart';

// global variable to store the request to the server (for FutureBuilder)
late Future<List<SupervisorMeetingNote>> futureSupervisorMeetingNotes;

// Fetch supervisor meeting notes from the server
Future<List<SupervisorMeetingNote>> futureFetchSupervisorMeetingNotes(context) async {
  final response = await globals.session.get(
    Uri.parse('${globals.serverUrl}/api/get_supervisor_meeting_notes/${globals.campId}'),
  );

  // Create List of supervisor meeting notes
  List<SupervisorMeetingNote> supervisorMeetingNotes = [];

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON and store the Supervisor Meeting Notes
    List<dynamic> supervisorMeetingNotesJson = jsonDecode(response.body);
    supervisorMeetingNotes = supervisorMeetingNotesJson.map((dynamic json) => SupervisorMeetingNote.fromJson(json)).toList();
    return supervisorMeetingNotes;
  } else if (response.statusCode == 401) {
        //redirect to /
        globals.loggedIn = false;
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);        
        return supervisorMeetingNotes;
    } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load supervisor meeting notes');
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

// List supervisor meeting notes page wrapper
class FetchSupervisorMeetingNotes extends StatefulWidget {
  const FetchSupervisorMeetingNotes({super.key});

  @override
  State<FetchSupervisorMeetingNotes> createState() => _FetchSupervisorMeetingNotesState();
}

// List supervisor meeting notes page content
class _FetchSupervisorMeetingNotesState extends State<FetchSupervisorMeetingNotes> {
  // Fetch list of supervisor meeting notes from the server
  @override
  void initState() {
    super.initState();
    futureSupervisorMeetingNotes = futureFetchSupervisorMeetingNotes(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Supervisor Meeting Notes', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
        actions: <Widget>[
          // New supervisor meeting note button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewSupervisorMeetingNote()),
              ).then((value) {
                // Refresh the list of supervisor meeting notes after returning from the new supervisor meeting note page
                futureSupervisorMeetingNotes = futureFetchSupervisorMeetingNotes(context);
                setState(() {});
              });
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the list of supervisor meeting notes
              futureSupervisorMeetingNotes = futureFetchSupervisorMeetingNotes(context);
              setState(() {});
            },
          ),
        ],
      ),
      drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          // Display supervisor meeting notes in a list view, future builder waits for the server to return the data
          FutureBuilder<List<SupervisorMeetingNote>>(
            future: futureSupervisorMeetingNotes,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      // For each supervisor meeting note, display the camper name, date, and a chevron icon
                      return ListTile(
                        title: Text("${dateTimeFormatter(snapshot.data![index].stNoteDate)}"),
                        subtitle: Text(snapshot.data![index].stNote),
                        trailing: const Icon(Icons.chevron_right),

                        // If not followed up change the background color to a light red
                        onTap: () {
                          // Display the absence details page when the absence is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SupervisorMeetingNoteDetails(supervisorMeetingNote: snapshot.data![index])),
                          ).then((value) {
                            // Refresh the list of absences after returning from the absence details page
                            futureSupervisorMeetingNotes = futureFetchSupervisorMeetingNotes(context);
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

// class FetchSupervisorMeetingNotes extends StatefulWidget {
//   const FetchSupervisorMeetingNotes({super.key});

//   @override
//   State<FetchSupervisorMeetingNotes> createState() => _FetchSupervisorMeetingNotesState();
// }

// class _FetchSupervisorMeetingNotesState extends State<FetchSupervisorMeetingNotes> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         title: const Text('Supervisor Meeting Notes', style: TextStyle(color: globals.secondaryColor)),
//         iconTheme: const IconThemeData(color: globals.secondaryColor),
//         actions: <Widget>[
//           // New supervisor meeting note button
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               // TODO add new supervisor meeting note page
//             },
//           ),
//           // Refresh button
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               // Refresh the list of supervisor meeting notes
//               // TODO add a refresh state
//               setState(() {});
//             },
//           ),
//         ],
//       ),
//       drawer: drawer.drawer(context),
//       body: Column(
//         children: <Widget>[
//           // Display supervisor meeting notes in a list view, future builder waits for the server to return the data
          
//         ],
//       ),
//     );
//   }
// }