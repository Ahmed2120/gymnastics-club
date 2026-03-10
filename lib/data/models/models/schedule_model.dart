class ScheduleModel {
  final int id;
  final String day;
  final String startTime;
  final String endTime;
  final String groupId;
  final String? createdAt;

  ScheduleModel({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.groupId,
    this.createdAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'],
      day: json['day'],
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      groupId: json['groupId']?.toString() ?? '', // Matches camelCase in schema
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'groupId': groupId,
      'created_at': createdAt,
    };
  }
}
