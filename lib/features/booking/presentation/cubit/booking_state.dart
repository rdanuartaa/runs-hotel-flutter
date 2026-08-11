part of 'booking_cubit.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingCreated extends BookingState {
  final BookingModel booking;
  const BookingCreated(this.booking);

  @override
  List<Object?> get props => [booking];
}

class BookingHistoryLoaded extends BookingState {
  final List<BookingModel> upcoming;
  final List<BookingModel> completed;
  final List<BookingModel> cancelled;

  const BookingHistoryLoaded({
    required this.upcoming,
    required this.completed,
    required this.cancelled,
  });

  @override
  List<Object?> get props => [upcoming, completed, cancelled];
}

class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}

class AllBookingsLoaded extends BookingState {
  final List<BookingModel> bookings;
  const AllBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}
