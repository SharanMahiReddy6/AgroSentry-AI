import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/widgets/app_button.dart';
import 'package:mobile/core/widgets/app_scaffold.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/auth/presentation/widgets/auth_card.dart';
import 'package:mobile/features/auth/presentation/widgets/auth_countdown_timer.dart';
import 'package:mobile/features/auth/presentation/widgets/auth_header.dart';
import 'package:mobile/features/auth/presentation/widgets/otp_box_input.dart';
import 'package:mobile/l10n/app_localizations.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final _otpController = TextEditingController();
  bool _hasError = false;

  bool get _isFormValid {
    final code = _otpController.text.trim();
    return code.length == 6 && RegExp(r'^[0-9]+$').hasMatch(code);
  }

  void _onOtpChanged(String code) {
    setState(() {
      _hasError = false;
    });
  }

  Future<void> _handleVerify([String? directCode]) async {
    FocusScope.of(context).unfocus();

    final code = (directCode ?? _otpController.text).trim();
    if (code.length != 6) return;

    try {
      await ref.read(authProvider.notifier).verifyOtp(widget.email, code);

      if (!mounted) return;
      context.go(
        '/reset-password?email=${Uri.encodeComponent(widget.email)}&code=${Uri.encodeComponent(code)}',
        extra: {'email': widget.email, 'code': code},
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
      });

      String message = 'Invalid or expired OTP code';
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

  Future<void> _handleResend() async {
    try {
      await ref.read(authProvider.notifier).forgotPassword(widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(child: Text('A new OTP has been sent to your email.')),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      String message = 'Failed to resend OTP';
      if (e is Failure) message = e.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      rethrow;
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
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
                      icon: Icons.mark_email_read_rounded,
                      title: AppLocalizations.of(context)?.enterVerificationCode ?? 'Enter Verification Code',
                      subtitle: 'We sent a 6-digit verification code to:',
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
                            Icon(Icons.email, size: 16, color: primaryColor),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                widget.email.isNotEmpty ? widget.email : 'your email',
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
                    const SizedBox(height: 20),
                    OtpBoxInput(
                      controller: _otpController,
                      length: 6,
                      hasError: _hasError,
                      enabled: !authState.isLoading,
                      onChanged: _onOtpChanged,
                    ),
                    const SizedBox(height: 16),
                    AuthCountdownTimer(
                      initialSeconds: 60,
                      onResend: _handleResend,
                      isLoading: authState.isLoading,
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      text: AppLocalizations.of(context)?.verify ?? 'Verify',
                      isLoading: authState.isLoading,
                      onPressed: _isFormValid && !authState.isLoading ? () => _handleVerify() : null,
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
