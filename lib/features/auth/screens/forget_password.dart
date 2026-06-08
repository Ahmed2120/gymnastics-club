import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/widgets/main_textfield.dart';
import '../auth_provider.dart';
import '../../../core/routing/routes.dart';
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
  final _membershipController = TextEditingController();
 
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).clearError();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _membershipController.dispose();
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
        title: const MainText('نسيت كلمة المرور', fontWeight: FontWeight.bold),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          children: [
            // Logo
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
            const MainText(
              'أدخل رقم الهاتف ورمز العضوية الخاص بك للتحقق',
              fontSize: 14,
              textAlign: TextAlign.center,
              color: Colors.grey,
            ),
            32.ph,
            MainTextField(
              controller: _phoneController,
              hint: 'رقم الهاتف',
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined, color: Colors.grey),
            ),
            16.ph,
            MainTextField(
              controller: _membershipController,
              hint: 'رمز العضوية',
              prefixIcon: const Icon(Icons.vpn_key_outlined, color: Colors.grey),
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
              text: authState.isLoading ? 'جاري التحقق...' : 'تحقق',
              borderRadius: 24,
              padding: const EdgeInsets.symmetric(vertical: 16),
              onPressed: authState.isLoading
                  ? null
                  : () async {
                      final phone = _phoneController.text.trim();
                      final membership = _membershipController.text.trim();
                      
                      if (phone.isEmpty || membership.isEmpty) return;
                      
                      final success = await authNotifier.verifyMembership(
                        phone: phone, 
                        membershipNumber: membership
                      );
                      
                      if (mounted && success) {
                        context.push(Routes.resetPassword);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
