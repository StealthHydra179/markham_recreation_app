import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:markham_recreation_app/globals.dart' as globals;
import 'package:markham_recreation_app/pages/message_board/fetch_messages.dart';

import 'message.dart';
import 'edit_message.dart';

// Details of an Message
class MessageBoardDetails extends StatelessWidget {
  final MessageBoard messageBoard;

  const MessageBoardDetails({super.key, required this.messageBoard});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        
        title: const Text(
          'Message Details',
          style: TextStyle(color: globals.secondaryColor) 
        ),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
        
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // go back to the previous page and force a refresh
            Navigator.pop(context, true);
          },
        ),
        actions: <Widget>[
          // Edit current Message
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditMessageBoard(messageBoard: messageBoard)),
              );
            },
          ),
          // Delete current Message
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Send a request to the server to delete the Message
              Future<http.Response> response = http.post(
                Uri.parse('${globals.serverUrl}/api/delete_message/${globals.campId}'),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(<String, String>{
                  'app_message_id': messageBoard.inNoteId.toString(),
                }),
              );

              response.then((http.Response response) {
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deleted Message'),
                      duration: Duration(seconds: 3),
                    ),
                  );

                  // go back to the previous page and force a refresh
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Delete Message'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }).catchError((error, stackTrace) {
                // Runs when the server is down
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to Delete Message'),
                    duration: Duration(seconds: 3),
                  ),
                );
              });
            },
          ),
        ],
      ),

      // Display Message details
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('Date: ${dateFormatter(messageBoard.inNoteDate)}'),
          ),
          ListTile(
            title: Text("Note:"),
            subtitle: Text(messageBoard.inNote),
          ),
          ListTile(
            title: Text('Date Modified: ${dateTimeFormatter(messageBoard.updDate)}'),
          ),
          ListTile(
            title: Text('Modified By: ${messageBoard.updBy}'),
          ),
        ],
      ),
    );
  }
}
