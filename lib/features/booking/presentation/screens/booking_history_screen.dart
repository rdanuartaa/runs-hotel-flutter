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
            Tab(text: 'Dibatalkan'),
          ],
        ),
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
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
      case 'checked_in':
        color = AppColors.info;
        label = 'Check-in';
      case 'checked_out':
        color = AppColors.textSecondary;
        label = 'Selesai';
      case 'cancelled':
        color = AppColors.error;
        label = 'Dibatalkan';
      default:
        color = AppColors.warning;
        label = 'Menunggu';
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
