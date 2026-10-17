import 'package:flutter/material.dart';

enum AppThemeMode {
  cyberDark,
  oledBlack,
  modernLight,
}

class AppColors {
  final Color background;
  final Color surface;
  final Color displayBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color numBtnBg;
  final Color numBtnText;
  final Color opBtnBg;
  final Color opBtnText;
  final Color sciBtnBg;
  final Color sciBtnText;
  final Color equalsBtnBg;
  final Color equalsBtnText;
  final Color actionBtnBg; // AC, Del
  final Color actionBtnText;
  final Color accent;

  const AppColors({
    required this.background,
    required this.surface,
    required this.displayBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.numBtnBg,
    required this.numBtnText,
    required this.opBtnBg,
    required this.opBtnText,
    required this.sciBtnBg,
    required this.sciBtnText,
    required this.equalsBtnBg,
    required this.equalsBtnText,
    required this.actionBtnBg,
    required this.actionBtnText,
    required this.accent,
  });

  static const cyberDark = AppColors(
    background: Color(0xFF0F141C),
    surface: Color(0xFF181F2C),
    displayBg: Color(0xFF131924),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    numBtnBg: Color(0xFF1E2638),
    numBtnText: Color(0xFFFFFFFF),
    opBtnBg: Color(0xFFFF9F0A),
    opBtnText: Color(0xFFFFFFFF),
    sciBtnBg: Color(0xFF263349),
    sciBtnText: Color(0xFF38BDF8),
    equalsBtnBg: Color(0xFF10B981),
    equalsBtnText: Color(0xFFFFFFFF),
    actionBtnBg: Color(0xFFEF4444),
    actionBtnText: Color(0xFFFFFFFF),
    accent: Color(0xFF38BDF8),
  );

  static const oledBlack = AppColors(
    background: Color(0xFF000000),
    surface: Color(0xFF111111),
    displayBg: Color(0xFF0A0A0A),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF888888),
    numBtnBg: Color(0xFF1C1C1E),
    numBtnText: Color(0xFFFFFFFF),
    opBtnBg: Color(0xFFFF9500),
    opBtnText: Color(0xFFFFFFFF),
    sciBtnBg: Color(0xFF2C2C2E),
    sciBtnText: Color(0xFF0A84FF),
    equalsBtnBg: Color(0xFF30D158),
    equalsBtnText: Color(0xFFFFFFFF),
    actionBtnBg: Color(0xFFFF453A),
    actionBtnText: Color(0xFFFFFFFF),
    accent: Color(0xFF0A84FF),
  );

  static const modernLight = AppColors(
    background: Color(0xFFF1F5F9),
    surface: Color(0xFFFFFFFF),
    displayBg: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    numBtnBg: Color(0xFFFFFFFF),
    numBtnText: Color(0xFF1E293B),
    opBtnBg: Color(0xFFF59E0B),
    opBtnText: Color(0xFFFFFFFF),
    sciBtnBg: Color(0xFFE0E7FF),
    sciBtnText: Color(0xFF4338CA),
    equalsBtnBg: Color(0xFF059669),
    equalsBtnText: Color(0xFFFFFFFF),
    actionBtnBg: Color(0xFFFEE2E2),
    actionBtnText: Color(0xFFDC2626),
    accent: Color(0xFF2563EB),
  );

  static AppColors of(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.cyberDark:
        return cyberDark;
      case AppThemeMode.oledBlack:
        return oledBlack;
      case AppThemeMode.modernLight:
        return modernLight;
    }
  }
}
