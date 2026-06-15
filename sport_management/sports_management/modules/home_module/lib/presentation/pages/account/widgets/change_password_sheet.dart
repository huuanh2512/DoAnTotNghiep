import 'package:flutter/material.dart';
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
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final response = await GetIt.I<AuthService>().changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message ??
                context.tr(
                  vi: 'Không thể đổi mật khẩu',
                  en: 'Unable to change password',
                ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr(
            vi: 'Đổi mật khẩu thành công',
            en: 'Password changed successfully',
          ),
        ),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
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
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _passwordField(
                  controller: _currentPasswordController,
                  label: context.tr(
                    vi: 'Mật khẩu hiện tại',
                    en: 'Current password',
                  ),
                  obscureText: _hideCurrentPassword,
                  onToggleVisibility: () => setState(
                    () => _hideCurrentPassword = !_hideCurrentPassword,
                  ),
                ),
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
                    if (value == _currentPasswordController.text) {
                      return context.tr(
                        vi: 'Mật khẩu mới phải khác mật khẩu hiện tại',
                        en: 'New password must differ from current password',
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
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
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
                        : Text(
                            context.tr(
                              vi: 'Xác nhận đổi mật khẩu',
                              en: 'Change password',
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
