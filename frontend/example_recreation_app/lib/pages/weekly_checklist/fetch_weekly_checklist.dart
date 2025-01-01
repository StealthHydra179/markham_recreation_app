

// TODO add reload action
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:example_recreation_app/drawer.dart' as drawer;
import 'package:example_recreation_app/globals.dart' as globals;

class FetchWeeklyChecklist extends StatefulWidget {
  const FetchWeeklyChecklist({super.key});

  @override
  State<FetchWeeklyChecklist> createState() => _FetchWeeklyChecklistState();
}

class ChecklistItem {
  final String title;
  final String description;
  final int checklist_id;
  bool value;

  ChecklistItem(this.title, this.description, this.checklist_id, this.value);

  void setValue(bool value) {
    this.value = value;
  }

  bool getValue() {
    return value;
  }

  void toggleValue() {
    value = !value;
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      json['checklist_name'],
      json['checklist_description'],
      json['checklist_id'],
      json['checklist_status'],
    );
  }

  Map toJson() {
    return {
      'checklist_id': checklist_id,
      'checklist_status': value,
    };
  }
}

class _FetchWeeklyChecklistState extends State<FetchWeeklyChecklist> {
  List<ChecklistItem> checklist = [];

  void _fetch_checklist() async {
    Future<http.Response> response = globals.session.get(
      Uri.parse('${globals.serverUrl}/api/weekly_checklist/${globals.campId}'),
    );
    response.then((http.Response response) {
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        checklist.clear();
        print(data[0]['checklist_status']);
        for (int i = 0; i < data.length; i++) {
          if (!data[i]['checklist_active']) {
            continue;
          }
          checklist.add(ChecklistItem.fromJson(data[i]));
        }
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weekly Checklist Loaded'),
            duration: Duration(seconds: 3),
            //TODO edit the state of the checkboxes to match the response
          ),
        );
      } else if (response.statusCode == 401) {
        //redirect to /
        globals.loggedIn = false;
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to Load Weekly Checklist'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }).catchError((error, stackTrace) {
      print(stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _fetch_checklist();
  }

  @override
  Widget build(BuildContext context) {
    // Update checkbox state

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Weekly Checklist', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
        actions: <Widget>[
          // New attendance button
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the list of attendance
              // TODO add a refresh state
              _fetch_checklist();
              setState(() {});
            },
          ),
        ],
      ),
      drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          // Display checklist in a list view
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListView.builder(
                  itemCount: checklist.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      value: checklist[index].getValue(),
                      onChanged: (bool? value) {
                        setState(() {
                          checklist[index].toggleValue();
                        });
                      },
                      title: Text(checklist[index].title),
                      subtitle: Text(checklist[index].description),
                    );
                  },
                ),
                // ),

                const Divider(height: 0),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(10),
                  ),
                  onPressed: () {
                    // Send the checklist to the server
                    Future<http.Response> response = globals.session.post(
                      Uri.parse('${globals.serverUrl}/api/weekly_checklist/${globals.campId}'),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode(<String, dynamic>{
                        'camp_id': globals.campId,
                        'checklist': checklist,
                      }),
                    );
                    response.then((http.Response response) {
                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Weekly Checklist Saved'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      } else if (response.statusCode == 401) {
                        //redirect to /
                        globals.loggedIn = false;
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to Save Weekly Checklist'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }).catchError((error, stackTrace) {
                      // Runs when the server is down
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to Load Weekly Checklist'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    });
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
