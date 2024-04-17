class CounsellorMeetingNote {
  final int stNoteId;
  final int campId;
  final String stNote;
  final String stNoteDate;
  final String updDate;
  final String updBy; //Index of who modfied the counsellor meeting note

  const CounsellorMeetingNote({
    required this.stNoteId,
    required this.campId,
    required this.stNote,
    required this.stNoteDate,
    required this.updDate,
    required this.updBy,
  });

  factory CounsellorMeetingNote.fromJson(Map<String, dynamic> json) {
    // Create an counsellor meeting note from a JSON object
    return switch (json) {
      {
        // TODO change the JSON object keys server-side to camelCase
        'cmeet_note_id': int stNoteId,
        'camp_id': int campId,
        'cmeet_note': String stNote,
        'cmeet_note_date': String stNoteDate,
        'cmeet_note_upd_date': String updDate,
        'first_name': String updByFirstName,
        'last_name': String updByLastName,
      } =>
        CounsellorMeetingNote(
          stNoteId: stNoteId,
          campId: campId,
          stNote: stNote,
          stNoteDate: stNoteDate,
          updDate: updDate,
          updBy: '$updByFirstName $updByLastName',
        ),
      _ => throw const FormatException('Unexpected JSON type'),
    };
  }
}
