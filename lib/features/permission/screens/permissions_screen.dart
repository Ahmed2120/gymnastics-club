import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';

import '../../../widgets/main_text.dart';

class PermissionsScreen extends StatelessWidget {
  PermissionsScreen({super.key});
  final statusesList = [
    PermissionStatus.approved,
    PermissionStatus.rejected,
    PermissionStatus.pending,
    PermissionStatus.pending,
    PermissionStatus.pending,
    PermissionStatus.pending,
    PermissionStatus.pending,
    PermissionStatus.pending,
    PermissionStatus.pending,
    PermissionStatus.pending,
    PermissionStatus.pending,
    PermissionStatus.pending,
    PermissionStatus.pending,
  ];
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: MainText('الطلبات'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
            itemCount: statusesList.length,
            shrinkWrap: true,
            separatorBuilder: (context, index) => 12.ph,
            itemBuilder: (context, index) {
              final item = statusesList[index];

              return FadeInUp(
                duration: const Duration(milliseconds: 300),
                delay: Duration(milliseconds: 250 * (index)),
                child: Container(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MainText('طلب إذن غياب'.tr(), fontSize: 20,
                              fontWeight: FontWeight.w700),
                          statusChip(item),
                        ],
                      ),
                      12.ph,
                      MainText('التاريخ: 28 أكتوبر 2024', fontSize: 16),
                      12.pw,
                      MainText('السبب: سفر عائلي', fontSize: 16),
                      if(item == PermissionStatus.rejected)...[
                        12.ph,
                        MainText('الرد: عذراً، يوم البطولة لا يمكن الغياب', fontSize: 16, color: statusColor(item),),
                      ]
                    ],
                  ),
                ),
              );
            }
        ),
      ),
    );
  }

  Widget statusChip(PermissionStatus status){
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: statusBackgroundColor(status)
      ),
      child: MainText(statusText(status), color: statusColor(status), fontSize: 16, fontWeight: FontWeight.w700,),
    );
  }

  Color statusColor(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.approved:
        return Colors.green;
      case PermissionStatus.rejected:
        return Colors.red;
      case PermissionStatus.pending:
        return Color(0xFF856404);
    }
  }

  Color statusBackgroundColor(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.approved:
        return Color(0xFFd4edda);
      case PermissionStatus.rejected:
        return Color(0xFFf8d7da);
      case PermissionStatus.pending:
        return Color(0xFFfff3cd);
    }
  }
  String statusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.approved:
        return 'مقبول';
      case PermissionStatus.rejected:
        return 'مرفوض';
      case PermissionStatus.pending:
        return 'قيد المراجعة';
    }
  }

}

enum PermissionStatus{
  rejected,
  approved,
  pending
}