import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:server_module/server_module.dart';
import 'package:user_management_module/data/datasources/remote/user_management_remote_data_source.dart';
import 'package:user_management_module/data/repositories/admin_user_repository_impl.dart';
import 'package:user_management_module/domain/usecases/get_users_usecase.dart';
import 'package:user_management_module/domain/usecases/update_user_role_usecase.dart';
import 'package:user_management_module/domain/usecases/update_user_status_usecase.dart';
import 'package:user_management_module/domain/usecases/assign_facility_usecase.dart';
import 'package:user_management_module/domain/usecases/update_user_usecase.dart';
import 'package:user_management_module/presentation/cubit/user_management_cubit.dart';
import 'package:user_management_module/presentation/cubit/user_management_state.dart';

class FakeRemoteDataSource implements UserManagementRemoteDataSource {
  bool shouldSucceed = true;
  String? lastUserId;
  String? lastRole;
  String? lastStatus;
  String? lastFacilityId;
  Map<String, dynamic>? lastUpdateData;

  @override
  Future<BaseResponse<dynamic>> getUsers() async {
    return BaseResponse(
      success: shouldSucceed,
      data: shouldSucceed ? {'items': []} : null,
      message: shouldSucceed ? null : 'Error',
    );
  }

  @override
  Future<BaseResponse<dynamic>> getUserById(String id) async {
    return BaseResponse(
      success: shouldSucceed,
      data: shouldSucceed ? {'_id': id, 'email': 'test@test.com'} : null,
      message: shouldSucceed ? null : 'Error',
    );
  }

  @override
  Future<BaseResponse<dynamic>> updateUser(String id, Map<String, dynamic> data) async {
    lastUserId = id;
    lastUpdateData = data;
    return BaseResponse(
      success: shouldSucceed,
      data: shouldSucceed ? {'_id': id, 'email': 'test@test.com', 'profile': data['profile']} : null,
      message: shouldSucceed ? null : 'Error',
    );
  }

  @override
  Future<BaseResponse<dynamic>> updateUserRole(String id, String role) async {
    lastUserId = id;
    lastRole = role;
    return BaseResponse(
      success: shouldSucceed,
      data: shouldSucceed ? {'_id': id, 'role': role} : null,
      message: shouldSucceed ? null : 'Error',
    );
  }

  @override
  Future<BaseResponse<dynamic>> updateUserStatus(String id, String status) async {
    lastUserId = id;
    lastStatus = status;
    return BaseResponse(
      success: shouldSucceed,
      data: shouldSucceed ? {'_id': id, 'status': status} : null,
      message: shouldSucceed ? null : 'Error',
    );
  }

  @override
  Future<BaseResponse<dynamic>> assignFacility(String id, String facilityId) async {
    lastUserId = id;
    lastFacilityId = facilityId;
    return BaseResponse(
      success: shouldSucceed,
      data: shouldSucceed ? {'_id': id, 'facilityId': facilityId} : null,
      message: shouldSucceed ? null : 'Error',
    );
  }
}

class MockAuthService implements AuthService {
  bool shouldSucceed = true;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<BaseResponse<dynamic>> register(AuthRegisterRequest request) async {
    lastEmail = request.email;
    lastPassword = request.password;
    if (shouldSucceed) {
      return BaseResponse(
        success: true,
        data: {
          'user': {'id': 'mocked_user_id_123', 'email': request.email}
        },
      );
    } else {
      return BaseResponse(success: false, message: 'Email already exists');
    }
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('UserManagementCubit registerUser tests', () {
    late FakeRemoteDataSource fakeDataSource;
    late AdminUserRepositoryImpl repository;
    late GetUsersUseCase getUsersUseCase;
    late UpdateUserRoleUseCase updateUserRoleUseCase;
    late UpdateUserStatusUseCase updateUserStatusUseCase;
    late AssignFacilityUseCase assignFacilityUseCase;
    late UpdateUserUseCase updateUserUseCase;
    late MockAuthService mockAuthService;
    late UserManagementCubit cubit;

    setUp(() {
      fakeDataSource = FakeRemoteDataSource();
      repository = AdminUserRepositoryImpl(fakeDataSource);
      getUsersUseCase = GetUsersUseCase(repository);
      updateUserRoleUseCase = UpdateUserRoleUseCase(repository);
      updateUserStatusUseCase = UpdateUserStatusUseCase(repository);
      assignFacilityUseCase = AssignFacilityUseCase(repository);
      updateUserUseCase = UpdateUserUseCase(repository);
      mockAuthService = MockAuthService();

      final getIt = GetIt.instance;
      getIt.reset();
      getIt.registerSingleton<AuthService>(mockAuthService);

      cubit = UserManagementCubit(
        getUsersUseCase,
        updateUserRoleUseCase,
        updateUserStatusUseCase,
        assignFacilityUseCase,
        updateUserUseCase,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('should register user and update status, profile, and role successfully', () async {
      // Act
      await cubit.registerUser(
        email: 'new_staff@test.com',
        password: 'password123',
        role: 'STAFF',
        name: 'New Staff Name',
        phone: '0987654321',
        facilityId: 'facility_abc',
      );

      // Assert
      expect(mockAuthService.lastEmail, 'new_staff@test.com');
      expect(mockAuthService.lastPassword, 'password123');

      expect(fakeDataSource.lastUserId, 'mocked_user_id_123');
      expect(fakeDataSource.lastStatus, 'ACTIVE');

      expect(fakeDataSource.lastUpdateData, {
        'profile': {
          'name': 'New Staff Name',
          'phone': '0987654321',
        }
      });

      expect(fakeDataSource.lastRole, 'STAFF');
      expect(fakeDataSource.lastFacilityId, 'facility_abc');

      expect(cubit.state, isA<UserManagementLoaded>());
    });

    test('should fail if register fails', () async {
      // Arrange
      mockAuthService.shouldSucceed = false;

      // Act
      await cubit.registerUser(
        email: 'staff_fail@test.com',
        password: 'password123',
        role: 'STAFF',
      );

      // Assert
      expect(cubit.state, isA<UserManagementError>());
      expect((cubit.state as UserManagementError).message, contains('Email already exists'));
    });
  });
}
