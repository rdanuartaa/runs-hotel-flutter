import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class DialogUtils {
  /// Menampilkan modal sukses dengan icon centang
  static Future<void> showSuccess(BuildContext context, String message) async {
    await _showCustomDialog(
      context: context,
      icon: Icons.check_circle_outline_rounded,
      iconColor: AppColors.success,
      message: message,
    );
  }

  /// Menampilkan modal error dengan icon silang/seru
  static Future<void> showError(BuildContext context, String message) async {
    await _showCustomDialog(
      context: context,
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.error,
      message: message,
    );
  }

  /// Menampilkan modal peringatan
  static Future<void> showWarning(BuildContext context, String message) async {
    await _showCustomDialog(
      context: context,
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.warning,
      message: message,
    );
  }

  static Future<void> _showCustomDialog({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String message,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (dialogContext) {
        // Otomatis menutup setelah 2 detik
        Future.delayed(const Duration(seconds: 2), () {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        });

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 56),
                  ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                  const Gap(24),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9)),
          ),
        );
      },
    );
  }
}
