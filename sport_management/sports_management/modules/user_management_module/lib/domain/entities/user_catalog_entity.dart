import 'package:server_module/server_module.dart';

class UserCatalogEntity extends UserEntity {
  final String? facilityName;
  final String? facilityId;
  final String? phone;

  const UserCatalogEntity({
    required super.id,
    super.email,
    super.name,
    super.avatar,
    super.role,
    super.status,
    super.createdAt,
    this.facilityName,
    this.facilityId,
    this.phone,
  });

  @override
  List<Object?> get props => [...super.props, facilityName, facilityId, phone];
}
