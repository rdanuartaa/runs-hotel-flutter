import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF56A8E5) : const Color(0xFF2171C4);
    final cardColor = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 64, color: subtextColor),
                  const Gap(16),
                  Text(
                    'Silakan login terlebih dahulu',
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                  const Gap(16),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final user = state.user;
          final userAvatar = user.avatarUrl ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.fullName)}&background=random';

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.read<ThemeCubit>().toggleTheme();
                          },
                          child: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            size: 24,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Gap(8),

                  // Avatar
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: accentColor, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                          backgroundImage: NetworkImage(userAvatar),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),

                  const Gap(16),
                  Text(
                    user.fullName,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const Gap(4),
                  Text(
                    user.email,
                    style: TextStyle(color: subtextColor, fontSize: 12),
                  ).animate().fadeIn(delay: 300.ms),
                  if (user.phone != null) ...[
                    const Gap(4),
                    Text(
                      user.phone!,
                      style: TextStyle(color: subtextColor, fontSize: 12),
                    ).animate().fadeIn(delay: 400.ms),
                  ],

                  const Gap(32),

                  // Menu items
                  _menuItem(
                    context: context,
                    icon: Icons.person_outline,
                    title: AppStrings.editProfile,
                    onTap: () => context.push('/edit-profile'),
                    accentColor: accentColor,
                    cardColor: cardColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    isDark: isDark,
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

                  _menuItem(
                    context: context,
                    icon: Icons.bookmark_border,
                    title: AppStrings.bookingHistory,
                    onTap: () => context.go('/bookings'),
                    accentColor: accentColor,
                    cardColor: cardColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    isDark: isDark,
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),

                  _menuItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: AppStrings.settings,
                    onTap: () {},
                    accentColor: accentColor,
                    cardColor: cardColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    isDark: isDark,
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),

                  _menuItem(
                    context: context,
                    icon: Icons.help_outline,
                    title: 'Bantuan',
                    onTap: () {},
                    accentColor: accentColor,
                    cardColor: cardColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    isDark: isDark,
                  ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.1),

                  const Gap(24),

                  // Logout button
                  GestureDetector(
                    onTap: () => _showLogoutDialog(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.red[400], size: 20),
                          const Gap(8),
                          Text(
                            AppStrings.logout,
                            style: TextStyle(
                              color: Colors.red[400],
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms),

                  const Gap(32),
                  Text(
                    '${AppStrings.appName} v1.0.0',
                    style: TextStyle(color: subtextColor, fontSize: 11),
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
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color accentColor,
    required Color cardColor,
    required Color textColor,
    required Color subtextColor,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accentColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: subtextColor, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Keluar', style: TextStyle(color: textColor)),
        content: Text('Yakin ingin keluar dari akun?', style: TextStyle(color: textColor)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().signOut();
            },
            child: Text('Keluar', style: TextStyle(color: Colors.red[400])),
          ),
        ],
      ),
    );
  }
}
