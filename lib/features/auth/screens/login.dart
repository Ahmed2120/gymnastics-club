import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/widgets/main_textfield.dart';
import '../auth_provider.dart';

import '../../../core/costants/app_icons.dart';
import '../../../core/routing/routes.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/main_text.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppIcons.logo, height: 120),
            24.ph,
            const MainText(
              'تسجيل الدخول',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            32.ph,
            MainTextField(
              controller: _phoneController,
              hint: 'رقم الهاتف',
              keyboardType: TextInputType.phone,
            ),
            16.ph,
            MainTextField(
              controller: _passwordController,
              hint: 'كلمة المرور',
              isPassword: true,
            ),
            24.ph,
            PrimaryButton(
              text: authState.isLoading ? 'جاري الدخول...' : 'تسجيل الدخول',
              borderRadius: 10,
              onPressed: authState.isLoading
                  ? null
                  : () async {
                      if (_phoneController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty) {
                        final success = await authNotifier.loginWithPassword(
                          _phoneController.text,
                          _passwordController.text,
                        );
                        if (success && mounted) {
                          context.go(Routes.dashboard);
                        }
                      }
                    },
            ),
            16.ph,
            TextButton(
              onPressed: () => context.push(Routes.forgetPassword),
              child: const MainText(
                'نسيت كلمة المرور؟',
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
            if (authState.errorMessage != null) ...[
              12.ph,
              MainText(
                authState.errorMessage!,
                color: Colors.red,
                fontSize: 14,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
