import '../../../core/utils/enums.dart';

class PermissionModel {
  final int id;
  final String childName;
  final DateTime date;
  final String reason;
  final PermissionStatusEnum status;

  PermissionModel({
    required this.id,
    required this.childName,
    required this.date,
    required this.reason,
    required this.status,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeName': childName,
      'date': date.toIso8601String(),
      'reason': reason,
      'status': status.toString().split('.').last,
    };
  }

  // Create from JSON
  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'],
      childName: json['employeeName'],
      date: DateTime.parse(json['date']),
      reason: json['reason'],
      status: PermissionStatusEnum.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() == json['status'].toLowerCase(),
      ),
    );
  }

  // Copy with method for updates
  PermissionModel copyWith({
    int? id,
    String? employeeName,
    DateTime? date,
    String? reason,
    PermissionStatusEnum? status,
  }) {
    return PermissionModel(
      id: id ?? this.id,
      childName: employeeName ?? this.childName,
      date: date ?? this.date,
      reason: reason ?? this.reason,
      status: status ?? this.status,
    );
  }
}