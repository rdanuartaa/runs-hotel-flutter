import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    this.role = 'guest',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [id, email, fullName, phone, avatarUrl, role];
}
