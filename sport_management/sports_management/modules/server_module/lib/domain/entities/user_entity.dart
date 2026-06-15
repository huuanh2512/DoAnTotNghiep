import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? name;
  final String? avatar;
  final String? role;
  final String? status;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    this.email,
    this.name,
    this.avatar,
    this.role,
    this.status,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, name, avatar, role, status, createdAt];
}