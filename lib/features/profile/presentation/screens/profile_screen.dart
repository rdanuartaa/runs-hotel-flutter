import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline, size: 64, color: AppColors.textTertiary),
                  const Gap(16),
                  Text('Silakan login terlebih dahulu', style: AppTextStyles.bodyLarge),
                  const Gap(16),
                  CustomButton(
                    text: AppStrings.login,
                    width: 200,
                    onPressed: () => context.go('/login'),
                  ),
                ],
              ),
            );
          }

          final user = state.user;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Gap(16),
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: CachedImageWidget(
                            imageUrl: user.avatarUrl,
                            width: 100,
                            height: 100,
                            borderRadius: 50,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),

                  const Gap(16),
                  Text(user.fullName, style: AppTextStyles.h3)
                      .animate().fadeIn(delay: 200.ms),
                  const Gap(4),
                  Text(user.email, style: AppTextStyles.bodySmall)
                      .animate().fadeIn(delay: 300.ms),
                  if (user.phone != null) ...[
                    const Gap(4),
                    Text(user.phone!, style: AppTextStyles.bodySmall)
                        .animate().fadeIn(delay: 400.ms),
                  ],

                  const Gap(32),

                  // Menu items
                  _menuItem(
                    icon: Icons.person_outline,
                    title: AppStrings.editProfile,
                    onTap: () => context.push('/edit-profile'),
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

                  _menuItem(
                    icon: Icons.bookmark_border,
                    title: AppStrings.bookingHistory,
                    onTap: () => context.go('/bookings'),
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),

                  _menuItem(
                    icon: Icons.settings_outlined,
                    title: AppStrings.settings,
                    onTap: () {},
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),

                  _menuItem(
                    icon: Icons.help_outline,
                    title: 'Bantuan',
                    onTap: () {},
                  ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.1),

                  const Gap(24),



                  CustomButton(
                    text: AppStrings.logout,
                    backgroundColor: AppColors.error,
                    icon: Icons.logout_rounded,
                    onPressed: () => _showLogoutDialog(context),
                  ).animate().fadeIn(delay: 800.ms),

                  const Gap(32),
                  Text(
                    '${AppStrings.appName} v1.0.0',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: AppTextStyles.labelLarge),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().signOut();
            },
            child: const Text('Keluar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
