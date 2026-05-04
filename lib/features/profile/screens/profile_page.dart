import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';
import 'package:gymnastics_club/widgets/app_network_image.dart';
import 'package:gymnastics_club/widgets/main_text.dart';
import 'dart:ui' as ui;

import '../../../core/routing/routes.dart';
import '../profile_controller/child_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/auth_provider.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import '../../../widgets/full_screen_viewer.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(childRiverpod.notifier).getChildren();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);
    final childState = ref.watch(childRiverpod);
    final activeChild = childState.selectedChild;
    final authNotifier = ref.read(authProvider.notifier);

    if (childState.isLoading && childState.childrenList.isEmpty) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primaryCrimson)),
      );
    }

    if (activeChild == null && !childState.isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFAFAFA),
        body: Center(
          child: MainText(
            'لا توجد بيانات لاعبين حالياً',
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: MainText(
          'الملف الشخصي',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.lightText,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Main Profile Header ──
            Column(
              children: [
                24.ph,
                // Double Bordered Avatar
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isDark ? AppColors.energyGradient : null,
                      border: isDark 
                        ? null 
                        : Border.all(
                            color: const Color(0xFFFFD4D4),
                            width: 4,
                          ),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(isDark ? 3 : 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppColors.darkBackground : Colors.white,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBackground : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            final child = activeChild;
                            if (child?.imageUrl != null) {
                              FullScreenImageViewer.open(
                                context,
                                NetworkImage(child!.imageUrl!),
                                'main_profile_avatar',
                              );
                            }
                          },
                          child: Hero(
                            tag: 'main_profile_avatar',
                            child: AppNetworkAvatar(
                              url: activeChild?.imageUrl,
                              size: 140,
                              errorWidget: Image.asset(
                                'assets/images/defualt-user.png',
                                fit: BoxFit.cover,
                                width: 140,
                                height: 140,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                24.ph,
                // Name
                MainText(
                  activeChild?.name ?? 'تحميل...',
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF212121),
                ),
                if (activeChild?.parentEmail != null && activeChild!.parentEmail!.isNotEmpty) ...[
                  4.ph,
                  MainText(
                    activeChild!.parentEmail!,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ],
                24.ph,
                // Badges Row
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildPillBadge(
                      text: activeChild != null ? 'المستوى ${activeChild.level}' : 'المستوى ...',
                      icon: Icons.workspace_premium,
                      backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFFFDE8E8),
                      textColor: isDark ? Colors.white : const Color(0xFF2D3243),
                      iconColor: AppColors.primaryCrimson,
                    ),
                    _buildPillBadge(
                      text: activeChild != null ? 'المجموعة ${activeChild.groupName}' : 'المجموعة ...',
                      icon: Icons.groups,
                      backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFFF3F7FA),
                      textColor: isDark ? Colors.white : const Color(0xFF2D3243),
                      iconColor: isDark ? AppColors.vibrantRed : const Color(0xFF676E7D),
                      borderColor: isDark ? Colors.white10 : const Color(0xFFE3EFF7),
                    ),
                  ],
                ),
              ],
            ),

            32.ph,
            // ── Children Switcher Section ──
            if (childState.childrenList.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    MainText(
                      'الأبطال',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF212121),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              _buildChildrenSection(childState.childrenList, activeChild?.id, isDark),
            ],
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  18.ph,
                  _profileCard(
                    context,
                    isDark: isDark,
                    title: 'طلب إذن',
                    icon: Icons.assignment_outlined,
                    onTap: () => context.push(Routes.permissions),
                  ),
                  18.ph,
                  _profileCard(
                    context,
                    isDark: isDark,
                    title: 'الحضور والغياب',
                    icon: Icons.how_to_reg_outlined,
                    onTap: () => context.push(Routes.attendanceAndAbsence),
                  ),
                  18.ph,
                  _profileCard(
                    context,
                    isDark: isDark,
                    title: 'الوضع الليلي',
                    icon: iThemeMode(themeMode) == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                    onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
                    trailing: Switch(
                      value: iThemeMode(themeMode) == ThemeMode.dark,
                      activeColor: AppColors.primaryCrimson,
                      onChanged: (val) => ref.read(themeProvider.notifier).toggleTheme(),
                    ),
                  ),
                  18.ph,
                  _profileCard(
                    context,
                    isDark: isDark,
                    title: 'تسجيل الخروج',
                    icon: Icons.logout_rounded,
                    color: Colors.red,
                    onTap: () async {
                      await authNotifier.signOut();
                      if (context.mounted) {
                        context.go(Routes.login);
                      }
                    },
                  ),
                  30.ph,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ThemeMode iThemeMode(ThemeMode mode) => mode;

  Widget _buildChildrenSection(List children, int? selectedId, bool isDark) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        // reverse: true, // RTL support for the list
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];
          final isSelected = child.id == selectedId;

          return GestureDetector(
            onTap: () {
              ref.read(childRiverpod.notifier).selectChild(child.id);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryCrimson
                            : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFEEEEEE)),
                        width: isSelected ? 4.5 : 2,
                      ),
                      color: isSelected
                          ? (isDark ? AppColors.darkSurface : AppColors.primaryCrimson.withOpacity(0.05))
                          : (isDark ? AppColors.darkItem : const Color(0xFFF5F5F5)),
                      boxShadow: isSelected && isDark ? [
                        BoxShadow(
                          color: AppColors.primaryCrimson.withOpacity(0.35),
                          blurRadius: 18,
                          spreadRadius: 4,
                        )
                      ] : null,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: AppNetworkAvatar(
                        url: child.imageUrl,
                        size: 68,
                      ),
                    ),
                  ),
                  10.ph,
                  SizedBox(
                    width: 85,
                    child: MainText(
                      child.name, // Show whole name
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected
                          ? (isDark ? Colors.white : AppColors.primaryCrimson)
                          : (isDark ? Colors.white54 : const Color(0xFF676E7D)),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPillBadge({
    required String text,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required Color iconColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(32),
        border: borderColor != null ? Border.all(color: borderColor) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MainText(
            text,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          8.pw,
          Icon(icon, color: iconColor, size: 18),
        ],
      ),
    );
  }

  Widget _profileCard(
    BuildContext context, {
    required bool isDark,
    required String title,
    required IconData icon,
    Color? color,
    Widget? trailing,
    required ui.VoidCallback onTap,
  }) {
    final effectiveColor = color ?? AppColors.primaryCrimson;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isDark 
          ? [
             BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] 
          : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: effectiveColor.withOpacity(isDark ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: effectiveColor, size: 24),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: MainText(
                title,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white.withOpacity(0.9) : AppColors.lightText,
              ),
            ),
            if (trailing != null)
              trailing
            else
              Transform.flip(
                flipX: true, // RTL flip
                child: Icon(Icons.arrow_back_ios_new, size: 14, color: isDark ? Colors.white24 : Colors.grey.shade400),
              ),
          ],
        ),
      ),
    );
  }
}
