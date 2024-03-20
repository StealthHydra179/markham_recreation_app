library weekly_checklist;

import 'package:flutter/material.dart';
import 'package:markham_recreation_app/drawer.dart' as drawer;
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:date_field/date_field.dart';

import 'package:markham_recreation_app/globals.dart' as globals;

class FetchAbsences extends StatefulWidget {
  const FetchAbsences({super.key});

  @override
  State<FetchAbsences> createState() => _FetchAbsencesState();
}

Future<List<Absence>> fetchAbsences() async {
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

class _FetchAbsencesState extends State<FetchAbsences> {

  late Future<List<Absence>> absences;

  @override
  void initState() {
    super.initState();
    absences = fetchAbsences();
  }

  @override
  Widget build(BuildContext context) {
    // Update checkbox state

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
            future: absences,
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

  const AbsenceDetails({required this.absence});

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
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('Camper Name: ${absence.camper_name}'),
          ),
          ListTile(
            title: Text('Date: ${absence.date}'),
          ),
          ListTile(
            title: Text('Followed Up: ${absence.followed_up}'),
          ),
          ListTile(
            title: Text('Reason: ${absence.reason}'),
          ),
          ListTile(
            title: Text('Date Modified: ${absence.date_modified}'),
          ),
        ],
      ),
    );
  }
}

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