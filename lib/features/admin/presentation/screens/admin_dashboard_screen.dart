import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Admin Dashboard', style: AppTextStyles.h3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _adminCard(
              context: context,
              title: 'Kelola Hotel & Kamar',
              icon: Icons.hotel,
              color: Colors.blueAccent,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Kelola Hotel segera hadir!')),
                );
              },
            ),
            const Gap(16),
            _adminCard(
              context: context,
              title: 'Semua Pesanan (Bookings)',
              icon: Icons.list_alt,
              color: Colors.green,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Semua Pesanan segera hadir!')),
                );
              },
            ),
            const Gap(16),
            _adminCard(
              context: context,
              title: 'Laporan Pendapatan',
              icon: Icons.attach_money,
              color: Colors.orange,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Laporan segera hadir!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Gap(16),
            Expanded(
              child: Text(title, style: AppTextStyles.h4),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
