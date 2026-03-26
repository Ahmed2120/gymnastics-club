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

    // Handle both flat (from RPC) and nested (from .select('*, parents(...)'))
    final pName = json['parent_name'] ?? json['parents']?['name'];
    final pEmail = json['parent_email'] ?? json['parents']?['email'];

    return ChildModel(
      id: json['id'],
      name: json['name'] ?? '',
      parentPhone: json['parent_phone'] ?? '',
      age: json['birth_date'] ?? '',
      groupId: gid,
      groupName: gname,
      level: json['level'] ?? '',
      imageUrl: json['image_url'],
      parentName: pName,
      parentEmail: pEmail,
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
      // parent_name and parent_email are no longer stored in 'children' table
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
