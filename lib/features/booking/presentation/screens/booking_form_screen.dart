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
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../hotel/data/models/hotel_model.dart';
import '../../../hotel/data/models/room_model.dart';
import '../cubit/booking_cubit.dart';

class BookingFormScreen extends StatefulWidget {
  final HotelModel hotel;
  final RoomModel room;

  const BookingFormScreen({
    super.key,
    required this.hotel,
    required this.room,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  DateTimeRange? _dateRange;
  int _guestCount = 1;
  final _specialRequestController = TextEditingController();

  @override
  void dispose() {
    _specialRequestController.dispose();
    super.dispose();
  }

  int get _totalNights =>
      _dateRange != null ? _dateRange!.end.difference(_dateRange!.start).inDays : 0;

  int get _totalPrice => _totalNights * widget.room.pricePerNight;

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  void _handleBooking() {
    if (_dateRange == null) {
      DialogUtils.showWarning(context, 'Pilih tanggal check-in dan check-out');
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      context.go('/login');
      return;
    }

    context.push('/booking-summary', extra: {
      'hotel': widget.hotel,
      'room': widget.room,
      'checkIn': _dateRange!.start,
      'checkOut': _dateRange!.end,
      'guests': _guestCount,
      'totalPrice': _totalPrice,
      'specialRequest': _specialRequestController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Booking', style: AppTextStyles.h4),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel & Room Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CachedImageWidget(
                    imageUrl: widget.hotel.thumbnailUrl,
                    width: 80,
                    height: 80,
                    borderRadius: 10,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.hotel.name, style: AppTextStyles.labelLarge),
                        const Gap(4),
                        Text(
                          widget.room.name,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          '${CurrencyFormatter.format(widget.room.pricePerNight)} /malam',
                          style: AppTextStyles.priceSmall.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const Gap(20),

            // Date Selection
            Text('Tanggal Menginap', style: AppTextStyles.h4)
                .animate().fadeIn(delay: 100.ms),
            const Gap(12),
            GestureDetector(
              onTap: _selectDateRange,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.checkIn, style: AppTextStyles.labelMedium),
                          const Gap(4),
                          Text(
                            _dateRange != null
                                ? DateFormatter.short(_dateRange!.start)
                                : 'Pilih tanggal',
                            style: _dateRange != null
                                ? AppTextStyles.bodyMedium
                                : AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: AppColors.divider,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.checkOut, style: AppTextStyles.labelMedium),
                            const Gap(4),
                            Text(
                              _dateRange != null
                                  ? DateFormatter.short(_dateRange!.end)
                                  : 'Pilih tanggal',
                              style: _dateRange != null
                                  ? AppTextStyles.bodyMedium
                                  : AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Icon(Icons.calendar_today_outlined,
                        color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),

            if (_dateRange != null) ...[
              const Gap(8),
              Text(
                '$_totalNights malam',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
              ),
            ],

            const Gap(20),

            // Guest counter
            Text(AppStrings.guests, style: AppTextStyles.h4)
                .animate().fadeIn(delay: 300.ms),
            const Gap(12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Jumlah Tamu', style: AppTextStyles.bodyMedium),
                  Row(
                    children: [
                      _buildCounterButton(
                        icon: Icons.remove,
                        onTap: () {
                          if (_guestCount > 1) {
                            setState(() => _guestCount--);
                          }
                        },
                        enabled: _guestCount > 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '$_guestCount',
                          style: AppTextStyles.h4,
                        ),
                      ),
                      _buildCounterButton(
                        icon: Icons.add,
                        onTap: () {
                          if (_guestCount < widget.room.maxGuests) {
                            setState(() => _guestCount++);
                          }
                        },
                        enabled: _guestCount < widget.room.maxGuests,
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),
            const Gap(4),
            Text(
              'Maks. ${widget.room.maxGuests} tamu',
              style: AppTextStyles.caption,
            ),

            const Gap(20),

            // Special Request
            CustomTextField(
              label: AppStrings.specialRequest,
              hint: 'Contoh: Kamar lantai tinggi, extra bed...',
              controller: _specialRequestController,
              maxLines: 3,
              prefixIcon: Icons.edit_note,
            ).animate().fadeIn(delay: 500.ms),

            const Gap(24),

            // Price summary
            if (_dateRange != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _buildPriceRow(
                      '${CurrencyFormatter.format(widget.room.pricePerNight)} x $_totalNights malam',
                      CurrencyFormatter.format(_totalPrice),
                    ),
                    const Divider(color: AppColors.divider, height: 20),
                    _buildPriceRow(
                      AppStrings.totalPrice,
                      CurrencyFormatter.format(_totalPrice),
                      isBold: true,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms),

            const Gap(24),

            CustomButton(
              text: 'Lanjut ke Ringkasan',
              onPressed: _handleBooking,
              icon: Icons.arrow_forward_rounded,
            ).animate().fadeIn(delay: 700.ms),

            const Gap(24),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : AppColors.textTertiary,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold ? AppTextStyles.labelLarge : AppTextStyles.bodyMedium,
        ),
        Text(
          amount,
          style: isBold ? AppTextStyles.price : AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}
