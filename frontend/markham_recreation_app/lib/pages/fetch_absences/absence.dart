class Absence {
  final int absent_id;
  final int camp_id;
  final String camper_name;
  final String date;
  final bool followed_up;
  final String reason;
  final String date_modified;
  final String modified_by; //Index of who modfied the absence

  const Absence({
    required this.absent_id,
    required this.camp_id,
    required this.camper_name,
    required this.date,
    required this.followed_up,
    required this.reason,
    required this.date_modified,
    required this.modified_by,
  });

  factory Absence.fromJson(Map<String, dynamic> json) {
    //log the json
    print(json);
    print(json['date']);
    print(json['followed_up'] is bool);
    return switch (json) {
      {
            'absent_id': int absent_id,
            'camp_id': int camp_id,
            'camper_name': String camper_name,
            'date': String date,
            'followed_up': bool followed_up,
            'reason': String reason,
            'date_modified': String date_modified,
            'upd_by': String modified_by,
      } => 
      Absence(
        absent_id: absent_id,
        camp_id: camp_id,
        camper_name: camper_name,
        date: date,
        followed_up: followed_up,
        reason: reason,
        date_modified: date_modified,
        modified_by: modified_by,
      ), 
      _ => throw const FormatException('Unexpected JSON type'),
    };
  }
}