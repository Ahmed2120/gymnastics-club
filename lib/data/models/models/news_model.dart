class NewsModel {
  final int id;
  final String title;
  final String newsContent;
  final String? type;
  final String? groupId;
  final String newsDuration;
  final String publishDate;
  final String? imageUrl;
  final int? priority;
  final String? childId;
  final int likesCount;
  final bool isLiked;

  NewsModel({
    required this.id,
    required this.title,
    required this.newsContent,
    this.type,
    this.groupId,
    required this.publishDate,
    required this.newsDuration,
    this.imageUrl,
    this.priority,
    this.childId,
    this.likesCount = 0,
    this.isLiked = false,
  });

  /// From JSON
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      newsContent: json['news_content'] as String? ?? '',
      type: json['type'] as String?,
      groupId: json['group_id']?.toString(), // Use underscore to match schema
      publishDate: json['publish_date'] as String? ?? '',
      newsDuration: json['news_duration'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      priority: (json['priority'] as num?)?.toInt(),
      childId: json['child_id']?.toString(),
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked_by_me'] ?? false,
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
      'priority': priority,
      'child_id': childId,
      'likes_count': likesCount,
      'is_liked_by_me': isLiked,
    };
  }
}
