import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/widgets/main_textfield.dart';
import '../auth_provider.dart';

import '../../../core/costants/app_icons.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/main_text.dart';
import '../../../widgets/custom_back_button.dart';

class ForgetPasswordScreen extends ConsumerStatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  ConsumerState<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends ConsumerState<ForgetPasswordScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isOtpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const MainText('نسيت كلمة المرور', fontWeight: FontWeight.bold),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          children: [
            // Premium Logo Container (Matched with Login)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.08),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Image.asset(
                AppIcons.logo,
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
            40.ph,
            if (!_isOtpSent) ...[
              const MainText(
                'أدخل رقم الهاتف المسجل لإرسال رمز التحقق',
                fontSize: 14,
                textAlign: TextAlign.center,
                color: Colors.grey,
              ),
              32.ph,
              MainTextField(
                controller: _phoneController,
                hint: 'رقم الهاتف',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_android_rounded, color: Colors.grey),
              ),
              32.ph,
              PrimaryButton(
                text: authState.isLoading ? 'جاري الإرسال...' : 'إرسال الرمز',
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(vertical: 16),
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        if (_phoneController.text.isNotEmpty) {
                          await authNotifier.sendOtp(_phoneController.text);
                          if (mounted && authState.errorMessage == null) {
                            setState(() {
                              _isOtpSent = true;
                            });
                          }
                        }
                      },
              ),
            ] else ...[
              const MainText(
                'أدخل رمز التحقق وكلمة المرور الجديدة',
                fontSize: 14,
                textAlign: TextAlign.center,
                color: Colors.grey,
              ),
              32.ph,
              MainTextField(
                controller: _otpController,
                hint: 'رمز التحقق (OTP)',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.pin_rounded, color: Colors.grey),
              ),
              16.ph,
              MainTextField(
                controller: _passwordController,
                hint: 'كلمة المرور الجديدة',
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.grey),
              ),
              16.ph,
              MainTextField(
                controller: _confirmPasswordController,
                hint: 'تأكيد كلمة المرور',
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_reset_rounded, color: Colors.grey),
              ),
              32.ph,
              PrimaryButton(
                text: authState.isLoading
                    ? 'جاري التحديث...'
                    : 'تحديث كلمة المرور',
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(vertical: 16),
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        if (_passwordController.text !=
                            _confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('كلمات المرور غير متطابقة'),
                            ),
                          );
                          return;
                        }

                        final success = await authNotifier.resetPasswordWithOtp(
                          phone: _phoneController.text,
                          token: _otpController.text,
                          newPassword: _passwordController.text,
                        );

                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم تحديث كلمة المرور بنجاح'),
                            ),
                          );
                          context.pop();
                        }
                      },
              ),
            ],
            if (authState.errorMessage != null) ...[
              24.ph,
              MainText(
                authState.errorMessage!,
                color: Colors.red,
                fontSize: 14,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
