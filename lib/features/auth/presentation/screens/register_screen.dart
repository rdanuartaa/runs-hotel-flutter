import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../cubit/auth_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUpWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/');
          } else if (state is AuthError) {
            DialogUtils.showError(context, state.message);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(8),
                  Text('Buat Akun Baru', style: AppTextStyles.h2)
                      .animate()
                      .fadeIn(duration: 400.ms),
                  const Gap(8),
                  Text(
                    'Daftar untuk mulai booking hotel impianmu',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                  const Gap(32),

                  CustomTextField(
                    label: AppStrings.fullName,
                    hint: 'Masukkan nama lengkap',
                    controller: _nameController,
                    validator: Validators.name,
                    prefixIcon: Icons.person_outlined,
                    textInputAction: TextInputAction.next,
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                  const Gap(16),

                  CustomTextField(
                    label: AppStrings.email,
                    hint: 'contoh@email.com',
                    controller: _emailController,
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    textInputAction: TextInputAction.next,
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                  const Gap(16),

                  CustomTextField(
                    label: AppStrings.phone,
                    hint: '08xxxxxxxxxx',
                    controller: _phoneController,
                    validator: Validators.phone,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    textInputAction: TextInputAction.next,
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                  const Gap(16),

                  CustomTextField(
                    label: AppStrings.password,
                    hint: 'Minimal 6 karakter',
                    controller: _passwordController,
                    validator: Validators.password,
                    obscureText: true,
                    prefixIcon: Icons.lock_outlined,
                    textInputAction: TextInputAction.next,
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                  const Gap(16),

                  CustomTextField(
                    label: AppStrings.confirmPassword,
                    hint: 'Ulangi password',
                    controller: _confirmPasswordController,
                    validator: (value) => Validators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
                    obscureText: true,
                    prefixIcon: Icons.lock_outlined,
                    textInputAction: TextInputAction.done,
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),
                  const Gap(32),

                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: AppStrings.register,
                        isLoading: state is AuthLoading,
                        onPressed: _handleRegister,
                      );
                    },
                  ).animate().fadeIn(delay: 700.ms),
                  const Gap(24),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.hasAccount,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(
                            AppStrings.login,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                  const Gap(24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
