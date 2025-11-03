// ============================================
// 1. main_screen.dart - Main Navigation Container
// ============================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gymnastics_club/features/achievement/screens/achievement_page.dart';
import 'package:gymnastics_club/features/profile/screens/profile_page.dart';
import 'package:gymnastics_club/features/schedule/screens/schedule_page.dart';


import 'home/screens/home.dart';

// Provider للتحكم في الصفحة الحالية

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {

    // قائمة الشاشات
    final screens = [
      const homePage(),
      const SchedulePage(),
      const AchievementPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(
      BuildContext context,
      ) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        _currentIndex = index;

        setState(() {});
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'الجدول',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events_outlined),
          activeIcon: Icon(Icons.emoji_events),
          label: 'الإنجازات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'الملف الشخصي',
        ),
      ],
    );
  }
}