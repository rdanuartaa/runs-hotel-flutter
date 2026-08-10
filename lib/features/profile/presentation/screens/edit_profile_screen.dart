import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/cached_image_widget.dart';
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
          SnackBar(content: Text('Gagal upload avatar: $e'), backgroundColor: AppColors.error),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Edit Profil', style: AppTextStyles.h4),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocListener<AuthCubit, AuthState>(
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
                          ClipOval(
                            child: CachedImageWidget(
                              imageUrl: user.avatarUrl,
                              width: 100,
                              height: 100,
                              borderRadius: 50,
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
                        return CustomButton(
                          text: 'Simpan Perubahan',
                          isLoading: state is AuthLoading || _isLoading,
                          onPressed: _handleSave,
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
    );
  }
}
