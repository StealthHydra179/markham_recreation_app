class Absence {
  final int absentId;
  final int campId;
  final String camperFirstName;
  final String camperLastName;
  final String absentDate;
  final bool followedUp;
  final String reason;
  final String dateModified;
  final String modifiedBy; //Index of who modfied the absence

  const Absence({
    required this.absentId,
    required this.campId,
    required this.camperFirstName,
    required this.camperLastName,
    required this.absentDate,
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
        'camper_first_name': String camperFirstName,
        'camper_last_name': String camperLastName,
        'absent_date': String absentDate,
        'followed_up': bool followedUp,
        'reason': String reason,
        'absent_date_modified': String dateModified,
        'absent_upd_by': String modifiedBy,
      } =>
        Absence(
          absentId: absentId,
          campId: campId,
          camperFirstName: camperFirstName,
          camperLastName: camperLastName,
          absentDate: absentDate,
          followedUp: followedUp,
          reason: reason,
          dateModified: dateModified,
          modifiedBy: modifiedBy,
        ),
      _ => throw const FormatException('Unexpected JSON type'),
    };
  }
}
