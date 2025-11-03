import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  /// Shortcut to access theme
  ThemeData get theme => Theme.of(this);

  /// Shortcut to access media query
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen width easily
  double get width => mediaQuery.size.width;

  /// Get screen height easily
  double get height => mediaQuery.size.height;

  /// Get text theme quickly
  TextTheme get textTheme => theme.textTheme;

  /// Get color scheme easily
  ColorScheme get colorScheme => theme.colorScheme;

  /// Navigate easily
  void push(Widget page) => Navigator.of(this).push(
    MaterialPageRoute(builder: (_) => page),
  );

  /// Pop screen easily
  void pop() => Navigator.of(this).pop();
}