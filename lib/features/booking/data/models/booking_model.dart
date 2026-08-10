import 'package:equatable/equatable.dart';

class BookingModel extends Equatable {
  final String id;
  final String userId;
  final String hotelId;
  final String roomId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int totalGuests;
  final int? totalNights;
  final int totalPrice;
  final String status;
  final String? specialRequest;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Joined data
  final String? hotelName;
  final String? hotelThumbnail;
  final String? hotelCity;
  final String? roomName;
  final String? roomType;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.roomId,
    required this.checkIn,
    required this.checkOut,
    this.totalGuests = 1,
    this.totalNights,
    required this.totalPrice,
    this.status = 'pending',
    this.specialRequest,
    required this.createdAt,
    required this.updatedAt,
    this.hotelName,
    this.hotelThumbnail,
    this.hotelCity,
    this.roomName,
    this.roomType,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final hotel = json['hotels'] as Map<String, dynamic>?;
    final room = json['rooms'] as Map<String, dynamic>?;
    return BookingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      hotelId: json['hotel_id'] as String,
      roomId: json['room_id'] as String,
      checkIn: DateTime.parse(json['check_in'] as String),
      checkOut: DateTime.parse(json['check_out'] as String),
      totalGuests: json['total_guests'] as int? ?? 1,
      totalNights: json['total_nights'] as int?,
      totalPrice: json['total_price'] as int,
      status: json['status'] as String? ?? 'pending',
      specialRequest: json['special_request'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      hotelName: hotel?['name'] as String?,
      hotelThumbnail: hotel?['thumbnail_url'] as String?,
      hotelCity: hotel?['city'] as String?,
      roomName: room?['name'] as String?,
      roomType: room?['room_type'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'hotel_id': hotelId,
      'room_id': roomId,
      'check_in': checkIn.toIso8601String().split('T').first,
      'check_out': checkOut.toIso8601String().split('T').first,
      'total_guests': totalGuests,
      'total_price': totalPrice,
      'special_request': specialRequest,
    };
  }

  int get calculatedNights => checkOut.difference(checkIn).inDays;

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'checked_in':
        return 'Check-in';
      case 'checked_out':
        return 'Check-out';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  @override
  List<Object?> get props => [id, userId, hotelId, roomId, status];
}
