// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_module/app_module.dart';
import 'package:app_module/router/route_paths.dart';
import 'package:notification_module/notification_module.dart';
import 'package:authentication_module/data/models/sign_in_request.dart';
import 'package:authentication_module/presentation/blocs/auth/auth_bloc.dart';
import 'package:authentication_module/presentation/blocs/auth/auth_event.dart';
import 'package:authentication_module/presentation/blocs/auth/auth_state.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _localizeAuthErrorMessage(BuildContext context, String error) {
    final lower = error.toLowerCase();
    if (lower.contains('wrong-password') || 
        lower.contains('invalid-credential') || 
        lower.contains('sai mật khẩu') ||
        lower.contains('mật khẩu không đúng')) {
      return context.tr(vi: 'Mật khẩu nhập không chính xác.', en: 'Incorrect password.');
    }
    if (lower.contains('user-not-found') || 
        lower.contains('no user found') ||
        lower.contains('không tìm thấy người dùng')) {
      return context.tr(vi: 'Tài khoản Email không tồn tại.', en: 'Email account does not exist.');
    }
    if (lower.contains('invalid-email')) {
      return context.tr(vi: 'Địa chỉ email không đúng định dạng.', en: 'Invalid email address format.');
    }
    if (lower.contains('email-already-in-use')) {
      return context.tr(vi: 'Địa chỉ email này đã được đăng ký.', en: 'This email address is already registered.');
    }
    return error;
  }

  void _submitSignIn() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthSignInRequested(
              SignInRequest(
                username: _emailController.text.trim(),
                password: _passwordController.text,
              ),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          AppPopup.show(
            context,
            message: context.tr(vi: 'Đăng nhập thành công', en: 'Logged in successfully'),
            tone: AppPopupTone.success,
          );
          context.goNamed(RoutePaths.homeName);
        }

        if (state is AuthFailureState) {
          final isUnverified = state.message.toLowerCase().contains('email chưa xác thực') ||
                               state.message.toLowerCase().contains('verify email') ||
                               state.message.toLowerCase().contains('not verified') ||
                               state.message.toLowerCase().contains('xác thực email');
          if (isUnverified) {
            context.go(
              '/verify-email',
              extra: <String, String>{
                'email': _emailController.text.trim(),
                'password': _passwordController.text,
              },
            );
          } else {
            AppPopup.show(
              context,
              message: _localizeAuthErrorMessage(context, state.message),
              tone: AppPopupTone.danger,
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Background decorations
            Positioned.fill(
              child: CustomPaint(
                painter: AuthBackgroundPainter(theme: theme),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      
                      return Form(
                        key: _formKey,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.cardColor.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.dividerColor.withOpacity(0.1),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
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
                              const SizedBox(height: 32),
                              Text(
                                context.tr(vi: 'Đăng nhập', en: 'Sign In'),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                context.tr(vi: 'Chào mừng trở lại. Sẵn sàng bứt phá giới hạn.', en: 'Welcome back. Ready to push the limits.'),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              // Email Field
                              _EnergyTextField(
                                controller: _emailController,
                                labelText: context.tr(vi: 'Email', en: 'Email'),
                                hintText: 'you@example.com',
                                prefixIcon: Icons.email_outlined,
                                enabled: !isLoading,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return context.tr(vi: 'Vui lòng nhập Email', en: 'Please enter Email');
                                  }
                                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegex.hasMatch(val.trim())) {
                                    return context.tr(vi: 'Định dạng Email không hợp lệ', en: 'Invalid email format');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Password Field
                              _EnergyTextField(
                                controller: _passwordController,
                                labelText: context.tr(vi: 'Mật khẩu', en: 'Password'),
                                hintText: '••••••••',
                                prefixIcon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                enabled: !isLoading,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: theme.colorScheme.primary.withOpacity(0.5),
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return context.tr(vi: 'Vui lòng nhập Mật khẩu', en: 'Please enter Password');
                                  }
                                  if (val.length < 6) {
                                    return context.tr(vi: 'Mật khẩu phải chứa ít nhất 6 ký tự', en: 'Password must be at least 6 characters');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: isLoading ? null : () => context.push('/reset-password'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFFF5600),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Text(context.tr(vi: 'Quên mật khẩu?', en: 'Forgot password?')),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Sign In Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: isLoading ? null : _submitSignIn,
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
                                          context.tr(vi: 'Đăng nhập ngay', en: 'Sign In Now'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // 3-Role Info Card
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withOpacity(0.06),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: Color(0xFFFF5600),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        context.tr(vi: 'Hệ sinh thái đa vai trò: Tài khoản có thể đăng nhập với vai trò Người chơi, Chủ sân hoặc Admin.', en: 'Multi-role ecosystem: Account can log in as Player, Owner, or Admin.'),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                                          fontSize: 11,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    context.tr(vi: 'Chưa có tài khoản?', en: 'Don\'t have an account?'),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  TextButton(
                                    onPressed: isLoading ? null : () => context.push('/sign-up'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFFFF5600),
                                    ),
                                    child: Text(context.tr(vi: 'Đăng ký', en: 'Sign Up')),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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

class _EnergyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _EnergyTextField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: theme.colorScheme.primary.withOpacity(0.6)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: theme.cardColor.withOpacity(0.7),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
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
      ..color = theme.colorScheme.primary.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final accentPaint = Paint()
      ..color = const Color(0xFFFF5600).withOpacity(0.025) // finOrange opacity
      ..style = PaintingStyle.fill;

    // Diagonal decorative shapes
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

    // Track lines
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), 140, paint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), 90, paint);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.85), 180, paint);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.85), 130, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}