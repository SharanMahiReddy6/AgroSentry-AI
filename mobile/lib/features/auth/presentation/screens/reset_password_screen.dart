import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/widgets/app_button.dart';
import 'package:mobile/core/widgets/app_scaffold.dart';
import 'package:mobile/core/widgets/app_text_field.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/auth/presentation/widgets/auth_card.dart';
import 'package:mobile/features/auth/presentation/widgets/auth_header.dart';
import 'package:mobile/features/auth/presentation/widgets/password_requirements_view.dart';
import 'package:mobile/l10n/app_localizations.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String code;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get _isPasswordValid {
    final pwd = _passwordController.text;
    final hasMinLength = pwd.length >= 8;
    final hasUppercase = pwd.contains(RegExp(r'[A-Z]'));
    final hasNumber = pwd.contains(RegExp(r'[0-9]'));
    return hasMinLength && hasUppercase && hasNumber;
  }

  bool get _isFormValid {
    final pwd = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    return _isPasswordValid && confirm.isNotEmpty && pwd == confirm;
  }

  void _onTextChanged(String _) {
    setState(() {});
  }

  Future<void> _handleResetPassword() async {
    FocusScope.of(context).unfocus();

    if (!_isFormValid) return;

    try {
      await ref.read(authProvider.notifier).resetPassword(
            widget.email,
            widget.code,
            _passwordController.text,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)?.passwordResetSuccessfulPleaseSignIn ??
                      'Password reset successful. Please sign in.',
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      context.go('/login');
    } catch (e) {
      if (!mounted) return;

      String message = 'Failed to reset password';
      if (e is Failure) {
        message = e.message;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AppScaffold(
        title: '',
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: AuthCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthHeader(
                      icon: Icons.lock_outline_rounded,
                      title: AppLocalizations.of(context)?.setNewPassword ?? 'Set New Password',
                      subtitle: 'Create a secure new password for:',
                    ),
                    const SizedBox(height: 12),
                    // Email badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF263328) : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_outline, size: 16, color: primaryColor),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                widget.email.isNotEmpty ? widget.email : 'your account',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppTextField(
                      controller: _passwordController,
                      hintText: AppLocalizations.of(context)?.newPassword ?? 'New Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      onChanged: _onTextChanged,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    PasswordRequirementsView(
                      password: _passwordController.text,
                      confirmPassword: _confirmPasswordController.text.isNotEmpty
                          ? _confirmPasswordController.text
                          : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _confirmPasswordController,
                      hintText: AppLocalizations.of(context)?.confirmPassword ?? 'Confirm Password',
                      prefixIcon: Icons.lock_reset,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onChanged: _onTextChanged,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppButton(
                      text: AppLocalizations.of(context)?.resetPassword ?? 'Reset Password',
                      isLoading: authState.isLoading,
                      onPressed: _isFormValid && !authState.isLoading ? _handleResetPassword : null,
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            context.go('/login');
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            AppLocalizations.of(context)?.backToLogin ?? 'Back to Login',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
