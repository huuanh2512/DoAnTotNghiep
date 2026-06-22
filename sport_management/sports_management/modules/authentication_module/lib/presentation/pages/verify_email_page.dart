import 'dart:async';

import 'package:app_module/app_module.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:server_module/server_module.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key, required this.email, this.password = ''});

  final String email;
  final String password;

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _otpController = TextEditingController();
  Timer? _timer;
  int _cooldownSeconds = 0;
  bool _isSending = false;
  bool _isVerifying = false;

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _timer?.cancel();
    setState(() => _cooldownSeconds = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _cooldownSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds--);
      }
    });
  }

  int? _cooldownFromResponse(BaseResponse<dynamic> response) {
    final root = response.data;
    if (root is Map) {
      final nested = root['data'];
      final value = nested is Map
          ? nested['cooldownSeconds']
          : root['cooldownSeconds'];
      return value is num ? value.ceil() : null;
    }
    return null;
  }

  Future<void> _resend() async {
    if (_isSending || _cooldownSeconds > 0) return;
    setState(() => _isSending = true);
    final response = await GetIt.I<AuthService>().resendVerification(
      email: widget.email,
    );
    if (!mounted) return;
    setState(() => _isSending = false);
    final cooldown = _cooldownFromResponse(response);
    if (cooldown != null && cooldown > 0) _startCooldown(cooldown);
    AppPopup.show(
      context,
      message:
          response.message ??
          (response.success
              ? 'Đã gửi mã xác thực.'
              : 'Không thể gửi mã xác thực.'),
      tone: response.success ? AppPopupTone.success : AppPopupTone.danger,
    );
  }

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      AppPopup.show(
        context,
        message: 'Vui lòng nhập mã OTP gồm 6 chữ số.',
        tone: AppPopupTone.warning,
      );
      return;
    }
    setState(() => _isVerifying = true);
    final response = await GetIt.I<AuthService>().verifyEmail(
      email: widget.email,
      otp: otp,
    );
    if (!mounted) return;
    setState(() => _isVerifying = false);
    if (response.success) {
      AppPopup.show(
        context,
        message: 'Xác thực email thành công. Hãy đăng nhập.',
        tone: AppPopupTone.success,
      );
      context.go('/sign-in');
      return;
    }
    AppPopup.show(
      context,
      message: response.message ?? 'Xác thực email thất bại.',
      tone: AppPopupTone.danger,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 76,
                    color: Color(0xFFFFC266),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Xác thực Email',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nhập mã gồm 6 chữ số đã gửi đến\n${widget.email}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      letterSpacing: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Mã OTP',
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _verify,
                      child: _isVerifying
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Xác thực'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: (_isSending || _cooldownSeconds > 0)
                        ? null
                        : _resend,
                    child: Text(
                      _cooldownSeconds > 0
                          ? 'Gửi lại sau $_cooldownSeconds giây'
                          : 'Gửi lại mã xác thực',
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/sign-in'),
                    child: const Text('Quay về đăng nhập'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
