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
import '../cubit/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
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
                  const Gap(48),
                  // Logo & Welcome
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.hotel_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                      ),
                  const Gap(24),
                  Center(
                    child: Text(AppStrings.appName, style: AppTextStyles.h1),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  const Gap(8),
                  Center(
                    child: Text(
                      'Selamat datang kembali!',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                  const Gap(40),

                  // Email field
                  CustomTextField(
                    label: AppStrings.email,
                    hint: 'contoh@email.com',
                    controller: _emailController,
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    textInputAction: TextInputAction.next,
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                  const Gap(16),

                  // Password field
                  CustomTextField(
                    label: AppStrings.password,
                    hint: 'Masukkan password',
                    controller: _passwordController,
                    validator: Validators.password,
                    obscureText: true,
                    prefixIcon: Icons.lock_outlined,
                    textInputAction: TextInputAction.done,
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Navigate to forgot password
                      },
                      child: Text(
                        AppStrings.forgotPassword,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),

                  // Login button
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: AppStrings.login,
                        isLoading: state is AuthLoading,
                        onPressed: _handleLogin,
                      );
                    },
                  ).animate().fadeIn(delay: 600.ms),
                  const Gap(24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.divider)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppStrings.orContinueWith,
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.divider)),
                    ],
                  ).animate().fadeIn(delay: 700.ms),
                  const Gap(24),

                  // Google Sign In
                  CustomButton(
                    text: AppStrings.loginWithGoogle,
                    isOutlined: true,
                    icon: Icons.g_mobiledata_rounded,
                    onPressed: () {
                      context.read<AuthCubit>().signInWithGoogle();
                    },
                  ).animate().fadeIn(delay: 800.ms),
                  const Gap(32),

                  // Register link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.noAccount,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          child: Text(
                            AppStrings.register,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 900.ms),
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
