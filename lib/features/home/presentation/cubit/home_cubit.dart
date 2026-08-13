import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../hotel/data/models/hotel_model.dart';
import '../../../hotel/data/repositories/hotel_repository.dart';
import '../../../../core/services/location_service.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HotelRepository _hotelRepository;

  HomeCubit(this._hotelRepository) : super(const HomeInitial());

  Future<void> loadHomeData({
    String category = 'Semua',
    double? userLat,
    double? userLon,
  }) async {
    if (isClosed) return;
    emit(const HomeLoading());
    try {
      var popularHotels = await _hotelRepository.getPopularHotels(limit: 10);
      
      String? search;
      int? starRating;
      int? maxPrice;

      if (category == '⭐ 5') {
        starRating = 5;
      } else if (category == 'Suite') {
        search = 'Suite';
      } else if (category == 'Budget') {
        maxPrice = 300000;
      } else if (category == 'Resort') {
        search = 'Resort';
      }

      var allHotels = await _hotelRepository.getHotels(
        limit: 20,
        search: search,
        starRating: starRating,
        maxPrice: maxPrice,
      );
      
      if (userLat != null && userLon != null) {
        // Calculate distance and sort allHotels
        allHotels = allHotels.map((hotel) {
          if (hotel.latitude != null && hotel.longitude != null) {
            final distance = LocationService.calculateDistance(
              userLat, 
              userLon, 
              hotel.latitude!, 
              hotel.longitude!
            );
            return hotel.copyWith(distanceInMeters: distance);
          }
          return hotel;
        }).toList();

        allHotels.sort((a, b) {
          if (a.distanceInMeters == null && b.distanceInMeters == null) return 0;
          if (a.distanceInMeters == null) return 1;
          if (b.distanceInMeters == null) return -1;
          return a.distanceInMeters!.compareTo(b.distanceInMeters!);
        });

        // Optionally, also sort popularHotels if desired, but usually popular is separate.
        // Let's sort popular as well if we want them localized, or leave as is. 
        // We will just leave popularHotels as is since it's "Popular", but let's calculate distance for UI just in case.
        popularHotels = popularHotels.map((hotel) {
          if (hotel.latitude != null && hotel.longitude != null) {
            final distance = LocationService.calculateDistance(
              userLat, 
              userLon, 
              hotel.latitude!, 
              hotel.longitude!
            );
            return hotel.copyWith(distanceInMeters: distance);
          }
          return hotel;
        }).toList();
      }

      if (isClosed) return;
      emit(HomeLoaded(
        popularHotels: popularHotels,
        allHotels: allHotels,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(HomeError(e.toString()));
    }
  }
}
