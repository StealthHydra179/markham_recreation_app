import 'package:flutter/material.dart';

import 'package:markham_recreation_app/drawer.dart' as drawer;
import 'package:markham_recreation_app/globals.dart' as globals;

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_spinbox/material.dart';

class FetchAttendance extends StatefulWidget {
  const FetchAttendance({Key? key}) : super(key: key);

  @override
  State<FetchAttendance> createState() => _FetchAttendanceState();
}

class DailyAttendanceItem {
  final String attendance_date;
  final int attendance_id;
  int? present_count;
  int? before_care_count;
  int? after_care_count;
  final int camper_count;

  DailyAttendanceItem(this.attendance_date, this.attendance_id, this.present_count, this.before_care_count, this.after_care_count, this.camper_count);

  factory DailyAttendanceItem.fromJson(Map<String, dynamic> json) {
    return DailyAttendanceItem(
      json['attendance_date'],
      json['attendance_id'],
      json['present'],
      json['before_care'],
      json['after_care'],
      json['camper_count'],
    );
  }

  Map toJson() {
    return {
      'attendance_id': attendance_id,
      'present': present_count,
      'before_care': before_care_count,
      'after_care': after_care_count,
    };
  }
}


String date_to_day(DateTime date) {
  var days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  return days[date.weekday - 1];
}

class _FetchAttendanceState extends State<FetchAttendance> {
  List<DailyAttendanceItem> attendance = [];

  void _fetch_attendance() async {
    Future<http.Response> response = globals.session.get(
       Uri.parse('${globals.serverUrl}/api/attendance/${globals.campId}'),
     );
     response.then((response) {
       if (response.statusCode == 200) {
         List<dynamic> data = jsonDecode(response.body);

          attendance = data.map((dynamic item) {
            return DailyAttendanceItem.fromJson(item);
          }).toList();
         
        

         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
            content: Text('Attendance loaded'),
            duration: Duration(seconds: 3),
           )
         );
         setState(() {});
       } else if (response.statusCode == 401) {
        globals.loggedIn = false;
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
       } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to Load Attendance'),
            duration: Duration(seconds: 3),
          ),
        );
      }
     });
  }
  
  // Fetch list of attendance from the server
  @override
  void initState() {
    super.initState();
    _fetch_attendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Attendance', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
        actions: <Widget>[
          // New attendance button
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the list of attendance
              // TODO add a refresh state
              _fetch_attendance();
              setState(() {});
            },
          ),
        ],
      ),
      drawer: drawer.drawer(context),
      body: 
      // Column(
      //   children: <Widget>[
      //     // Display checklist in a list view
      //     // Expanded(
      //     //   child: 
      //        SingleChildScrollView(
      //       child: Column(
        Flex(direction: Axis.vertical, children: [
        Expanded(
                // physics: const AlwaysScrollableScrollPhysics(),
              // child: <Widget>[
                child:
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: attendance.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(date_to_day(DateTime.parse(attendance[index].attendance_date))),
                      subtitle: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: SpinBox(
                              value: attendance[index].present_count == null ? 0 : attendance[index].present_count!.toDouble(),
                              min: 0,
                              max: attendance[index].camper_count.toDouble(),
                              onChanged: (value) {
                                attendance[index].present_count = value.toInt();
                              },
                              decoration: InputDecoration(labelText: "Number of campers present on " + date_to_day(DateTime.parse(attendance[index].attendance_date))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: SpinBox(
                              value: attendance[index].before_care_count == null ? 0 : attendance[index].before_care_count!.toDouble(),
                              min: 0,
                              max: attendance[index].camper_count.toDouble(),
                              onChanged: (value) {
                                attendance[index].before_care_count = value.toInt();
                              },
                              decoration: InputDecoration(labelText: "Number of campers in before care on " + date_to_day(DateTime.parse(attendance[index].attendance_date))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: SpinBox(
                              value: attendance[index].after_care_count == null ? 0 : attendance[index].after_care_count!.toDouble(),
                              min: 0,
                              max: attendance[index].camper_count.toDouble(),
                              onChanged: (value) {
                                attendance[index].after_care_count = value.toInt();
                              },
                              decoration: InputDecoration(labelText: "Number of campers in after care on " + date_to_day(DateTime.parse(attendance[index].attendance_date))),
                            ),
                          ),
                        ],
                      ),
                    );


                  },
                ),
        ),  
                const Divider(height: 0),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(10),
                  ),
                  onPressed: () {
                    // Send the checklist to the server
                    Future<http.Response> response = globals.session.post(
                      Uri.parse('${globals.serverUrl}/api/attendance/${globals.campId}'),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode(<String, dynamic>{
                        'camp_id': globals.campId,
                        'attendance': attendance,
                      }),
                    );
                    response.then((http.Response response) {
                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Attendance Saved'),
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
                            content: Text('Failed to Save Attendance'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }).catchError((error, stackTrace) {
                      // Runs when the server is down
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to Load Attendance'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    });
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          // ),
          // ),
      //   ],
      // ),
    );
  }
}