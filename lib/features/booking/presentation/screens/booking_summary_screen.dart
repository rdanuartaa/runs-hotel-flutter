import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFFD4B996) : const Color(0xFF7B6649);
    final cardColor = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header with back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(Icons.arrow_back_ios_new, size: 16, color: textColor),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Ringkasan Booking',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Content
            Expanded(
              child: BlocListener<BookingCubit, BookingState>(
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
                      _buildHotelCard(cardColor, textColor, subtextColor, accentColor, isDark)
                          .animate().fadeIn(duration: 400.ms),
                      const Gap(16),
                      // Details card
                      _buildDetailsCard(cardColor, textColor, subtextColor, accentColor, isDark)
                          .animate().fadeIn(delay: 200.ms),
                      const Gap(16),
                      // Price card
                      _buildPriceCard(accentColor, textColor)
                          .animate().fadeIn(delay: 400.ms),
                      const Gap(24),
                      // Pay button
                      BlocBuilder<BookingCubit, BookingState>(
                        builder: (context, state) {
                          return GestureDetector(
                            onTap: state is BookingLoading ? null : () => _handlePay(context),
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
                              child: state is BookingLoading
                                  ? const Center(child: SizedBox(
                                      width: 24, height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    ))
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.payment_rounded, color: Colors.white, size: 20),
                                        Gap(8),
                                        Text(
                                          'Bayar Sekarang',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),
                      const Gap(24),
                    ],
                  ),
                ),
              ),
            ),
          ],
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

  Widget _buildHotelCard(Color cardColor, Color textColor, Color subtextColor, Color accentColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              hotel.thumbnailUrl ?? 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?q=80&w=500',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                child: Icon(Icons.hotel, color: subtextColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hotel.name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                const Gap(4),
                Text(hotel.city, style: TextStyle(color: subtextColor, fontSize: 12)),
                const Gap(4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    room.name,
                    style: TextStyle(color: accentColor, fontWeight: FontWeight.w600, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(Color cardColor, Color textColor, Color subtextColor, Color accentColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _row(Icons.calendar_today_outlined, AppStrings.checkIn, DateFormatter.full(checkIn), accentColor, textColor, subtextColor),
          Divider(color: Colors.grey.withValues(alpha: 0.2), height: 20),
          _row(Icons.calendar_today_outlined, AppStrings.checkOut, DateFormatter.full(checkOut), accentColor, textColor, subtextColor),
          Divider(color: Colors.grey.withValues(alpha: 0.2), height: 20),
          _row(Icons.nights_stay_outlined, 'Durasi', '$totalNights malam', accentColor, textColor, subtextColor),
          Divider(color: Colors.grey.withValues(alpha: 0.2), height: 20),
          _row(Icons.person_outlined, AppStrings.guests, '$guests orang', accentColor, textColor, subtextColor),
        ],
      ),
    );
  }

  Widget _buildPriceCard(Color accentColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${room.name} x $totalNights malam',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                CurrencyFormatter.format(totalPrice),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const Gap(12),
          Container(height: 1, color: Colors.white24),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                CurrencyFormatter.format(totalPrice),
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, Color accentColor, Color textColor, Color subtextColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: accentColor),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: subtextColor, fontSize: 12, fontWeight: FontWeight.w600)),
            Text(value, style: TextStyle(color: textColor, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
