import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';

class PaymentStatusScreen extends StatelessWidget {
  final String status;

  const PaymentStatusScreen({super.key, required this.status});

  bool get isSuccess => status == 'success';
  bool get isPending => status == 'pending';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFFD4B996) : const Color(0xFF7B6649);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Status icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(_statusIcon, color: _statusColor, size: 50),
              ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
              const Gap(24),
              Text(
                _statusTitle,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),
              const Gap(12),
              Text(
                _statusMessage,
                style: TextStyle(color: subtextColor, fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 500.ms),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go('/bookings'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Lihat Booking',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms),
              const Gap(12),
              GestureDetector(
                onTap: () => context.go('/'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accentColor.withValues(alpha: 0.5)),
                  ),
                  child: Center(
                    child: Text(
                      'Kembali ke Beranda',
                      style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),
              const Gap(24),
            ],
          ),
        ),
      ),
    );
  }

  Color get _statusColor {
    if (isSuccess) return AppColors.success;
    if (isPending) return AppColors.warning;
    return AppColors.error;
  }

  IconData get _statusIcon {
    if (isSuccess) return Icons.check_circle_rounded;
    if (isPending) return Icons.access_time_rounded;
    return Icons.cancel_rounded;
  }

  String get _statusTitle {
    if (isSuccess) return 'Pembayaran Berhasil! 🎉';
    if (isPending) return 'Menunggu Pembayaran';
    return 'Pembayaran Gagal';
  }

  String get _statusMessage {
    if (isSuccess) return 'Booking kamu sudah dikonfirmasi. Selamat berlibur!';
    if (isPending) return 'Silakan selesaikan pembayaran sebelum batas waktu.';
    return 'Pembayaran tidak berhasil. Silakan coba lagi.';
  }
}
