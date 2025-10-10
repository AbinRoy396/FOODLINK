import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF00C853);  // More vibrant green
  static const Color primaryDark = Color(0xFF009624);  // Darker shade for pressed state
  static const Color primaryLight = Color(0xFF5EFC82);  // Lighter shade

  // Background Colors
  static const Color backgroundLight = Color(0xFFF6F8F6);
  static const Color backgroundDark = Color(0xFF102216);

  // Surface Colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF182E1F);

  // Text Colors
  static const Color foregroundLight = Color(0xFF111813);
  static const Color foregroundDark = Color(0xFFE3E3E3);

  // Secondary Colors
  static const Color secondary = Color(0xFF61896F);
  static const Color secondaryLight = Color(0xFFA0B3A8);

  // Input Colors
  static const Color inputLight = Color(0xFFF0F4F2);
  static const Color inputDark = Color(0xFF1A3824);

  // Border Colors
  static const Color borderLight = Color(0xFFDBE6DF);
  static const Color borderDark = Color(0xFF2A3C31);

  // Card Colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E3A2E);

  // Icon Background Colors
  static const Color iconBackgroundLight = Color(0xFFF0F4F2);
  static const Color iconBackgroundDark = Color(0xFF2A3C31);

  // Subtle Colors
  static const Color subtleLight = Color(0xFF8B9A8F);
  static const Color subtleDark = Color(0xFF6B7C71);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFF6B6B);

  // Success Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);

  // Warning Colors
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);

  // Info Colors
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);

  // Status Colors
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusVerified = Color(0xFF2196F3);
  static const Color statusAllocated = Color(0xFF9C27B0);
  static const Color statusDelivered = Color(0xFF4CAF50);
  static const Color statusExpired = Color(0xFFF44336);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, errorLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
