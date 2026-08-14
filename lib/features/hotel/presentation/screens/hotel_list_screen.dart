import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
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
          sortByPriceAsc: _sortByPriceAsc,
          sortByDistance: _sortByDistance,
        );
  }

  void _showFilterBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFFD4B996) : const Color(0xFF7B6649);
    final cardColor = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);

    bool? currentSortPrice = _sortByPriceAsc;
    bool currentSortDistance = _sortByDistance;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
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
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Gap(16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter & Urutkan',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, color: textColor, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),
                  Text('Urutkan', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14)),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        label: 'Terdekat',
                        icon: Icons.location_on,
                        isSelected: currentSortDistance,
                        accentColor: accentColor,
                        onTap: () {
                          setModalState(() {
                            currentSortDistance = !currentSortDistance;
                            if (currentSortDistance) currentSortPrice = null;
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: 'Termurah',
                        icon: Icons.arrow_upward,
                        isSelected: currentSortPrice == true,
                        accentColor: accentColor,
                        onTap: () {
                          setModalState(() {
                            currentSortPrice = currentSortPrice == true ? null : true;
                            if (currentSortPrice != null) currentSortDistance = false;
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: 'Termahal',
                        icon: Icons.arrow_downward,
                        isSelected: currentSortPrice == false,
                        accentColor: accentColor,
                        onTap: () {
                          setModalState(() {
                            currentSortPrice = currentSortPrice == false ? null : false;
                            if (currentSortPrice != null) currentSortDistance = false;
                          });
                        },
                      ),
                    ],
                  ),
                  const Gap(24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _sortByPriceAsc = null;
                              _sortByDistance = false;
                            });
                            Navigator.pop(context);
                            _loadHotels();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                            ),
                            child: Center(
                              child: Text('Reset', style: TextStyle(color: accentColor, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _sortByPriceAsc = currentSortPrice;
                              _sortByDistance = currentSortDistance;
                            });
                            Navigator.pop(context);
                            _loadHotels();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text('Terapkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                          ),
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

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : accentColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : accentColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const Gap(4),
            Icon(icon, size: 16, color: isSelected ? Colors.white : accentColor),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFFD4B996) : const Color(0xFF7B6649);
    final cardColor = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header matching home screen style
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'Cari Hotel',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search bar matching home design
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _loadHotels(),
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search for our nearby hotel',
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey[500], size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    _loadHotels();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  GestureDetector(
                    onTap: _showFilterBottomSheet,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: (_sortByPriceAsc != null || _sortByDistance)
                            ? accentColor
                            : cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.tune,
                        color: (_sortByPriceAsc != null || _sortByDistance)
                            ? Colors.white
                            : subtextColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Gap(8),

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
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.hotel_outlined, size: 64, color: subtextColor),
                            const Gap(16),
                            Text(
                              'Hotel tidak ditemukan',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              'Coba sesuaikan filter atau kata kunci',
                              style: TextStyle(color: subtextColor, fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _loadHotels(),
                      color: accentColor,
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
      ),
    );
  }
}
