import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/widgets/app_button.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/auth/presentation/screens/register_screen.dart';

class MockAuthNotifier extends AuthNotifier {
  MockAuthNotifier(super.ref);
  @override
  Future<void> checkSession() async {
    state = const AuthState();
  }
}

void main() {
  testWidgets('RegisterScreen initial state has disabled button', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier(ref)),
        ],
        child: const MaterialApp(
          home: RegisterScreen(),
        ),
      ),
    );

    expect(find.text('Join AgroSentry'), findsOneWidget);
    
    // Find button
    final buttonFinder = find.byType(AppButton);
    expect(buttonFinder, findsOneWidget);
    
    final appButton = tester.widget<AppButton>(buttonFinder);
    expect(appButton.onPressed, isNull); // Disabled
  });

  testWidgets('RegisterScreen enables button on valid input', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier(ref)),
        ],
        child: const MaterialApp(
          home: RegisterScreen(),
        ),
      ),
    );

    final textFields = find.byType(TextField);

    // Full Name
    await tester.enterText(textFields.at(0), 'John Doe');
    
    // Email
    await tester.enterText(textFields.at(1), 'john@example.com');
    
    // Password (valid)
    await tester.enterText(textFields.at(2), 'Password123');
    
    // Confirm Password
    await tester.enterText(textFields.at(3), 'Password123');
    
    // State
    await tester.enterText(textFields.at(4), 'California');
    
    // City
    await tester.enterText(textFields.at(5), 'Los Angeles');
    
    // Crop
    await tester.enterText(textFields.at(6), 'Apple');
    
    await tester.pumpAndSettle();

    // Button should be enabled
    final appButton = tester.widget<AppButton>(find.byType(AppButton));
    expect(appButton.onPressed, isNotNull);
  });
}
