part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<HotelModel> popularHotels;
  final List<HotelModel> allHotels;

  const HomeLoaded({
    required this.popularHotels,
    required this.allHotels,
  });

  @override
  List<Object?> get props => [popularHotels, allHotels];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
