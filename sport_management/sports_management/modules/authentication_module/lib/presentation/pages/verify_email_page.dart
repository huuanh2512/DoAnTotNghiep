// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:notification_module/notification_module.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_module/app_module.dart';
import 'package:authentication_module/data/models/sign_in_request.dart';
import 'package:authentication_module/presentation/blocs/auth/auth_bloc.dart';
import 'package:authentication_module/presentation/blocs/auth/auth_event.dart';
import 'package:authentication_module/presentation/blocs/auth/auth_state.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;
  final String password;

  const VerifyEmailPage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  int _cooldownSeconds = 0;
  Timer? _timer;
  bool _isSending = false;
  bool _isChecking = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _cooldownSeconds = 45;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 0) {
        setState(() {
          _cooldownSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _openEmailApp() async {
    final emailLaunchUri = Uri(
      scheme: 'mailto',
    );
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        if (mounted) {
          AppPopup.show(
            context,
            message: context.tr(vi: 'Không thể mở ứng dụng Email tự động.', en: 'Cannot open Email application automatically.'),
            tone: AppPopupTone.warning,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppPopup.show(
          context,
          message: '${context.tr(vi: 'Lỗi khi mở app email: ', en: 'Error opening email app: ')}$e',
          tone: AppPopupTone.danger,
        );
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    if (_cooldownSeconds > 0 || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final auth = FirebaseAuth.instance;
      // Đăng nhập tạm thời để lấy session gửi email
      final userCredential = await auth.signInWithEmailAndPassword(
        email: widget.email.trim(),
        password: widget.password,
      );
      final user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        _startCooldown();
        if (mounted) {
          AppPopup.show(
            context,
            message: context.tr(vi: 'Email xác thực đã được gửi lại!', en: 'Verification email has been resent!'),
            tone: AppPopupTone.success,
          );
        }
      }
      // Đăng xuất ngay lập tức sau khi gửi xong
      await auth.signOut();
    } catch (e) {
      if (mounted) {
        AppPopup.show(
          context,
          message: '${context.tr(vi: 'Gửi email xác thực thất bại: ', en: 'Failed to send verification email: ')}$e',
          tone: AppPopupTone.danger,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _retrySignIn() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
    });

    // Gọi sự kiện đăng nhập lại để hệ thống kiểm tra trạng thái xác thực
    context.read<AuthBloc>().add(
      AuthSignInRequested(
        SignInRequest(
          username: widget.email,
          password: widget.password,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          setState(() {
            _isChecking = false;
          });
          AppPopup.show(
            context,
            message: context.tr(vi: 'Xác thực và đăng nhập thành công!', en: 'Verification and login successful!'),
            tone: AppPopupTone.success,
          );
          // Điều hướng về Home
          context.go('/home');
        } else if (state is AuthFailureState) {
          setState(() {
            _isChecking = false;
          });
          AppPopup.show(
            context,
            message: state.message,
            tone: AppPopupTone.danger,
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: AuthBackgroundPainter(theme: theme),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF5600), // finOrange
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.sports_soccer_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SPORT ENERGY',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      
                      // Email Icon
                      const Icon(
                        Icons.mark_email_unread_outlined,
                        size: 80,
                        color: Color(0xFFFFC266),
                      ),
                      const SizedBox(height: 24),
                      
                      Text(
                        context.tr(vi: 'Xác thực Email', en: 'Email Verification'),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      
                      Text(
                        '${context.tr(vi: 'Chúng tôi đã gửi một liên kết xác nhận đến email của bạn:', en: 'We have sent a verification link to your email:')}\n${widget.email}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 36),

                      // Nút Mở app email
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _openEmailApp,
                          icon: const Icon(Icons.open_in_new_rounded),
                          label: Text(context.tr(vi: 'Mở ứng dụng Email', en: 'Open Email App')),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: theme.colorScheme.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nút Gửi lại email
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: (_cooldownSeconds > 0 || _isSending) ? null : _sendVerificationEmail,
                          icon: _isSending 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send_rounded),
                          label: Text(_cooldownSeconds > 0 
                              ? '${context.tr(vi: 'Gửi lại sau', en: 'Resend in')} ($_cooldownSeconds s)' 
                              : context.tr(vi: 'Gửi lại email xác thực', en: 'Resend verification email')),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nút Đã xác thực
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isChecking ? null : _retrySignIn,
                          icon: _isChecking
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.verified_outlined),
                          label: Text(context.tr(vi: 'Tôi đã xác thực xong', en: 'I have verified')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5600), // finOrange
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Quay lại đăng nhập
                      TextButton(
                        onPressed: () {
                          context.go('/sign-in');
                        },
                        child: Text(
                          context.tr(vi: 'Quay về đăng nhập', en: 'Back to sign in'),
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthBackgroundPainter extends CustomPainter {
  final ThemeData theme;

  AuthBackgroundPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.colorScheme.primary.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final accentPaint = Paint()
      ..color = const Color(0xFFFF5600).withOpacity(0.03) // finOrange opacity
      ..style = PaintingStyle.fill;

    // Diagonal designs
    final path = Path();
    path.moveTo(size.width * 0.7, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.25);
    path.close();
    canvas.drawPath(path, accentPaint);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.75);
    path2.lineTo(0, size.height);
    path2.lineTo(size.width * 0.3, size.height);
    path2.close();
    canvas.drawPath(path2, accentPaint);

    // Circles
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), 140, paint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), 90, paint);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.85), 180, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
