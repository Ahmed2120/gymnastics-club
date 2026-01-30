class AchievementModel {
  final int id;
  final int childId;
  final String title;
  final String participantName;
  final DateTime date;
  final String venue;
  final String status;
  final String championType;

  AchievementModel({
    required this.id,
    required this.childId,
    required this.title,
    required this.participantName,
    required this.date,
    required this.venue,
    required this.status,
    required this.championType,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'],
      childId: json['childId'],
      title: json['title'],
      participantName: json['participantName'],
      date: DateTime.parse(json['date']),
      venue: json['venue'],
      status: json['status'],
      championType: json['champion_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'title': title,
      'participantName': participantName,
      'date': date.toIso8601String(),
      'venue': venue,
      'status': status,
      'champion_type': championType,
    };
  }
}
