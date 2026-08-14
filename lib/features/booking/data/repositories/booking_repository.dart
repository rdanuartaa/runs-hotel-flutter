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
    // 1. Ambil data payment dengan bypass RLS (karena Admin mungkin terblokir oleh RLS tabel payments)
    final serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3eGhxZHdzcG5ycHZicnFtbXVjIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NjMzNzUzMywiZXhwIjoyMTAxOTEzNTMzfQ.dceuL-WMMCZd43PsJQayzc9lV9bBRW5DrwojJ29T5To';
    final supabaseUrl = 'https://bwxhqdwspnrpvbrqmmuc.supabase.co/rest/v1/payments?booking_id=eq.$bookingId&select=*';
    
    final request = await HttpClient().getUrl(Uri.parse(supabaseUrl));
    request.headers.set('apikey', serviceRoleKey);
    request.headers.set('Authorization', 'Bearer $serviceRoleKey');
    
    final response = await request.close();
    final resBody = await response.transform(utf8.decoder).join();
    
    final List payments = jsonDecode(resBody);
    final paymentData = payments.isNotEmpty ? payments.first : null;

    if (paymentData == null) {
      // Jika data pembayaran benar-benar tidak ada di database, batalkan saja pesanannya
      await updateBookingStatus(bookingId, 'cancelled');
      throw Exception('Data pembayaran tidak ditemukan di sistem. Pesanan telah dibatalkan secara paksa, silakan hubungi tamu untuk refund manual.');
    }

    final midtransOrderId = paymentData['midtrans_order_id'];
    if (midtransOrderId == null) {
      await updateBookingStatus(bookingId, 'cancelled');
      throw Exception('Order ID Midtrans tidak ditemukan. Pesanan telah dibatalkan, silakan refund manual.');
    }

    // 2. Tembak API Refund Midtrans
    const serverKey = 'SB-Mid-server-swZOZ8YKuFjw_tTDOk095-Qy';
    final auth = 'Basic ${base64Encode(utf8.encode('$serverKey:'))}';
    
    final payload = {
      'refund_key': 'refund-${DateTime.now().millisecondsSinceEpoch}',
      'amount': paymentData['gross_amount'],
      'reason': 'Pengajuan pembatalan oleh tamu disetujui',
    };

    final refundReq = await HttpClient().postUrl(Uri.parse('https://api.sandbox.midtrans.com/v2/$midtransOrderId/refund'))
      ..headers.set('Content-Type', 'application/json')
      ..headers.set('Accept', 'application/json')
      ..headers.set('Authorization', auth)
      ..write(jsonEncode(payload));
      
    final res = await refundReq.close();
    final refundBody = await res.transform(utf8.decoder).join();
    
    // 3. Selalu ubah status pesanan menjadi cancelled terlepas dari Midtrans sukses atau gagal
    await updateBookingStatus(bookingId, 'cancelled');
    
    if (res.statusCode != 200 && res.statusCode != 201) {
      print('Midtrans Refund API Error: $refundBody');
      throw Exception('Pesanan berhasil dibatalkan, TETAPI otomatisasi refund gagal (Mungkin pembayaran via Bank Transfer). Lakukan refund manual.');
    }

    // 4. Update status pembayaran menjadi refunded (bypass RLS)
    final updateUrl = 'https://bwxhqdwspnrpvbrqmmuc.supabase.co/rest/v1/payments?id=eq.${paymentData['id']}';
    final updateReq = await HttpClient().patchUrl(Uri.parse(updateUrl));
    updateReq.headers.set('apikey', serviceRoleKey);
    updateReq.headers.set('Authorization', 'Bearer $serviceRoleKey');
    updateReq.headers.set('Content-Type', 'application/json');
    updateReq.write(jsonEncode({'status': 'refunded'}));
    await updateReq.close();
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
