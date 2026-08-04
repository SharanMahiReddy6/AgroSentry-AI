import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/widgets/app_button.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/auth/presentation/screens/login_screen.dart';

class MockAuthNotifier extends AuthNotifier {
  MockAuthNotifier(super.ref);
  @override
  Future<void> checkSession() async {
    state = const AuthState();
  }
  @override
  Future<void> login(String email, String password) async {}
}

void main() {
  testWidgets('LoginScreen initial state has disabled button', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier(ref)),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('Welcome to AgroSentry'), findsOneWidget);
    
    // Find button
    final buttonFinder = find.byType(AppButton);
    expect(buttonFinder, findsOneWidget);
    
    final appButton = tester.widget<AppButton>(buttonFinder);
    expect(appButton.onPressed, isNull); // Disabled
  });

  testWidgets('LoginScreen enables button on valid input', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier(ref)),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Enter email
    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.pump();
    
    // Enter password
    await tester.enterText(find.byType(TextField).last, 'password123');
    await tester.pump();

    // Button should be enabled
    final appButton = tester.widget<AppButton>(find.byType(AppButton));
    expect(appButton.onPressed, isNotNull);
  });
}
