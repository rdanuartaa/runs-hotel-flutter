import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../hotel/data/models/hotel_model.dart';
import '../../../hotel/data/models/room_model.dart';
import '../cubit/booking_cubit.dart';

class BookingSummaryScreen extends StatelessWidget {
  final HotelModel hotel;
  final RoomModel room;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final int totalPrice;
  final String? specialRequest;

  const BookingSummaryScreen({
    super.key,
    required this.hotel,
    required this.room,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalPrice,
    this.specialRequest,
  });

  int get totalNights => checkOut.difference(checkIn).inDays;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.bookingSummary, style: AppTextStyles.h4),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocListener<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingCreated) {
            context.go('/payment', extra: {'booking': state.booking});
          } else if (state is BookingError) {
            DialogUtils.showError(context, state.message);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Hotel info card
              _buildHotelCard().animate().fadeIn(duration: 400.ms),
              const Gap(16),
              // Details card
              _buildDetailsCard().animate().fadeIn(delay: 200.ms),
              const Gap(16),
              // Price card
              _buildPriceCard().animate().fadeIn(delay: 400.ms),
              const Gap(24),
              // Pay button
              BlocBuilder<BookingCubit, BookingState>(
                builder: (context, state) {
                  return CustomButton(
                    text: AppStrings.payNow,
                    isLoading: state is BookingLoading,
                    icon: Icons.payment_rounded,
                    onPressed: () => _handlePay(context),
                  );
                },
              ),
              const Gap(24),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePay(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<BookingCubit>().createBooking(
            userId: authState.user.id,
            hotelId: hotel.id,
            roomId: room.id,
            checkIn: checkIn,
            checkOut: checkOut,
            totalGuests: guests,
            totalPrice: totalPrice,
            specialRequest: specialRequest,
          );
    }
  }

  Widget _buildHotelCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CachedImageWidget(imageUrl: hotel.thumbnailUrl, width: 80, height: 80, borderRadius: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hotel.name, style: AppTextStyles.h4),
                const Gap(4),
                Text(hotel.city, style: AppTextStyles.bodySmall),
                const Gap(4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(6)),
                  child: Text(room.name, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _row(Icons.calendar_today_outlined, AppStrings.checkIn, DateFormatter.full(checkIn)),
          const Divider(color: AppColors.divider, height: 20),
          _row(Icons.calendar_today_outlined, AppStrings.checkOut, DateFormatter.full(checkOut)),
          const Divider(color: AppColors.divider, height: 20),
          _row(Icons.nights_stay_outlined, 'Durasi', '$totalNights malam'),
          const Divider(color: AppColors.divider, height: 20),
          _row(Icons.person_outlined, AppStrings.guests, '$guests orang'),
        ],
      ),
    );
  }

  Widget _buildPriceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${room.name} x $totalNights malam', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
              Text(CurrencyFormatter.format(totalPrice), style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
            ],
          ),
          const Gap(12),
          Container(height: 1, color: Colors.white24),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.totalPrice, style: AppTextStyles.h4.copyWith(color: Colors.white)),
              Text(CurrencyFormatter.format(totalPrice), style: AppTextStyles.h3.copyWith(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelMedium),
            Text(value, style: AppTextStyles.bodyMedium),
          ],
        ),
      ],
    );
  }
}
