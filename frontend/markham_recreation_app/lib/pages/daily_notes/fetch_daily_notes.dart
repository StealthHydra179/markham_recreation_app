

import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:markham_recreation_app/drawer.dart' as drawer;
import 'package:markham_recreation_app/globals.dart' as globals;

import 'package:markham_recreation_app/pages/daily_notes/daily_note.dart';
import 'package:markham_recreation_app/pages/daily_notes/new_daily_note.dart';
import 'package:markham_recreation_app/pages/daily_notes/daily_note_details.dart';

// global variable to store the request to the server (for FutureBuilder)
late Future<List<DailyNote>> futureDailyNotes;

// Fetch daily notes from the server
Future<List<DailyNote>> futureFetchDailyNotes(context) async {
  final response = await globals.session.get(
    Uri.parse('${globals.serverUrl}/api/get_daily_notes/${globals.campId}'),
  );

  // Create List of daily notes
  List<DailyNote> dailyNotes = [];

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON and store the Daily Notes
    List<dynamic> dailyNotesJson = jsonDecode(response.body);
    dailyNotes = dailyNotesJson.map((dynamic json) => DailyNote.fromJson(json)).toList();
    return dailyNotes;
  } else if (response.statusCode == 401) {
        //redirect to /
    globals.loggedIn = false;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    return dailyNotes;
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load daily notes');
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

// List daily notes page wrapper
class FetchDailyNotes extends StatefulWidget {
  const FetchDailyNotes({super.key});

  @override
  State<FetchDailyNotes> createState() => _FetchDailyNotesState();
}

// List daily notes page content
class _FetchDailyNotesState extends State<FetchDailyNotes> {
  // Fetch list of daily notes from the server
  @override
  void initState() {
    super.initState();
    futureDailyNotes = futureFetchDailyNotes(context);
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewDailyNote()),
              ).then((value) {
                // Refresh the list of daily notes after returning from the new daily note page
                futureDailyNotes = futureFetchDailyNotes(context);
                setState(() {});
              });
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the list of daily notes
              futureDailyNotes = futureFetchDailyNotes(context);
              setState(() {});
            },
          ),
        ],
      ),
      drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          // Display daily notes in a list view, future builder waits for the server to return the data
          FutureBuilder<List<DailyNote>>(
            future: futureDailyNotes,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      // For each daily note, display the camper name, date, and a chevron icon
                      return ListTile(
                        title: Text("${dateTimeFormatter(snapshot.data![index].inNoteDate)}"),
                        subtitle: Text(snapshot.data![index].inNote),
                        trailing: const Icon(Icons.chevron_right),

                        // If not followed up change the background color to a light red
                        onTap: () {
                          // Display the absence details page when the absence is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DailyNoteDetails(dailyNote: snapshot.data![index])),
                          ).then((value) {
                            // Refresh the list of absences after returning from the absence details page
                            futureDailyNotes = futureFetchDailyNotes(context);
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

// class FetchDailyNotes extends StatefulWidget {
//   const FetchDailyNotes({super.key});

//   @override
//   State<FetchDailyNotes> createState() => _FetchDailyNotesState();
// }

// class _FetchDailyNotesState extends State<FetchDailyNotes> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         title: const Text('Daily Notes', style: TextStyle(color: globals.secondaryColor)),
//         iconTheme: const IconThemeData(color: globals.secondaryColor),
//         actions: <Widget>[
//           // New daily note button
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               // TODO add new daily note page
//             },
//           ),
//           // Refresh button
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               // Refresh the list of daily notes
//               // TODO add a refresh state
//               setState(() {});
//             },
//           ),
//         ],
//       ),
//       drawer: drawer.drawer(context),
//       body: Column(
//         children: <Widget>[
//           // Display daily notes in a list view, future builder waits for the server to return the data
          
//         ],
//       ),
//     );
//   }
// }