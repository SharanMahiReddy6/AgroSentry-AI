import 'package:flutter/material.dart';

class PasswordRequirementsView extends StatelessWidget {
  final String password;
  final String? confirmPassword;

  const PasswordRequirementsView({
    super.key,
    required this.password,
    this.confirmPassword,
  });

  bool get hasMinLength => password.length >= 8;
  bool get hasUppercase => password.contains(RegExp(r'[A-Z]'));
  bool get hasLowercase => password.contains(RegExp(r'[a-z]'));
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get hasSpecialChar => password.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?~`]'));
  bool get passwordsMatch =>
      confirmPassword != null &&
      confirmPassword!.isNotEmpty &&
      password == confirmPassword;

  int get metCount {
    int count = 0;
    if (hasMinLength) count++;
    if (hasUppercase) count++;
    if (hasLowercase) count++;
    if (hasNumber) count++;
    if (hasSpecialChar) count++;
    return count;
  }

  double get strengthFraction => metCount / 5.0;

  String get strengthLabel {
    if (password.isEmpty) return 'Enter a password';
    if (metCount <= 2) return 'Weak';
    if (metCount == 3) return 'Fair';
    if (metCount == 4) return 'Good';
    return 'Strong';
  }

  Color get strengthColor {
    if (password.isEmpty) return Colors.grey;
    if (metCount <= 2) return const Color(0xFFE53935);
    if (metCount == 3) return const Color(0xFFFB8C00);
    if (metCount == 4) return const Color(0xFF7CB342);
    return const Color(0xFF2E7D32);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bar header
        if (password.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Password Strength',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[300] : const Color(0xFF424242),
                ),
              ),
              Text(
                strengthLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: strengthColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Segmented progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: strengthFraction,
              minHeight: 6,
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Requirements list
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B241D) : const Color(0xFFF4F8F4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE0EBE0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRequirementRow(
                context,
                isMet: hasMinLength,
                text: 'At least 8 characters',
              ),
              const SizedBox(height: 4),
              _buildRequirementRow(
                context,
                isMet: hasUppercase,
                text: 'At least 1 uppercase letter (A-Z)',
              ),
              const SizedBox(height: 4),
              _buildRequirementRow(
                context,
                isMet: hasLowercase,
                text: 'At least 1 lowercase letter (a-z)',
              ),
              const SizedBox(height: 4),
              _buildRequirementRow(
                context,
                isMet: hasNumber,
                text: 'At least 1 number (0-9)',
              ),
              const SizedBox(height: 4),
              _buildRequirementRow(
                context,
                isMet: hasSpecialChar,
                text: 'At least 1 special character (!@#\$%...)',
              ),
              if (confirmPassword != null) ...[
                const SizedBox(height: 4),
                _buildRequirementRow(
                  context,
                  isMet: passwordsMatch,
                  text: 'Passwords match',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementRow(BuildContext context, {required bool isMet, required String text}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
    final inactiveColor = isDark ? Colors.grey[600]! : Colors.grey[500]!;

    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 16,
          color: isMet ? activeColor : inactiveColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isMet
                  ? (isDark ? Colors.grey[200] : const Color(0xFF1B2E1D))
                  : inactiveColor,
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
