class Absence {
  final int absenceId;
  final int campId;
  final String camperFirstName;
  final String camperLastName;
  final String absenceDate;
  final bool followedUp;
  final String reason;
  final String updDate;
  final String updBy; //Index of who modfied the absence

  const Absence({
    required this.absenceId,
    required this.campId,
    required this.camperFirstName,
    required this.camperLastName,
    required this.absenceDate,
    required this.followedUp,
    required this.reason,
    required this.updDate,
    required this.updBy,
  });

  factory Absence.fromJson(Map<String, dynamic> json) {
    // print(json);

    // if reason for an item is null, set it to an empty string
    if (json['reason'] == null) {
      json['reason'] = '';
    }

    // Create an absence from a JSON object
    return switch (json) {
      {
        // TODO change the JSON object keys server-side to camelCase
        'absence_id': int absenceId,
        'camp_id': int campId,
        'camper_first_name': String camperFirstName,
        'camper_last_name': String camperLastName,
        'absence_date': String absenceDate,
        'followed_up': bool followedUp,
        'reason': String reason,
        'absence_upd_date': String updDate,
        'first_name': String updByFirstName,
        'last_name': String updByLastName,
      } =>
        Absence(
          absenceId: absenceId,
          campId: campId,
          camperFirstName: camperFirstName,
          camperLastName: camperLastName,
          absenceDate: absenceDate,
          followedUp: followedUp,
          reason: reason,
          updDate: updDate,
          updBy: '$updByFirstName $updByLastName',
        ),
      _ => throw const FormatException('Unexpected JSON type'),
    };
  }
}
