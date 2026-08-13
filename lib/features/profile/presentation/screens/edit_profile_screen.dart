import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../../injection_container.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _nameController = TextEditingController(text: authState.user.fullName);
      _phoneController = TextEditingController(text: authState.user.phone ?? '');
    } else {
      _nameController = TextEditingController();
      _phoneController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (image == null || !mounted) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isLoading = true);
    try {
      final profileRepo = getIt<ProfileRepository>();
      final avatarUrl = await profileRepo.uploadAvatar(authState.user.id, File(image.path));
      if (mounted) {
        context.read<AuthCubit>().updateProfile(userId: authState.user.id, avatarUrl: avatarUrl);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload avatar: $e'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    context.read<AuthCubit>().updateProfile(
      userId: authState.user.id,
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFFD4B996) : const Color(0xFF7B6649);
    final cardColor = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header with back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(Icons.arrow_back_ios_new, size: 16, color: textColor),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Edit Profil',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Content
            Expanded(
              child: BlocListener<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Profil berhasil diperbarui'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is! AuthAuthenticated) return const SizedBox.shrink();
                    final user = state.user;
                    final userAvatar = user.avatarUrl ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.fullName)}&background=random';

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Gap(16),
                            // Avatar
                            GestureDetector(
                              onTap: _pickAndUploadAvatar,
                              child: Stack(
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
                              ),
                            ),
                            const Gap(24),
                            CustomTextField(
                              label: 'Nama Lengkap',
                              controller: _nameController,
                              validator: Validators.name,
                              prefixIcon: Icons.person_outlined,
                            ),
                            const Gap(16),
                            CustomTextField(
                              label: 'Email',
                              hint: user.email,
                              enabled: false,
                              prefixIcon: Icons.email_outlined,
                            ),
                            const Gap(16),
                            CustomTextField(
                              label: 'Nomor Telepon',
                              controller: _phoneController,
                              validator: Validators.phone,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone_outlined,
                            ),
                            const Gap(32),
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, state) {
                                return GestureDetector(
                                  onTap: (state is AuthLoading || _isLoading) ? null : _handleSave,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accentColor.withValues(alpha: 0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: (state is AuthLoading || _isLoading)
                                        ? const Center(child: SizedBox(
                                            width: 24, height: 24,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          ))
                                        : const Center(
                                            child: Text(
                                              'Simpan Perubahan',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
