import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../hotel/presentation/cubit/hotel_cubit.dart';
import '../../../hotel/data/models/hotel_model.dart';

class AdminHotelsScreen extends StatefulWidget {
  const AdminHotelsScreen({super.key});

  @override
  State<AdminHotelsScreen> createState() => _AdminHotelsScreenState();
}

class _AdminHotelsScreenState extends State<AdminHotelsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text(
                    'Kelola Hotel',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<HotelCubit, HotelState>(
        listener: (context, state) {
          if (state is HotelError) {
            DialogUtils.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is HotelLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is HotelListLoaded) {
            final hotels = state.hotels;
            
            if (hotels.isEmpty) {
              return Center(child: Text('Belum ada hotel yang ditambahkan.', style: AppTextStyles.bodyLarge));
            }
            
            
            final filteredHotels = hotels.where((h) => 
              h.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
              h.city.toLowerCase().contains(_searchQuery.toLowerCase())
            ).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari nama hotel atau kota...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                if (filteredHotels.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text('Tidak ada hotel ditemukan.', style: AppTextStyles.bodyLarge),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredHotels.length,
                      itemBuilder: (context, index) {
                        final hotel = filteredHotels[index];
                        return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedImageWidget(
                        imageUrl: hotel.thumbnailUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(hotel.name, style: AppTextStyles.h4),
                    subtitle: Text('${hotel.city} • Tap untuk kelola kamar', style: AppTextStyles.bodySmall),
                    onTap: () {
                      context.push('/admin/hotels/${hotel.id}/rooms');
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.primary),
                          onPressed: () async {
                            final result = await context.push('/admin/add-hotel', extra: hotel);
                            if (result == true && context.mounted) {
                              context.read<HotelCubit>().loadHotels();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Hapus Hotel'),
                                content: Text('Yakin ingin menghapus ${hotel.name}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                        await context.read<HotelCubit>().deleteHotel(hotel.id);
                                        if (context.mounted) {
                                          DialogUtils.showSuccess(context, 'Hotel berhasil dihapus');
                                        }
                                    },
                                    child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
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
        ],
      );
    }
          
          return const SizedBox();
        },
      ),
      ),
      ],
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/admin/add-hotel');
          if (result == true && context.mounted) {
            context.read<HotelCubit>().loadHotels();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
