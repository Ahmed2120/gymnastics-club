import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';

import '../../../widgets/main_text.dart';

class AchievementPage extends StatelessWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MainText('الإنجازات'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFFD700), // gold
                                    Color(0xFFFFED4E), // light gold
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                            ),
                            child: MainText('🥇', fontSize: 30,),
                          ),
                          12.pw,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MainText('بطولة الجمهورية'.tr(), fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF667eea),),
                              12.ph,
                              MainText('3 أغسطس 2024', fontSize: 14, color: Colors.grey,),
                              12.pw,
                              MainText('المركز الثاني - جهاز الحلق', fontSize: 18,),
                            ],
                          ),
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
