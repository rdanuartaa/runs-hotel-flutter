import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../cubit/hotel_cubit.dart';
import '../widgets/hotel_card.dart';
import '../widgets/room_card.dart';
import '../widgets/review_card.dart';
import '../widgets/facility_chip.dart';
import '../widgets/image_gallery.dart';

class HotelDetailScreen extends StatefulWidget {
  final String hotelId;

  const HotelDetailScreen({super.key, required this.hotelId});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HotelCubit>().loadHotelDetail(widget.hotelId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HotelCubit, HotelState>(
        builder: (context, state) {
          if (state is HotelLoading) {
            return const LoadingWidget();
          }

          if (state is HotelError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () => context.read<HotelCubit>().loadHotelDetail(widget.hotelId),
            );
          }

          if (state is HotelDetailLoaded) {
            final hotel = state.hotel;
            final rooms = state.rooms;
            final reviews = state.reviews;

            return CustomScrollView(
              slivers: [
                // Image Gallery with App Bar
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: AppColors.surface,
                  leading: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        color: AppColors.textPrimary,
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: ImageGallery(
                      imageUrls: hotel.imageUrls ?? [if (hotel.thumbnailUrl != null) hotel.thumbnailUrl!],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hotel name & rating
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(hotel.name, style: AppTextStyles.h2),
                                  const Gap(6),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          size: 16, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${hotel.address}, ${hotel.city}',
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Rating card
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: AppColors.starRating, size: 24),
                                  Text(
                                    hotel.avgRating.toStringAsFixed(1),
                                    style: AppTextStyles.h4.copyWith(color: AppColors.primary),
                                  ),
                                  Text(
                                    '${hotel.totalReviews} ulasan',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 400.ms),

                        const Gap(8),
                        // Star rating
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: hotel.starRating.toDouble(),
                              itemSize: 18,
                              itemBuilder: (context, _) =>
                                  const Icon(Icons.star_rounded, color: AppColors.secondary),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Hotel Bintang ${hotel.starRating}',
                              style: AppTextStyles.labelMedium,
                            ),
                          ],
                        ),

                        // Description
                        if (hotel.description != null && hotel.description!.isNotEmpty) ...[
                          const Gap(20),
                          Text(AppStrings.description, style: AppTextStyles.h4)
                              .animate().fadeIn(delay: 100.ms),
                          const Gap(8),
                          Text(
                            hotel.description!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ],

                        // Facilities
                        if (hotel.facilities.isNotEmpty) ...[
                          const Gap(20),
                          Text(AppStrings.facilities, style: AppTextStyles.h4)
                              .animate().fadeIn(delay: 200.ms),
                          const Gap(12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: hotel.facilities
                                .map((f) => FacilityChip(facility: f))
                                .toList(),
                          ),
                        ],

                        // Rooms
                        const Gap(24),
                        Text(AppStrings.rooms, style: AppTextStyles.h4)
                            .animate().fadeIn(delay: 300.ms),
                        const Gap(12),
                        if (rooms.isEmpty)
                          const EmptyStateWidget(
                            icon: Icons.bed_outlined,
                            title: 'Tidak ada kamar tersedia',
                          )
                        else
                          ...rooms.map((room) => RoomCard(
                                room: room,
                                onSelect: () => context.push(
                                  '/booking',
                                  extra: {
                                    'hotel': hotel,
                                    'room': room,
                                  },
                                ),
                              )),

                        // Reviews
                        const Gap(24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppStrings.reviews, style: AppTextStyles.h4),
                            Text(
                              '${reviews.length} ulasan',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ).animate().fadeIn(delay: 400.ms),
                        const Gap(12),
                        if (reviews.isEmpty)
                          const EmptyStateWidget(
                            icon: Icons.rate_review_outlined,
                            title: 'Belum ada ulasan',
                            subtitle: 'Jadilah yang pertama memberikan ulasan!',
                          )
                        else
                          ...reviews.map((review) => ReviewCard(review: review)),

                        const Gap(32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
