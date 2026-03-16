import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';
import 'package:gymnastics_club/features/achievement/screens/achievement_page.dart';
import 'package:gymnastics_club/features/profile/screens/profile_page.dart';
import 'package:gymnastics_club/features/schedule/screens/schedule_page.dart';

import 'dashboard_controller/dashboard_provider.dart';
import 'home/screens/home.dart';
import 'profile/profile_controller/child_riverpod.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(childRiverpod.notifier).getChildren();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(dashboardProvider);
    
    final List<Widget> screens = [
      HomePage(),
      const SchedulePage(),
      const AchievementPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: _buildBottomNavigationBar(context, currentIndex),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, int currentIndex) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            ref.read(dashboardProvider.notifier).setIndex(index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: colorScheme.surface,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: const Color(0xFFB0B0B0),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 26),
              activeIcon: Icon(Icons.home_rounded, size: 26),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined, size: 22),
              activeIcon: Icon(Icons.calendar_today_rounded, size: 22),
              label: 'الجدول',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined, size: 26),
              activeIcon: Icon(Icons.emoji_events_rounded, size: 26),
              label: 'الإنجازات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 26),
              activeIcon: Icon(Icons.person_rounded, size: 26),
              label: 'الملف',
            ),
          ],
        ),
      ),
    );
  }
}
