class MessageBoard {
  final int inNoteId;
  final int campId;
  final String inNote;
  final String inNoteDate;
  final String updDate;
  final String updBy; //Index of who modfied the message

  const MessageBoard({
    required this.inNoteId,
    required this.campId,
    required this.inNote,
    required this.inNoteDate,
    required this.updDate,
    required this.updBy,
  });

  factory MessageBoard.fromJson(Map<String, dynamic> json) {
    // Create an message from a JSON object
    print(json);
    return switch (json) {
      {
        // TODO change the JSON object keys server-side to camelCase
        'app_message_id': int inNoteId,
        'camp_id': int campId,
        'app_message': String inNote,
        'app_message_date': String inNoteDate,
        'app_message_upd_date': String updDate,
        'first_name': String updByFirstName,
        'last_name': String updByLastName,
      } =>
        MessageBoard(
          inNoteId: inNoteId,
          campId: campId,
          inNote: inNote,
          inNoteDate: inNoteDate,
          updDate: updDate,
          updBy: '$updByFirstName $updByLastName',
        ),
      _ => throw const FormatException('Unexpected JSON type'),
    };
  }
}
