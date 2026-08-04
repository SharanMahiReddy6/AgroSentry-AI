import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/widgets/app_button.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/auth/presentation/screens/forgot_password_screen.dart';

class MockAuthNotifier extends AuthNotifier {
  MockAuthNotifier(super.ref);
  @override
  Future<void> checkSession() async {
    state = const AuthState();
  }
}

void main() {
  testWidgets('ForgotPasswordScreen initial state has disabled button', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier(ref)),
        ],
        child: const MaterialApp(
          home: ForgotPasswordScreen(),
        ),
      ),
    );

    expect(find.text('Reset Password'), findsOneWidget);
    
    // Find button
    final buttonFinder = find.byType(AppButton);
    expect(buttonFinder, findsOneWidget);
    
    final appButton = tester.widget<AppButton>(buttonFinder);
    expect(appButton.onPressed, isNull); // Disabled
  });

  testWidgets('ForgotPasswordScreen enables button on valid input', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier(ref)),
        ],
        child: const MaterialApp(
          home: ForgotPasswordScreen(),
        ),
      ),
    );

    final textFields = find.byType(TextField);

    // Email
    await tester.enterText(textFields.first, 'john@example.com');
    await tester.pumpAndSettle();

    // Button should be enabled
    final appButton = tester.widget<AppButton>(find.byType(AppButton));
    expect(appButton.onPressed, isNotNull);
  });
}
