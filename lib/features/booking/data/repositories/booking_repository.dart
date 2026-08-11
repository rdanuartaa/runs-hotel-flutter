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
        .eq('status', 'cancelled')
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
      'status': 'cancelled',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', bookingId);
  }
}
