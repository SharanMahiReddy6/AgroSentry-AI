import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/router/app_router.dart';
import 'package:mobile/core/widgets/app_button.dart';
import 'package:mobile/core/widgets/app_text_field.dart';
import 'package:mobile/features/auth/data/models/auth_requests.dart';
import 'package:mobile/features/auth/data/models/auth_responses.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:mobile/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:mobile/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';

class MockAuthRepository implements AuthRepository {
  String? lastForgotPasswordEmail;
  String? lastVerifiedEmail;
  String? lastVerifiedCode;
  String? lastResetEmail;
  String? lastResetCode;
  String? lastResetPassword;

  @override
  Future<bool> isLoggedIn() async => false;

  @override
  Future<UserModel> getCurrentUser() async => UserModel(id: 1, email: 'test@example.com', isAdmin: false);

  @override
  Future<void> login(String email, String password) async {}

  @override
  Future<void> register(RegisterRequest request) async {}

  @override
  Future<GenericAuthResponse> forgotPassword(ForgotPasswordRequest request) async {
    lastForgotPasswordEmail = request.email;
    return GenericAuthResponse(success: true, message: 'Reset code sent');
  }

  @override
  Future<GenericAuthResponse> verifyOtp(VerifyOtpRequest request) async {
    lastVerifiedEmail = request.email;
    lastVerifiedCode = request.code;
    return GenericAuthResponse(success: true, message: 'Code verified');
  }

  @override
  Future<GenericAuthResponse> resetPassword(ResetPasswordRequest request) async {
    lastResetEmail = request.email;
    lastResetCode = request.code;
    lastResetPassword = request.newPassword;
    return GenericAuthResponse(success: true, message: 'Password reset successful');
  }

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('E2E Forgot Password -> OTP Verification -> Reset Password navigation flow', (WidgetTester tester) async {
    final mockRepo = MockAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final router = ref.watch(appRouterProvider);
            return MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Initially on Login Screen
    expect(find.byType(LoginScreen), findsOneWidget);

    // 2. Click "Forgot Password?"
    final forgotPasswordButton = find.text('Forgot Password?');
    expect(forgotPasswordButton, findsOneWidget);
    await tester.tap(forgotPasswordButton);
    await tester.pumpAndSettle();

    // 3. Verify we are on ForgotPasswordScreen
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);

    // 4. Enter registered email and tap "Send OTP"
    final emailField = find.byType(AppTextField);
    expect(emailField, findsOneWidget);
    await tester.enterText(emailField, 'farmer@example.com');
    await tester.pumpAndSettle();

    final sendOtpButton = find.widgetWithText(AppButton, 'Send OTP');
    expect(sendOtpButton, findsOneWidget);
    await tester.tap(sendOtpButton);
    await tester.pumpAndSettle();

    // Verify repository received the correct email
    expect(mockRepo.lastForgotPasswordEmail, 'farmer@example.com');

    // 5. Must have navigated to VerifyOtpScreen (and NOT redirected to LoginScreen)
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(VerifyOtpScreen), findsOneWidget);
    expect(find.textContaining('farmer@example.com'), findsOneWidget);

    // 6. Enter 6-digit OTP code on VerifyOtpScreen
    final otpFields = find.byType(TextField);
    expect(otpFields, findsWidgets);
    await tester.enterText(otpFields.first, '123456');
    await tester.pumpAndSettle();

    final verifyButton = find.widgetWithText(AppButton, 'Verify');
    expect(verifyButton, findsOneWidget);
    await tester.ensureVisible(verifyButton);
    await tester.tap(verifyButton);
    await tester.pumpAndSettle();

    // Verify repository received the verification call
    expect(mockRepo.lastVerifiedEmail, 'farmer@example.com');
    expect(mockRepo.lastVerifiedCode, '123456');

    // 7. Must have navigated to ResetPasswordScreen
    expect(find.byType(ResetPasswordScreen), findsOneWidget);

    // 8. Enter new password & confirm password
    final newPasswordFields = find.byType(AppTextField);
    expect(newPasswordFields, findsNWidgets(2));
    await tester.enterText(newPasswordFields.at(0), 'NewPass123!');
    await tester.enterText(newPasswordFields.at(1), 'NewPass123!');
    await tester.pumpAndSettle();

    final resetSubmitButton = find.widgetWithText(AppButton, 'Reset Password');
    expect(resetSubmitButton, findsOneWidget);
    await tester.ensureVisible(resetSubmitButton);
    await tester.tap(resetSubmitButton);
    await tester.pumpAndSettle();

    // Verify repository received reset password request
    expect(mockRepo.lastResetEmail, 'farmer@example.com');
    expect(mockRepo.lastResetCode, '123456');
    expect(mockRepo.lastResetPassword, 'NewPass123!');

    // 9. Must have redirected back to LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
