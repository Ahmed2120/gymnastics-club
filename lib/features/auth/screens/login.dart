import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/widgets/main_textfield.dart';
import '../auth_provider.dart';

import '../../../core/costants/app_icons.dart';
import '../../../core/routing/routes.dart';
import '../../../widgets/main_text.dart';
import '../../../core/theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).clearError();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8F9FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Logo ──
                  Image.asset(
                    AppIcons.logoFull,
                    height: 160,
                    fit: BoxFit.contain,
                  ),

                  56.ph,

                  // ── Club name ──
                   MainText(
                    'مرحباً بك',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                  8.ph,
                   MainText(
                    'سجّل دخولك للمتابعة',
                    fontSize: 14,
                    color: isDark ? Colors.white54 : const Color(0xFF777777),
                  ),

                  40.ph,

                  // ── Phone field ──
                  MainTextField(
                    controller: _phoneController,
                    hint: 'رقم الهاتف',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icon(
                      Icons.phone_android_rounded,
                      color: isDark ? Colors.white38 : const Color(0xFF999999),
                    ),
                  ),

                  16.ph,

                  // ── Password field ──
                  MainTextField(
                    controller: _passwordController,
                    hint: 'كلمة المرور',
                    isPassword: true,
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: isDark ? Colors.white38 : const Color(0xFF999999),
                    ),
                  ),

                  12.ph,
                  
                  // ── Forgot Password ──
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => context.push(Routes.forgetPassword),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const MainText(
                        'نسيت كلمة المرور؟',
                        fontSize: 14,
                        color: AppColors.primaryCrimson,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  32.ph,

                  // ── Login button ──
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.energyGradient,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryCrimson.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const MainText(
                                'تسجيل الدخول',
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                      ),
                    ),
                  ),

                  if (authState.errorMessage != null) ...[
                    16.ph,
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: MainText(
                              authState.errorMessage!,
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  40.ph,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
