import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../hotel/data/models/hotel_model.dart';
import '../../../hotel/presentation/widgets/hotel_card.dart';
import '../cubit/home_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => context.read<HomeCubit>().loadHomeData(category: _selectedCategory),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),
              // Search bar
              SliverToBoxAdapter(
                child: _buildSearchBar(),
              ),
              // Category chips
              SliverToBoxAdapter(
                child: _buildCategoryChips(),
              ),
              // Content
              SliverToBoxAdapter(
                child: BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: List.generate(3, (_) => const HotelCardShimmer()),
                        ),
                      );
                    }

                    if (state is HomeError) {
                      return ErrorStateWidget(
                        message: state.message,
                        onRetry: () => context.read<HomeCubit>().loadHomeData(category: _selectedCategory),
                      );
                    }

                    if (state is HomeLoaded) {
                      return Column(
                        children: [
                          // Popular Hotels Section
                          if (state.popularHotels.isNotEmpty) ...[
                            _buildSectionHeader(
                              AppStrings.popularHotels,
                              onViewAll: () => context.push('/hotels'),
                            ),
                            _buildPopularHotelsCarousel(state.popularHotels),
                          ],
                          // All Hotels
                          _buildSectionHeader(
                            'Semua Hotel',
                            onViewAll: () => context.push('/hotels'),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: state.allHotels
                                  .asMap()
                                  .entries
                                  .map((entry) => HotelCard(
                                        hotel: entry.value,
                                        index: entry.key,
                                      ))
                                  .toList(),
                            ),
                          ),
                          const Gap(24),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final userName = state is AuthAuthenticated
            ? state.user.fullName
            : 'Tamu';

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hai, $userName! 👋',
                      style: AppTextStyles.h3,
                    ).animate().fadeIn(duration: 500.ms),
                    const Gap(4),
                    Text(
                      AppStrings.appTagline,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                  ],
                ),
              ),
              // Notification bell
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
              ).animate().fadeIn(delay: 300.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: GestureDetector(
        onTap: () => context.push('/hotels'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textTertiary, size: 20),
              const SizedBox(width: 12),
              Text(
                AppStrings.searchHint,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildCategoryChips() {
    final categories = [
      {'label': 'Semua', 'icon': Icons.grid_view_rounded},
      {'label': '⭐ 5', 'icon': Icons.star_rounded},
      {'label': 'Suite', 'icon': Icons.king_bed_outlined},
      {'label': 'Budget', 'icon': Icons.savings_outlined},
      {'label': 'Resort', 'icon': Icons.beach_access_outlined},
    ];

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat['label'];
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat['label'] as String),
              selected: isSelected,
              onSelected: (selected) {
                if (selected && _selectedCategory != cat['label']) {
                  setState(() {
                    _selectedCategory = cat['label'] as String;
                  });
                  context.read<HomeCubit>().loadHomeData(category: _selectedCategory);
                }
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                ),
              ),
              showCheckmark: false,
            ),
          ).animate().fadeIn(
                delay: Duration(milliseconds: 500 + (index * 80)),
              );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.h4),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                AppStrings.viewAll,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPopularHotelsCarousel(List<HotelModel> hotels) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: hotels.length,
        itemBuilder: (context, index) {
          final hotel = hotels[index];
          return GestureDetector(
            onTap: () => context.push('/hotel/${hotel.id}'),
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Stack(
                    children: [
                      CachedImageWidget(
                        imageUrl: hotel.thumbnailUrl,
                        height: 150,
                        width: 220,
                        borderRadius: 16,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppColors.starRating, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                hotel.avgRating.toStringAsFixed(1),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hotel.name,
                          style: AppTextStyles.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 12, color: AppColors.textTertiary),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                hotel.city,
                                style: AppTextStyles.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Gap(6),
                        if (hotel.minPrice != null)
                          Text(
                            '${CurrencyFormatter.format(hotel.minPrice!)}/malam',
                            style: AppTextStyles.priceSmall.copyWith(fontSize: 14),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(
                delay: Duration(milliseconds: 100 * index),
                duration: 400.ms,
              ).slideX(begin: 0.2, end: 0);
        },
      ),
    );
  }
}
