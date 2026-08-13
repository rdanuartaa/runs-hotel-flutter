import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../hotel/presentation/cubit/hotel_cubit.dart';

class AdminRoomsScreen extends StatefulWidget {
  final String hotelId;
  const AdminRoomsScreen({super.key, required this.hotelId});

  @override
  State<AdminRoomsScreen> createState() => _AdminRoomsScreenState();
}

class _AdminRoomsScreenState extends State<AdminRoomsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HotelCubit>().loadHotelDetail(widget.hotelId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Kelola Kamar', style: AppTextStyles.h3),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<HotelCubit, HotelState>(
        listener: (context, state) {
          if (state is HotelError) {
            DialogUtils.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is HotelLoading || state is HotelInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HotelError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<HotelCubit>().loadHotelDetail(widget.hotelId),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          if (state is HotelDetailLoaded) {
            final hotel = state.hotel;
            final rooms = state.rooms;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Hotel: ${hotel.name}', style: AppTextStyles.h4),
                ),
                Expanded(
                  child: rooms.isEmpty
                      ? Center(child: Text('Belum ada kamar', style: AppTextStyles.bodyMedium))
                      : ListView.builder(
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: room.thumbnailUrl != null && room.thumbnailUrl!.isNotEmpty
                                      ? CachedImageWidget(imageUrl: room.thumbnailUrl!, width: 60, height: 60)
                                      : Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.bed),
                                        ),
                                ),
                                title: Text(room.name, style: AppTextStyles.labelLarge),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${room.roomTypeDisplay} • Max ${room.maxGuests} tamu', style: AppTextStyles.bodySmall),
                                    Text(
                                      '${formatCurrency.format(room.pricePerNight)} / malam',
                                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: AppColors.primary),
                                      onPressed: () async {
                                        final result = await context.push('/admin/hotels/${widget.hotelId}/add-room', extra: room);
                                        if (result == true && context.mounted) {
                                          context.read<HotelCubit>().loadHotelDetail(widget.hotelId);
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Hapus Kamar'),
                                            content: Text('Yakin ingin menghapus ${room.name}?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx),
                                                child: const Text('Batal'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.pop(ctx);
                                                  await context.read<HotelCubit>().deleteRoom(room.id, widget.hotelId);
                                                  if (context.mounted) {
                                                    DialogUtils.showSuccess(context, 'Kamar berhasil dihapus');
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/admin/hotels/${widget.hotelId}/add-room');
          if (result == true && context.mounted) {
            context.read<HotelCubit>().loadHotelDetail(widget.hotelId);
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
