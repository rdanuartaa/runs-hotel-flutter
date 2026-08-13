import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../booking/presentation/cubit/booking_cubit.dart';
import 'package:go_router/go_router.dart';

import '../../../booking/data/models/booking_model.dart';
import 'package:gap/gap.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  String _selectedFilter = 'all';

  final List<Map<String, String>> _filters = [
    {'id': 'all', 'label': 'Semua'},
    {'id': 'cancel_requested', 'label': 'Menunggu Refund'},
    {'id': 'confirmed', 'label': 'Confirmed'},
    {'id': 'checked_in', 'label': 'In House'},
    {'id': 'checked_out', 'label': 'Selesai'},
    {'id': 'pending', 'label': 'Pending'},
    {'id': 'cancelled', 'label': 'Sukses Refund'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(Icons.arrow_back, color: textColor, size: 20),
                    ),
                  ),
                  const Gap(16),
                  Text(
                    'Kelola Pesanan',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          // Filter Section
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (context, index) => const Gap(8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter['id'];
                
                return FilterChip(
                  label: Text(filter['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = filter['id']!;
                    });
                  },
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                );
              },
            ),
          ),
          const Gap(12),
          
          // List Section
          Expanded(
            child: BlocBuilder<BookingCubit, BookingState>(
              builder: (context, state) {
                if (state is BookingLoading || state is BookingInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (state is BookingError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const Gap(16),
                        Text(state.message, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
                        const Gap(16),
                        ElevatedButton(
                          onPressed: () => context.read<BookingCubit>().loadAllBookings(),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is AllBookingsLoaded) {
                  List<BookingModel> bookings = state.bookings;
                  
                  // Apply Filter
                  if (_selectedFilter != 'all') {
                    bookings = bookings.where((b) => b.status == _selectedFilter).toList();
                  }
                  
                  if (bookings.isEmpty) {
                    return Center(child: Text('Belum ada pesanan.', style: AppTextStyles.bodyLarge));
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return _buildBookingCard(context, booking);
                    },
                  );
                }
                
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking) {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    // Logic untuk Attention/Warning Badges
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final checkInDate = DateTime(booking.checkIn.year, booking.checkIn.month, booking.checkIn.day);
    final checkOutDate = DateTime(booking.checkOut.year, booking.checkOut.month, booking.checkOut.day);
    
    Widget? attentionBadge;
    Color cardBorder = _getStatusColor(booking.status);
    
    if (booking.status == 'cancel_requested') {
      attentionBadge = _buildBadge('MENUNGGU REFUND', Colors.red);
    } else if (booking.status == 'confirmed' && (todayDate.isAtSameMomentAs(checkInDate) || todayDate.isAfter(checkInDate))) {
      attentionBadge = _buildBadge('TUNGGU CHECK-IN HARI INI', Colors.orange);
    } else if (booking.status == 'checked_in' && (todayDate.isAtSameMomentAs(checkOutDate) || todayDate.isAfter(checkOutDate))) {
      attentionBadge = _buildBadge('TUNGGU CHECK-OUT HARI INI', AppColors.primary);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cardBorder.withOpacity(0.5), width: 1.5),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () async {
          final result = await context.push('/admin/bookings/detail', extra: booking);
          if (result == true && context.mounted) {
            context.read<BookingCubit>().loadAllBookings();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (attentionBadge != null) ...[
                attentionBadge,
                const Gap(8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('${booking.hotelName ?? 'Hotel'} - ${booking.roomName ?? 'Kamar'}', 
                      style: AppTextStyles.h4, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
              const Gap(8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Check-in: ${DateFormat('dd MMM yyyy').format(booking.checkIn)}', style: AppTextStyles.bodySmall),
                        Text('Pemesan: ${booking.userName ?? '-'}', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(booking.statusDisplay, style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(booking.status))),
                        Text(formatCurrency.format(booking.totalPrice), style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(booking.status).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusDescription(booking.status),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _getStatusColor(booking.status).withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'confirmed': return 'Pesanan dikonfirmasi. Menunggu jadwal check-in tamu.';
      case 'checked_in': return 'Tamu saat ini sedang berada di hotel (In House).';
      case 'checked_out': return 'Pesanan telah selesai. Tamu sudah check-out.';
      case 'cancelled': return 'Pesanan dibatalkan. Dana (Refund) telah berhasil dikembalikan.';
      case 'cancel_requested': return 'Tamu mengajukan pembatalan. Harap segera proses refund.';
      case 'pending': default: return 'Menunggu tamu menyelesaikan proses pembayaran.';
    }
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 14, color: color),
          const Gap(4),
          Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.green;
      case 'checked_in': return Colors.blue;
      case 'checked_out': return AppColors.primary;
      case 'cancelled': return Colors.red;
      case 'cancel_requested': return Colors.orange;
      case 'pending': default: return Colors.orange;
    }
  }
}
