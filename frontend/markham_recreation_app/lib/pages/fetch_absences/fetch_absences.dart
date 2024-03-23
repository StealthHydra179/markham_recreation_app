library weekly_checklist;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:markham_recreation_app/drawer.dart' as drawer;
import 'package:markham_recreation_app/globals.dart' as globals;

import 'absence.dart';
import 'absence_details.dart';
import 'edit_absence.dart';

Future<List<Absence>> futureFetchAbsences() async {
  final response = await http.get(
    Uri.parse('${globals.serverUrl}/api/get_absences/${globals.camp_id}'),
  );

  // Create return list
  List<Absence> absences = [];

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    List<dynamic> absencesJson = jsonDecode(response.body);
    absences = absencesJson.map((dynamic json) => Absence.fromJson(json)).toList();
    return absences;
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load absences');
  }
}

String dateTimeFormatter(String date) {
  // Import form yyyy-mm-ddThh:mm:ss.000Z to mm/dd/yyyy hh:mm
  return '${date.substring(5, 7)}/${date.substring(8, 10)}/${date.substring(0, 4)} ${date.substring(11, 16)}';
}

String dateFormatter(String date) {
  // Import form yyyy-mm-ddThh:mm:ss.000Z to mm/dd/yyyy
  return '${date.substring(5, 7)}/${date.substring(8, 10)}/${date.substring(0, 4)}';
}

late Future<List<Absence>> futureAbsences;

class FetchAbsences extends StatefulWidget {
  const FetchAbsences({super.key});

  @override
  State<FetchAbsences> createState() => _FetchAbsencesState();
}

class _FetchAbsencesState extends State<FetchAbsences> {

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
        title: const Text(
          'Absences',
          style: TextStyle(color: globals.secondaryColor) 
        ),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
      ),
      drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          FutureBuilder<List<Absence>>(
            future: futureAbsences,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data![index].camper_name),
                        subtitle: Text(dateFormatter(snapshot.data![index].date)),
                        trailing: Icon(Icons.chevron_right),
                        // if not followed up change the background color to a light red
                        tileColor: snapshot.data![index].followed_up ? null : Color.fromARGB(255, 255, 230, 233),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AbsenceDetails(absence: snapshot.data![index])),
                          ).then((value) {
                            // if value is not null
                            // reload the page
                            print(value);
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
              return const CircularProgressIndicator();
            },
            ),
        ],
      ),
    );
  }
}
