import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/cached_image_widget.dart';

class ImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final double borderRadius;

  const ImageGallery({
    super.key,
    required this.imageUrls,
    this.height = 280,
    this.borderRadius = 0,
  });

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return CachedImageWidget(
        height: widget.height,
        borderRadius: widget.borderRadius,
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return CachedImageWidget(
                imageUrl: widget.imageUrls[index],
                height: widget.height,
                width: double.infinity,
                borderRadius: widget.borderRadius,
              );
            },
          ),
        ),
        // Page indicator
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: widget.imageUrls.length,
                  effect: const WormEffect(
                    dotWidth: 8,
                    dotHeight: 8,
                    spacing: 6,
                    dotColor: Colors.white38,
                    activeDotColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        // Image counter
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.photo_library_outlined, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '${widget.imageUrls.length} foto',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
