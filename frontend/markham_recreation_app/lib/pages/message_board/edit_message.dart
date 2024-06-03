import 'dart:convert';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:markham_recreation_app/pages/message_board/message_details.dart';
import 'package:markham_recreation_app/pages/message_board/fetch_messages.dart';
import 'package:markham_recreation_app/globals.dart' as globals;

import 'package:markham_recreation_app/pages/message_board/message.dart';

// Edit an message
class EditMessageBoard extends StatefulWidget {
  final MessageBoard messageBoard;

  const EditMessageBoard({super.key, required this.messageBoard});

  @override
  State<EditMessageBoard> createState() => _EditMessageBoardState();
}

// Edit message page content
class _EditMessageBoardState extends State<EditMessageBoard> {
  DateTime? selectedDate;

  final TextEditingController _notesController = TextEditingController();

  // Initialize the text fields with the message's data
  @override
  void initState() {
    super.initState();
    _notesController.text = widget.messageBoard.inNote;
    selectedDate = DateTime.parse(widget.messageBoard.inNoteDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Edit Message', style: TextStyle(color: globals.secondaryColor)),
        iconTheme: const IconThemeData(color: globals.secondaryColor),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
             Container(
              margin: const EdgeInsets.all(10),
              child: SizedBox(
                child: DateTimeFormField(
                  decoration: const InputDecoration(
                    labelText: 'Enter Date',
                  ),
                  mode: DateTimeFieldPickerMode.date,
                  // TODO replace with week processing
                  // firstDate: DateTime.now().add(const Duration(days: -7)),
                  // lastDate: DateTime.now().add(const Duration(days: 7)),
                  initialPickerDateTime: selectedDate,
                  initialValue: selectedDate,
                  onChanged: (DateTime? value) {
                    selectedDate = value;
                  },
                ),
              ),
            ),
             Container(
                margin: const EdgeInsets.all(10),
                child: SizedBox(
                  child: TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Message',
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
              ),
            const Divider(height: 0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
              ),
              onPressed: () {
 
                if (selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a date'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                if (_notesController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a reason'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                // TODO check if date is out of bounds

                // Send the checklist to the server
                Future<http.Response> response = globals.session.post(
                  Uri.parse('${globals.serverUrl}/api/edit_message/${globals.campId}'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, String>{
                    'app_message_id': widget.messageBoard.inNoteId.toString(),
                    'camp_id': widget.messageBoard.campId.toString(),
                    'app_message_date': selectedDate.toString(),
                    'app_message': _notesController.text,
                    'app_message_upd_date': DateTime.now().toString(),
                  }),
                );
                response.then((http.Response response) {
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edited Message'),
                        duration: Duration(seconds: 3),
                      ),
                    );

                    futureFetchMessageBoards(context).then((messageBoards) {
                      // move back 2 pages
                      Navigator.pop(context);
                      Navigator.pop(context);
                      //readd the current message page (refreshing it's contents)
                      MessageBoard messageBoard = const MessageBoard(inNoteId: 0, campId: 0, inNote: '', inNoteDate: '', updDate: '', updBy: '');
                      //find the message in the list
                      for (int i = 0; i < messageBoards.length; i++) {
                        if (messageBoards[i].inNoteId == widget.messageBoard.inNoteId) {
                          messageBoard = messageBoards[i];
                          break;
                        }
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MessageBoardDetails(messageBoard: messageBoard)));

                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to Edit Message'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }).catchError((error, stackTrace) {
                  // Runs when the server is down
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to Edit Message'),
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
    );
  }
}
