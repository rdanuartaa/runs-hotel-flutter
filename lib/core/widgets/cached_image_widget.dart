import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CachedImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedImageWidget({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) =>
            placeholder ?? _buildShimmerPlaceholder(),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.textTertiary,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.shimmerBase,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
