import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../booking/presentation/cubit/booking_cubit.dart';

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Semua Pesanan', style: AppTextStyles.h3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is BookingError) {
            return Center(child: Text(state.message, style: TextStyle(color: Colors.red)));
          }
          
          if (state is AllBookingsLoaded) {
            final bookings = state.bookings;
            
            if (bookings.isEmpty) {
              return Center(child: Text('Belum ada pesanan.', style: AppTextStyles.bodyLarge));
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text('${booking.hotelName ?? 'Hotel'} - ${booking.roomName ?? 'Kamar'}', style: AppTextStyles.h4),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Check-in: ${DateFormat('dd MMM yyyy').format(booking.checkIn)}', style: AppTextStyles.bodySmall),
                        Text('Status: ${booking.status.toUpperCase()}', style: TextStyle(fontWeight: FontWeight.bold, color: booking.status == 'confirmed' ? Colors.green : Colors.orange)),
                        const SizedBox(height: 4),
                        Text(formatCurrency.format(booking.totalPrice), style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Tindakan saat klik pesanan
                    },
                  ),
                );
              },
            );
          }
          
          return const SizedBox();
        },
      ),
    );
  }
}
