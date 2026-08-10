import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/payment_repository.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository _paymentRepository;
  StreamSubscription? _paymentSubscription;

  PaymentCubit(this._paymentRepository) : super(const PaymentInitial());

  Future<void> createPayment(String bookingId) async {
    emit(const PaymentLoading());
    try {
      final snapData = await _paymentRepository.createPayment(bookingId);
      final token = snapData['token'] as String?;
      final redirectUrl = snapData['redirect_url'] as String?;

      if (redirectUrl != null) {
        emit(PaymentSnapReady(token: token, redirectUrl: redirectUrl, bookingId: bookingId));
      } else {
        emit(const PaymentError('Gagal membuat pembayaran'));
      }
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  void watchPayment(String bookingId) {
    _paymentSubscription?.cancel();
    _paymentSubscription = _paymentRepository
        .watchPaymentStatus(bookingId)
        .listen((payment) {
      if (payment.isSettled) {
        emit(PaymentSuccess(payment));
      } else if (payment.isFailed) {
        emit(PaymentFailed(payment));
      } else {
        emit(PaymentPending(payment));
      }
    });
  }

  @override
  Future<void> close() {
    _paymentSubscription?.cancel();
    return super.close();
  }
}
