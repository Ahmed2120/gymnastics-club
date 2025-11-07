import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/widgets/main_textfield.dart';

import '../../../core/costants/app_icons.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/main_text.dart';

class LoginScreen extends StatelessWidget {
   LoginScreen({super.key});

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Image.asset(AppIcons.logo),
        // 16.ph,
            MainText('Gymnastics Club', fontSize: 18, fontWeight: FontWeight.bold,),
            12.ph,
            MainTextField(
              controller: _phoneController,
            ),
            12.ph,
            MainTextField(
controller: _passwordController,
              isPassword: true,
            ),
            22.ph,
            PrimaryButton(
              text: 'تسحيل الدخول',
              borderRadius: 10,
              onPressed: (){
                context.go('/dashboard');
              },
            ),
            32.ph,
            TextButton(onPressed: (){}, child: MainText('نسيت كلمة المرور؟', color: Colors.blue, fontSize: 16,))
        ],),
      ),
    );
  }
}
