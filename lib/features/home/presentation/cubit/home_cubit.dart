import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../hotel/data/models/hotel_model.dart';
import '../../../hotel/data/repositories/hotel_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HotelRepository _hotelRepository;

  HomeCubit(this._hotelRepository) : super(const HomeInitial());

  Future<void> loadHomeData() async {
    emit(const HomeLoading());
    try {
      final popularHotels = await _hotelRepository.getPopularHotels(limit: 10);
      final allHotels = await _hotelRepository.getHotels(limit: 20);
      emit(HomeLoaded(
        popularHotels: popularHotels,
        allHotels: allHotels,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
