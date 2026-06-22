import 'package:authentication_module/data/datasources/local/authentication_local_data_source.dart';
import 'package:authentication_module/data/models/user_result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:server_module/server_module.dart';

class FirebaseEmailAuthFlow {
  FirebaseEmailAuthFlow._();

  static final FirebaseAuth _firebase = FirebaseAuth.instance;

  static Future<void> register({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    final credential = await _firebase.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.sendEmailVerification();
    final response = await GetIt.I<AuthService>().firebaseRegister(
      firebaseIdToken: (await credential.user!.getIdToken())!,
      fullName: fullName,
      phone: phone,
    );
    if (!response.success) {
      throw FirebaseAuthException(
        code: response.code ?? 'backend-register-failed',
        message: response.message,
      );
    }
  }

  static Future<void> resendVerification() async {
    final user = _firebase.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'no-current-user');
    await user.sendEmailVerification();
  }

  static Future<UserResult> completeVerification() async {
    final user = _firebase.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'no-current-user');
    await user.reload();
    final refreshed = _firebase.currentUser;
    if (refreshed == null || !refreshed.emailVerified) {
      throw FirebaseAuthException(code: 'email-not-verified');
    }
    final response = await GetIt.I<AuthService>()
        .firebaseCompleteEmailVerification((await refreshed.getIdToken(true))!);
    if (!response.success) {
      throw FirebaseAuthException(
        code: response.code ?? 'backend-verification-failed',
        message: response.message,
      );
    }
    return _persist(response.data);
  }

  static Future<UserResult> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _firebase.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (!credential.user!.emailVerified) {
      await credential.user!.sendEmailVerification();
      throw FirebaseAuthException(code: 'email-not-verified');
    }
    final response = await GetIt.I<AuthService>().firebaseLogin(
      (await credential.user!.getIdToken())!,
    );
    if (!response.success) {
      throw FirebaseAuthException(
        code: response.code ?? 'backend-login-failed',
        message: response.message,
      );
    }
    return _persist(response.data);
  }

  static Future<UserResult> _persist(dynamic raw) async {
    final data = raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};
    final user = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'])
        : <String, dynamic>{};
    final profile = user['profile'] is Map
        ? Map<String, dynamic>.from(user['profile'])
        : <String, dynamic>{};
    final result = UserResult(
      isSuccess: true,
      userId: user['id']?.toString(),
      email: user['email']?.toString(),
      name: profile['name']?.toString(),
      avatarUrl: profile['avatarUrl']?.toString(),
      role: user['role']?.toString(),
      status: user['status']?.toString(),
      accessToken: data['accessToken']?.toString(),
      expiresAt: data['expiresAt'] == null
          ? null
          : DateTime.tryParse(data['expiresAt'].toString()),
    );
    await GetIt.I<AuthenticationLocalDataSource>().saveUser(result);
    return result;
  }
}
