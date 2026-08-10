part of 'hotel_cubit.dart';

abstract class HotelState extends Equatable {
  const HotelState();

  @override
  List<Object?> get props => [];
}

class HotelInitial extends HotelState {
  const HotelInitial();
}

class HotelLoading extends HotelState {
  const HotelLoading();
}

class HotelListLoaded extends HotelState {
  final List<HotelModel> hotels;
  const HotelListLoaded(this.hotels);

  @override
  List<Object?> get props => [hotels];
}

class HotelDetailLoaded extends HotelState {
  final HotelModel hotel;
  final List<RoomModel> rooms;
  final List<ReviewModel> reviews;

  const HotelDetailLoaded({
    required this.hotel,
    required this.rooms,
    required this.reviews,
  });

  @override
  List<Object?> get props => [hotel, rooms, reviews];
}

class HotelError extends HotelState {
  final String message;
  const HotelError(this.message);

  @override
  List<Object?> get props => [message];
}
