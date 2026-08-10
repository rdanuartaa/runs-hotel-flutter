import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../cubit/hotel_cubit.dart';
import '../widgets/hotel_card.dart';

class HotelListScreen extends StatefulWidget {
  final String? searchQuery;
  final String? city;
  final int? starRating;

  const HotelListScreen({
    super.key,
    this.searchQuery,
    this.city,
    this.starRating,
  });

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
    }
    _loadHotels();
  }

  void _loadHotels() {
    context.read<HotelCubit>().loadHotels(
          search: _searchController.text.isEmpty ? null : _searchController.text,
          city: widget.city,
          starRating: widget.starRating,
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Cari Hotel', style: AppTextStyles.h4),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _loadHotels(),
              decoration: InputDecoration(
                hintText: AppStrings.searchHint,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _loadHotels();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // Results
          Expanded(
            child: BlocBuilder<HotelCubit, HotelState>(
              builder: (context, state) {
                if (state is HotelLoading) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 3,
                    itemBuilder: (_, __) => const HotelCardShimmer(),
                  );
                }

                if (state is HotelError) {
                  return ErrorStateWidget(
                    message: state.message,
                    onRetry: _loadHotels,
                  );
                }

                if (state is HotelListLoaded) {
                  if (state.hotels.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.hotel_outlined,
                      title: 'Hotel tidak ditemukan',
                      subtitle: 'Coba cari dengan kata kunci lain',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadHotels(),
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.hotels.length,
                      itemBuilder: (context, index) {
                        return HotelCard(
                          hotel: state.hotels[index],
                          index: index,
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
