import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/widgets/main_text.dart';
import 'dart:ui' as ui;

import '../../../core/routing/routes.dart';
import '../../../core/utils/global_methods.dart';
import '../profile_controller/child_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childState = ref.watch(childRiverpod);
    final activeChild = childState.selectedChild;

    if (childState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (activeChild == null) {
      return const Scaffold(
        body: Center(child: MainText('لا توجد بيانات للاعبين حالياً')),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              // borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)), // optional
            ),
            child: Column(
              children: [
                ClipOval(
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF667EEA), // soft blue
                          Color(0xFF764BA2), // violet
                        ],
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/defualt-user.png',
                      fit: BoxFit.cover,
                      colorBlendMode: BlendMode
                          .dstOver, // keeps background visible under transparent parts
                    ),
                  ),
                ),

                12.ph,
                MainText(
                  activeChild.name,
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
                12.ph,
                MainText(
                  'العمر: ${GlobalMethods.calcAge(activeChild.age)} | المستوى: ${activeChild.level}',
                  color: Colors.white,
                  fontSize: 18,
                ),

                12.ph,
                MainText(
                  'المجموعة: ${activeChild.group}',
                  color: Colors.white,
                  fontSize: 18,
                ),
              ],
            ),
          ),
          22.ph,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MainText('أبنائي', fontSize: 20, fontWeight: FontWeight.w700),
                12.ph,
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    // padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    clipBehavior: Clip.none,
                    scrollDirection: Axis.horizontal,
                    itemCount: childState.childrenList.length,
                    separatorBuilder: (context, index) => 12.pw,
                    itemBuilder: (context, index) {
                      final child = childState.childrenList[index];
                      final isSelected = child.id == activeChild.id;
                      return GestureDetector(
                        onTap: () => ref
                            .read(childRiverpod.notifier)
                            .selectChild(child.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF667EEA)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: MainText(
                              child.name,
                              color: isSelected ? Colors.white : Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                22.ph,
                _profileCard(
                  context,
                  title: 'طلب إذن',
                  icon: Icon(Icons.perm_identity),
                  onTap: () => context.push(Routes.permissions),
                ),
                18.ph,
                _profileCard(
                  context,
                  title: 'الحضور والغياب',
                  icon: Icon(Icons.perm_identity),
                  onTap: () => context.push(Routes.attendanceAndAbsence),
                ),
                18.ph,
                _profileCard(
                  context,
                  title: 'تسجيل الخروج',
                  icon: Icon(Icons.logout, color: Colors.red),
                  onTap: () {},
                  color: Colors.red,
                  withoutArrow: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard(
    BuildContext context, {
    required String title,
    required Widget icon,
    Color? color,
    bool withoutArrow = true,
    required ui.VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: color != null ? Border.all(color: color) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: color != null
                    ? color.withValues(alpha: 0.05)
                    : Color(0xFFf0f0f0),
              ),
              child: icon,
            ),
            12.pw,
            MainText(title, fontSize: 18),
            if (withoutArrow) ...[
              Spacer(),
              Transform.flip(
                flipX: Directionality.of(context) == ui.TextDirection.rtl,
                child: Icon(Icons.arrow_back_ios_new),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
