import 'package:equatable/equatable.dart';

class PaymentModel extends Equatable {
  final String id;
  final String bookingId;
  final String userId;
  final String midtransOrderId;
  final String? midtransTransactionId;
  final String? paymentType;
  final int grossAmount;
  final String status;
  final String? snapToken;
  final String? snapRedirectUrl;
  final Map<String, dynamic>? paymentResponse;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.midtransOrderId,
    this.midtransTransactionId,
    this.paymentType,
    required this.grossAmount,
    this.status = 'pending',
    this.snapToken,
    this.snapRedirectUrl,
    this.paymentResponse,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      userId: json['user_id'] as String,
      midtransOrderId: json['midtrans_order_id'] as String,
      midtransTransactionId: json['midtrans_transaction_id'] as String?,
      paymentType: json['payment_type'] as String?,
      grossAmount: json['gross_amount'] as int,
      status: json['status'] as String? ?? 'pending',
      snapToken: json['snap_token'] as String?,
      snapRedirectUrl: json['snap_redirect_url'] as String?,
      paymentResponse: json['payment_response'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  bool get isSettled => status == 'settlement' || status == 'capture';
  bool get isFailed => status == 'deny' || status == 'cancel' || status == 'expire';
  bool get isPending => status == 'pending';

  @override
  List<Object?> get props => [id, bookingId, status];
}
