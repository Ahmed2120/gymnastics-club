import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class MainSelectedCard extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final bool hasError;
  const MainSelectedCard({
    required this.onTap,
    required this.child,
    this.hasError = false,
    super.key,
  });

  factory MainSelectedCard.create({
    required VoidCallback onTap,
    required Widget child,
    bool hasError = false,
  }) {
    if (kIsWeb) {
      return SelectedCardWeb(onTap: onTap, child: child, hasError: hasError);
    }
    return SelectedCard(onTap: onTap, child: child, hasError: hasError);
  }
}

class SelectedCard extends MainSelectedCard {
  const SelectedCard({
    required super.onTap,
    required super.child,
    super.hasError,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasError ? Colors.red : Colors.grey.shade300,
            width: hasError ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class SelectedCardWeb extends MainSelectedCard {
  const SelectedCardWeb({
    required super.onTap,
    required super.child,
    super.hasError,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasError ? Colors.red : Colors.grey.shade300,
            width: hasError ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
