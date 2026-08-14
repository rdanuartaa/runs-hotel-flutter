import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final SupabaseClient _client;

  BookingRepository(this._client);

  Future<BookingModel> createBooking({
    required String userId,
    required String hotelId,
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int totalGuests,
    required int totalPrice,
    String? specialRequest,
  }) async {
    final data = await _client.from('bookings').insert({
      'user_id': userId,
      'hotel_id': hotelId,
      'room_id': roomId,
      'check_in': checkIn.toIso8601String().split('T').first,
      'check_out': checkOut.toIso8601String().split('T').first,
      'total_guests': totalGuests,
      'total_price': totalPrice,
      'special_request': specialRequest,
    }).select('*, hotels(name, thumbnail_url, city), rooms(name, room_type)').single();

    return BookingModel.fromJson(data);
  }

  Future<List<BookingModel>> getUserBookings(String userId, {String? status}) async {
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T').first;
    
    // Auto check-out stale bookings (lazy update)
    await _client.from('bookings')
        .update({'status': 'checked_out', 'updated_at': now.toIso8601String()})
        .eq('user_id', userId)
        .inFilter('status', ['checked_in', 'confirmed'])
        .lt('check_out', todayStr);

    var query = _client
        .from('bookings')
        .select('*, hotels(name, thumbnail_url, city), rooms(name, room_type)')
        .eq('user_id', userId);

    if (status != null) {
      query = query.eq('status', status);
    }

    final data = await query.order('created_at', ascending: false);

    return (data as List).map((e) => BookingModel.fromJson(e)).toList();
  }

  // --- UNTUK ADMIN ---
  Future<List<BookingModel>> getAllBookings({String? status}) async {
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T').first;
    
    // Auto check-out stale bookings for all users (lazy update)
    await _client.from('bookings')
        .update({'status': 'checked_out', 'updated_at': now.toIso8601String()})
        .inFilter('status', ['checked_in', 'confirmed'])
        .lt('check_out', todayStr);

    var query = _client
        .from('bookings')
        .select('*, hotels(name, thumbnail_url, city), rooms(name, room_type), users(full_name, email)');

    if (status != null) {
      query = query.eq('status', status);
    }

    final data = await query.order('created_at', ascending: false);

    return (data as List).map((e) => BookingModel.fromJson(e)).toList();
  }

  Future<List<BookingModel>> getUpcomingBookings(String userId) async {
    final data = await _client
        .from('bookings')
        .select('*, hotels(name, thumbnail_url, city), rooms(name, room_type)')
        .eq('user_id', userId)
        .inFilter('status', ['pending', 'confirmed'])
        .gte('check_in', DateTime.now().toIso8601String().split('T').first)
        .order('check_in');

    return (data as List).map((e) => BookingModel.fromJson(e)).toList();
  }

  Future<List<BookingModel>> getCompletedBookings(String userId) async {
    final data = await _client
        .from('bookings')
        .select('*, hotels(name, thumbnail_url, city), rooms(name, room_type)')
        .eq('user_id', userId)
        .eq('status', 'checked_out')
        .order('check_out', ascending: false);

    return (data as List).map((e) => BookingModel.fromJson(e)).toList();
  }

  Future<List<BookingModel>> getCancelledBookings(String userId) async {
    final data = await _client
        .from('bookings')
        .select('*, hotels(name, thumbnail_url, city), rooms(name, room_type)')
        .eq('user_id', userId)
        .inFilter('status', ['cancelled', 'cancel_requested'])
        .order('created_at', ascending: false);

    return (data as List).map((e) => BookingModel.fromJson(e)).toList();
  }

  Future<BookingModel> getBookingById(String bookingId) async {
    final data = await _client
        .from('bookings')
        .select('*, hotels(name, thumbnail_url, city), rooms(name, room_type)')
        .eq('id', bookingId)
        .single();

    return BookingModel.fromJson(data);
  }

  Future<void> cancelBooking(String bookingId) async {
    await _client.from('bookings').update({
      'status': 'cancel_requested',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', bookingId);
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _client.from('bookings').update({
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', bookingId);
  }

  Future<void> processRefund(String bookingId) async {
    // 1. Ambil data payment
    final paymentData = await _client
        .from('payments')
        .select()
        .eq('booking_id', bookingId)
        .maybeSingle();

    if (paymentData == null) {
      throw Exception('Data pembayaran tidak ditemukan. Lakukan refund manual.');
    }

    final midtransOrderId = paymentData['midtrans_order_id'];
    if (midtransOrderId == null) {
      throw Exception('Order ID Midtrans tidak ditemukan. Lakukan refund manual.');
    }

    // 2. Tembak API Refund Midtrans
    const serverKey = 'SB-Mid-server-swZOZ8YKuFjw_tTDOk095-Qy';
    final auth = 'Basic ${base64Encode(utf8.encode('$serverKey:'))}';
    
    final payload = {
      'refund_key': 'refund-${DateTime.now().millisecondsSinceEpoch}',
      'amount': paymentData['gross_amount'],
      'reason': 'Pengajuan pembatalan oleh tamu disetujui',
    };

    final response = await HttpClient().postUrl(Uri.parse('https://api.sandbox.midtrans.com/v2/$midtransOrderId/refund'))
      ..headers.set('Content-Type', 'application/json')
      ..headers.set('Accept', 'application/json')
      ..headers.set('Authorization', auth)
      ..write(jsonEncode(payload));
      
    final res = await response.close();
    final resBody = await res.transform(utf8.decoder).join();
    
    if (res.statusCode != 200 && res.statusCode != 201) {
      print('Midtrans Refund API Error: $resBody');
      throw Exception('Otomatisasi refund via Midtrans gagal (kemungkinan metode pembayaran Bank Transfer/VA tidak didukung Midtrans untuk auto-refund). Silakan transfer manual ke tamu.');
    }

    // 3. Update status pesanan
    await _client.from('bookings').update({
      'status': 'cancelled',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', bookingId);
    
    // 4. Update status pembayaran
    await _client.from('payments').update({
      'status': 'refunded',
    }).eq('id', paymentData['id']);
    
    // 5. Send Notification
    try {
      await _client.functions.invoke('send-push-notification', body: {
        'userId': paymentData['user_id'],
        'title': 'Refund Berhasil 💸',
        'body': 'Dana Anda telah berhasil dikembalikan karena pengajuan pembatalan (Refund) disetujui.',
        'dataPayload': {'booking_id': bookingId, 'type': 'payment_refunded'}
      });
    } catch (e) {
      print('Gagal mengirim notifikasi refund: $e');
    }
  }
}
