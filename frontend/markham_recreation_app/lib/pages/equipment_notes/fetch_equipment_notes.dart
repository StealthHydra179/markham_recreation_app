library weekly_checklist;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:markham_recreation_app/drawer.dart' as drawer;
import 'package:markham_recreation_app/globals.dart' as globals;

import 'package:markham_recreation_app/pages/equipment_notes/equipment_note.dart';
import 'package:markham_recreation_app/pages/equipment_notes/new_equipment_note.dart';
import 'package:markham_recreation_app/pages/equipment_notes/equipment_note_details.dart';

// global variable to store the request to the server (for FutureBuilder)
late Future<List<EquipmentNote>> futureEquipmentNotes;

// Fetch equipment notes from the server
Future<List<EquipmentNote>> futureFetchEquipmentNotes() async {
  final response = await http.get(
    Uri.parse('${globals.serverUrl}/api/get_equipment_notes/${globals.campId}'),
  );

  // Create List of equipment notes
  List<EquipmentNote> equipmentNotes = [];

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON and store the Equipment Notes
    List<dynamic> equipmentNotesJson = jsonDecode(response.body);
    equipmentNotes = equipmentNotesJson.map((dynamic json) => EquipmentNote.fromJson(json)).toList();
    return equipmentNotes;
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load equipment notes');
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

// List equipment notes page wrapper
class FetchEquipmentNotes extends StatefulWidget {
  const FetchEquipmentNotes({super.key});

  @override
  State<FetchEquipmentNotes> createState() => _FetchEquipmentNotesState();
}

// List equipment notes page content
class _FetchEquipmentNotesState extends State<FetchEquipmentNotes> {
  // Fetch list of equipment notes from the server
  @override
  void initState() {
    super.initState();
    futureEquipmentNotes = futureFetchEquipmentNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Equipment Notes', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
        actions: <Widget>[
          // New equipment note button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewEquipmentNote()),
              ).then((value) {
                // Refresh the list of equipment notes after returning from the new equipment note page
                futureEquipmentNotes = futureFetchEquipmentNotes();
                setState(() {});
              });
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the list of equipment notes
              futureEquipmentNotes = futureFetchEquipmentNotes();
              setState(() {});
            },
          ),
        ],
      ),
      drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          // Display equipment notes in a list view, future builder waits for the server to return the data
          FutureBuilder<List<EquipmentNote>>(
            future: futureEquipmentNotes,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      // For each equipment note, display the camper name, date, and a chevron icon
                      return ListTile(
                        title: Text("${dateTimeFormatter(snapshot.data![index].equipNoteDate)}"),
                        subtitle: Text(snapshot.data![index].equipNote),
                        trailing: const Icon(Icons.chevron_right),

                        // If not followed up change the background color to a light red
                        onTap: () {
                          // Display the absence details page when the absence is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EquipmentNoteDetails(equipmentNote: snapshot.data![index])),
                          ).then((value) {
                            // Refresh the list of absences after returning from the absence details page
                            futureEquipmentNotes = futureFetchEquipmentNotes();
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

// class FetchEquipmentNotes extends StatefulWidget {
//   const FetchEquipmentNotes({super.key});

//   @override
//   State<FetchEquipmentNotes> createState() => _FetchEquipmentNotesState();
// }

// class _FetchEquipmentNotesState extends State<FetchEquipmentNotes> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         title: const Text('Equipment Notes', style: TextStyle(color: globals.secondaryColor)),
//         iconTheme: const IconThemeData(color: globals.secondaryColor),
//         actions: <Widget>[
//           // New equipment note button
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               // TODO add new equipment note page
//             },
//           ),
//           // Refresh button
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               // Refresh the list of equipment notes
//               // TODO add a refresh state
//               setState(() {});
//             },
//           ),
//         ],
//       ),
//       drawer: drawer.drawer(context),
//       body: Column(
//         children: <Widget>[
//           // Display equipment notes in a list view, future builder waits for the server to return the data
          
//         ],
//       ),
//     );
//   }
// }