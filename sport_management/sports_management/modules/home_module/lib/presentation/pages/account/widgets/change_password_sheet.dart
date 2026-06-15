import 'package:authentication_module/data/datasources/local/authentication_local_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:notification_module/notification_module.dart';
import 'package:server_module/server_module.dart';

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChangePasswordSheet(),
    );
  }

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  static const _primaryColor = Color(0xFFFF5600);

  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;
  bool _isSendingOtp = false;
  bool _isSubmitting = false;
  bool _otpSent = false;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadEmail() async {
    final user = await GetIt.I<AuthenticationLocalDataSource>().getUser();
    if (!mounted) return;
    setState(() => _email = user?.email?.trim());
  }

  Future<void> _sendOtp() async {
    if (_isSendingOtp) return;

    final email = _email;
    if (email == null || email.isEmpty) {
      _showSnackBar(
        context.tr(
          vi: 'Không tìm thấy email tài khoản để gửi OTP',
          en: 'Could not find your account email to send OTP',
        ),
        isError: true,
      );
      return;
    }

    setState(() => _isSendingOtp = true);
    final response = await GetIt.I<AuthService>().forgotPassword(email: email);

    if (!mounted) return;
    setState(() {
      _isSendingOtp = false;
      _otpSent = response.success;
    });

    _showSnackBar(
      response.success
          ? context.tr(
              vi: 'Mã OTP đã được gửi đến email của bạn',
              en: 'OTP has been sent to your email',
            )
          : response.message ??
                context.tr(vi: 'Không thể gửi OTP', en: 'Unable to send OTP'),
      isError: !response.success,
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final response = await GetIt.I<AuthService>().changePassword(
      otp: _otpController.text.trim(),
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!response.success) {
      _showSnackBar(
        response.message ??
            context.tr(
              vi: 'Không thể đổi mật khẩu',
              en: 'Unable to change password',
            ),
        isError: true,
      );
      return;
    }

    _showSnackBar(
      context.tr(
        vi: 'Đổi mật khẩu thành công',
        en: 'Password changed successfully',
      ),
    );
    Navigator.of(context).pop();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 12,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lock_reset_rounded, color: _primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.tr(vi: 'Đổi mật khẩu', en: 'Change password'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isSubmitting || _isSendingOtp
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _email == null || _email!.isEmpty
                      ? context.tr(
                          vi: 'OTP sẽ được gửi đến email tài khoản của bạn.',
                          en: 'OTP will be sent to your account email.',
                        )
                      : context.tr(
                          vi: 'OTP sẽ được gửi đến $_email',
                          en: 'OTP will be sent to $_email',
                        ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                _otpField(),
                const SizedBox(height: 14),
                _passwordField(
                  controller: _newPasswordController,
                  label: context.tr(vi: 'Mật khẩu mới', en: 'New password'),
                  obscureText: _hideNewPassword,
                  onToggleVisibility: () =>
                      setState(() => _hideNewPassword = !_hideNewPassword),
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return context.tr(
                        vi: 'Mật khẩu mới phải có ít nhất 8 ký tự',
                        en: 'New password must contain at least 8 characters',
                      );
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _passwordField(
                  controller: _confirmPasswordController,
                  label: context.tr(
                    vi: 'Nhập lại mật khẩu mới',
                    en: 'Confirm new password',
                  ),
                  obscureText: _hideConfirmPassword,
                  onToggleVisibility: () => setState(
                    () => _hideConfirmPassword = !_hideConfirmPassword,
                  ),
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return context.tr(
                        vi: 'Mật khẩu nhập lại không khớp',
                        en: 'Passwords do not match',
                      );
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting || _isSendingOtp
                            ? null
                            : _sendOtp,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primaryColor,
                          side: const BorderSide(color: _primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: _isSendingOtp
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                context.tr(
                                  vi: _otpSent ? 'Gửi lại OTP' : 'Gửi OTP',
                                  en: _otpSent ? 'Resend OTP' : 'Send OTP',
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isSubmitting || !_otpSent ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: _primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(context.tr(vi: 'Xác nhận', en: 'Confirm')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _otpField() {
    return TextFormField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      validator: (value) {
        if (value == null || value.trim().length != 6) {
          return context.tr(
            vi: 'Vui lòng nhập OTP gồm 6 chữ số',
            en: 'Please enter the 6-digit OTP',
          );
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: context.tr(vi: 'Mã OTP', en: 'OTP code'),
        prefixIcon: const Icon(Icons.password_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enableSuggestions: false,
      autocorrect: false,
      textInputAction: TextInputAction.next,
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return context.tr(
                vi: 'Vui lòng nhập mật khẩu',
                en: 'Please enter your password',
              );
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
