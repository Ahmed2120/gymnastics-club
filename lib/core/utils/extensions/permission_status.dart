import '../enums.dart';

extension PermissionStatusExtension on PermissionStatusEnum {
  String get arabicLabel {
    switch (this) {
      case PermissionStatusEnum.pending:
        return 'قيد المراجعة';
      case PermissionStatusEnum.accepted:
        return 'قبول';
      case PermissionStatusEnum.rejected:
        return 'رفض';
    }
  }

  String get englishLabel {
    switch (this) {
      case PermissionStatusEnum.pending:
        return 'Pending';
      case PermissionStatusEnum.accepted:
        return 'Accepted';
      case PermissionStatusEnum.rejected:
        return 'Rejected';
    }
  }
}