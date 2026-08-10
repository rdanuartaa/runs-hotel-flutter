part of 'payment_cubit.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentSnapReady extends PaymentState {
  final String? token;
  final String redirectUrl;
  final String bookingId;

  const PaymentSnapReady({this.token, required this.redirectUrl, required this.bookingId});

  @override
  List<Object?> get props => [token, redirectUrl, bookingId];
}

class PaymentPending extends PaymentState {
  final PaymentModel payment;
  const PaymentPending(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentSuccess extends PaymentState {
  final PaymentModel payment;
  const PaymentSuccess(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentFailed extends PaymentState {
  final PaymentModel payment;
  const PaymentFailed(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentError extends PaymentState {
  final String message;
  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}
