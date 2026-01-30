import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/features/permission/screens/request_permission.dart';

import '../../features/attendance_and_absence.dart';
import '../../features/auth/screens/login.dart';
import '../../features/dashboard.dart';
import '../../features/permission/screens/permissions_screen.dart';
import 'routes.dart';

final GoRouter router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: Routes.login,
  routes: [
    GoRoute(
      path: Routes.login,
      builder: (context, state) =>  LoginScreen(),
    ),
    GoRoute(
      path: Routes.dashboard,
      builder: (context, state) => const Dashboard(),
    ),
    GoRoute(
      path: Routes.requestPermission,
      builder: (context, state) => RequestPermission(),
    ),
    GoRoute(
      path: Routes.permissions,
      builder: (context, state) => PermissionsScreen(),
    ),
    GoRoute(
      path: Routes.attendanceAndAbsence,
      builder: (context, state) => AttendanceAndAbsenceScreen(),
    ),
  ],
);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
