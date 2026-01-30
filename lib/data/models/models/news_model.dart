class NewsModel {
  final int id;
  final String title;
  final String newsContent;
  final String typeId;
  final String? groupId;
  final String newsDuration;
  final String publishDate;

  NewsModel({
    required this.id,
    required this.title,
    required this.newsContent,
    required this.typeId,
    required this.groupId,
    required this.publishDate,
    required this.newsDuration,
  });

  /// From JSON
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'],
      title: json['title'],
      newsContent: json['news_content'],
      typeId: json['typeId'],
      groupId: json['groupId'],
      publishDate: json['publish_date'],
      newsDuration: json['news_duration'],
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'news_content': newsContent,
      'typeId': typeId,
      'groupId': groupId,
      'news_duration': newsDuration,
      'publish_date': publishDate,
    };
  }
}