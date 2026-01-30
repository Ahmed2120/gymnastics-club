class AttendanceModel {
  final int id;
  final int childId;
  final String name;
  final bool didAttend;
  final String group;
  final DateTime date;

  AttendanceModel({
    required this.id,
    required this.childId,
    required this.name,
    required this.didAttend,
    required this.group,
    required this.date,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      childId: json['childId'],
      name: json['name'],
      didAttend: json['didAttend'],
      group: json['group'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'name': name,
      'didAttend': didAttend,
      'group': group,
      'date': date.toIso8601String(),
    };
  }
}
