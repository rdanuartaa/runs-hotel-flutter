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
  int? _minPrice;
  int? _maxPrice;
  bool? _sortByPriceAsc;
  bool _sortByDistance = false;

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
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          sortByPriceAsc: _sortByPriceAsc,
          sortByDistance: _sortByDistance,
        );
  }

  void _showFilterBottomSheet() {
    // Local state for bottom sheet
    RangeValues currentRange = RangeValues(
      _minPrice?.toDouble() ?? 0,
      _maxPrice?.toDouble() ?? 5000000,
    );
    bool? currentSortPrice = _sortByPriceAsc;
    bool currentSortDistance = _sortByDistance;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filter Harga & Jarak', style: AppTextStyles.h4),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Gap(16),
                  Text('Rentang Harga', style: AppTextStyles.labelLarge),
                  const Gap(8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rp ${currentRange.start.toInt()}'),
                      Text('Rp ${currentRange.end.toInt()}'),
                    ],
                  ),
                  RangeSlider(
                    values: currentRange,
                    min: 0,
                    max: 5000000,
                    divisions: 100,
                    activeColor: AppColors.primary,
                    onChanged: (values) {
                      setModalState(() {
                        currentRange = values;
                      });
                    },
                  ),
                  const Gap(16),
                  Text('Urutkan', style: AppTextStyles.labelLarge),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('Terdekat '),
                            Icon(Icons.location_on, size: 16),
                          ],
                        ),
                        selected: currentSortDistance,
                        onSelected: (selected) {
                          setModalState(() {
                            currentSortDistance = selected;
                            if (selected) currentSortPrice = null;
                          });
                        },
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                      ),
                      ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('Termurah '),
                            Icon(Icons.arrow_upward, size: 16),
                          ],
                        ),
                        selected: currentSortPrice == true,
                        onSelected: (selected) {
                          setModalState(() {
                            currentSortPrice = selected ? true : null;
                            if (selected) currentSortDistance = false;
                          });
                        },
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                      ),
                      ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('Termahal '),
                            Icon(Icons.arrow_downward, size: 16),
                          ],
                        ),
                        selected: currentSortPrice == false,
                        onSelected: (selected) {
                          setModalState(() {
                            currentSortPrice = selected ? false : null;
                            if (selected) currentSortDistance = false;
                          });
                        },
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const Gap(24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _minPrice = null;
                              _maxPrice = null;
                              _sortByPriceAsc = null;
                              _sortByDistance = false;
                            });
                            Navigator.pop(context);
                            _loadHotels();
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _minPrice = currentRange.start.toInt();
                              _maxPrice = currentRange.end.toInt();
                              _sortByPriceAsc = currentSortPrice;
                              _sortByDistance = currentSortDistance;
                            });
                            Navigator.pop(context);
                            _loadHotels();
                          },
                          child: const Text('Terapkan'),
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                ],
              ),
            );
          },
        );
      },
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
            child: Row(
              children: [
                Expanded(
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
                const Gap(8),
                InkWell(
                  onTap: _showFilterBottomSheet,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (_minPrice != null || _sortByPriceAsc != null)
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.tune,
                      color: (_minPrice != null || _sortByPriceAsc != null)
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Results
          Expanded(
            child: BlocBuilder<HotelCubit, HotelState>(
              builder: (context, state) {
                if (state is HotelLoading || state is HotelInitial) {
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
                      subtitle: 'Coba sesuaikan filter atau kata kunci',
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
