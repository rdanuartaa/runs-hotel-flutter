import 'dart:io';
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
    int? minPrice,
    int? maxPrice,
    bool? sortByPriceAsc,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _client
        .from('hotels')
        .select('*, hotel_images(image_url), rooms(price_per_night)')
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

    // We fetch all matching non-price filters first, ordered by avg_rating
    final data = await query.order('avg_rating', ascending: false);

    // Calculate minPrice from rooms and parse to Model
    List<HotelModel> allHotels = (data as List).map((e) {
      final rooms = e['rooms'] as List?;
      int? calcMinPrice;
      if (rooms != null && rooms.isNotEmpty) {
        calcMinPrice = rooms
            .map((r) => r['price_per_night'] as int)
            .reduce((a, b) => a < b ? a : b);
      }
      // Inject min_price to JSON so HotelModel.fromJson can pick it up
      e['min_price'] = calcMinPrice;
      return HotelModel.fromJson(e);
    }).toList();

    // Filter by price in Dart
    if (minPrice != null) {
      allHotels = allHotels.where((h) => h.minPrice != null && h.minPrice! >= minPrice).toList();
    }
    if (maxPrice != null) {
      allHotels = allHotels.where((h) => h.minPrice != null && h.minPrice! <= maxPrice).toList();
    }

    // Sort by price in Dart
    if (sortByPriceAsc == true) {
      allHotels.sort((a, b) => (a.minPrice ?? 999999999).compareTo(b.minPrice ?? 999999999));
    } else if (sortByPriceAsc == false) {
      allHotels.sort((a, b) => (b.minPrice ?? 0).compareTo(a.minPrice ?? 0));
    }

    // Apply Pagination
    final end = (offset + limit < allHotels.length) ? offset + limit : allHotels.length;
    if (offset >= allHotels.length) return [];
    
    return allHotels.sublist(offset, end);
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

  Future<HotelModel> addHotel({
    required String name,
    String? description,
    required String address,
    required String city,
    String? province,
    required double latitude,
    required double longitude,
    required int starRating,
    String? thumbnailUrl,
    List<String> facilities = const [],
  }) async {
    final response = await _client.from('hotels').insert({
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'province': province,
      'latitude': latitude,
      'longitude': longitude,
      'star_rating': starRating,
      'thumbnail_url': thumbnailUrl,
      'facilities': facilities,
      'is_active': true,
    }).select().single();

    return HotelModel.fromJson(response);
  }

  Future<HotelModel> updateHotel({
    required String id,
    required String name,
    String? description,
    required String address,
    required String city,
    String? province,
    required double latitude,
    required double longitude,
    required int starRating,
    String? thumbnailUrl,
    List<String> facilities = const [],
  }) async {
    final response = await _client.from('hotels').update({
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'province': province,
      'latitude': latitude,
      'longitude': longitude,
      'star_rating': starRating,
      'thumbnail_url': thumbnailUrl,
      'facilities': facilities,
    }).eq('id', id).select().single();

    return HotelModel.fromJson(response);
  }

  Future<void> deleteHotel(String id) async {
    await _client.from('hotels').update({'is_active': false}).eq('id', id);
  }

  Future<RoomModel> addRoom({
    required String hotelId,
    required String name,
    String? description,
    required String roomType,
    required int pricePerNight,
    required int maxGuests,
    required int totalRooms,
    String? thumbnailUrl,
    List<String> amenities = const [],
  }) async {
    final response = await _client.from('rooms').insert({
      'hotel_id': hotelId,
      'name': name,
      'description': description,
      'room_type': roomType,
      'price_per_night': pricePerNight,
      'max_guests': maxGuests,
      'total_rooms': totalRooms,
      'thumbnail_url': thumbnailUrl,
      'amenities': amenities,
      'is_available': true,
    }).select().single();

    return RoomModel.fromJson(response);
  }

  Future<RoomModel> updateRoom({
    required String id,
    required String name,
    String? description,
    required String roomType,
    required int pricePerNight,
    required int maxGuests,
    required int totalRooms,
    String? thumbnailUrl,
    List<String> amenities = const [],
  }) async {
    final response = await _client.from('rooms').update({
      'name': name,
      'description': description,
      'room_type': roomType,
      'price_per_night': pricePerNight,
      'max_guests': maxGuests,
      'total_rooms': totalRooms,
      'thumbnail_url': thumbnailUrl,
      'amenities': amenities,
    }).eq('id', id).select().single();

    return RoomModel.fromJson(response);
  }

  Future<void> deleteRoom(String id) async {
    await _client.from('rooms').delete().eq('id', id);
  }

  Future<String> uploadImage(File file, String folder) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final filePath = '$folder/$fileName';
    
    await _client.storage.from('hotel_images').upload(
      filePath,
      file,
    );
    
    return _client.storage.from('hotel_images').getPublicUrl(filePath);
  }
}
