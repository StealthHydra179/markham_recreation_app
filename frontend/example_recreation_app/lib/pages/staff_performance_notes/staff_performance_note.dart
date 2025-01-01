class StaffPerformanceNote {
  final int stNoteId;
  final int campId;
  final String stNote;
  final String stNoteDate;
  final String updDate;
  final String updBy; //Index of who modfied the staff performance note

  const StaffPerformanceNote({
    required this.stNoteId,
    required this.campId,
    required this.stNote,
    required this.stNoteDate,
    required this.updDate,
    required this.updBy,
  });

  factory StaffPerformanceNote.fromJson(Map<String, dynamic> json) {
    // Create an staff performance note from a JSON object
    return switch (json) {
      {
        // TODO change the JSON object keys server-side to camelCase
        'st_note_id': int stNoteId,
        'camp_id': int campId,
        'st_note': String stNote,
        'st_note_date': String stNoteDate,
        'st_note_upd_date': String updDate,
        'first_name': String updByFirstName,
        'last_name': String updByLastName,
      } =>
        StaffPerformanceNote(
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
