import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  final SupabaseClient _client;

  PaymentRepository(this._client);

  Future<Map<String, dynamic>> createPayment(String bookingId) async {
    final response = await _client.functions.invoke(
      'create-payment',
      body: {'booking_id': bookingId},
    );
    return jsonDecode(response.data) as Map<String, dynamic>;
  }

  Stream<PaymentModel> watchPaymentStatus(String bookingId) {
    return _client
        .from('payments')
        .stream(primaryKey: ['id'])
        .eq('booking_id', bookingId)
        .map((data) => PaymentModel.fromJson(data.first));
  }

  Future<PaymentModel?> getPaymentByBooking(String bookingId) async {
    final data = await _client
        .from('payments')
        .select()
        .eq('booking_id', bookingId)
        .maybeSingle();

    if (data == null) return null;
    return PaymentModel.fromJson(data);
  }
}
