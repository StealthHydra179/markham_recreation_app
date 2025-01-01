class EquipmentNote {
  final int equipNoteId;
  final int campId;
  final String equipNote;
  final String equipNoteDate;
  final String updDate;
  final String updBy; //Index of who modfied the equipment note

  const EquipmentNote({
    required this.equipNoteId,
    required this.campId,
    required this.equipNote,
    required this.equipNoteDate,
    required this.updDate,
    required this.updBy,
  });

  factory EquipmentNote.fromJson(Map<String, dynamic> json) {
    // Create an equipment note from a JSON object
    return switch (json) {
      {
        // TODO change the JSON object keys server-side to camelCase
        'equip_note_id': int equipNoteId,
        'camp_id': int campId,
        'equip_note': String equipNote,
        'equip_note_date': String equipNoteDate,
        'equip_note_upd_date': String updDate,
        'first_name': String updByFirstName,
        'last_name': String updByLastName,
      } =>
        EquipmentNote(
          equipNoteId: equipNoteId,
          campId: campId,
          equipNote: equipNote,
          equipNoteDate: equipNoteDate,
          updDate: updDate,
          updBy: '$updByFirstName $updByLastName',
        ),
      _ => throw const FormatException('Unexpected JSON type'),
    };
  }
}
