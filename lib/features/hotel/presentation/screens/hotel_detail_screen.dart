import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../cubit/hotel_cubit.dart';
import '../widgets/room_card.dart';
import '../widgets/review_card.dart';
import '../widgets/facility_chip.dart';
import '../widgets/image_gallery.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFFD4B996) : const Color(0xFF7B6649);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<HotelCubit, HotelState>(
        builder: (context, state) {
          if (state is HotelLoading || state is HotelInitial) {
            return Center(
              child: CircularProgressIndicator(color: accentColor),
            );
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
                  backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
                  leading: Padding(
                    padding: const EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: ImageGallery(
                      imageUrls: (hotel.imageUrls == null || hotel.imageUrls!.isEmpty)
                          ? [if (hotel.thumbnailUrl != null) hotel.thumbnailUrl!]
                          : hotel.imageUrls!,
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
                                  Text(
                                    hotel.name,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Gap(6),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_outlined,
                                          size: 16, color: subtextColor),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${hotel.address}, ${hotel.city}',
                                          style: TextStyle(color: subtextColor, fontSize: 12),
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
                                color: accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: Color(0xFFFFB800), size: 24),
                                  Text(
                                    hotel.avgRating.toStringAsFixed(1),
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${hotel.totalReviews} ulasan',
                                    style: TextStyle(color: subtextColor, fontSize: 11),
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
                                  const Icon(Icons.star_rounded, color: Color(0xFFFFB800)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Hotel Bintang ${hotel.starRating}',
                              style: TextStyle(
                                color: subtextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        // Description
                        if (hotel.description != null && hotel.description!.isNotEmpty) ...[
                          const Gap(20),
                          Text(
                            AppStrings.description,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn(delay: 100.ms),
                          const Gap(8),
                          Text(
                            hotel.description!,
                            style: TextStyle(
                              color: subtextColor,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ],

                        // Facilities
                        if (hotel.facilities.isNotEmpty) ...[
                          const Gap(20),
                          Text(
                            AppStrings.facilities,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                          const Gap(12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: hotel.facilities
                                .map((f) => FacilityChip(facility: f))
                                .toList(),
                          ),
                        ],

                        // Map Location
                        if (hotel.latitude != null && hotel.longitude != null) ...[
                          const Gap(24),
                          Text(
                            'Lokasi',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn(delay: 250.ms),
                          const Gap(12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              height: 200,
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(hotel.latitude!, hotel.longitude!),
                                  initialZoom: 15.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.hotelbooking.app',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(hotel.latitude!, hotel.longitude!),
                                        width: 80,
                                        height: 80,
                                        child: const Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: 250.ms),
                        ],

                        // Rooms
                        const Gap(24),
                        Text(
                          AppStrings.rooms,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(delay: 300.ms),
                        const Gap(12),
                        if (rooms.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.bed_outlined, size: 48, color: subtextColor),
                                const Gap(8),
                                Text(
                                  'Tidak ada kamar tersedia',
                                  style: TextStyle(color: subtextColor, fontSize: 14),
                                ),
                              ],
                            ),
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
                            Text(
                              AppStrings.reviews,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${reviews.length} ulasan',
                              style: TextStyle(color: subtextColor, fontSize: 12),
                            ),
                          ],
                        ).animate().fadeIn(delay: 400.ms),
                        const Gap(12),
                        if (reviews.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.rate_review_outlined, size: 48, color: subtextColor),
                                const Gap(8),
                                Text(
                                  'Belum ada ulasan',
                                  style: TextStyle(color: subtextColor, fontSize: 14),
                                ),
                                const Gap(4),
                                Text(
                                  'Jadilah yang pertama memberikan ulasan!',
                                  style: TextStyle(color: subtextColor, fontSize: 12),
                                ),
                              ],
                            ),
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
