import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/widgets/main_text.dart';
import 'dart:ui' as ui;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667EEA),
                  Color(0xFF764BA2),
                ],
              ),
              // borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)), // optional
            ),
            child: Column(
              children: [
                ClipOval(
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF667EEA), // soft blue
                          Color(0xFF764BA2), // violet
                        ],
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/defualt-user.png',
                      fit: BoxFit.cover,
                      colorBlendMode: BlendMode.dstOver, // keeps background visible under transparent parts
                    ),
                  ),
                ),

                12.ph,
                MainText('أحمد محمود', color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700,),
                12.ph,
                MainText('العمر: 10 سنوات | المستوى: متقدم', color: Colors.white, fontSize: 24,),

                12.ph,
                MainText('المدرب: أحمد محمد', color: Colors.white, fontSize: 24,),

              ],
            ),
          ),
          22.ph,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _profileCard(context, title: 'طلب إذن',
                    icon: Icon(Icons.perm_identity),
                    onTap: ()=>  context.push('/permissions')),
                18.ph,
                _profileCard(context,
                    title: 'تسجيل الخروج',
                    icon: Icon(Icons.logout, color: Colors.red,),
                    onTap: (){},
                    color: Colors.red, withoutArrow: false),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _profileCard(BuildContext context, {required String title, required Widget icon, Color? color, bool withoutArrow = true, required ui.VoidCallback onTap}){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: color !=null ? Border.all(color: color) : null,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  offset: Offset(0, 2),
                  blurRadius: 4
              )
            ]
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: color != null ? color.withValues(alpha: 0.05) : Color(0xFFf0f0f0)
              ),
              child: icon,
            ),
            12.pw,
            MainText(title, fontSize: 18,),
            if(withoutArrow)...[Spacer(),
            Transform.flip(
                flipX: Directionality.of(context) == ui.TextDirection.rtl,
                child: Icon(Icons.arrow_back_ios_new))]
          ],
        ),
      ),
    );
  }
}
