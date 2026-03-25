import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import '../auth_provider.dart';
import '../../../core/routing/routes.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/main_text.dart';
import '../../../widgets/custom_back_button.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Timer? _timer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const defaultRadius = 12.0;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const MainText('التحقق من الرمز', fontWeight: FontWeight.bold),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              40.ph,
              MainText(
                'أدخل رمز التحقق المكون من 6 أرقام المرسل إلى\n${authState.email ?? ""}',
                fontSize: 14,
                textAlign: TextAlign.center,
                color: Colors.grey,
              ),
              48.ph,
              Directionality(
                textDirection: TextDirection.ltr,
                child: Pinput(
                  autofocus: true,
                  controller: _otpController,
                  length: 6,
                  separatorBuilder: (index) => const SizedBox(width: 8),
                  defaultPinTheme: PinTheme(
                    width: 48,
                    height: 56,
                    textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(defaultRadius),
                      border: Border.all(
                        color: isDarkMode ? Colors.grey.shade800 : const Color(0xFFCED4DA),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.16),
                          offset: const Offset(0, 2),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 48,
                    height: 56,
                    textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(defaultRadius),
                      border: Border.all(color: Theme.of(context).primaryColor),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.16),
                          offset: const Offset(0, 2),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  submittedPinTheme: PinTheme(
                    width: 48,
                    height: 56,
                    textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(defaultRadius),
                      border: Border.all(color: Theme.of(context).primaryColor),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.16),
                          offset: const Offset(0, 2),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  onCompleted: (text) async {
                    final email = authState.email;
                    if (email == null) return;

                    final success = await authNotifier.verifyEmailOtp(
                      email: email,
                      token: text,
                    );

                    if (success && mounted) {
                      context.pushReplacement(Routes.resetPassword);
                    }
                  },
                ),
              ),
              48.ph,
              if (authState.errorMessage != null) ...[
                MainText(
                  authState.errorMessage!,
                  color: Colors.red,
                  fontSize: 14,
                  textAlign: TextAlign.center,
                ),
                24.ph,
              ],
              if (_secondsRemaining > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const MainText(
                      'يمكنك إعادة إرسال الرمز خلال ',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    MainText(
                      _formatTime(_secondsRemaining),
                      fontSize: 14,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                )
              else
                TextButton(
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          final email = authState.email;
                          if (email != null) {
                            await authNotifier.sendEmailOtp(email);
                            if (mounted) {
                              _startTimer();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم إعادة إرسال الرمز')),
                              );
                            }
                          }
                        },
                  child: const MainText(
                    'إعادة إرسال الرمز',
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              32.ph,
              PrimaryButton(
                text: authState.isLoading ? 'جاري التحقق...' : 'تحقق',
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(vertical: 16),
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        final email = authState.email;
                        final token = _otpController.text;
                        if (email == null || token.length < 6) return;

                        final success = await authNotifier.verifyEmailOtp(
                          email: email,
                          token: token,
                        );

                        if (success && mounted) {
                          context.pushReplacement(Routes.resetPassword);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
