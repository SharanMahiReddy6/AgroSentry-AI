import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:mobile/features/dashboard/data/models/dashboard_models.dart';
import 'package:mobile/features/dashboard/presentation/widgets/dashboard_stats_card.dart';
import 'package:mobile/features/dashboard/presentation/widgets/quick_action_card.dart';
import 'package:mobile/features/dashboard/presentation/widgets/recent_scan_card.dart';
import 'package:mobile/features/dashboard/presentation/widgets/quick_tip_card.dart';
import 'package:mobile/features/dashboard/presentation/widgets/dashboard_skeleton.dart';
import 'package:mobile/features/dashboard/presentation/widgets/dashboard_empty_state.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';
import 'package:mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:mobile/features/dashboard/data/repositories/dashboard_repository_impl.dart';

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<List<ScanRecordModel>> getRecentScans() async {
    return [
      const ScanRecordModel(
        id: 1,
        imageUrl: '',
        heatmapUrl: '',
        cropType: 'Tomato',
        prediction: 'Healthy',
        confidence: 0.9,
        severity: 'Low',
        createdAt: '2023-10-01T10:00:00Z',
      )
    ];
  }

  @override
  Future<List<TipModel>> getQuickTips() async {
    return [
      const TipModel(
        id: 1,
        title: 'Tip',
        category: 'Gen',
        readTime: '1',
        content: 'Content',
        author: 'Me',
        isApproved: true,
      )
    ];
  }
}

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
}

void main() {
  testWidgets('DashboardScreen renders placeholders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(MockDashboardRepository()),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify greetings
    expect(find.textContaining('Hello,'), findsOneWidget);

    // Verify stat cards
    expect(find.text('Overview'), findsOneWidget);
    expect(find.byType(DashboardStatsCard), findsNWidgets(4));

    // Verify quick actions
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.byType(QuickActionCard), findsNWidgets(4));

    // Verify quick tips
    expect(find.text('Quick Tips'), findsOneWidget);
    expect(find.byType(QuickTipCard), findsNWidgets(1));

    // Scroll down to see recent scans
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    // Verify recent scans
    expect(find.text('Recent Scans'), findsOneWidget);
    expect(find.byType(RecentScanCard), findsNWidgets(1));
  });
  
  testWidgets('DashboardSkeleton renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DashboardSkeleton()),
      ),
    );
    expect(find.byType(DashboardSkeleton), findsOneWidget);
  });
  
  testWidgets('DashboardEmptyState renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DashboardEmptyState()),
      ),
    );
    expect(find.text('Welcome to AgroSentry!'), findsOneWidget);
  });
}
