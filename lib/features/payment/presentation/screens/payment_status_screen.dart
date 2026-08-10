import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';

class PaymentStatusScreen extends StatelessWidget {
  final String status;

  const PaymentStatusScreen({super.key, required this.status});

  bool get isSuccess => status == 'success';
  bool get isPending => status == 'pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                  color: _statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_statusIcon, color: _statusColor, size: 50),
              ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
              const Gap(24),
              Text(_statusTitle, style: AppTextStyles.h2, textAlign: TextAlign.center)
                  .animate().fadeIn(delay: 300.ms),
              const Gap(12),
              Text(
                _statusMessage,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 500.ms),
              const Spacer(),
              CustomButton(
                text: 'Lihat Booking',
                onPressed: () => context.go('/bookings'),
              ).animate().fadeIn(delay: 700.ms),
              const Gap(12),
              CustomButton(
                text: 'Kembali ke Beranda',
                isOutlined: true,
                onPressed: () => context.go('/'),
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
