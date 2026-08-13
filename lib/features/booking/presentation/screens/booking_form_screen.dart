import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../hotel/data/models/hotel_model.dart';
import '../../../hotel/data/models/room_model.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFFD4B996) : const Color(0xFF7B6649);

    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: accentColor,
                    onPrimary: Colors.white,
                    surface: const Color(0xFF1E1E1E),
                  )
                : ColorScheme.light(
                    primary: accentColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
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
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final accentColor = isDark ? const Color(0xFFD4B996) : const Color(0xFF7B6649);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih tanggal check-in dan check-out'),
          backgroundColor: accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
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
                        'Booking',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balance the back button
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hotel & Room Info
                    Container(
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
                              widget.hotel.thumbnailUrl ?? 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?q=80&w=500',
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
                                Text(
                                  widget.hotel.name,
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const Gap(4),
                                Text(
                                  widget.room.name,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  '${CurrencyFormatter.format(widget.room.pricePerNight)} /malam',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),

                    const Gap(20),

                    // Date Selection
                    Text(
                      'Tanggal Menginap',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                    const Gap(12),
                    GestureDetector(
                      onTap: _selectDateRange,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppStrings.checkIn, style: TextStyle(color: subtextColor, fontSize: 12, fontWeight: FontWeight.w600)),
                                  const Gap(4),
                                  Text(
                                    _dateRange != null
                                        ? DateFormatter.short(_dateRange!.start)
                                        : 'Pilih tanggal',
                                    style: TextStyle(
                                      color: _dateRange != null ? textColor : subtextColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(AppStrings.checkOut, style: TextStyle(color: subtextColor, fontSize: 12, fontWeight: FontWeight.w600)),
                                    const Gap(4),
                                    Text(
                                      _dateRange != null
                                          ? DateFormatter.short(_dateRange!.end)
                                          : 'Pilih tanggal',
                                      style: TextStyle(
                                        color: _dateRange != null ? textColor : subtextColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Icon(Icons.calendar_today_outlined,
                                color: accentColor, size: 20),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    if (_dateRange != null) ...[
                      const Gap(8),
                      Text(
                        '$_totalNights malam',
                        style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],

                    const Gap(20),

                    // Guest counter
                    Text(
                      AppStrings.guests,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const Gap(12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Jumlah Tamu', style: TextStyle(color: textColor, fontSize: 14)),
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
                                accentColor: accentColor,
                                isDark: isDark,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  '$_guestCount',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                accentColor: accentColor,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    const Gap(4),
                    Text(
                      'Maks. ${widget.room.maxGuests} tamu',
                      style: TextStyle(color: subtextColor, fontSize: 11),
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
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            _buildPriceRow(
                              '${CurrencyFormatter.format(widget.room.pricePerNight)} x $_totalNights malam',
                              CurrencyFormatter.format(_totalPrice),
                              textColor: textColor,
                              accentColor: accentColor,
                            ),
                            Divider(color: accentColor.withValues(alpha: 0.2), height: 20),
                            _buildPriceRow(
                              AppStrings.totalPrice,
                              CurrencyFormatter.format(_totalPrice),
                              isBold: true,
                              textColor: textColor,
                              accentColor: accentColor,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 600.ms),

                    const Gap(24),

                    // Book button
                    GestureDetector(
                      onTap: _handleBooking,
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Lanjut ke Ringkasan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Gap(8),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 700.ms),

                    const Gap(24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
    required Color accentColor,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? accentColor : (isDark ? Colors.grey[800] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : (isDark ? Colors.grey[600] : Colors.grey[400]),
          size: 18,
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {
    bool isBold = false,
    required Color textColor,
    required Color accentColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 14 : 13,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: isBold ? accentColor : textColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 18 : 13,
          ),
        ),
      ],
    );
  }
}
