import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const Color primaryColor = Colors.red;
const Color secondaryColor = Colors.white;

const String title = 'Camp Administration Application';

// Select the correct server URL based on the platform
// Android emulator: 10.0.2.2:3000
// Web: localhost:3000
// Deployed: example-recreation.ca
const String serverUrl = 'http://10.0.2.2:3000';
// const String serverUrl = 'http://localhost:3000';
// const serverUrl = "https://example-recreation.ca";

// The first week of the camp, all dates will be initialized relative to here.
DateTime firstWeek = DateTime.parse('2024-07-02');

// Logged in user information
int userId = -1;
String username = "";
// Current viewed camp information
int campId = -1;
String campName = 'Loading';
DateTime startDate = DateTime.now();
String facilityName = 'Loading';
int weekNumber = 1;

// List of available camps to the user
List<Camp> campList = [];

// Whether the camp has been loaded from the server
bool campLoaded = false;

// Fetch camp from server
Future<void> fetchcamp(int attemptNumber) async {
  if (userId == -1) {
    throw Exception('Failed to load camp');
  }

  // Send a GET request to the server to get the camp information
  final response = await session.get(Uri.parse('$serverUrl/api/camp/$userId')).catchError(
    (error) {
      throw Exception('Failed to load camp');
    },
  );
  if (response.statusCode == 200) {
    // If the server returns an OK response, parse the JSON and store the camp information
    List<dynamic> data = jsonDecode(response.body);
    campList = data.map((camp) => Camp.fromJson(camp)).toList();
    campLoaded = true;

    // If the camp has not been selected, select the first camp in the list
    if (campId == -1) {
      campId = campList[0].id;
      campName = campList[0].name;
      startDate = campList[0].startDate;
      facilityName = campList[0].facilityName;
      weekNumber = ((startDate.difference(firstWeek).inDays) / 7).ceil();
    }
  } else if (response.statusCode == 401) {
    // If the server returns an unauthorized response, the user is not logged in,
    // the app will prompt the user to log in on the next interaction
    loggedIn = false;
  } else {
    throw Exception('Failed to load camp');
  }
}

// Camp class to store camp information
class Camp {
  final int id;
  final String name;
  final DateTime startDate;
  final String facilityName;
  final int weekNumber;

  Camp({required this.id, required this.name, required this.startDate, required this.facilityName, required this.weekNumber});

  // Parse JSON data to create a camp object
  factory Camp.fromJson(Map<String, dynamic> json) {
    return Camp(
      id: json['camp_id'],
      name: json['camp_name'],
      startDate: DateTime.parse(json['start_date']),
      facilityName: json['facility_name'],
      weekNumber: ((DateTime.parse(json['start_date']).difference(firstWeek).inDays) / 7).ceil(),
    );
  }
}

// ----------------------------
// Session management
// ----------------------------

// Whether the user is logged in
bool loggedIn = false;

// Exception for unauthorized access
class UnauthorisedException implements Exception {
  UnauthorisedException();
}

// Session class to manage HTTP requests
class Session {
  Map<String, String> storedHeaders = {};

  // Send a GET request with the stored headers
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    Map<String, String> tempHeaders = Map.from(storedHeaders);
    if (headers != null) {
      tempHeaders.addAll(headers);
    }
    Future<http.Response> response = http.get(url, headers: tempHeaders);
    response.then((value) => updateCookie(value));
    return response;
  }

  // Send a POST request with the stored headers
  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    Map<String, String> tempHeaders = Map.from(storedHeaders);
    if (headers != null) {
      tempHeaders.addAll(headers);
    }
    Future<http.Response> response = http.post(url, headers: tempHeaders, body: body, encoding: encoding);
    response.then((value) => updateCookie(value));
    return response;
  }

  // Update the stored headers with the cookie from the response
  void updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      storedHeaders['cookie'] = (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }
}

// Global session object to manage HTTP requests
Session session = Session();


// Format the date from yyyy-mm-ddThh:mm:ss.000Z to mm/dd/yyyy
String dateFormatter(String date) {
  return '${date.substring(5, 7)}/${date.substring(8, 10)}/${date.substring(0, 4)}';
}