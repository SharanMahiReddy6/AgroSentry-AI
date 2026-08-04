import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/widgets/app_button.dart';
import 'package:mobile/core/widgets/app_scaffold.dart';
import 'package:mobile/core/widgets/app_text_field.dart';
import 'package:mobile/features/auth/data/models/auth_requests.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/auth/presentation/widgets/auth_card.dart';
import 'package:mobile/features/auth/presentation/widgets/auth_header.dart';
import 'package:mobile/features/auth/presentation/widgets/password_requirements_view.dart';
import 'package:mobile/l10n/app_localizations.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // NOTE: State, City, and Primary Crop are captured here for UX completeness
  // and will later be synced with the Profile endpoints.
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _cropController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get _isFormValid {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final stateRegion = _stateController.text.trim();
    final city = _cityController.text.trim();
    final crop = _cropController.text.trim();

    final isEmailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final passwordsMatch = password.isNotEmpty && password == confirmPassword;

    return fullName.isNotEmpty &&
        isEmailValid &&
        hasMinLength &&
        hasUppercase &&
        hasNumber &&
        passwordsMatch &&
        stateRegion.isNotEmpty &&
        city.isNotEmpty &&
        crop.isNotEmpty;
  }

  void _onTextChanged(String _) {
    setState(() {});
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    try {
      final request = RegisterRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );

      await ref.read(authProvider.notifier).register(request);

      final authState = ref.read(authProvider);
      if (!authState.isAuthenticated && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)?.registrationSuccessfulPleaseSignIn ??
                        'Registration successful. Please sign in.',
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
      }
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
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _cropController.dispose();
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
                        icon: Icons.person_add_alt_1_rounded,
                        title: AppLocalizations.of(context)?.joinAgrosentry ?? 'Join AgroSentry',
                        subtitle: AppLocalizations.of(context)?.createYourFreeAccount ?? 'Create your free account',
                      ),
                      const SizedBox(height: 28),

                      // Section: Personal Details
                      _buildSectionHeader('Personal Details', isDark),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _fullNameController,
                        hintText: AppLocalizations.of(context)?.fullName ?? 'Full Name',
                        prefixIcon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        onChanged: _onTextChanged,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _emailController,
                        hintText: AppLocalizations.of(context)?.email ?? 'Email',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        onChanged: _onTextChanged,
                      ),

                      const SizedBox(height: 22),
                      // Section: Security
                      _buildSectionHeader('Security', isDark),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _passwordController,
                        hintText: AppLocalizations.of(context)?.password ?? 'Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
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
                      const SizedBox(height: 10),
                      PasswordRequirementsView(
                        password: _passwordController.text,
                        confirmPassword: _confirmPasswordController.text.isNotEmpty
                            ? _confirmPasswordController.text
                            : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _confirmPasswordController,
                        hintText: AppLocalizations.of(context)?.confirmPassword ?? 'Confirm Password',
                        prefixIcon: Icons.lock_reset_rounded,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.next,
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

                      const SizedBox(height: 22),
                      // Section: Farm Profile
                      _buildSectionHeader('Farming Profile', isDark),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _stateController,
                        hintText: AppLocalizations.of(context)?.stateRegion ?? 'State / Region',
                        prefixIcon: Icons.map_outlined,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.addressState],
                        onChanged: _onTextChanged,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _cityController,
                        hintText: AppLocalizations.of(context)?.city ?? 'City',
                        prefixIcon: Icons.location_city_outlined,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.addressCity],
                        onChanged: _onTextChanged,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _cropController,
                        hintText: AppLocalizations.of(context)?.primaryCropEgAppleRice ?? 'Primary Crop (e.g. Apple, Rice)',
                        prefixIcon: Icons.grass_rounded,
                        textInputAction: TextInputAction.done,
                        onChanged: _onTextChanged,
                      ),

                      const SizedBox(height: 32),
                      AppButton(
                        text: AppLocalizations.of(context)?.register ?? 'Create Account',
                        isLoading: authState.isLoading,
                        onPressed: _isFormValid && !authState.isLoading ? _handleRegister : null,
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.grey[400] : const Color(0xFF616161),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/login');
                              }
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

  Widget _buildSectionHeader(String title, bool isDark) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE0E0E0),
          ),
        ),
      ],
    );
  }
}
