import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const Color primaryColor = Colors.red;
const Color secondaryColor = Colors.white;
  
const String title = 'Markham Recreation Summer Camp Administration App';

// const String serverUrl = 'http://10.0.2.2:3000'; //localhost is 10.0.2.2 in the emulator
// const String serverUrl = 'http://localhost:3000';
const serverUrl = "https://markham-recreation.ca";


int userId = -1;
String username = "";
// Current Camp
int campId = -1; //TODO: change this to be dynamic based on the user's camp
String campName = 'Loading'; //TODO: change this to be dynamic based on the user's camp
DateTime startDate = DateTime.now(); //TODO: change this to be dynamic based on the user's camp

// List of available camp // TODO fetch from server
List<Camp> campList = [
//   Camp(id: 1, name: 'Example Camp'),
//   Camp(id: 2, name: 'Another Camp'),
//   Camp(id: 3, name: 'Third Camp'),
];

bool campLoaded = false;

// Fetch camp from server
Future<void> fetchcamp(int attemptNumber) async {
  if (userId == -1) {
    throw Exception('Failed to load camp');
  }
  final response = await session.get(Uri.parse('$serverUrl/api/camp/$userId')).catchError(// TODO error check no camp assigned
    (error) {
      throw Exception('Failed to load camp');
    },
  );
  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    campList = data.map((camp) => Camp.fromJson(camp)).toList();
    campLoaded = true;
    if (campId == -1) {
      campId = campList[0].id;
      campName = campList[0].name;
      startDate = campList[0].startDate;
    }
  } else if (response.statusCode == 401) {
      //redirect to /
      loggedIn = false;
      // retryFuture(fetchcamp, attemptNumber+1);
      // Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); // TODO renable this
    } else {
    throw Exception('Failed to load camp');
  }
}

retryFuture(Future<void> Function(int) function, int attemptNumber) async {
  if (attemptNumber > 5) {
    return;
  }
  await Future.delayed(Duration(milliseconds: 100*attemptNumber), () => function(attemptNumber+1));
}


// TODO refactor to own file
class Camp {
  final int id;
  final String name;
  final DateTime startDate;

  Camp({required this.id, required this.name, required this.startDate});

  factory Camp.fromJson(Map<String, dynamic> json) {
    return Camp(
      id: json['camp_id'],
      name: json['camp_name'],
      startDate: DateTime.parse(json['start_date']),
    );
  }
}

bool loggedIn = false;

class UnauthorisedException implements Exception  {
  UnauthorisedException();
}

class Session {
  Map<String, String> storedHeaders = {};

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    Map<String, String> tempHeaders = Map.from(storedHeaders);
    if (headers != null) {
      tempHeaders.addAll(headers);
    }
    print('Headers: $tempHeaders');
    Future<http.Response> response = http.get(url, headers: tempHeaders);
    response.then((value) => updateCookie(value));
    return response;
  }

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    Map<String, String> tempHeaders = Map.from(storedHeaders);
    if (headers != null) {
      tempHeaders.addAll(headers);
    }
    print('Headers: $tempHeaders');
    Future<http.Response> response = http.post(url, headers: tempHeaders, body: body, encoding: encoding);
    response.then((value) => updateCookie(value));
    return response;
  }

  void updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      print('Cookie: $rawCookie');
      int index = rawCookie.indexOf(';');
      storedHeaders['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
      print(storedHeaders['cookie']);
    }
  }
}

Session session = Session();