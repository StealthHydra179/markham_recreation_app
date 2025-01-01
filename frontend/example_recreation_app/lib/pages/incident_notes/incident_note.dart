class IncidentNote {
  final int inNoteId;
  final int campId;
  final String inNote;
  final String inNoteDate;
  final String updDate;
  final String updBy; //Index of who modfied the incident note

  const IncidentNote({
    required this.inNoteId,
    required this.campId,
    required this.inNote,
    required this.inNoteDate,
    required this.updDate,
    required this.updBy,
  });

  factory IncidentNote.fromJson(Map<String, dynamic> json) {
    // Create an incident note from a JSON object
    return switch (json) {
      {
        // TODO change the JSON object keys server-side to camelCase
        'in_note_id': int inNoteId,
        'camp_id': int campId,
        'in_note': String inNote,
        'in_note_date': String inNoteDate,
        'in_note_upd_date': String updDate,
        'first_name': String updByFirstName,
        'last_name': String updByLastName,
      } =>
        IncidentNote(
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
