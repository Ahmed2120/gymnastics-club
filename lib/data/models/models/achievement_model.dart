class AchievementModel {
  final int id;
  final int? childId;
  final String title;
  final String? participantName;
  final DateTime? date;
  final String? venue;
  final String? championType;
  final String? imageUrl;
  final String? createdAt;

  AchievementModel({
    required this.id,
    this.childId,
    required this.title,
    this.participantName,
    this.date,
    this.venue,
    this.championType,
    this.imageUrl,
    this.createdAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'],
      childId: json['childId'],
      title: json['title'] ?? '',
      participantName: json['participantName'],
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      venue: json['venue'],
      championType: json['champion_type'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'title': title,
      'participantName': participantName,
      'date': date?.toIso8601String(),
      'venue': venue,
      'champion_type': championType,
      'image_url': imageUrl,
      'created_at': createdAt,
    };
  }
}
