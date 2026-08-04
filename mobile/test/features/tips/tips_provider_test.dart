import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/tips/data/datasources/tips_remote_datasource.dart';
import 'package:mobile/features/tips/data/models/quick_tip_model.dart';
import 'package:mobile/features/tips/presentation/providers/tips_provider.dart';

class MockTipsRemoteDataSource implements TipsRemoteDataSource {
  int callCount = 0;
  bool shouldThrow = false;
  CancelToken? lastCancelToken;

  final List<QuickTipModel> mockTips = const [
    QuickTipModel(
      id: 1,
      title: 'Watering Tomato',
      category: 'Tomato',
      crop: 'Tomato',
      description: 'Water early.',
      detailedContent: 'Water in morning to prevent blight.',
      author: 'John',
      readTime: '2 min read',
      tags: ['water', 'morning'],
    ),
    QuickTipModel(
      id: 2,
      title: 'Spacing Plants',
      category: 'General',
      crop: null,
      description: 'Keep 24 inches spacing.',
      author: 'Jane',
      readTime: '1 min read',
    ),
    QuickTipModel(
      id: 3,
      title: 'Blight spray',
      category: 'Potato',
      crop: 'Potato',
      description: 'Use baking soda.',
      author: 'Doe',
      readTime: '3 min read',
    ),
  ];

  @override
  Future<List<QuickTipModel>> getTips({CancelToken? cancelToken}) async {
    callCount++;
    lastCancelToken = cancelToken;
    if (shouldThrow) {
      throw Exception('Failed');
    }
    return mockTips;
  }

  @override
  Future<Map<String, dynamic>> submitTip(Map<String, dynamic> tipData, {CancelToken? cancelToken}) async {
    return {'is_approved': true};
  }
}

void main() {
  late ProviderContainer container;
  late MockTipsRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockTipsRemoteDataSource();
    container = ProviderContainer(
      overrides: [
        tipsRemoteDataSourceProvider.overrideWithValue(mockDataSource),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('quickTipsProvider loads data correctly', () async {
    final tips = await container.read(quickTipsProvider.future);
    expect(tips.length, 3);
    expect(mockDataSource.callCount, 1);
  });

  test('quickTipsProvider caches data', () async {
    await container.read(quickTipsProvider.future);
    expect(mockDataSource.callCount, 1);
    
    // Read again
    await container.read(quickTipsProvider.future);
    expect(mockDataSource.callCount, 1); // Should remain 1
  });

  test('filteredTipsProvider filters by search query', () async {
    await container.read(quickTipsProvider.future);
    
    container.read(tipsSearchQueryProvider.notifier).state = 'water';
    
    final filtered = container.read(filteredTipsProvider);
    expect(filtered.value?.length, 1);
    expect(filtered.value?.first.title, 'Watering Tomato');
  });

  test('filteredTipsProvider filters by category', () async {
    await container.read(quickTipsProvider.future);
    
    container.read(tipsCategoryFilterProvider.notifier).state = 'Potato';
    
    final filtered = container.read(filteredTipsProvider);
    expect(filtered.value?.length, 1);
    expect(filtered.value?.first.title, 'Blight spray');
  });

  test('tipsAvailableCategoriesProvider extracts unique sorted categories', () async {
    await container.read(quickTipsProvider.future);
    
    final categories = container.read(tipsAvailableCategoriesProvider);
    expect(categories.value, ['General', 'Potato', 'Tomato']);
  });

  test('Provider disposal cancels the request token', () async {
    final sub = container.listen(quickTipsProvider, (_, __) {});
    
    expect(mockDataSource.lastCancelToken, isNotNull);
    final cancelToken = mockDataSource.lastCancelToken!;
    expect(cancelToken.isCancelled, false);
    
    sub.close();
    container.dispose();
    
    expect(cancelToken.isCancelled, true);
  });
}
