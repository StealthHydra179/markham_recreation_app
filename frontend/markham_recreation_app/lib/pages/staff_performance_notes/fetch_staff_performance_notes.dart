

import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:markham_recreation_app/drawer.dart' as drawer;
import 'package:markham_recreation_app/globals.dart' as globals;

import 'package:markham_recreation_app/pages/staff_performance_notes/staff_performance_note.dart';
import 'package:markham_recreation_app/pages/staff_performance_notes/new_staff_performance_note.dart';
import 'package:markham_recreation_app/pages/staff_performance_notes/staff_performance_note_details.dart';

// global variable to store the request to the server (for FutureBuilder)
late Future<List<StaffPerformanceNote>> futureStaffPerformanceNotes;

// Fetch staff performance notes from the server
Future<List<StaffPerformanceNote>> futureFetchStaffPerformanceNotes(context) async {
  final response = await globals.session.get(
    Uri.parse('${globals.serverUrl}/api/get_staff_performance_notes/${globals.campId}'),
  );

  // Create List of staff performance notes
  List<StaffPerformanceNote> staffPerformanceNotes = [];

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON and store the Staff performance Notes
    List<dynamic> staffPerformanceNotesJson = jsonDecode(response.body);
    staffPerformanceNotes = staffPerformanceNotesJson.map((dynamic json) => StaffPerformanceNote.fromJson(json)).toList();
    return staffPerformanceNotes;
  } else if (response.statusCode == 401) {
    //redirect to /
    globals.loggedIn = false;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    return staffPerformanceNotes;
  
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load staff performance notes');
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

// List staff performance notes page wrapper
class FetchStaffPerformanceNotes extends StatefulWidget {
  const FetchStaffPerformanceNotes({super.key});

  @override
  State<FetchStaffPerformanceNotes> createState() => _FetchStaffPerformanceNotesState();
}

// List staff performance notes page content
class _FetchStaffPerformanceNotesState extends State<FetchStaffPerformanceNotes> {
  // Fetch list of staff performance notes from the server
  @override
  void initState() {
    super.initState();
    futureStaffPerformanceNotes = futureFetchStaffPerformanceNotes(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Staff performance Notes', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
        actions: <Widget>[
          // New staff performance note button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewStaffPerformanceNote()),
              ).then((value) {
                // Refresh the list of staff performance notes after returning from the new staff performance note page
                futureStaffPerformanceNotes = futureFetchStaffPerformanceNotes(context);
                setState(() {});
              });
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the list of staff performance notes
              futureStaffPerformanceNotes = futureFetchStaffPerformanceNotes(context);
              setState(() {});
            },
          ),
        ],
      ),
      drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          // Display staff performance notes in a list view, future builder waits for the server to return the data
          FutureBuilder<List<StaffPerformanceNote>>(
            future: futureStaffPerformanceNotes,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      // For each staff performance note, display the camper name, date, and a chevron icon
                      return ListTile(
                        title: Text("${dateTimeFormatter(snapshot.data![index].stNoteDate)}"),
                        subtitle: Text(snapshot.data![index].stNote),
                        trailing: const Icon(Icons.chevron_right),

                        // If not followed up change the background color to a light red
                        onTap: () {
                          // Display the absence details page when the absence is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => StaffPerformanceNoteDetails(staffPerformanceNote: snapshot.data![index])),
                          ).then((value) {
                            // Refresh the list of absences after returning from the absence details page
                            futureStaffPerformanceNotes = futureFetchStaffPerformanceNotes(context);
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

// class FetchStaffPerformanceNotes extends StatefulWidget {
//   const FetchStaffPerformanceNotes({super.key});

//   @override
//   State<FetchStaffPerformanceNotes> createState() => _FetchStaffPerformanceNotesState();
// }

// class _FetchStaffPerformanceNotesState extends State<FetchStaffPerformanceNotes> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         title: const Text('Staff performance Notes', style: TextStyle(color: globals.secondaryColor)),
//         iconTheme: const IconThemeData(color: globals.secondaryColor),
//         actions: <Widget>[
//           // New staff performance note button
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               // TODO add new staff performance note page
//             },
//           ),
//           // Refresh button
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               // Refresh the list of staff performance notes
//               // TODO add a refresh state
//               setState(() {});
//             },
//           ),
//         ],
//       ),
//       drawer: drawer.drawer(context),
//       body: Column(
//         children: <Widget>[
//           // Display staff performance notes in a list view, future builder waits for the server to return the data
          
//         ],
//       ),
//     );
//   }
// }