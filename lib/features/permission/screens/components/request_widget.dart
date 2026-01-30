import 'package:flutter/material.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';

import '../../../../core/utils/date_converter.dart';
import '../../../../core/utils/enums.dart';
import '../../../../data/models/models/permission_model.dart';
import '../../../../widgets/main_text.dart';

class RequestWidget extends StatelessWidget {
  const RequestWidget({
    super.key,
    required this.permissionModel,
    this.isLoading = false,
  });

  final PermissionModel permissionModel;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: MainText(
                  'طلب إذن غياب',
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              statusChip(permissionModel.status),
            ],
          ),
          12.ph,
          MainText(
            'الطفل: ${permissionModel.childName}',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black.withValues(alpha: 0.6),
          ),
          12.ph,
          MainText(
            'التاريخ: ${DateConverter.dateToReadableDate(permissionModel.date.toIso8601String())}',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black.withValues(alpha: 0.6),
          ),
          12.ph,
          MainText(
            'السبب: ${permissionModel.reason}',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black.withValues(alpha: 0.6),
          ),
          if(permissionModel.status == PermissionStatusEnum.rejected)...[
            12.ph,
            MainText('الرد: عذراً، يوم البطولة لا يمكن الغياب', fontSize: 16, color: statusColor(permissionModel.status),),
          ]
        ],
      ),
    );
  }

  Color statusColor(PermissionStatusEnum status) {
    switch (status) {
      case PermissionStatusEnum.accepted:
        return Colors.green;
      case PermissionStatusEnum.rejected:
        return Colors.red;
      case PermissionStatusEnum.pending:
        return Color(0xFF856404);
    }
  }

  Color statusBackgroundColor(PermissionStatusEnum status) {
    switch (status) {
      case PermissionStatusEnum.accepted:
        return Color(0xFFd4edda);
      case PermissionStatusEnum.rejected:
        return Color(0xFFf8d7da);
      case PermissionStatusEnum.pending:
        return Color(0xFFfff3cd);
    }
  }

  String statusText(PermissionStatusEnum status) {
    switch (status) {
      case PermissionStatusEnum.accepted:
        return 'مقبول';
      case PermissionStatusEnum.rejected:
        return 'مرفوض';
      case PermissionStatusEnum.pending:
        return 'قيد المراجعة';
    }
  }

  Widget statusChip(PermissionStatusEnum status) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: statusBackgroundColor(status),
      ),
      child: MainText(
        statusText(status),
        color: statusColor(status),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
