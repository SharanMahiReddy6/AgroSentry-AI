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
import 'package:mobile/l10n/app_localizations.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  bool get _isFormValid {
    final email = _emailController.text.trim();
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  void _onTextChanged(String _) {
    setState(() {});
  }

  Future<void> _handleSendOtp() async {
    FocusScope.of(context).unfocus();

    try {
      final email = _emailController.text.trim();
      await ref.read(authProvider.notifier).forgotPassword(email);

      if (!mounted) return;
      context.go(
        '/verify-reset-code?email=${Uri.encodeComponent(email)}',
        extra: email,
      );
    } catch (e) {
      if (!mounted) return;

      String message = 'An unknown error occurred';
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
    _emailController.dispose();
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
                child: AutofillGroup(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthHeader(
                        icon: Icons.lock_reset_rounded,
                        title: AppLocalizations.of(context)?.resetPassword ?? 'Reset Password',
                        subtitle: AppLocalizations.of(context)?.enterYourEmailAddressAndWeWillSendYouAnO ??
                            'Enter your email address and we will send you an OTP to reset your password.',
                      ),
                      const SizedBox(height: 32),
                      AppTextField(
                        controller: _emailController,
                        hintText: AppLocalizations.of(context)?.email ?? 'Email',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.email],
                        onChanged: _onTextChanged,
                      ),
                      const SizedBox(height: 28),
                      AppButton(
                        text: AppLocalizations.of(context)?.sendOtp ?? 'Send OTP',
                        isLoading: authState.isLoading,
                        onPressed: _isFormValid && !authState.isLoading ? _handleSendOtp : null,
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "Remembered your password? ",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.grey[400] : const Color(0xFF616161),
                            ),
                          ),
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
                              AppLocalizations.of(context)?.login ?? 'Login',
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
      ),
    );
  }
}
