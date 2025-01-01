class DailyNote {
  final int inNoteId;
  final int campId;
  final String inNote;
  final String inNoteDate;
  final String updDate;
  final String updBy; //Index of who modfied the daily note

  const DailyNote({
    required this.inNoteId,
    required this.campId,
    required this.inNote,
    required this.inNoteDate,
    required this.updDate,
    required this.updBy,
  });

  factory DailyNote.fromJson(Map<String, dynamic> json) {
    // Create an daily note from a JSON object
    return switch (json) {
      {
        // TODO change the JSON object keys server-side to camelCase
        'daily_note_id': int inNoteId,
        'camp_id': int campId,
        'daily_note': String inNote,
        'daily_note_date': String inNoteDate,
        'daily_note_upd_date': String updDate,
        'first_name': String updByFirstName,
        'last_name': String updByLastName,
      } =>
        DailyNote(
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
