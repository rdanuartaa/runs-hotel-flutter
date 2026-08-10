import 'package:equatable/equatable.dart';

class RoomModel extends Equatable {
  final String id;
  final String hotelId;
  final String name;
  final String? description;
  final String roomType;
  final int pricePerNight;
  final int maxGuests;
  final int totalRooms;
  final String? thumbnailUrl;
  final List<String> amenities;
  final bool isAvailable;
  final DateTime createdAt;

  const RoomModel({
    required this.id,
    required this.hotelId,
    required this.name,
    this.description,
    required this.roomType,
    required this.pricePerNight,
    this.maxGuests = 2,
    this.totalRooms = 1,
    this.thumbnailUrl,
    this.amenities = const [],
    this.isAvailable = true,
    required this.createdAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      hotelId: json['hotel_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      roomType: json['room_type'] as String,
      pricePerNight: json['price_per_night'] as int,
      maxGuests: json['max_guests'] as int? ?? 2,
      totalRooms: json['total_rooms'] as int? ?? 1,
      thumbnailUrl: json['thumbnail_url'] as String?,
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotel_id': hotelId,
      'name': name,
      'description': description,
      'room_type': roomType,
      'price_per_night': pricePerNight,
      'max_guests': maxGuests,
      'total_rooms': totalRooms,
      'thumbnail_url': thumbnailUrl,
      'amenities': amenities,
      'is_available': isAvailable,
    };
  }

  String get roomTypeDisplay {
    switch (roomType) {
      case 'standard':
        return 'Standard';
      case 'deluxe':
        return 'Deluxe';
      case 'suite':
        return 'Suite';
      case 'presidential':
        return 'Presidential';
      default:
        return roomType;
    }
  }

  @override
  List<Object?> get props => [id, hotelId, name, roomType, pricePerNight];
}
