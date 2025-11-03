import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/widgets/main_text.dart';

class homePage extends StatelessWidget {
  const homePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MainText('الرئيسية'),
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
                    color: Colors.grey,
                    offset: Offset(0, 2),
                    blurRadius: 14
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MainText('hello_again'.tr(), fontSize: 22, fontWeight: FontWeight.w600,),
                  12.ph,
                  MainText('عبد الرحمن أشرف', fontSize: 16, color: Colors.grey.shade500,),
                ],
              ),
            ),
            22.ph,
            Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF7FB6FD),
                    Color(0xFFC0DAFB),
                  ],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                )
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF667eea),
                    ),
                    child: MainText('🏃', fontSize: 24,),
                  ),
                  12.pw,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MainText('التدريب القادم'.tr(), fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1565c0),),
                      12.ph,
                      MainText('اليوم الساعة 4:00 م', fontSize: 14,),
                    ],
                  ),
                ],
              ),
            ),
            22.ph,
            MainText('آخر الأخبار'.tr(), fontSize: 18, fontWeight: FontWeight.w600,),
            22.ph,
            ListView.separated(
              itemCount: 3,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              separatorBuilder: (context, index) => 12.ph,
              itemBuilder: (context, index) {
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
                      MainText('عنوان الخبر'.tr(), fontSize: 18, fontWeight: FontWeight.w600,),
                      12.ph,
                      MainText('وصف مختصر للخبر..', fontSize: 14, color: Colors.grey.shade500,),
                    ],
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
