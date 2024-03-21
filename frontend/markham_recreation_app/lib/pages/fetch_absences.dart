library weekly_checklist;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:markham_recreation_app/drawer.dart' as drawer;
import 'package:markham_recreation_app/globals.dart' as globals;

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

class FetchAbsences extends StatefulWidget {
  const FetchAbsences({super.key});

  @override
  State<FetchAbsences> createState() => _FetchAbsencesState();
}

class _FetchAbsencesState extends State<FetchAbsences> {
  late Future<List<Absence>> futureAbsences;

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
                        subtitle: Text(snapshot.data![index].date.toString()),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AbsenceDetails(absence: snapshot.data![index])),
                          );
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

class AbsenceDetails extends StatelessWidget {
  final Absence absence;

  const AbsenceDetails({super.key, required this.absence});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        
        title: const Text(
          'Absence Details',
          style: TextStyle(color: globals.secondaryColor) 
        ),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
        //add edit and delete buttons
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              //TODO add edit page
              // open a new version of new_absence but with the fields filled in and the error messages be tailored towards editing
              // send put request to server
              // if successful, update the page
              // if not, show error message 
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              //TODO add delete function
              // send delete request to server
              // if successful, pop the page
              // if not, show error message

            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('Camper Name: ${absence.camper_name}'),
          ),
          ListTile(
            title: Text('Date: ${dateFormatter(absence.date)}'),
          ),
          ListTile(
            title: Text('Followed Up: ${absence.followed_up ? 'yes' : 'no'}'),
          ),
          ListTile(
            title: Text('Reason: ${absence.reason}'),
          ),
          ListTile(
            title: Text('Date Modified: ${dateTimeFormatter(absence.date_modified)}'),
          ),
        ],
      ),
    );
  }
}

// TODO add modified by field to absence
class Absence {
  final int absent_id;
  final int camp_id;
  final String camper_name;
  final String date;
  final bool followed_up;
  final String reason;
  final String date_modified;

  const Absence({
    required this.absent_id,
    required this.camp_id,
    required this.camper_name,
    required this.date,
    required this.followed_up,
    required this.reason,
    required this.date_modified,
  });

  factory Absence.fromJson(Map<String, dynamic> json) {
    //log the json
    print(json);
    print(json['date']);
    print(json['followed_up'] is bool);
    return switch (json) {
      {
            'absent_id': int absent_id,
            'camp_id': int camp_id,
            'camper_name': String camper_name,
            'date': String date,
            'followed_up': bool followed_up,
            'reason': String reason,
            'date_modified': String date_modified,
      } => 
      Absence(
        absent_id: absent_id,
        camp_id: camp_id,
        camper_name: camper_name,
        date: date,
        followed_up: followed_up,
        reason: reason,
        date_modified: date_modified,
      ), 
      _ => throw const FormatException('Unexpected JSON type'),
    };
  }
}