import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';
import 'package:gymnastics_club/widgets/main_text.dart';
import 'dart:ui' as ui;

import '../../../core/routing/routes.dart';
import '../profile_controller/child_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/auth_provider.dart';
import '../../../core/costants/app_assets.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final childState = ref.watch(childRiverpod);
    final activeChild = childState.selectedChild;
    final themeMode = ref.watch(themeProvider);
    final authNotifier = ref.read(authProvider.notifier);

    if (childState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (activeChild == null) {
      return const Scaffold(
        body: Center(child: MainText('لا توجد بيانات للاعبين حالياً')),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            // 1. Curved Gradient Header for Profile
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33D32F2F),
                    blurRadius: 25,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white12,
                          backgroundImage: activeChild.imageUrl != null
                              ? NetworkImage(activeChild.imageUrl!)
                              : const AssetImage(AppAssets.userPlaceholder) as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 16),
                      MainText(
                        activeChild.name,
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_outline, color: Colors.white70, size: 16),
                                const SizedBox(width: 8),
                                MainText(
                                  'المستوى: ${activeChild.level}',
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.groups_outlined, color: Colors.white70, size: 16),
                                const SizedBox(width: 8),
                                MainText(
                                  'المجموعة: ${activeChild.groupName}',
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MainText(
                    'أبنائي',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: childState.childrenList.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final child = childState.childrenList[index];
                        final isSelected = child.id == activeChild.id;
                        return GestureDetector(
                          onTap: () => ref
                              .read(childRiverpod.notifier)
                              .selectChild(child.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryColor : cardColor,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryColor : Colors.grey.withOpacity(0.3),
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ] : null,
                            ),
                            child: Center(
                              child: MainText(
                                child.name,
                                color: isSelected ? Colors.white : colorScheme.onSurface,
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _profileCard(
                    context,
                    title: 'طلب إذن',
                    icon: Icons.assignment_outlined,
                    onTap: () => context.push(Routes.permissions),
                  ),
                  const SizedBox(height: 16),
                  _profileCard(
                    context,
                    title: 'الحضور والغياب',
                    icon: Icons.how_to_reg_outlined,
                    onTap: () => context.push(Routes.attendanceAndAbsence),
                  ),
                  const SizedBox(height: 16),
                  _profileCard(
                    context,
                    title: 'الوضع الليلي',
                    icon: themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                    onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
                    trailing: Switch(
                      value: themeMode == ThemeMode.dark,
                      activeColor: AppColors.accentColor,
                      onChanged: (val) => ref.read(themeProvider.notifier).toggleTheme(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _profileCard(
                    context,
                    title: 'تسجيل الخروج',
                    icon: Icons.logout_rounded,
                    onTap: () async {
                      await authNotifier.signOut();
                      if (context.mounted) {
                        context.go(Routes.login);
                      }
                    },
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    Color? color,
    Widget? trailing,
    required ui.VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (color ?? AppColors.primaryColor).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color ?? AppColors.primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MainText(
                title,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color ?? Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (trailing != null)
              trailing
            else
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
