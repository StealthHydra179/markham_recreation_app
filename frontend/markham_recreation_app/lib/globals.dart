import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const Color primaryColor = Colors.red;
const Color secondaryColor = Colors.white;

const String title = 'Markham Recreation Summer Camp Administration App';

const String serverUrl = 'http://10.0.2.2:3000'; //localhost is 10.0.2.2 in the emulator
// const String serverUrl = 'http://localhost:3000';

// Current Camp
int camp_id = -1; //TODO: change this to be dynamic based on the user's camp
String campName = 'Loading'; //TODO: change this to be dynamic based on the user's camp

// List of available camp // TODO fetch from server
List<Camp> campList = [
//   Camp(id: 1, name: 'Example Camp'),
//   Camp(id: 2, name: 'Another Camp'),
//   Camp(id: 3, name: 'Third Camp'),
];

bool campLoaded = false;

// Fetch camp from server
Future<void> fetchcamp() async {
  final response = await http.get(Uri.parse('$serverUrl/api/camp/0')).catchError(
    (error) {
      throw Exception('Failed to load camp');
    },
  );
  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    campList = data.map((camp) => Camp.fromJson(camp)).toList();
    campLoaded = true;
    if (camp_id == -1) {
      camp_id = campList[0].id;
      campName = campList[0].name;
    }
  } else {
    throw Exception('Failed to load camp');
  }
}

class Camp {
  final int id;
  final String name;

  Camp({required this.id, required this.name});

  factory Camp.fromJson(Map<String, dynamic> json) {
    return Camp(
      id: json['camp_id'],
      name: json['camp_name'],
    );
  }
}