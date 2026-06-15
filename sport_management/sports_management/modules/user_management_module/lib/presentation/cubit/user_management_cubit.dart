import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:server_module/server_module.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/update_user_role_usecase.dart';
import '../../domain/usecases/update_user_status_usecase.dart';
import '../../domain/usecases/assign_facility_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import 'user_management_state.dart';

class UserManagementCubit extends Cubit<UserManagementState> {
  final GetUsersUseCase _getUsersUseCase;
  final UpdateUserRoleUseCase _updateUserRoleUseCase;
  final UpdateUserStatusUseCase _updateUserStatusUseCase;
  final AssignFacilityUseCase _assignFacilityUseCase;
  final UpdateUserUseCase _updateUserUseCase;

  UserManagementCubit(
    this._getUsersUseCase,
    this._updateUserRoleUseCase,
    this._updateUserStatusUseCase,
    this._assignFacilityUseCase,
    this._updateUserUseCase,
  ) : super(UserManagementInitial());

  Future<void> loadUsers() async {
    emit(UserManagementLoading());
    try {
      final response = await _getUsersUseCase();
      if (response.success && response.data != null) {
        emit(UserManagementLoaded(response.data!));
      } else {
        emit(UserManagementError(response.message ?? 'Lỗi tải danh sách người dùng'));
      }
    } catch (e) {
      emit(UserManagementError('Lỗi kết nối: $e'));
    }
  }

  Future<void> updateUserRole(String id, String role) async {
    emit(UserManagementLoading());
    try {
      final response = await _updateUserRoleUseCase(id, role);
      if (response.success) {
        emit(const UserManagementSuccess('Cập nhật vai trò người dùng thành công!'));
        await loadUsers();
      } else {
        emit(UserManagementError(response.message ?? 'Cập nhật vai trò thất bại'));
      }
    } catch (e) {
      emit(UserManagementError('Lỗi: $e'));
    }
  }

  Future<void> updateUserStatus(String id, String status) async {
    emit(UserManagementLoading());
    try {
      final response = await _updateUserStatusUseCase(id, status);
      if (response.success) {
        emit(const UserManagementSuccess('Cập nhật trạng thái người dùng thành công!'));
        await loadUsers();
      } else {
        emit(UserManagementError(response.message ?? 'Cập nhật trạng thái thất bại'));
      }
    } catch (e) {
      emit(UserManagementError('Lỗi: $e'));
    }
  }

  Future<void> assignFacility(String id, String facilityId) async {
    emit(UserManagementLoading());
    try {
      final response = await _assignFacilityUseCase(id, facilityId);
      if (response.success) {
        emit(const UserManagementSuccess('Gán cơ sở thành công!'));
        await loadUsers();
      } else {
        emit(UserManagementError(response.message ?? 'Gán cơ sở thất bại'));
      }
    } catch (e) {
      emit(UserManagementError('Lỗi: $e'));
    }
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String role,
    String? name,
    String? phone,
    String? facilityId,
  }) async {
    emit(UserManagementLoading());
    try {
      final authService = GetIt.I<AuthService>();
      final registerRes = await authService.register(
        AuthRegisterRequest(
          email: email.trim().toLowerCase(),
          password: password,
        ),
      );

      if (!registerRes.success) {
        emit(UserManagementError(registerRes.message ?? 'Đăng ký tài khoản thất bại'));
        return;
      }

      String? userId;
      final rawData = registerRes.data;
      if (rawData is Map) {
        String? findId(dynamic data) {
          if (data == null) return null;
          if (data is Map) {
            if (data['userId'] != null) return data['userId'].toString();
            if (data['id'] != null) return data['id'].toString();
            if (data['_id'] != null) return data['_id'].toString();
            
            if (data['data'] != null) {
              final found = findId(data['data']);
              if (found != null) return found;
            }
            if (data['user'] != null) {
              final found = findId(data['user']);
              if (found != null) return found;
            }
          }
          return null;
        }
        userId = findId(rawData);
      }

      if (userId == null || userId.isEmpty) {
        emit(const UserManagementError('Đăng ký thành công nhưng không lấy được ID người dùng'));
        return;
      }

      // 1. Kích hoạt tài khoản lập tức
      final statusRes = await _updateUserStatusUseCase(userId, 'ACTIVE');
      if (!statusRes.success) {
        emit(UserManagementError(statusRes.message ?? 'Kích hoạt tài khoản thất bại'));
        return;
      }

      // 2. Cập nhật thông tin profile
      if ((name != null && name.isNotEmpty) || (phone != null && phone.isNotEmpty)) {
        final profileRes = await _updateUserUseCase(userId, {
          'profile': {
            'name': name,
            'phone': phone,
          }
        });
        if (!profileRes.success) {
          emit(UserManagementError(profileRes.message ?? 'Cập nhật thông tin cá nhân thất bại'));
          return;
        }
      }

      // 3. Gán vai trò
      final roleRes = await _updateUserRoleUseCase(userId, role);
      if (!roleRes.success) {
        emit(UserManagementError(roleRes.message ?? 'Gán vai trò thất bại'));
        return;
      }

      // 4. Gán cơ sở nếu role là STAFF
      if (role.toUpperCase() == 'STAFF' && facilityId != null && facilityId.isNotEmpty) {
        final facilityRes = await _assignFacilityUseCase(userId, facilityId);
        if (!facilityRes.success) {
          emit(UserManagementError(facilityRes.message ?? 'Gán cơ sở thất bại'));
          return;
        }
      }

      emit(const UserManagementSuccess('Thêm thành viên mới thành công!'));
      await loadUsers();
    } catch (e) {
      emit(UserManagementError('Thêm thành viên thất bại: $e'));
    }
  }
}
