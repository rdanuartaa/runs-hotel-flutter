import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String id;
  final String userId;
  final String hotelId;
  final String? bookingId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatar;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.hotelId,
    this.bookingId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['users'] as Map<String, dynamic>?;
    return ReviewModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      hotelId: json['hotel_id'] as String,
      bookingId: json['booking_id'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: user?['full_name'] as String?,
      userAvatar: user?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'hotel_id': hotelId,
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
    };
  }

  @override
  List<Object?> get props => [id, userId, hotelId, rating];
}
