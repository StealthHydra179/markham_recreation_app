

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:markham_recreation_app/drawer.dart' as drawer;
import 'package:markham_recreation_app/globals.dart' as globals;

import 'package:markham_recreation_app/pages/message_board/message.dart';
import 'package:markham_recreation_app/pages/message_board/new_message.dart';
import 'package:markham_recreation_app/pages/message_board/message_details.dart';

// global variable to store the request to the server (for FutureBuilder)
late Future<List<MessageBoard>> futureMessageBoards;

// Fetch messages from the server
Future<List<MessageBoard>> futureFetchMessageBoards(context) async {
  final response = await globals.session.get(
    Uri.parse('${globals.serverUrl}/api/get_messages/${globals.campId}'),
  );

  // Create List of messages
  List<MessageBoard> messageBoards = [];

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON and store the Messages
    List<dynamic> messageBoardsJson = jsonDecode(response.body);
    messageBoards = messageBoardsJson.map((dynamic json) => MessageBoard.fromJson(json)).toList();
    return messageBoards;
  } else if (response.statusCode == 401) {
    //redirect to /
    globals.loggedIn = false;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    return messageBoards;
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load messages');
  }
}
// Format datetime string into a date and a time
String dateTimeFormatter(String date) {
  // Import form yyyy-mm-ddThh:mm:ss.000Z to mm/dd/yyyy hh:mm
  final DateFormat formatter = DateFormat('MM/dd/yyyy HH:mm');
  return formatter.format(DateTime.parse(date).add(DateTime.now().timeZoneOffset));
}

// Format datetime string into a date
String dateFormatter(String date) {
  // Import form yyyy-mm-ddThh:mm:ss.000Z to mm/dd/yyyy
  return '${date.substring(5, 7)}/${date.substring(8, 10)}/${date.substring(0, 4)}';
}

// List messages page wrapper
class FetchMessageBoards extends StatefulWidget {
  const FetchMessageBoards({super.key});

  @override
  State<FetchMessageBoards> createState() => _FetchMessageBoardsState();
}

// List messages page content
class _FetchMessageBoardsState extends State<FetchMessageBoards> {
  // Fetch list of messages from the server
  @override
  void initState() {
    super.initState();
    futureMessageBoards = futureFetchMessageBoards(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Messages', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
        actions: <Widget>[
          // New message button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewMessageBoard()),
              ).then((value) {
                // Refresh the list of messages after returning from the new message page
                futureMessageBoards = futureFetchMessageBoards(context);
                setState(() {});
              });
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the list of messages
              futureMessageBoards = futureFetchMessageBoards(context);
              setState(() {});
            },
          ),
        ],
      ),
      drawer: drawer.drawer(context),
      body: Column(
        children: <Widget>[
          // Display messages in a list view, future builder waits for the server to return the data
          FutureBuilder<List<MessageBoard>>(
            future: futureMessageBoards,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      // For each message, display the camper name, date, and a chevron icon
                      return ListTile(
                        title: Text("${dateTimeFormatter(snapshot.data![index].inNoteDate)}"),
                        subtitle: Text(snapshot.data![index].inNote),
                        trailing: const Icon(Icons.chevron_right),

                        // If not followed up change the background color to a light red
                        onTap: () {
                          // Display the absence details page when the absence is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MessageBoardDetails(messageBoard: snapshot.data![index])),
                          ).then((value) {
                            // Refresh the list of absences after returning from the absence details page
                            futureMessageBoards = futureFetchMessageBoards(context);
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
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }
}







// 

// import 'package:flutter/material.dart';

// import 'package:markham_recreation_app/globals.dart' as globals;
// import 'package:markham_recreation_app/drawer.dart' as drawer;

// class FetchMessageBoards extends StatefulWidget {
//   const FetchMessageBoards({super.key});

//   @override
//   State<FetchMessageBoards> createState() => _FetchMessageBoardsState();
// }

// class _FetchMessageBoardsState extends State<FetchMessageBoards> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         title: const Text('Messages', style: TextStyle(color: globals.secondaryColor)),
//         iconTheme: const IconThemeData(color: globals.secondaryColor),
//         actions: <Widget>[
//           // New message button
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               // TODO add new message page
//             },
//           ),
//           // Refresh button
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               // Refresh the list of messages
//               // TODO add a refresh state
//               setState(() {});
//             },
//           ),
//         ],
//       ),
//       drawer: drawer.drawer(context),
//       body: Column(
//         children: <Widget>[
//           // Display messages in a list view, future builder waits for the server to return the data
          
//         ],
//       ),
//     );
//   }
// }