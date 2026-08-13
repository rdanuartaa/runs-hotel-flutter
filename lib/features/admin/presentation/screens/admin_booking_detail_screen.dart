import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../booking/presentation/cubit/booking_cubit.dart';

class AdminBookingDetailScreen extends StatefulWidget {
  final BookingModel booking;

  const AdminBookingDetailScreen({super.key, required this.booking});

  @override
  State<AdminBookingDetailScreen> createState() => _AdminBookingDetailScreenState();
}

class _AdminBookingDetailScreenState extends State<AdminBookingDetailScreen> {
  late BookingModel _booking;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final formatDate = DateFormat('dd MMMM yyyy', 'id_ID');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Detail Pesanan', style: AppTextStyles.h4),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<BookingCubit, BookingState>(
        listener: (context, state) async {
          if (state is AllBookingsLoaded) {
            // Update the local booking instance
            try {
              final updatedBooking = state.bookings.firstWhere((b) => b.id == _booking.id);
              setState(() {
                _booking = updatedBooking;
              });
            } catch (e) {
              // Jika tidak ketemu (jarang terjadi)
            }
            await DialogUtils.showSuccess(context, 'Status pesanan berhasil diperbarui');
            if (context.mounted) {
              context.pop(); // Lanjut ke halaman sebelumnya (dashboard)
            }
          } else if (state is BookingError) {
            await DialogUtils.showError(context, state.message);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informasi Pemesan'),
              _buildInfoRow('Nama Pemesan', _booking.userName ?? '-'),
              _buildInfoRow('Email', _booking.userEmail ?? '-'),
              const Gap(24),

              _buildSectionTitle('Informasi Hotel'),
              _buildInfoRow('Hotel', _booking.hotelName ?? '-'),
              _buildInfoRow('Kota', _booking.hotelCity ?? '-'),
              _buildInfoRow('Tipe Kamar', _booking.roomType ?? '-'),
              _buildInfoRow('Kamar', _booking.roomName ?? '-'),
              const Gap(24),

              _buildSectionTitle('Detail Reservasi'),
              _buildInfoRow('Check-in', formatDate.format(_booking.checkIn)),
              _buildInfoRow('Check-out', formatDate.format(_booking.checkOut)),
              _buildInfoRow('Jumlah Tamu', '${_booking.totalGuests} Orang'),
              if (_booking.specialRequest != null && _booking.specialRequest!.isNotEmpty)
                _buildInfoRow('Permintaan Khusus', _booking.specialRequest!),
              const Gap(24),

              _buildSectionTitle('Pembayaran'),
              _buildInfoRow('Total Harga', formatCurrency.format(_booking.totalPrice)),
              _buildInfoRow('Status Saat Ini', _booking.status.toUpperCase(), 
                valueColor: _getStatusColor(_booking.status), isBold: true),
              const Gap(32),

              _buildSectionTitle('Ubah Status Pesanan'),
              const Gap(16),
              _buildStatusAction(
                context, 
                title: 'Konfirmasi (Confirmed)', 
                status: 'confirmed', 
                color: Colors.green, 
                icon: Icons.check_circle_outline,
                currentStatus: _booking.status,
              ),
              const Gap(12),
              _buildStatusAction(
                context, 
                title: 'Check-in (Gues in House)', 
                status: 'checked_in', 
                color: Colors.blue, 
                icon: Icons.login,
                currentStatus: _booking.status,
              ),
              const Gap(12),
              _buildStatusAction(
                context, 
                title: 'Check-out (Selesai)', 
                status: 'checked_out', 
                color: AppColors.primary, 
                icon: Icons.logout,
                currentStatus: _booking.status,
              ),
              const Gap(12),
              _buildStatusAction(
                context, 
                title: 'Batalkan & Refund', 
                status: 'cancelled', 
                color: Colors.red, 
                icon: Icons.cancel_outlined,
                currentStatus: _booking.status,
                isDisabled: _booking.status == 'checked_in' || _booking.status == 'checked_out',
              ),
              const Gap(12),
              if (_booking.status == 'cancel_requested') ...[
                const Gap(12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.red),
                          const Gap(8),
                          Expanded(child: Text('Tamu Mengajukan Pembatalan (Refund)', style: AppTextStyles.labelLarge.copyWith(color: Colors.red))),
                        ],
                      ),
                      const Gap(8),
                      Text(
                        'Dengan menekan Setujui, sistem akan mencoba melakukan Auto-Refund melalui Midtrans. Jika gagal (misal bayar via Bank Transfer yang tidak di-support Midtrans auto-refund), Anda akan diminta transfer manual.',
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.red.shade700),
                      ),
                      const Gap(12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Tolak Pembatalan'),
                                    content: const Text('Pesanan akan dikembalikan ke status Confirmed.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          context.read<BookingCubit>().updateBookingStatus(_booking.id, 'confirmed');
                                        },
                                        child: const Text('Tolak'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red),
                              child: const Text('Tolak'),
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Setujui Pembatalan & Refund'),
                                    content: const Text('Sistem akan mencoba mengembalikan dana langsung via Midtrans. Lanjutkan?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          context.read<BookingCubit>().processRefund(_booking.id);
                                        },
                                        child: const Text('Setujui & Refund'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                              child: const Text('Setujui (Refund)'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const Gap(48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.h4.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusAction(
    BuildContext context, {
    required String title,
    required String status,
    required Color color,
    required IconData icon,
    required String currentStatus,
    bool isDisabled = false,
  }) {
    final isCompleted = _isStatusAchieved(status, currentStatus);
    return InkWell(
      onTap: (isCompleted || isDisabled)
        ? null 
        : () {
            if (status == 'checked_in') {
              final today = DateTime.now();
              final checkInDate = DateTime(_booking.checkIn.year, _booking.checkIn.month, _booking.checkIn.day);
              final todayDate = DateTime(today.year, today.month, today.day);
              if (todayDate.isBefore(checkInDate)) {
                DialogUtils.showWarning(context, 'Tamu belum bisa check-in sebelum tanggal reservasi!');
                return;
              }
            }

            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(status == 'cancelled' ? 'Batalkan & Refund' : 'Ubah Status'),
                content: Text(status == 'cancelled' 
                  ? 'Yakin ingin membatalkan pesanan ini dan memproses uang kembali (refund)?' 
                  : 'Yakin ingin mengubah status menjadi $title?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<BookingCubit>().updateBookingStatus(_booking.id, status);
                    },
                    child: const Text('Ya, Lanjutkan'),
                  ),
                ],
              ),
            );
          },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: isCompleted ? color : AppColors.divider),
          borderRadius: BorderRadius.circular(12),
          color: (isCompleted || isDisabled) ? (isCompleted ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.05)) : AppColors.surface,
        ),
        child: Opacity(
          opacity: isDisabled ? 0.4 : 1.0,
          child: Row(
          children: [
            Icon(icon, color: isCompleted ? color : AppColors.textSecondary),
            const Gap(16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isCompleted ? color : AppColors.textPrimary,
                ),
              ),
            ),
            if (isCompleted)
              const Icon(Icons.check, color: AppColors.primary)
            else if (!isDisabled)
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
      ),
    );
  }

  bool _isStatusAchieved(String targetStatus, String currentStatus) {
    if (currentStatus == 'cancelled') {
      return targetStatus == 'cancelled';
    }
    if (currentStatus == 'cancel_requested') {
      // It's technically pending refund. Don't check the other boxes.
      return false;
    }
    
    final flow = ['pending', 'confirmed', 'checked_in', 'checked_out'];
    final targetIndex = flow.indexOf(targetStatus);
    final currentIndex = flow.indexOf(currentStatus);
    
    if (targetIndex == -1 || currentIndex == -1) return false;
    return targetIndex <= currentIndex;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'checked_in':
        return Colors.blue;
      case 'checked_out':
        return AppColors.primary;
      case 'cancelled':
        return Colors.red;
      case 'cancel_requested':
        return Colors.orange;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}
