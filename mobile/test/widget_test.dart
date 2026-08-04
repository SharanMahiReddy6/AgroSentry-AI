// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/main.dart';

class MockAuthNotifier extends AuthNotifier {
  MockAuthNotifier(super.ref);
  @override
  Future<void> checkSession() async {
    state = const AuthState();
  }
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) => MockAuthNotifier(ref)),
      ],
      child: const AgroSentryApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsWidgets);
  });
}
