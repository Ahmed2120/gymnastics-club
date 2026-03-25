class ChildModel {
  final int id;
  final String name;
  final String parentPhone;
  final String age; // Maps to birth_date
  final String groupId;
  final String groupName;
  final String level;
  final String? imageUrl;
  final String? parentName;
  final String? parentEmail;

  ChildModel({
    required this.id,
    required this.name,
    required this.parentPhone,
    required this.age,
    required this.groupId,
    required this.groupName,
    required this.level,
    this.imageUrl,
    this.parentName,
    this.parentEmail,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    final gid = json['group']?.toString() ?? '';
    final gname = json['group_name']?.toString() ?? '';

    return ChildModel(
      id: json['id'],
      name: json['name'] ?? '',
      parentPhone: json['parent_phone'] ?? '',
      age: json['birth_date'] ?? '',
      groupId: gid,
      groupName: gname,
      level: json['level'] ?? '',
      imageUrl: json['image_url'],
      parentName: json['parent_name'],
      parentEmail: json['parent_email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "parent_phone": parentPhone,
      "birth_date": age,
      "group": groupId,
      "group_name": groupName,
      "level": level,
      "image_url": imageUrl,
      "parent_name": parentName,
      "parent_email": parentEmail,
    };
  }

  // Override equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChildModel && other.id == id;
  }

  // Override hashCode
  @override
  int get hashCode {
    return id.hashCode;
  }
}
