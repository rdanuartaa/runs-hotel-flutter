import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../hotel/data/models/hotel_model.dart';
import '../../../hotel/data/repositories/hotel_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HotelRepository _hotelRepository;

  HomeCubit(this._hotelRepository) : super(const HomeInitial());

  Future<void> loadHomeData({String category = 'Semua'}) async {
    emit(const HomeLoading());
    try {
      final popularHotels = await _hotelRepository.getPopularHotels(limit: 10);
      
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

      final allHotels = await _hotelRepository.getHotels(
        limit: 20,
        search: search,
        starRating: starRating,
        maxPrice: maxPrice,
      );
      
      emit(HomeLoaded(
        popularHotels: popularHotels,
        allHotels: allHotels,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
