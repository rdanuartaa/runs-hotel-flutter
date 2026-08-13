import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/utils/dialog_utils.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Pembayaran', style: AppTextStyles.h4),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocListener<PaymentCubit, PaymentState>(
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
            DialogUtils.showError(context, state.message);
          }
        },
        child: BlocBuilder<PaymentCubit, PaymentState>(
          builder: (context, state) {
            if (state is PaymentError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<PaymentCubit>().createPayment(widget.booking.id),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingWidget(),
                  SizedBox(height: 16),
                  Text('Menyiapkan pembayaran...'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
