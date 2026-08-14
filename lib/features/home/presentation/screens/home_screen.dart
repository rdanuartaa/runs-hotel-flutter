import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../hotel/data/models/hotel_model.dart';
import '../cubit/home_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String _locationName = 'Mencari lokasi...';

  double? _userLat;
  double? _userLon;

  final List<String> _categories = [
    'All',
    'The Royal',
    'Standard',
    'Executive',
    'King\'s suite',
    'Deluxe suite'
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    _reloadHomeData();
    await _fetchLocation();
    if (_userLat != null && _userLon != null && mounted) {
      _reloadHomeData();
    }
  }

  Future<void> _fetchLocation() async {
    try {
      final pos = await LocationService.getCurrentLocation();
      if (pos != null) {
        _userLat = pos.latitude;
        _userLon = pos.longitude;
        final url = Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=${pos.latitude}&lon=${pos.longitude}');
        final response = await http.get(url, headers: {'User-Agent': 'HotelApp/1.0'});
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final address = data['address'] as Map<String, dynamic>?;
          if (address != null) {
            final city = address['city'] ?? address['town'] ?? address['village'] ?? address['county'] ?? 'Unknown';
            final country = address['country'] ?? '';
            if (mounted) {
              setState(() {
                _locationName = '$city, $country';
              });
            }
          }
        } else {
          if (mounted) setState(() => _locationName = 'Lokasi tidak diketahui');
        }
      } else {
        if (mounted) setState(() => _locationName = 'Lokasi tidak aktif');
      }
    } catch (e) {
      if (mounted) setState(() => _locationName = 'Gagal memuat lokasi');
    }
  }

  Future<void> _reloadHomeData() async {
    String backendCategory = 'Semua';
    if (_selectedCategory == 'The Royal' || _selectedCategory == 'King\'s suite' || _selectedCategory == 'Deluxe suite') {
      backendCategory = 'Suite';
    } else if (_selectedCategory == 'Standard') {
      backendCategory = 'Budget';
    } else if (_selectedCategory == 'Executive') {
      backendCategory = '⭐ 5';
    }
    return context.read<HomeCubit>().loadHomeData(
      category: backendCategory,
      userLat: _userLat,
      userLon: _userLon,
    );
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _reloadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _fetchLocation();
            return _reloadHomeData();
          },
          color: const Color(0xFF2171C4),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildBanner()),
              SliverToBoxAdapter(child: _buildSectionTitle()),
              SliverToBoxAdapter(child: _buildCategoryTabs()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoading || state is HomeInitial) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF2171C4)));
                      }
                      if (state is HomeError) {
                        return ErrorStateWidget(
                          message: state.message,
                          onRetry: () => _reloadHomeData(),
                        );
                      }
                      if (state is HomeLoaded) {
                        return SizedBox(
                          height: 280,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: state.allHotels.length,
                            separatorBuilder: (context, index) => const Gap(16),
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: 180,
                                child: _buildRoomCard(state.allHotels[index]),
                              );
                            },
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final userName = user?.fullName ?? 'User';
    final userAvatar = user?.avatarUrl ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=random';
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 16),
              const Gap(4),
              Text(
                _locationName,
                style: AppTextStyles.labelMedium.copyWith(color: textColor),
              ),
            ],
          ),
          Row(
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
              const Gap(12),
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[200],
                backgroundImage: NetworkImage(userAvatar),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => context.push('/hotels'),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Colors.white,
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
          child: Row(
            children: [
              const Gap(16),
              const Icon(Icons.search, color: Colors.grey, size: 20),
              const Gap(12),
              Expanded(
                child: Text(
                  'Search for our nearby hotel',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey.withValues(alpha: 0.2),
              ),
              const Gap(12),
              const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: const DecorationImage(
            image: NetworkImage(
              'https://images.pexels.com/photos/258154/pexels-photo-258154.jpeg?auto=compress&cs=tinysrgb&w=800',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black.withValues(alpha: 0.3),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'A Hotel for every\nmoment rich in emotion.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const Gap(16),
              GestureDetector(
                onTap: () => context.push('/hotels'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Text(
                    'Book now',
                    style: TextStyle(
                      color: Color(0xFF2171C4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Choose a room',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF56A8E5) : const Color(0xFF2171C4),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Text(
            'view all',
            style: TextStyle(
              color: Colors.red[400],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => _onCategorySelected(cat),
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected 
                        ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF56A8E5) : const Color(0xFF2171C4)) 
                        : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600]),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomCard(HotelModel hotel) {
    return GestureDetector(
      onTap: () => context.push('/hotel/${hotel.id}'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(
              hotel.thumbnailUrl ?? 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?q=80&w=500&auto=format&fit=crop',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.2),
                Colors.black.withValues(alpha: 0.8),
              ],
              stops: const [0.5, 0.7, 1.0],
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 16,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      hotel.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        color: index < hotel.starRating ? const Color(0xFFFFB800) : Colors.grey,
                        size: 10,
                      );
                    }),
                  ),
                ],
              ),
              const Gap(4),
              if (hotel.minPrice != null)
                Text(
                  'Rs ${hotel.minPrice}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildMiniIcon(Icons.tv),
                      const Gap(4),
                      _buildMiniIcon(Icons.cleaning_services),
                      const Gap(4),
                      _buildMiniIcon(Icons.wifi),
                    ],
                  ),
                  const Text(
                    'Available',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 10, color: Colors.black87),
    );
  }
}
