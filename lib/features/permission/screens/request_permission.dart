import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';
import 'package:gymnastics_club/core/utils/enums.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/data/models/models/permission_model.dart';
import 'package:gymnastics_club/features/permission/permission_controller/permission_riverpod.dart';
import 'package:gymnastics_club/features/profile/profile_controller/child_riverpod.dart';
import 'package:gymnastics_club/widgets/main_textfield.dart';

import '../../../widgets/custom_button.dart';
import '../../../widgets/main_text.dart';
import '../../../widgets/select_date.dart';

class RequestPermission extends ConsumerStatefulWidget {
  const RequestPermission({super.key});

  @override
  ConsumerState<RequestPermission> createState() => _RequestPermissionState();
}

class _RequestPermissionState extends ConsumerState<RequestPermission>
    with SingleTickerProviderStateMixin {
  final _reasonController = TextEditingController();
  DateTime? _selectedDate;
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final permissionState = ref.watch(permissionRiverpod);
    final activeChild = ref.watch(childRiverpod).selectedChild;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F6FA),
      body: Column(
        children: [
          // ── Curved Header ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        const Expanded(
                          child: MainText(
                            'طلب إذن غياب جديد',
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48), // balance
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Form ─────────────────────────────────────────────────────────
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                  children: [
                    // Child name info chip
                    if (activeChild != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.child_care_rounded,
                                  color: AppColors.primaryColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MainText(
                                  'اسم اللاعب',
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                                MainText(
                                  activeChild.name,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    28.ph,

                    // Section label: Date
                    _SectionLabel(
                        icon: Icons.calendar_today_rounded,
                        label: 'تاريخ الغياب'),
                    12.ph,
                    SelectDateWidget(
                      onSelect: (date) =>
                          setState(() => _selectedDate = date),
                    ),

                    28.ph,

                    // Section label: Reason
                    _SectionLabel(
                        icon: Icons.notes_rounded, label: 'سبب الغياب'),
                    12.ph,
                    MainTextField(
                      controller: _reasonController,
                      maxLines: 4,
                      hint: 'اكتب السبب هنا...',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى كتابة سبب الغياب';
                        }
                        return null;
                      },
                    ),

                    32.ph,

                    // Submit button
                    PrimaryButton(
                      text: 'إرسال الطلب',
                      isLoading: permissionState.isLoading,
                      borderRadius: 16,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        if (_selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('يرجى اختيار التاريخ')),
                          );
                          return;
                        }
                        if (activeChild == null) return;

                        final newRequest = PermissionModel(
                          childName: activeChild.name,
                          date: _selectedDate!,
                          reason: _reasonController.text,
                          status: PermissionStatusEnum.pending,
                        );

                        try {
                          await ref
                              .read(permissionRiverpod.notifier)
                              .submitRequest(newRequest);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم إرسال الطلب بنجاح'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            context.pop();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('حدث خطأ: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Label Helper ─────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        MainText(
          label,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }
}
