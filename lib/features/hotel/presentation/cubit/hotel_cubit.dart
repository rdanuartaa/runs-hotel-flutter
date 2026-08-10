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
}
