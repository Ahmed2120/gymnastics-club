import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';

import '../../../widgets/main_text.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MainText('جدول المواعيد'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: Offset(0, 2),
                        blurRadius: 4
                    )
                  ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Transform.flip(
                    flipX: Directionality.of(context) == ui.TextDirection.rtl,
                      child: Icon(Icons.arrow_left_outlined, size: 40,)),
                  MainText('الأسبوع الحالي'.tr(), fontSize: 22, fontWeight: FontWeight.w600,),
                  Transform.flip(
                      flipX: Directionality.of(context) == ui.TextDirection.rtl,
                      child: Icon(Icons.arrow_right, size: 40,)),
                ],
              ),
            ),
            22.ph,
            ListView.separated(
                itemCount: 3,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                separatorBuilder: (context, index) => 12.ph,
                itemBuilder: (context, index) {
                  return FadeInUp(
                    duration: const Duration(seconds: 2),
                    delay: Duration(milliseconds: 100 * (3 - index)),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border(right: BorderSide(color: Color(0xFF667eea), width: 5)),
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
                          MainText('السبت'.tr(), fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF667eea),),
                          12.ph,
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color(0xFFf8f9fa),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row
                                (
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                        color: Color(0xFF667eea)
                                      ),
                                      child: MainText('4:00 م', fontSize: 14, color: Colors.white,)),
                                 12.pw,
                                  MainText('المجموعة A', fontSize: 18,),
                                ],
                              )),
                        ],
                      ),
                    ),
                  );
                }
            ),
          ],
        ),
      ),
    );
  }
}
