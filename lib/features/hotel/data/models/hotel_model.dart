import 'package:equatable/equatable.dart';

class HotelModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String address;
  final String city;
  final String? province;
  final double? latitude;
  final double? longitude;
  final int starRating;
  final String? thumbnailUrl;
  final double avgRating;
  final int totalReviews;
  final List<String> facilities;
  final bool isActive;
  final DateTime createdAt;
  final List<String>? imageUrls;
  final int? minPrice;
  final double? distanceInMeters;

  const HotelModel({
    required this.id,
    required this.name,
    this.description,
    required this.address,
    required this.city,
    this.province,
    this.latitude,
    this.longitude,
    this.starRating = 3,
    this.thumbnailUrl,
    this.avgRating = 0,
    this.totalReviews = 0,
    this.facilities = const [],
    this.isActive = true,
    required this.createdAt,
    this.imageUrls,
    this.minPrice,
    this.distanceInMeters,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String,
      city: json['city'] as String,
      province: json['province'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      starRating: json['star_rating'] as int? ?? 3,
      thumbnailUrl: json['thumbnail_url'] as String?,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      facilities: (json['facilities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      imageUrls: (json['hotel_images'] as List<dynamic>?)
          ?.map((e) => (e as Map<String, dynamic>)['image_url'] as String)
          .toList(),
      minPrice: json['min_price'] as int?,
      distanceInMeters: (json['distanceInMeters'] as num?)?.toDouble(),
    );
  }

  HotelModel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? city,
    String? province,
    double? latitude,
    double? longitude,
    int? starRating,
    String? thumbnailUrl,
    double? avgRating,
    int? totalReviews,
    List<String>? facilities,
    bool? isActive,
    DateTime? createdAt,
    List<String>? imageUrls,
    int? minPrice,
    double? distanceInMeters,
  }) {
    return HotelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      province: province ?? this.province,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      starRating: starRating ?? this.starRating,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      avgRating: avgRating ?? this.avgRating,
      totalReviews: totalReviews ?? this.totalReviews,
      facilities: facilities ?? this.facilities,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      imageUrls: imageUrls ?? this.imageUrls,
      minPrice: minPrice ?? this.minPrice,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'province': province,
      'latitude': latitude,
      'longitude': longitude,
      'star_rating': starRating,
      'thumbnail_url': thumbnailUrl,
      'facilities': facilities,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [id, name, city, avgRating];
}
