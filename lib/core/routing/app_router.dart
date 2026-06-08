import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/features/permission/screens/request_permission.dart';
import 'package:gymnastics_club/features/notifications/screens/parent_notifications_page.dart';

import '../../features/attendance_and_absence.dart';
import '../../features/auth/screens/forget_password.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/auth/screens/login.dart';
import '../../features/dashboard.dart';
import '../../features/permission/screens/permissions_screen.dart';
import '../../features/splash/splash_screen.dart';
import 'routes.dart';

final GoRouter router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: Routes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: Routes.dashboard,
      builder: (context, state) => const Dashboard(),
    ),
    GoRoute(
      path: Routes.requestPermission,
      builder: (context, state) => const RequestPermission(),
    ),
    GoRoute(
      path: Routes.permissions,
      builder: (context, state) => const PermissionsScreen(),
    ),
    GoRoute(
      path: Routes.attendanceAndAbsence,
      builder: (context, state) => const AttendanceAndAbsenceScreen(),
    ),
    GoRoute(
      path: Routes.forgetPassword,
      builder: (context, state) => const ForgetPasswordScreen(),
    ),
    GoRoute(
      path: Routes.resetPassword,
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: Routes.notifications,
      builder: (context, state) => const ParentNotificationsPage(),
    ),
  ],
);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
