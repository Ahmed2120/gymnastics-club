class NewsModel {
  final int id;
  final String title;
  final String newsContent;
  final String? type;
  final String? groupId;
  final String newsDuration;
  final String publishDate;
  final String? imageUrl;

  NewsModel({
    required this.id,
    required this.title,
    required this.newsContent,
    this.type,
    this.groupId,
    required this.publishDate,
    required this.newsDuration,
    this.imageUrl,
  });

  /// From JSON
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'],
      title: json['title'],
      newsContent: json['news_content'],
      type: json['type'],
      groupId: json['group_id']?.toString(), // Use underscore to match schema
      publishDate: json['publish_date'],
      newsDuration: json['news_duration'],
      imageUrl: json['image_url'],
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'news_content': newsContent,
      'type': type,
      'group_id': groupId,
      'news_duration': newsDuration,
      'publish_date': publishDate,
      'image_url': imageUrl,
    };
  }
}
