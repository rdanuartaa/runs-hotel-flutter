import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../booking/data/models/booking_model.dart';
import '../cubit/payment_cubit.dart';

class PaymentScreen extends StatefulWidget {
  final BookingModel booking;
  const PaymentScreen({super.key, required this.booking});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentCubit>().createPayment(widget.booking.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFFD4B996) : const Color(0xFF7B6649);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<PaymentCubit, PaymentState>(
          listener: (context, state) {
            if (state is PaymentSnapReady) {
              context.push('/payment-webview', extra: {
                'redirectUrl': state.redirectUrl,
                'bookingId': state.bookingId,
              });
            } else if (state is PaymentSuccess) {
              context.go('/payment-status', extra: {'status': 'success'});
            } else if (state is PaymentFailed) {
              context.go('/payment-status', extra: {'status': 'failed'});
            } else if (state is PaymentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red[400],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: accentColor),
                const SizedBox(height: 16),
                Text(
                  'Menyiapkan pembayaran...',
                  style: TextStyle(color: textColor, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
