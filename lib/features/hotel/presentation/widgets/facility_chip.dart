import 'package:flutter/material.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF56A8E5) : const Color(0xFF2171C4);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : accentColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : accentColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _facilityIcon,
              size: 16,
              color: isSelected ? Colors.white : accentColor,
            ),
            const SizedBox(width: 6),
            Text(
              facility,
              style: TextStyle(
                color: isSelected ? Colors.white : accentColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
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
