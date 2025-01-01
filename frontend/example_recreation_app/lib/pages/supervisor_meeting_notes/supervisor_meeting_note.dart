class SupervisorMeetingNote {
  final int stNoteId;
  final int campId;
  final String stNote;
  final String stNoteDate;
  final String updDate;
  final String updBy; //Index of who modfied the supervisor meeting note

  const SupervisorMeetingNote({
    required this.stNoteId,
    required this.campId,
    required this.stNote,
    required this.stNoteDate,
    required this.updDate,
    required this.updBy,
  });

  factory SupervisorMeetingNote.fromJson(Map<String, dynamic> json) {
    // Create an supervisor meeting note from a JSON object
    return switch (json) {
      {
        // TODO change the JSON object keys server-side to camelCase
        'smeet_note_id': int stNoteId,
        'camp_id': int campId,
        'smeet_note': String stNote,
        'smeet_note_date': String stNoteDate,
        'smeet_note_upd_date': String updDate,
        'first_name': String updByFirstName,
        'last_name': String updByLastName,
      } =>
        SupervisorMeetingNote(
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
