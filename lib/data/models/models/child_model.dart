class ChildModel {
  final int id;
  final String name;
  final String parentPhone;
  final String age;
  final String group;
  final String level;

  ChildModel({
    required this.id,
    required this.name,
    required this.parentPhone,
    required this.age,
    required this.group,
    required this.level,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'],
      name: json['name'],
      parentPhone: json['parent_phone'],
      age: json['birth_date'],
      group: json['group'],
      level: json['level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "parent_phone": parentPhone,
      "birth_date": age,
      "group": group,
      "level": level,
    };
  }

  // Override equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChildModel &&
        other.id == id &&
        other.name == name &&
        other.parentPhone == parentPhone &&
        other.age == age &&
        other.group == group &&
        other.level == level;
  }

  // Override hashCode
  @override
  int get hashCode {
    return id.hashCode ^
    name.hashCode ^
    parentPhone.hashCode ^
    age.hashCode ^
    group.hashCode ^
    level.hashCode;
  }
}