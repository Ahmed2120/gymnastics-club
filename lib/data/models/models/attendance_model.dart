class AttendanceModel {
  final int id;
  final int? childId;
  final String? name;
  final bool? didAttend;
  final String? group;
  final DateTime? date;
  final String? createdAt;

  AttendanceModel({
    required this.id,
    this.childId,
    this.name,
    this.didAttend,
    this.group,
    this.date,
    this.createdAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      childId: json['childId'],
      name: json['name'],
      didAttend: json['didAttend'],
      group: json['group'],
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'name': name,
      'didAttend': didAttend,
      'group': group,
      'date': date?.toIso8601String(),
      'created_at': createdAt,
    };
  }
}
