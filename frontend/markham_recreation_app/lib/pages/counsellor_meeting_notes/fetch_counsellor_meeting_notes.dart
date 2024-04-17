library weekly_checklist;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:markham_recreation_app/drawer.dart' as drawer;
import 'package:markham_recreation_app/globals.dart' as globals;

import 'package:markham_recreation_app/pages/counsellor_meeting_notes/counsellor_meeting_note.dart';
import 'package:markham_recreation_app/pages/counsellor_meeting_notes/new_counsellor_meeting_note.dart';
import 'package:markham_recreation_app/pages/counsellor_meeting_notes/counsellor_meeting_note_details.dart';

// global variable to store the request to the server (for FutureBuilder)
late Future<List<CounsellorMeetingNote>> futureCounsellorMeetingNotes;

// Fetch counsellor meeting notes from the server
Future<List<CounsellorMeetingNote>> futureFetchCounsellorMeetingNotes() async {
  final response = await http.get(
    Uri.parse('${globals.serverUrl}/api/get_counsellor_meeting_notes/${globals.campId}'),
  );

  // Create List of counsellor meeting notes
  List<CounsellorMeetingNote> counsellorMeetingNotes = [];

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON and store the Counsellor Meeting Notes
    List<dynamic> counsellorMeetingNotesJson = jsonDecode(response.body);
    counsellorMeetingNotes = counsellorMeetingNotesJson.map((dynamic json) => CounsellorMeetingNote.fromJson(json)).toList();
    return counsellorMeetingNotes;
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load counsellor meeting notes');
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
    futureCounsellorMeetingNotes = futureFetchCounsellorMeetingNotes();
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
                futureCounsellorMeetingNotes = futureFetchCounsellorMeetingNotes();
                setState(() {});
              });
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the list of counsellor meeting notes
              futureCounsellorMeetingNotes = futureFetchCounsellorMeetingNotes();
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
                        title: Text("${dateTimeFormatter(snapshot.data![index].stNoteDate)}"),
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
                            futureCounsellorMeetingNotes = futureFetchCounsellorMeetingNotes();
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







// library weekly_checklist;

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