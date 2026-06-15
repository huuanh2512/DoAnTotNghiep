import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:server_module/server_module.dart' as server_module;
import 'package:notification_module/notification_module.dart';
import 'package:authentication_module/data/models/reset_password_request.dart';
import 'package:authentication_module/presentation/blocs/auth/auth_bloc.dart';
import 'package:authentication_module/presentation/blocs/auth/auth_event.dart';
import 'package:authentication_module/presentation/blocs/auth/auth_state.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _otpController = TextEditingController();
  bool _obscurePassword = true;
  bool _otpSent = false;
  bool _isSendingOtp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr(vi: 'Vui lòng nhập Email', en: 'Please enter Email'))),
      );
      return;
    }
    setState(() => _isSendingOtp = true);
    try {
      final authService = GetIt.I<server_module.AuthService>();
      final res = await authService.forgotPassword(email: email);
      if (!mounted) return;
      if (res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr(
              vi: 'Mã xác thực OTP đã được gửi về hòm thư của bạn!',
              en: 'Verification OTP has been sent to your email!',
            )),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _otpSent = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message ?? context.tr(vi: 'Gửi mã OTP thất bại.', en: 'Failed to send OTP.')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingOtp = false);
      }
    }
  }

  void _onResetPassword() {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text;

    if (email.isEmpty || otp.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr(vi: 'Vui lòng điền đầy đủ thông tin', en: 'Please fill in all fields'))),
      );
      return;
    }

    context.read<AuthBloc>().add(
          AuthResetPasswordRequested(
            ResetPasswordRequest(
              email: email,
              otp: otp,
              newPassword: newPassword,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? context.tr(vi: 'Đặt lại mật khẩu thành công!', en: 'Password reset successfully!')),
              backgroundColor: Colors.green,
            ),
          );
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/sign-in');
          }
        }
        if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/sign-in');
              }
            },
          ),
        ),
        body: Stack(
          children: [
            // Sporty background decorations
            Positioned.fill(
              child: CustomPaint(
                painter: AuthBackgroundPainter(),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Branding header
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
                              Icons.sports_soccer,
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
                      const SizedBox(height: 40),
                      Text(
                        context.tr(vi: 'Khôi phục mật khẩu', en: 'Recover password'),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _otpSent
                            ? context.tr(
                                vi: 'Nhập mã OTP gửi về mail và mật khẩu mới để khôi phục.',
                                en: 'Enter OTP sent to your email and your new password to recover.',
                              )
                            : context.tr(
                                vi: 'Nhập email đăng ký để nhận mã OTP khôi phục tài khoản.',
                                en: 'Enter your registered email to receive recovery OTP code.',
                              ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 36),
                      // Email Field
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_otpSent && !_isSendingOtp,
                        decoration: InputDecoration(
                          labelText: context.tr(vi: 'Email', en: 'Email'),
                          hintText: 'you@example.com',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: theme.colorScheme.primary.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      if (_otpSent) ...[
                        const SizedBox(height: 16),
                        // OTP Field
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            labelText: context.tr(vi: 'Mã xác thực OTP', en: 'OTP Code'),
                            hintText: '6 chữ số...',
                            counterText: '',
                            prefixIcon: Icon(
                              Icons.security_outlined,
                              color: theme.colorScheme.primary.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // New Password Field
                        TextField(
                          controller: _newPasswordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: context.tr(vi: 'Mật khẩu mới', en: 'New Password'),
                            hintText: '••••••••',
                            prefixIcon: Icon(
                              Icons.lock_outlined,
                              color: theme.colorScheme.primary.withValues(alpha: 0.5),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _isSendingOtp ? null : _sendOtp,
                            child: Text(
                              context.tr(vi: 'Gửi lại mã OTP', en: 'Resend OTP'),
                              style: const TextStyle(color: Color(0xFFFF5600)),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 30),
                      // Action Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isResetting = state is AuthLoading;
                          final isLoading = _isSendingOtp || isResetting;

                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : (_otpSent ? _onResetPassword : _sendOtp),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _otpSent
                                          ? context.tr(vi: 'Khôi phục mật khẩu', en: 'Reset Password')
                                          : context.tr(vi: 'Gửi mã OTP', en: 'Send OTP'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          );
                        },
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final accentPaint = Paint()
      ..color = const Color(0xFFFF5600).withValues(alpha: 0.03) // finOrange opacity
      ..style = PaintingStyle.fill;

    // Sporty diagonal decorative shapes
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

    // Track/court lines
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), 140, paint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), 90, paint);

    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.85), 180, paint);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.85), 130, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}