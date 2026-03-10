import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/widgets/main_textfield.dart';
import '../auth_provider.dart';

import '../../../core/costants/app_icons.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/main_text.dart';

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
      appBar: AppBar(
        title: const MainText('نسيت كلمة المرور', fontWeight: FontWeight.bold),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Image.asset(AppIcons.logo, height: 120),
            32.ph,
            if (!_isOtpSent) ...[
              const MainText(
                'أدخل رقم الهاتف المسجل لإرسال رمز التحقق',
                fontSize: 14,
                textAlign: TextAlign.center,
              ),
              24.ph,
              MainTextField(
                controller: _phoneController,
                hint: 'رقم الهاتف',
                keyboardType: TextInputType.phone,
              ),
              24.ph,
              PrimaryButton(
                text: authState.isLoading ? 'جاري الإرسال...' : 'إرسال الرمز',
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
              ),
              24.ph,
              MainTextField(
                controller: _otpController,
                hint: 'رمز التحقق (OTP)',
                keyboardType: TextInputType.number,
              ),
              16.ph,
              MainTextField(
                controller: _passwordController,
                hint: 'كلمة المرور الجديدة',
                isPassword: true,
              ),
              16.ph,
              MainTextField(
                controller: _confirmPasswordController,
                hint: 'تأكيد كلمة المرور',
                isPassword: true,
              ),
              24.ph,
              PrimaryButton(
                text: authState.isLoading
                    ? 'جاري التحديث...'
                    : 'تحديث كلمة المرور',
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
              16.ph,
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
