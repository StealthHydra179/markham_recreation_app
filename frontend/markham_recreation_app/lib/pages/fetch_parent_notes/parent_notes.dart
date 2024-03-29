class ParentNote {
  final int parentNoteId;
  final int campId;
  final String parentNoteDate;
  final String parentNote;
  final String updatedDate;
  final String updatedBy; //Index of who modfied the parent note

  const ParentNote({
    required this.parentNoteId,
    required this.campId,
    required this.parentNoteDate,
    required this.parentNote,
    required this.updatedDate,
    required this.updatedBy,
  });

  factory ParentNote.fromJson(Map<String, dynamic> json) {
    // Create an parent note from a JSON object
    return switch (json) {
      {
        // TODO change the JSON object keys server-side to camelCase
        'pa_note_id': int parentNoteId,
        'camp_id': int campId,
        'pa_note_date': String parentNoteDate,
        'pa_note': String parentNote,
        'pa_note_upd_date': String updatedDate,
        'pa_note_upd_by': String updatedBy,
      } =>
        ParentNote(
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
