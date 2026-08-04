import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/widgets/app_button.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/auth/presentation/screens/verify_otp_screen.dart';

class MockAuthNotifier extends AuthNotifier {
  MockAuthNotifier(super.ref);
  @override
  Future<void> checkSession() async {
    state = const AuthState();
  }
}

void main() {
  testWidgets('VerifyOtpScreen initial state has disabled button', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier(ref)),
        ],
        child: const MaterialApp(
          home: VerifyOtpScreen(email: 'test@example.com'),
        ),
      ),
    );

    expect(find.text('Enter Verification Code'), findsOneWidget);
    expect(find.textContaining('test@example.com'), findsOneWidget);
    
    // Find button
    final buttonFinder = find.byType(AppButton);
    expect(buttonFinder, findsOneWidget);
    
    final appButton = tester.widget<AppButton>(buttonFinder);
    expect(appButton.onPressed, isNull); // Disabled
  });

  testWidgets('VerifyOtpScreen enables button on valid 6-digit input', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier(ref)),
        ],
        child: const MaterialApp(
          home: VerifyOtpScreen(email: 'test@example.com'),
        ),
      ),
    );

    final textFields = find.byType(TextField);

    // Enter 5 digits
    await tester.enterText(textFields.first, '12345');
    await tester.pumpAndSettle();
    
    var appButton = tester.widget<AppButton>(find.byType(AppButton));
    expect(appButton.onPressed, isNull);

    // Enter 6 digits
    await tester.enterText(textFields.first, '123456');
    await tester.pumpAndSettle();

    // Button should be enabled
    appButton = tester.widget<AppButton>(find.byType(AppButton));
    expect(appButton.onPressed, isNotNull);
  });
}
