class Absence {
  final int absentId;
  final int campId;
  final String camperName;
  final String date;
  final bool followedUp;
  final String reason;
  final String dateModified;
  final String modifiedBy; //Index of who modfied the absence

  const Absence({
    required this.absentId,
    required this.campId,
    required this.camperName,
    required this.date,
    required this.followedUp,
    required this.reason,
    required this.dateModified,
    required this.modifiedBy,
  });

  factory Absence.fromJson(Map<String, dynamic> json) {
    // Create an absence from a JSON object
    return switch (json) {
      {
        // TODO change the JSON object keys server-side to camelCase
        'absent_id': int absentId,
        'camp_id': int campId,
        'camper_name': String camperName,
        'date': String date,
        'followed_up': bool followedUp,
        'reason': String reason,
        'date_modified': String dateModified,
        'upd_by': String modifiedBy,
      } =>
        Absence(
          absentId: absentId,
          campId: campId,
          camperName: camperName,
          date: date,
          followedUp: followedUp,
          reason: reason,
          dateModified: dateModified,
          modifiedBy: modifiedBy,
        ),
      _ => throw const FormatException('Unexpected JSON type'),
    };
  }
}
