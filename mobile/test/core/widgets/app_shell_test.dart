import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/widgets/app_shell.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';

class MockAuthNotifier extends AuthNotifier {
  MockAuthNotifier(super.ref) {
    state = const AuthState().copyWith(
      isAuthenticated: true,
      user: UserModel(
        id: 1,
        email: 'test@example.com',
        fullName: 'Test User',
        isAdmin: true,
      ),
    );
  }
  
  @override
  Future<void> checkSession() async {}
}

void main() {
  testWidgets('AppShell renders AppBar and BottomNavigationBar', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/dashboard',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return AppShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(routes: [GoRoute(path: '/dashboard', builder: (_, __) => const Text('DashboardTab'))]),
            StatefulShellBranch(routes: [GoRoute(path: '/scan', builder: (_, __) => const Text('ScanTab'))]),
            StatefulShellBranch(routes: [GoRoute(path: '/history', builder: (_, __) => const Text('HistoryTab'))]),
            StatefulShellBranch(routes: [GoRoute(path: '/library', builder: (_, __) => const Text('LibraryTab'))]),
            StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, __) => const Text('ProfileTab'))]),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier(ref)),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify AppBar
    expect(find.text('AgroSentry'), findsOneWidget);

    // Verify NavigationBar items
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Verify initial body
    expect(find.text('DashboardTab'), findsOneWidget);
  });
  
  testWidgets('AppShell tab switching updates the body', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/dashboard',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return AppShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(routes: [GoRoute(path: '/dashboard', builder: (_, __) => const Text('DashboardTab'))]),
            StatefulShellBranch(routes: [GoRoute(path: '/scan', builder: (_, __) => const Text('ScanTab'))]),
            StatefulShellBranch(routes: [GoRoute(path: '/history', builder: (_, __) => const Text('HistoryTab'))]),
            StatefulShellBranch(routes: [GoRoute(path: '/library', builder: (_, __) => const Text('LibraryTab'))]),
            StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, __) => const Text('ProfileTab'))]),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => MockAuthNotifier(ref)),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();
    
    // Tap on Scan
    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();
    expect(find.text('ScanTab'), findsOneWidget);
    
    // Tap on Profile
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('ProfileTab'), findsOneWidget);
  });
}
