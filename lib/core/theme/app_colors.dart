import 'package:flutter/material.dart';

class AppColors {
  // Common Brand Colors
  static const Color primaryCrimson = Color(0xFFD32F2F);
  static const Color primaryColor = primaryCrimson; // Alias for backward compatibility
  
  static const Color energyGradientStart = Color(0xFFFF5252);
  static const Color energyGradientEnd = Color(0xFFB71C1C);
  
  static const Color achievementGold = Color(0xFFFFC107);
  
  // Light Mode Palette
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFEEEEEE);
  static const Color borderGrey = Color(0xFFEEEEEE);
  static const Color lightInput = Color(0xFFF5F5F5);
  static const Color lightText = Color(0xFF212121); // Deep Charcoal
  
  // Dark Mode Palette
  static const Color darkBackground = Color(0xFF1A0D0D);
  static const Color darkSurface = Color(0xFF261818);
  static const Color darkItem = Color(0xFF1E1414);
  static const Color vibrantRed = Color(0xFFEC1313);
  static const Color darkText = Color(0xFFFFFFFF); // Pure White
  static const Color darkSecondaryText = Color(0xFFBDBDBD);
  
  // Functional Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color neutral = Color(0xFF9E9E9E);

  // Legacy/Other (Keeping for compatibility if needed)
  static const Color primaryLight = Color(0xFFFF6659);
  static const Color primaryDark = Color(0xFF9A0007);
  static const Color accentColor = Color(0xFFFF5252);
  static const Color surfaceColor = Color(0xFFF8F9FA);
  static const Color hintColor = Color(0xFFAAAAAA);

  static const LinearGradient energyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
  );
}