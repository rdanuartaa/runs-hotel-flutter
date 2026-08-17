import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../data/models/hotel_model.dart';

class HotelCard extends StatelessWidget {
  final HotelModel hotel;
  final int index;

  const HotelCard({
    super.key,
    required this.hotel,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF56A8E5) : const Color(0xFF2171C4);
    final cardColor = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return GestureDetector(
      onTap: () => context.push('/hotel/${hotel.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                CachedImageWidget(
                  imageUrl: hotel.thumbnailUrl,
                  height: 180,
                  width: double.infinity,
                  borderRadius: 16,
                ),
                // Star badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${hotel.starRating}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          hotel.avgRating.toStringAsFixed(1),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          ' (${hotel.totalReviews})',
                          style: TextStyle(color: subtextColor, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: subtextColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${hotel.city}${hotel.province != null ? ', ${hotel.province}' : ''}',
                          style: TextStyle(color: subtextColor, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (hotel.distanceInMeters != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.directions_walk,
                          size: 14,
                          color: accentColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hotel.distanceInMeters! >= 1000
                              ? '${(hotel.distanceInMeters! / 1000).toStringAsFixed(1)} km dari Anda'
                              : '${hotel.distanceInMeters!.toStringAsFixed(0)} meter dari Anda',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  // Facilities preview
                  if (hotel.facilities.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: hotel.facilities
                          .take(3)
                          .map((f) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  f,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  if (hotel.facilities.isNotEmpty) const SizedBox(height: 10),
                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hotel.minPrice != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mulai dari',
                              style: TextStyle(color: subtextColor, fontSize: 11),
                            ),
                            Text(
                              CurrencyFormatter.format(hotel.minPrice!),
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () => context.push('/hotel/${hotel.id}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Lihat Detail',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: 400.ms,
        ).slideY(begin: 0.1, end: 0);
  }
}

