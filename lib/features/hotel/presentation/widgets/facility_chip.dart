import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class FacilityChip extends StatelessWidget {
  final String facility;
  final bool isSelected;
  final VoidCallback? onTap;

  const FacilityChip({
    super.key,
    required this.facility,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.primarySurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.primarySurface,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _facilityIcon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              facility,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _facilityIcon {
    switch (facility.toLowerCase()) {
      case 'wifi':
      case 'free wifi':
        return Icons.wifi;
      case 'pool':
      case 'swimming pool':
      case 'kolam renang':
        return Icons.pool;
      case 'parking':
      case 'parkir':
        return Icons.local_parking;
      case 'gym':
      case 'fitness':
        return Icons.fitness_center;
      case 'restaurant':
      case 'restoran':
        return Icons.restaurant;
      case 'spa':
        return Icons.spa;
      case 'bar':
      case 'lounge':
        return Icons.local_bar;
      case 'ac':
      case 'air conditioner':
        return Icons.ac_unit;
      case 'laundry':
        return Icons.local_laundry_service;
      case 'room service':
        return Icons.room_service;
      case 'breakfast':
      case 'sarapan':
        return Icons.free_breakfast;
      case 'airport shuttle':
        return Icons.airport_shuttle;
      default:
        return Icons.check_circle_outline;
    }
  }
}
