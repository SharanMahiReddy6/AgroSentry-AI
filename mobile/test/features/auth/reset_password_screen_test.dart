import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/widgets/app_button.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/auth/presentation/screens/reset_password_screen.dart';

class MockAuthNotifier extends AuthNotifier {
  MockAuthNotifier(super.ref);
  @override
  Future<void> checkSession() async {
    state = const AuthState();
  }
}

void main() {
  testWidgets('ResetPasswordScreen initial state has disabled button', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier(ref)),
        ],
        child: const MaterialApp(
          home: ResetPasswordScreen(email: 'test@example.com', code: '123456'),
        ),
      ),
    );

    expect(find.text('Set New Password'), findsOneWidget);
    expect(find.textContaining('test@example.com'), findsOneWidget);
    
    final appButton = tester.widget<AppButton>(find.byType(AppButton));
    expect(appButton.onPressed, isNull);
  });

  testWidgets('ResetPasswordScreen enables button on valid input', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier(ref)),
        ],
        child: const MaterialApp(
          home: ResetPasswordScreen(email: 'test@example.com', code: '123456'),
        ),
      ),
    );

    final textFields = find.byType(TextField);

    // Password
    await tester.enterText(textFields.first, 'Password123');
    // Confirm Password
    await tester.enterText(textFields.last, 'Password123');
    await tester.pumpAndSettle();

    final appButton = tester.widget<AppButton>(find.byType(AppButton));
    expect(appButton.onPressed, isNotNull);
  });

  testWidgets('ResetPasswordScreen keeps button disabled on mismatch', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier(ref)),
        ],
        child: const MaterialApp(
          home: ResetPasswordScreen(email: 'test@example.com', code: '123456'),
        ),
      ),
    );

    final textFields = find.byType(TextField);

    // Password
    await tester.enterText(textFields.first, 'Password123');
    // Confirm Password
    await tester.enterText(textFields.last, 'Password124');
    await tester.pumpAndSettle();

    final appButton = tester.widget<AppButton>(find.byType(AppButton));
    expect(appButton.onPressed, isNull);
  });
}
