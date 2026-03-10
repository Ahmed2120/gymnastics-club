import '../../../core/utils/enums.dart';

class PermissionModel {
  final int? id;
  final String childName;
  final DateTime? date;
  final String reason;
  final PermissionStatusEnum status;
  final String? createdAt;

  PermissionModel({
    this.id,
    required this.childName,
    this.date,
    required this.reason,
    required this.status,
    this.createdAt,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    final map = {
      'employeeName': childName, // Matches schema
      'date': date?.toIso8601String(),
      'reason': reason,
      'status': status.name,
    };
    if (id != null) map['id'] = id as dynamic;
    return map;
  }

  // Create from JSON
  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'],
      childName: json['employeeName'] ?? json['child_name'] ?? '',
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      reason: json['reason'] ?? '',
      status: PermissionStatusEnum.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            (json['status'] as String? ?? 'pending').toLowerCase(),
        orElse: () => PermissionStatusEnum.pending,
      ),
      createdAt: json['created_at'],
    );
  }

  // Copy with method for updates
  PermissionModel copyWith({
    int? id,
    String? childName,
    DateTime? date,
    String? reason,
    PermissionStatusEnum? status,
    String? createdAt,
  }) {
    return PermissionModel(
      id: id ?? this.id,
      childName: childName ?? this.childName,
      date: date ?? this.date,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
