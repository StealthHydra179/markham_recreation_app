

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:markham_recreation_app/drawer.dart' as drawer;
import 'package:markham_recreation_app/globals.dart' as globals;

import 'package:markham_recreation_app/pages/counsellor_meeting_notes/counsellor_meeting_note.dart';
import 'package:markham_recreation_app/pages/counsellor_meeting_notes/new_counsellor_meeting_note.dart';
import 'package:markham_recreation_app/pages/counsellor_meeting_notes/counsellor_meeting_note_details.dart';

// global variable to store the request to the server (for FutureBuilder)
late Future<List<CounsellorMeetingNote>> futureCounsellorMeetingNotes;

// Fetch counsellor meeting notes from the server
Future<List<CounsellorMeetingNote>> futureFetchCounsellorMeetingNotes(context) async {
  final response = await globals.session.get(
    Uri.parse('${globals.serverUrl}/api/get_counsellor_meeting_notes/${globals.campId}'),
  );

  // Create List of counsellor meeting notes
  List<CounsellorMeetingNote> counsellorMeetingNotes = [];

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON and store the Counsellor Meeting Notes
    List<dynamic> counsellorMeetingNotesJson = jsonDecode(response.body);
    counsellorMeetingNotes = counsellorMeetingNotesJson.map((dynamic json) => CounsellorMeetingNote.fromJson(json)).toList();
    return counsellorMeetingNotes;
  } else if (response.statusCode == 401) {
        //redirect to /
        globals.loggedIn = false;
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);        
        return counsellorMeetingNotes;    
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load counsellor meeting notes');
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

// List counsellor meeting notes page wrapper
class FetchCounsellorMeetingNotes extends StatefulWidget {
  const FetchCounsellorMeetingNotes({super.key});

  @override
  State<FetchCounsellorMeetingNotes> createState() => _FetchCounsellorMeetingNotesState();
}

// List counsellor meeting notes page content
class _FetchCounsellorMeetingNotesState extends State<FetchCounsellorMeetingNotes> {
  // Fetch list of counsellor meeting notes from the server
  @override
  void initState() {
    super.initState();
    futureCounsellorMeetingNotes = futureFetchCounsellorMeetingNotes(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Counsellor Meeting Notes', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
        actions: <Widget>[
          // New counsellor meeting note button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewCounsellorMeetingNote()),
              ).then((value) {
                // Refresh the list of counsellor meeting notes after returning from the new counsellor meeting note page
                futureCounsellorMeetingNotes = futureFetchCounsellorMeetingNotes(context);
                setState(() {});
              });
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the list of counsellor meeting notes
              futureCounsellorMeetingNotes = futureFetchCounsellorMeetingNotes(context);
              setState(() {});
            },
          ),
        ],
      ),
      drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          // Display counsellor meeting notes in a list view, future builder waits for the server to return the data
          FutureBuilder<List<CounsellorMeetingNote>>(
            future: futureCounsellorMeetingNotes,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      // For each counsellor meeting note, display the camper name, date, and a chevron icon
                      return ListTile(
                        title: Text("${dateFormatter(snapshot.data![index].stNoteDate)}"),
                        subtitle: Text(snapshot.data![index].stNote),
                        trailing: const Icon(Icons.chevron_right),

                        // If not followed up change the background color to a light red
                        onTap: () {
                          // Display the absence details page when the absence is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CounsellorMeetingNoteDetails(counsellorMeetingNote: snapshot.data![index])),
                          ).then((value) {
                            // Refresh the list of absences after returning from the absence details page
                            futureCounsellorMeetingNotes = futureFetchCounsellorMeetingNotes(context);
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

// class FetchCounsellorMeetingNotes extends StatefulWidget {
//   const FetchCounsellorMeetingNotes({super.key});

//   @override
//   State<FetchCounsellorMeetingNotes> createState() => _FetchCounsellorMeetingNotesState();
// }

// class _FetchCounsellorMeetingNotesState extends State<FetchCounsellorMeetingNotes> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         title: const Text('Counsellor Meeting Notes', style: TextStyle(color: globals.secondaryColor)),
//         iconTheme: const IconThemeData(color: globals.secondaryColor),
//         actions: <Widget>[
//           // New counsellor meeting note button
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               // TODO add new counsellor meeting note page
//             },
//           ),
//           // Refresh button
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               // Refresh the list of counsellor meeting notes
//               // TODO add a refresh state
//               setState(() {});
//             },
//           ),
//         ],
//       ),
//       drawer: drawer.drawer(context),
//       body: Column(
//         children: <Widget>[
//           // Display counsellor meeting notes in a list view, future builder waits for the server to return the data
          
//         ],
//       ),
//     );
//   }
// }