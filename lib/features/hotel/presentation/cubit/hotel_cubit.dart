import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/hotel_model.dart';
import '../../data/models/room_model.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/hotel_repository.dart';

part 'hotel_state.dart';

class HotelCubit extends Cubit<HotelState> {
  final HotelRepository _hotelRepository;

  HotelCubit(this._hotelRepository) : super(const HotelInitial());

  Future<void> loadHotels({
    String? search,
    String? city,
    int? starRating,
  }) async {
    emit(const HotelLoading());
    try {
      final hotels = await _hotelRepository.getHotels(
        search: search,
        city: city,
        starRating: starRating,
      );
      emit(HotelListLoaded(hotels));
    } catch (e) {
      emit(HotelError(e.toString()));
    }
  }

  Future<void> loadPopularHotels() async {
    emit(const HotelLoading());
    try {
      final hotels = await _hotelRepository.getPopularHotels();
      emit(HotelListLoaded(hotels));
    } catch (e) {
      emit(HotelError(e.toString()));
    }
  }

  Future<void> loadHotelDetail(String hotelId) async {
    emit(const HotelLoading());
    try {
      final hotel = await _hotelRepository.getHotelById(hotelId);
      final rooms = await _hotelRepository.getRoomsByHotel(hotelId);
      final reviews = await _hotelRepository.getReviewsByHotel(hotelId);
      emit(HotelDetailLoaded(hotel: hotel, rooms: rooms, reviews: reviews));
    } catch (e) {
      emit(HotelError(e.toString()));
    }
  }

  Future<void> searchHotels(String query) async {
    if (query.isEmpty) {
      await loadHotels();
      return;
    }
    emit(const HotelLoading());
    try {
      final hotels = await _hotelRepository.getHotels(search: query);
      emit(HotelListLoaded(hotels));
    } catch (e) {
      emit(HotelError(e.toString()));
    }
  }

  Future<void> submitReview({
    required String userId,
    required String hotelId,
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _hotelRepository.createReview(
        userId: userId,
        hotelId: hotelId,
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      );
      // Reload hotel detail to show updated reviews
      await loadHotelDetail(hotelId);
    } catch (e) {
      emit(HotelError(e.toString()));
    }
  }

  Future<bool> addHotel({
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
    emit(const HotelLoading());
    try {
      await _hotelRepository.addHotel(
        name: name,
        description: description,
        address: address,
        city: city,
        province: province,
        latitude: latitude,
        longitude: longitude,
        starRating: starRating,
        thumbnailUrl: thumbnailUrl,
        facilities: facilities,
      );
      await loadHotels();
      return true;
    } catch (e) {
      emit(HotelError(e.toString()));
      return false;
    }
  }

  Future<bool> updateHotel({
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
    emit(const HotelLoading());
    try {
      await _hotelRepository.updateHotel(
        id: id,
        name: name,
        description: description,
        address: address,
        city: city,
        province: province,
        latitude: latitude,
        longitude: longitude,
        starRating: starRating,
        thumbnailUrl: thumbnailUrl,
        facilities: facilities,
      );
      await loadHotels();
      return true;
    } catch (e) {
      emit(HotelError(e.toString()));
      return false;
    }
  }

  Future<void> deleteHotel(String id) async {
    emit(const HotelLoading());
    try {
      await _hotelRepository.deleteHotel(id);
      await loadHotels();
    } catch (e) {
      emit(HotelError(e.toString()));
    }
  }

  Future<bool> addRoom({
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
    emit(const HotelLoading());
    try {
      await _hotelRepository.addRoom(
        hotelId: hotelId,
        name: name,
        description: description,
        roomType: roomType,
        pricePerNight: pricePerNight,
        maxGuests: maxGuests,
        totalRooms: totalRooms,
        thumbnailUrl: thumbnailUrl,
        amenities: amenities,
      );
      // Reload hotel detail so the new room is visible
      await loadHotelDetail(hotelId);
      return true;
    } catch (e) {
      emit(HotelError(e.toString()));
      return false;
    }
  }

  Future<bool> updateRoom({
    required String id,
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
    emit(const HotelLoading());
    try {
      await _hotelRepository.updateRoom(
        id: id,
        name: name,
        description: description,
        roomType: roomType,
        pricePerNight: pricePerNight,
        maxGuests: maxGuests,
        totalRooms: totalRooms,
        thumbnailUrl: thumbnailUrl,
        amenities: amenities,
      );
      await loadHotelDetail(hotelId);
      return true;
    } catch (e) {
      emit(HotelError(e.toString()));
      return false;
    }
  }

  Future<void> deleteRoom(String id, String hotelId) async {
    emit(const HotelLoading());
    try {
      await _hotelRepository.deleteRoom(id);
      await loadHotelDetail(hotelId);
    } catch (e) {
      emit(HotelError(e.toString()));
    }
  }

  Future<String> uploadImage(File file, String folder) async {
    return await _hotelRepository.uploadImage(file, folder);
  }
}
