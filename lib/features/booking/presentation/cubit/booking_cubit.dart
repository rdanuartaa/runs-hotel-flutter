import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository _bookingRepository;

  BookingCubit(this._bookingRepository) : super(const BookingInitial());

  Future<void> createBooking({
    required String userId,
    required String hotelId,
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int totalGuests,
    required int totalPrice,
    String? specialRequest,
  }) async {
    emit(const BookingLoading());
    try {
      final booking = await _bookingRepository.createBooking(
        userId: userId,
        hotelId: hotelId,
        roomId: roomId,
        checkIn: checkIn,
        checkOut: checkOut,
        totalGuests: totalGuests,
        totalPrice: totalPrice,
        specialRequest: specialRequest,
      );
      emit(BookingCreated(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> loadBookingHistory(String userId) async {
    emit(const BookingLoading());
    try {
      final upcoming = await _bookingRepository.getUpcomingBookings(userId);
      final completed = await _bookingRepository.getCompletedBookings(userId);
      final cancelled = await _bookingRepository.getCancelledBookings(userId);
      emit(BookingHistoryLoaded(
        upcoming: upcoming,
        completed: completed,
        cancelled: cancelled,
      ));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> cancelBooking(String bookingId, String userId) async {
    emit(const BookingLoading());
    try {
      await _bookingRepository.cancelBooking(bookingId);
      await loadBookingHistory(userId);
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}
