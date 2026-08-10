import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hotel_model.dart';
import '../models/room_model.dart';
import '../models/review_model.dart';

class HotelRepository {
  final SupabaseClient _client;

  HotelRepository(this._client);

  Future<List<HotelModel>> getHotels({
    String? search,
    String? city,
    int? starRating,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _client
        .from('hotels')
        .select('*, hotel_images(image_url)')
        .eq('is_active', true);

    if (search != null && search.isNotEmpty) {
      query = query.or('name.ilike.%$search%,city.ilike.%$search%');
    }
    if (city != null && city.isNotEmpty) {
      query = query.eq('city', city);
    }
    if (starRating != null) {
      query = query.eq('star_rating', starRating);
    }

    final data = await query
        .order('avg_rating', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List).map((e) => HotelModel.fromJson(e)).toList();
  }

  Future<List<HotelModel>> getPopularHotels({int limit = 10}) async {
    final data = await _client
        .from('hotels')
        .select('*, hotel_images(image_url)')
        .eq('is_active', true)
        .order('avg_rating', ascending: false)
        .limit(limit);

    return (data as List).map((e) => HotelModel.fromJson(e)).toList();
  }

  Future<HotelModel> getHotelById(String hotelId) async {
    final data = await _client
        .from('hotels')
        .select('*, hotel_images(image_url, sort_order)')
        .eq('id', hotelId)
        .single();

    return HotelModel.fromJson(data);
  }

  Future<List<RoomModel>> getRoomsByHotel(String hotelId) async {
    final data = await _client
        .from('rooms')
        .select()
        .eq('hotel_id', hotelId)
        .eq('is_available', true)
        .order('price_per_night');

    return (data as List).map((e) => RoomModel.fromJson(e)).toList();
  }

  Future<RoomModel> getRoomById(String roomId) async {
    final data = await _client.from('rooms').select().eq('id', roomId).single();
    return RoomModel.fromJson(data);
  }

  Future<List<ReviewModel>> getReviewsByHotel(
    String hotelId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _client
        .from('reviews')
        .select('*, users(full_name, avatar_url)')
        .eq('hotel_id', hotelId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List).map((e) => ReviewModel.fromJson(e)).toList();
  }

  Future<void> createReview({
    required String userId,
    required String hotelId,
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    await _client.from('reviews').insert({
      'user_id': userId,
      'hotel_id': hotelId,
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
    });

    // Update hotel avg_rating and total_reviews
    final reviews = await _client
        .from('reviews')
        .select('rating')
        .eq('hotel_id', hotelId);

    final ratings = (reviews as List).map((r) => r['rating'] as int).toList();
    final avgRating = ratings.reduce((a, b) => a + b) / ratings.length;

    await _client.from('hotels').update({
      'avg_rating': double.parse(avgRating.toStringAsFixed(1)),
      'total_reviews': ratings.length,
    }).eq('id', hotelId);
  }

  Future<List<String>> getCities() async {
    final data = await _client
        .from('hotels')
        .select('city')
        .eq('is_active', true);

    final cities = (data as List)
        .map((e) => e['city'] as String)
        .toSet()
        .toList();
    cities.sort();
    return cities;
  }
}
