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
import '../../../widgets/custom_back_button.dart';

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
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
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
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const CustomBackButton(),
        title: MainText(
          'طلب إذن غياب جديد',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.lightText,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                  children: [
                    if (activeChild != null)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryCrimson.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.person_rounded,
                                  color: AppColors.primaryCrimson, size: 28),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MainText(
                                  'اسم اللاعب',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white38 : Colors.grey,
                                ),
                                const SizedBox(height: 4),
                                MainText(
                                  activeChild.name,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    40.ph,

                    _SectionLabel(
                        icon: Icons.calendar_today_rounded,
                        label: 'تاريخ الغياب',
                        isDark: isDark),
                    16.ph,
                    SelectDateWidget(
                      onSelect: (date) =>
                          setState(() => _selectedDate = date),
                    ),

                    40.ph,

                    _SectionLabel(
                        icon: Icons.edit_note_rounded, 
                        label: 'سبب الغياب',
                        isDark: isDark),
                    16.ph,
                    MainTextField(
                      controller: _reasonController,
                      maxLines: 5,
                      hint: 'اكتب السبب هنا بالتفصيل...',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى كتابة سبب الغياب';
                        }
                        return null;
                      },
                    ),

                    48.ph,

                    PrimaryButton(
                      text: 'إرسال الطلب الآن',
                      isLoading: permissionState.isLoading,
                      borderRadius: 24,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        if (_selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: const MainText('يرجى اختيار التاريخ', color: Colors.white, fontSize: 14),
                                backgroundColor: AppColors.primaryCrimson,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
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
                              SnackBar(
                                content: const MainText('تم إرسال الطلب بنجاح', color: Colors.white, fontSize: 14),
                                backgroundColor: Colors.green.shade600,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                            context.pop();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: MainText('حدث خطأ: $e', color: Colors.white, fontSize: 14),
                                backgroundColor: Colors.red.shade600,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    40.ph,
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

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _SectionLabel({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryCrimson.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryCrimson),
        ),
        const SizedBox(width: 14),
        MainText(
          label,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ],
    );
  }
}
