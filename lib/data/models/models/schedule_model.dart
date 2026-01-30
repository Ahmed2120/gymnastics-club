class ScheduleModel {
  final int id;
  final String day;
  final String startTime;
  final String endTime;
  final String trainer;
  final String groupId;

  ScheduleModel({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.trainer,
    required this.groupId,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'],
      day: json['day'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      trainer: json['trainer'],
      groupId: json['groupId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'trainer': trainer,
      'groupId': groupId,
    };
  }
}
