import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const primary = Color(0xFF1A56DB);
  static const primaryLight = Color(0xFF3B82F6);
  static const primaryDark = Color(0xFF0F3A8A);
  static const primarySurface = Color(0xFFEBF0FF);

  // Secondary
  static const secondary = Color(0xFFF59E0B);
  static const secondaryLight = Color(0xFFFBBF24);
  static const secondaryDark = Color(0xFFD97706);

  // Backgrounds
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1F5F9);
  static const scaffoldDark = Color(0xFF0F172A);

  // Text
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFFD1FAE5);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEE2E2);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFFDBEAFE);

  // Misc
  static const divider = Color(0xFFE2E8F0);
  static const shimmerBase = Color(0xFFE2E8F0);
  static const shimmerHighlight = Color(0xFFF8FAFC);
  static const overlay = Color(0x80000000);
  static const starRating = Color(0xFFFBBF24);

  // Gradient
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF3B82F6)],
  );

  static const heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0xCC000000)],
  );
}
