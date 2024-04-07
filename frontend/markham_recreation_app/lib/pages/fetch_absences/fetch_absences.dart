library weekly_checklist;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:markham_recreation_app/drawer.dart' as drawer;
import 'package:markham_recreation_app/globals.dart' as globals;

import 'package:markham_recreation_app/pages/fetch_absences/absence.dart';
import 'package:markham_recreation_app/pages/fetch_absences/absence_details.dart';
import 'package:markham_recreation_app/pages/fetch_absences/new_absence.dart';

// global variable to store the request to the server (for FutureBuilder)
late Future<List<Absence>> futureAbsences;

// Fetch absences from the server
Future<List<Absence>> futureFetchAbsences() async {
  final response = await http.get(
    Uri.parse('${globals.serverUrl}/api/get_absences/${globals.camp_id}'),
  );

  // Create List of absences
  List<Absence> absences = [];

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON and store the absences
    List<dynamic> absencesJson = jsonDecode(response.body);
    absences = absencesJson.map((dynamic json) => Absence.fromJson(json)).toList();
    return absences;
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load absences');
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

// List absences page wrapper
class FetchAbsences extends StatefulWidget {
  const FetchAbsences({super.key});

  @override
  State<FetchAbsences> createState() => _FetchAbsencesState();
}

// List absences page content
class _FetchAbsencesState extends State<FetchAbsences> {
  // Fetch list of absences from the server
  @override
  void initState() {
    super.initState();
    futureAbsences = futureFetchAbsences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Absences', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
        actions: <Widget>[
          // New absence button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewAbsence()),
              ).then((value) {
                // Refresh the list of absences after returning from the new absence page
                futureAbsences = futureFetchAbsences();
                setState(() {});
              });
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the list of absences
              futureAbsences = futureFetchAbsences();
              setState(() {});
            },
          ),
        ],
      ),
      drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          // Display absences in a list view, future builder waits for the server to return the data
          FutureBuilder<List<Absence>>(
            future: futureAbsences,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      // For each absence, display the camper name, date, and a chevron icon
                      return ListTile(
                        title: Text("${snapshot.data![index].camperFirstName} ${snapshot.data![index].camperLastName}"),
                        subtitle: Text(dateFormatter(snapshot.data![index].absenceDate)),
                        trailing: const Icon(Icons.chevron_right),

                        // If not followed up change the background color to a light red
                        tileColor: snapshot.data![index].followedUp ? null : const Color.fromARGB(255, 255, 230, 233),
                        onTap: () {
                          // Display the absence details page when the absence is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AbsenceDetails(absence: snapshot.data![index])),
                          ).then((value) {
                            // Refresh the list of absences after returning from the absence details page
                            futureAbsences = futureFetchAbsences();
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
