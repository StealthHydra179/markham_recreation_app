import 'package:flutter/material.dart';

import 'package:example_recreation_app/drawer.dart' as drawer;
import 'package:example_recreation_app/globals.dart' as globals;

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_spinbox/material.dart';

class FetchCampInformation extends StatefulWidget {
  const FetchCampInformation({Key? key}) : super(key: key);

  @override
  State<FetchCampInformation> createState() => _FetchCampInformationState();
}

class CampItem {
  int numberOfCampers;

  CampItem(this.numberOfCampers);

  factory CampItem.fromJson(Map<String, dynamic> json) {
    return CampItem(
      json['camper_count'],
    );
  }

  Map toJson() {
    return {
      'camper_count': numberOfCampers,
    };
  }
}

class _FetchCampInformationState extends State<FetchCampInformation> {
  CampItem? campItem;

  void _fetch_camp_information() async {
    Future<http.Response> response = globals.session.get(
        Uri.parse('${globals.serverUrl}/api/campers/${globals.campId}'));
    response.then((value) {
      if (value.statusCode == 200) {
        setState(() {
          campItem = CampItem.fromJson(jsonDecode(value.body));
        });
      } else {
        throw Exception('Failed to load camp information');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetch_camp_information();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Camp Information', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: IconThemeData(color: globals.secondaryColor),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetch_camp_information();
              setState(() {
                
              });
            },
          ),
        ],
      ),
      drawer: drawer.drawer(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              SpinBox(
                value: campItem?.numberOfCampers.toDouble() ?? 0,
                min: 0,
                // max: 100,
                onChanged: (value) {
                  campItem?.numberOfCampers = value.toInt();
                },
                decoration: const InputDecoration(
                  labelText: 'Number of Campers',
                ),
              ),
              const Divider(height: 0),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(10),
                ),
                onPressed: () {
                    Future<http.Response> response = globals.session.post(
                      Uri.parse('${globals.serverUrl}/api/campers/${globals.campId}'),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode(<String, dynamic>{
                        'camp_id': globals.campId,
                        'campers': campItem?.numberOfCampers,
                      }),
                    );
                    response.then((http.Response response) {
                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Campers Saved'),
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
                            content: Text('Failed to Save Campers'),
                            duration: Duration(seconds: 3),
                          ),
                          //print error
                          
                        );
                      }
                    }).catchError((error, stackTrace) {
                      // Runs when the server is down
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to Load Campers'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    });
                  },
                  child: const Text('Save'),
              )
            
            ],
          ),
        ),
      ),
    
    );
  }
}