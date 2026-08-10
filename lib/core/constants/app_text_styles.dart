import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _baseStyle => GoogleFonts.plusJakartaSans();

  // Headings
  static TextStyle get h1 => _baseStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get h2 => _baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get h3 => _baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get h4 => _baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // Body
  static TextStyle get bodyLarge => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  // Labels
  static TextStyle get labelLarge => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.1,
      );

  static TextStyle get labelSmall => _baseStyle.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
        letterSpacing: 0.15,
      );

  // Special
  static TextStyle get price => _baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      );

  static TextStyle get priceSmall => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  static TextStyle get button => _baseStyle.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle get caption => _baseStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
      );
}
