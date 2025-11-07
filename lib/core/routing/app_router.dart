import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/features/permission/screens/request_permission.dart';

import '../../features/auth/screens/login.dart';
import '../../features/dashboard.dart';
import '../../features/permission/screens/permissions_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) =>  LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const Dashboard(),
    ),
    GoRoute(
      path: '/requestPermission',
      builder: (context, state) => RequestPermission(),
    ),
    GoRoute(
      path: '/permissions',
      builder: (context, state) => PermissionsScreen(),
    ),
  ],
);