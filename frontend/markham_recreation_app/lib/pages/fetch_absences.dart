library weekly_checklist;

import 'package:date_field/date_field.dart';
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

late Future<List<Absence>> futureAbsences;

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);// TODO figure out why it doesnt force build anymore
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // edit page
              // open a new version of new_absence but with the fields filled in and the error messages be tailored towards editing
              // send put request to server
              // if successful, update the page
              // if not, show error message 

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditAbsence(absence: absence)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              //TODO add delete function
              // send delete request to server
              // if successful, pop the page
              // if not, show error message

              //post request to delete_absence
              Future<http.Response> response = http.post(
                Uri.parse('${globals.serverUrl}/api/delete_absence/${globals.camp_id}'),//+globals.camp_id.toString()
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(<String, String>{
                  'absent_id': absence.absent_id.toString(),
                }),
              );

              response.then((http.Response response) {
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deleted Absence'),
                      duration: Duration(seconds: 3),
                    ),
                  );

                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Delete Absence'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }).catchError((error, stackTrace) {
                // Runs when the server is down
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to Delete Absence'),
                    duration: Duration(seconds: 3),
                  ),
                );
              });
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
            // if not followed up change the background color to a light red
            tileColor: absence.followed_up ? null : Color.fromARGB(255, 255, 230, 233),
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

class EditAbsence extends StatefulWidget {
  final Absence absence;

  const EditAbsence({super.key, required this.absence});

  @override
  State<EditAbsence> createState() => _EditAbsenceState();
}

class _EditAbsenceState extends State<EditAbsence> {
  bool followedUp = false;
  DateTime? selectedDate;

  final TextEditingController _name_controller = TextEditingController();
  final TextEditingController _notes_controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name_controller.text = widget.absence.camper_name;
    _notes_controller.text = widget.absence.reason;
    followedUp = widget.absence.followed_up;
    selectedDate = DateTime.parse(widget.absence.date);
  }

  @override
  Widget build(BuildContext context) {
    // Update checkbox state

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        
        title: const Text(
          'Edit Absence',
          style: TextStyle(color: globals.secondaryColor) 
        ),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
      ),
      // drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          Container( 
            margin: const EdgeInsets.all(10),
            child:  SizedBox(
              child: TextField(
                controller: _name_controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Camper Name',
                ),
              ),
            ),
          ),
            Container( 
              margin: const EdgeInsets.all(10),
              child: SizedBox(
                child: DateTimeFormField(
                  decoration: const InputDecoration(
                    labelText: 'Enter Date',
                  ),
                  mode: DateTimeFieldPickerMode.date,
                  firstDate: DateTime.now().add(const Duration(days: -7)),
                  lastDate: DateTime.now().add(const Duration(days: 7)),
                  initialPickerDateTime: DateTime.now().add(const Duration(days: 0)),
                  onChanged: (DateTime? value) {
                    selectedDate = value;
                  },
                ),
              ),
            ),
            
          CheckboxListTile(
            value: followedUp,
            onChanged: (bool? value) {
              setState(() {
                followedUp = value!;
              });
            },
            // TODO add descriptions to make it clear what each checkbox is for?
            title: const Text('Followed Up?'),
          ),
          if (followedUp)
            //Text entry widget
            Container( 
              margin: const EdgeInsets.all(10),
              child:  SizedBox(
                child: TextField(
                  controller: _notes_controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Notes',
                  ),
                ),
              ),
            ),

          const Divider(height: 0),
        
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(10),
            ),
            onPressed: () {
              // TODO input validation
              if (_name_controller.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a name'),
                    duration: Duration(seconds: 3),
                  ),
                );
                return;
              }

              if (selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a date'),
                    duration: Duration(seconds: 3),
                  ),
                );
                return;
              }

              if (followedUp && _notes_controller.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter notes'),
                    duration: Duration(seconds: 3),
                  ),
                );
                return;
              }

              print(widget.absence.absent_id);

              // Send the checklist to the server
              Future<http.Response> response = http.post(
                Uri.parse('${globals.serverUrl}/api/edit_absence/${globals.camp_id}'),//+globals.camp_id.toString()
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                /*
                'absent_id': int absent_id,
            'camp_id': int camp_id,
            'camper_name': String camper_name,
            'date': String date,
            'followed_up': bool followed_up,
            'reason': String reason,
            'date_modified': String date_modified,
            */
                body: jsonEncode(<String, String>{
                  'absent_id': widget.absence.absent_id.toString(), 
                  'camp_id': widget.absence.camp_id.toString(),
                  'camper_name': _name_controller.text,
                  'date': selectedDate.toString(),
                  'followed_up': followedUp.toString(),
                  'reason': _notes_controller.text,
                  'date_modified': DateTime.now().toString(),
                }),
              );
              response.then((http.Response response) {
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edited Absence'),
                      duration: Duration(seconds: 3),
                    ),
                  );

                  futureFetchAbsences().then((absences) {
                    Navigator.pop(context); //TODO not sure if this works yet
                    Navigator.pop(context);
                    //readd the current absence page
                    Absence absence = new Absence(absent_id: 0, camp_id: 0, camper_name: '', date: '', followed_up: false, reason: '', date_modified: '');
                    //find the absence in the list
                    for (int i = 0; i < absences.length; i++) {
                      if (absences[i].absent_id == widget.absence.absent_id) {
                        absence = absences[i];
                        break;
                      }
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AbsenceDetails(absence: absence)),);
                  });
                  
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Edit Absence'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }).catchError((error, stackTrace) {
                // Runs when the server is down
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to Edit Absence'),
                    duration: Duration(seconds: 3),
                  ),
                );
              });
            },
            child: const Text('Save'),
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