import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/booking_model.dart';
import '../cubit/booking_cubit.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  void _loadBookings() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<BookingCubit>().loadBookingHistory(authState.user.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.bookingHistory, style: AppTextStyles.h4),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Mendatang'),
            Tab(text: 'Selesai'),
            Tab(text: 'Refund / Batal'),
          ],
        ),
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading || state is BookingInitial) {
            return const LoadingWidget();
          }
          if (state is BookingHistoryLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(state.upcoming, 'upcoming'),
                _buildBookingList(state.completed, 'completed'),
                _buildBookingList(state.cancelled, 'cancelled'),
              ],
            );
          }
          if (state is BookingError) {
            return ErrorStateWidget(message: state.message, onRetry: _loadBookings);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings, String type) {
    if (bookings.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.bookmark_border_rounded,
        title: 'Tidak ada booking',
        subtitle: type == 'upcoming' ? 'Yuk mulai booking hotel!' : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadBookings(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return _BookingCard(booking: bookings[index], index: index);
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final int index;

  const _BookingCard({required this.booking, required this.index});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final checkInDate = DateTime(booking.checkIn.year, booking.checkIn.month, booking.checkIn.day);
    final daysUntilCheckIn = checkInDate.difference(todayDate).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CachedImageWidget(
              imageUrl: booking.hotelThumbnail,
              width: 80,
              height: 80,
              borderRadius: 10,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.hotelName ?? '-', style: AppTextStyles.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(DateFormatter.dateRange(booking.checkIn, booking.checkOut), style: AppTextStyles.bodySmall),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatusBadge(status: booking.status),
                      Text(CurrencyFormatter.format(booking.totalPrice), style: AppTextStyles.priceSmall.copyWith(fontSize: 13)),
                    ],
                  ),
                  if (booking.status == 'pending' || booking.status == 'confirmed') ...[
                    const SizedBox(height: 12),
                    if (daysUntilCheckIn >= 3)
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Ajukan Pembatalan'),
                                content: const Text('Apakah Anda yakin ingin membatalkan pesanan ini dan meminta pengembalian dana (refund)?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tidak')),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      final authState = context.read<AuthCubit>().state;
                                      if (authState is AuthAuthenticated) {
                                        context.read<BookingCubit>().cancelBooking(booking.id, authState.user.id);
                                      }
                                    },
                                    child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Ajukan Pembatalan (Refund)', style: TextStyle(fontSize: 12)),
                        ),
                      )
                    else
                      Text('Pembatalan maksimal H-3 sebelum Check-in', style: AppTextStyles.bodySmall.copyWith(color: Colors.red, fontStyle: FontStyle.italic)),
                  ] else if (booking.status == 'cancel_requested') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Pengajuan refund sedang diproses oleh Admin', style: AppTextStyles.bodySmall.copyWith(color: Colors.orange))),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index), duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'confirmed':
        color = AppColors.success;
        label = 'Dikonfirmasi';
        break;
      case 'checked_in':
        color = AppColors.info;
        label = 'Check-in';
        break;
      case 'checked_out':
        color = AppColors.textSecondary;
        label = 'Selesai';
        break;
      case 'cancel_requested':
        color = Colors.orange;
        label = 'Menunggu Refund';
        break;
      case 'cancelled':
        color = AppColors.error;
        label = 'Sukses Refund';
        break;
      default:
        color = AppColors.warning;
        label = 'Menunggu';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}
