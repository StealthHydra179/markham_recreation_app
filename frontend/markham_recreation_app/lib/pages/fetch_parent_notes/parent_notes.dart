class Absence {
  final int parentNoteId;
  final int campId;
  final String parentNoteDate;
  final String parentNote;
  final String updatedDate;
  final String updatedBy; //Index of who modfied the absence

  const Absence({
    required this.parentNoteId,
    required this.campId,
    required this.parentNoteDate,
    required this.parentNote,
    required this.updatedDate,
    required this.updatedBy,
  });

  factory Absence.fromJson(Map<String, dynamic> json) {
    // Create an absence from a JSON object
    return switch (json) {
      {
        // TODO change the JSON object keys server-side to camelCase
        'parent_note_id': int parentNoteId,
        'camp_id': int campId,
        'parent_note_date': String parentNoteDate,
        'parent_note': String parentNote,
        'parent_note_upd_date': String updatedDate,
        'parent_note_upd_by': String updatedBy,
      } =>
        Absence(
          parentNoteId: parentNoteId,
          campId: campId,
          parentNoteDate: parentNoteDate,
          parentNote: parentNote,
          updatedDate: updatedDate,
          updatedBy: updatedBy,
        ),
      _ => throw const FormatException('Unexpected JSON type'),
    };
  }
}
