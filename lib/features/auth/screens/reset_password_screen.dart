import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/widgets/main_textfield.dart';
import '../auth_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/main_text.dart';
import '../../../widgets/custom_back_button.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const MainText('تغيير كلمة المرور', fontWeight: FontWeight.bold),
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
              const MainText(
                'قم بتعيين كلمة مرور جديدة لحسابك',
                fontSize: 14,
                textAlign: TextAlign.center,
                color: Colors.grey,
              ),
              32.ph,
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
              if (authState.errorMessage != null) ...[
                24.ph,
                MainText(
                  authState.errorMessage!,
                  color: Colors.red,
                  fontSize: 14,
                  textAlign: TextAlign.center,
                ),
              ],
              48.ph,
              PrimaryButton(
                text: authState.isLoading ? 'جاري التحديث...' : 'تحديث كلمة المرور',
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(vertical: 16),
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        final password = _passwordController.text;
                        final confirmPassword = _confirmPasswordController.text;

                        if (password.isEmpty) return;
                        if (password != confirmPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('كلمات المرور غير متطابقة')),
                          );
                          return;
                        }

                        final success = await authNotifier.resetPasswordAfterVerification(
                          newPassword: password,
                        );

                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم تحديث كلمة المرور بنجاح')),
                          );
                          // Navigate back to login
                          context.go('/login');
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
