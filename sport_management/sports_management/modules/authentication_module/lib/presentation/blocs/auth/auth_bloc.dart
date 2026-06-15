import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:server_module/server_module.dart';
import 'package:flutter/foundation.dart';
import 'package:authentication_module/domain/usecases/sign_in_usecase.dart';
import 'package:authentication_module/domain/usecases/sign_up_usecase.dart';
import 'package:authentication_module/domain/usecases/sign_out_usecase.dart';
import 'package:authentication_module/domain/usecases/refresh_session_usecase.dart';
import 'package:authentication_module/domain/usecases/reset_password_usecase.dart';
import 'package:authentication_module/domain/usecases/get_local_user_usecase.dart';
import 'package:authentication_module/application/session/session_manager.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required RefreshSessionUseCase refreshSessionUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
  // ignore: prefer_initializing_formals
  })  : _signInUseCase = signInUseCase,
        // ignore: prefer_initializing_formals
        _signUpUseCase = signUpUseCase,
        // ignore: prefer_initializing_formals
        _signOutUseCase = signOutUseCase,
        // ignore: prefer_initializing_formals
        _refreshSessionUseCase = refreshSessionUseCase,
        // ignore: prefer_initializing_formals
        _resetPasswordUseCase = resetPasswordUseCase,
        super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthSessionRefreshRequested>(_onRefreshSession);
    on<AuthResetPasswordRequested>(_onResetPassword);
    on<AuthSessionExpired>(_onSessionExpired);
    on<AuthSessionValidated>(_onSessionValidated);
  }

  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final RefreshSessionUseCase _refreshSessionUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  // ─── Helpers ─────────────────────────────────────────────────────────────

  /// Khởi động SessionManager và gắn callback hết hạn → emit AuthSessionExpired.
  void startSessionManager() {
    final sm = SessionManager.instance;
    sm.onSessionExpired = () {
      if (!isClosed) add(const AuthSessionExpired());
    };
    sm.startChecking();
  }

  /// Dừng SessionManager (gọi khi đăng xuất hoặc bloc close).
  void stopSessionManager() {
    SessionManager.instance.stopChecking();
  }

  // ─── Handlers ────────────────────────────────────────────────────────────

  Future<void> _onStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthUnauthenticated());
  }

  Future<void> _onSignIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signInUseCase(event.request);
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) {
        if (user.isSuccess) {
          startSessionManager();
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthFailureState(user.error ?? 'Đăng nhập thất bại.'));
        }
      },
    );
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signUpUseCase(event.request);
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(AuthSuccess(message: user.error)),
    );
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        final userService = GetIt.I<UserService>();
        await userService.removeFCMToken(token);
        debugPrint('[AuthBloc] FCM token removed successfully on logout.');
      }
    } catch (e) {
      debugPrint('[AuthBloc] Error removing FCM token on sign out: $e');
    }

    stopSessionManager();
    final result = await _signOutUseCase(event.request);
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onRefreshSession(
    AuthSessionRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _refreshSessionUseCase(event.refreshToken);
    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) => user.isSuccess
          ? emit(AuthAuthenticated(user))
          : emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onResetPassword(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _resetPasswordUseCase(event.request);
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => user.isSuccess
          ? emit(const AuthSuccess(message: 'Đặt lại mật khẩu thành công.'))
          : emit(AuthFailureState(user.error ?? 'Thất bại.')),
    );
  }

  /// Gọi bởi SessionManager khi token hết hạn hoàn toàn.
  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    stopSessionManager();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onSessionValidated(
    AuthSessionValidated event,
    Emitter<AuthState> emit,
  ) async {
    final getLocalUser = GetIt.I<GetLocalUserUseCase>();
    final result = await getLocalUser();
    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) {
        startSessionManager();
        emit(AuthAuthenticated(user));
      },
    );
  }

  @override
  Future<void> close() {
    stopSessionManager();
    return super.close();
  }
}