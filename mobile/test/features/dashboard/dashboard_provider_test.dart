import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:mobile/features/dashboard/data/models/dashboard_models.dart';
import 'package:mobile/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:mobile/features/dashboard/data/repositories/dashboard_repository_impl.dart';

class MockDashboardRepository implements DashboardRepository {
  List<ScanRecordModel> scansToReturn = [];
  List<TipModel> tipsToReturn = [];
  Exception? exceptionToThrow;

  @override
  Future<List<ScanRecordModel>> getRecentScans() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return scansToReturn;
  }

  @override
  Future<List<TipModel>> getQuickTips() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return tipsToReturn;
  }
}

void main() {
  late MockDashboardRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockDashboardRepository();
    container = ProviderContainer(
      overrides: [
        dashboardRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  final dummyScans = [
    const ScanRecordModel(
      id: 1,
      imageUrl: '/url1',
      heatmapUrl: '/heat1',
      cropType: 'Tomato',
      prediction: 'Healthy',
      confidence: 0.95,
      severity: 'Low',
      createdAt: '2023-10-01T10:00:00Z',
    ),
    const ScanRecordModel(
      id: 2,
      imageUrl: '/url2',
      heatmapUrl: '/heat2',
      cropType: 'Potato',
      prediction: 'Early Blight',
      confidence: 0.85,
      severity: 'Medium',
      createdAt: '2023-10-02T10:00:00Z',
    ),
  ];

  final dummyTips = [
    const TipModel(
      id: 1,
      title: 'Watering Tip',
      category: 'General',
      readTime: '2 min read',
      content: 'Water plants early morning.',
      author: 'Admin',
      isApproved: true,
    ),
  ];

  test('DashboardNotifier computes statistics correctly on successful load', () async {
    mockRepository.scansToReturn = dummyScans;
    mockRepository.tipsToReturn = dummyTips;

    container.read(dashboardProvider.notifier); // init
    await Future.delayed(const Duration(milliseconds: 100));

    final state = container.read(dashboardProvider);
    
    expect(state.isLoading, false);
    expect(state.error, null);
    expect(state.recentScans, dummyScans);
    expect(state.quickTips, dummyTips);
    
    expect(state.totalScans, 2);
    expect(state.healthyPlants, 1);
    expect(state.diseasedPlants, 1);
    expect(state.accuracy, closeTo(0.9, 0.001));
  });

  test('DashboardNotifier handles error state correctly', () async {
    mockRepository.exceptionToThrow = Exception('Failed to load');

    container.read(dashboardProvider.notifier);
    await Future.delayed(const Duration(milliseconds: 100));

    final state = container.read(dashboardProvider);
    
    expect(state.isLoading, false);
    expect(state.error, isNotNull);
    expect(state.error!.contains('Failed to load'), true);
  });
}
