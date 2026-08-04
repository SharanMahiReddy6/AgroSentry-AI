import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/library/data/datasources/library_remote_datasource.dart';
import 'package:mobile/features/library/data/models/library_disease_model.dart';

import 'package:mobile/features/library/presentation/providers/library_provider.dart';

class MockLibraryRemoteDataSource implements LibraryRemoteDataSource {
  int callCount = 0;
  bool shouldThrow = false;
  CancelToken? lastCancelToken;

  final List<LibraryDiseaseModel> mockDiseases = const [
    LibraryDiseaseModel(
      id: 'Apple_Scab',
      name: 'Apple Scab',
      scientificName: 'Venturia inaequalis',
      cropType: 'Apple',
      description: 'Apple scab description.',
      causes: ['Fungus'],
      symptoms: [],
      treatments: {},
    ),
    LibraryDiseaseModel(
      id: 'Apple_Healthy',
      name: 'Apple Healthy',
      scientificName: '',
      cropType: 'Apple',
      description: 'Healthy apple.',
      causes: [],
      symptoms: [],
      treatments: {},
    ),
    LibraryDiseaseModel(
      id: 'Corn_Rust',
      name: 'Common Rust',
      scientificName: 'Puccinia sorghi',
      cropType: 'Corn',
      description: 'Corn rust description.',
      causes: ['Fungus'],
      symptoms: [],
      treatments: {},
    ),
  ];

  @override
  Future<List<LibraryDiseaseModel>> getDiseases({CancelToken? cancelToken}) async {
    callCount++;
    lastCancelToken = cancelToken;
    if (shouldThrow) {
      throw Exception('Failed');
    }
    return mockDiseases;
  }
}

void main() {
  late ProviderContainer container;
  late MockLibraryRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockLibraryRemoteDataSource();
    container = ProviderContainer(
      overrides: [
        libraryRemoteDataSourceProvider.overrideWithValue(mockDataSource),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('libraryDiseasesProvider loads data correctly', () async {
    final diseases = await container.read(libraryDiseasesProvider.future);
    expect(diseases.length, 3);
    expect(mockDataSource.callCount, 1);
  });

  test('libraryDiseasesProvider caches data', () async {
    // Read once
    await container.read(libraryDiseasesProvider.future);
    expect(mockDataSource.callCount, 1);
    
    // Read again, should not increment callCount because of keepAlive
    await container.read(libraryDiseasesProvider.future);
    expect(mockDataSource.callCount, 1);
  });

  test('filteredLibraryDiseasesProvider filters by search query', () async {
    // Await initial load
    await container.read(libraryDiseasesProvider.future);
    
    container.read(librarySearchQueryProvider.notifier).state = 'rust';
    
    final filtered = container.read(filteredLibraryDiseasesProvider);
    expect(filtered.value?.length, 1);
    expect(filtered.value?.first.name, 'Common Rust');
  });

  test('filteredLibraryDiseasesProvider filters by crop', () async {
    await container.read(libraryDiseasesProvider.future);
    
    container.read(libraryCropFilterProvider.notifier).state = 'Apple';
    
    final filtered = container.read(filteredLibraryDiseasesProvider);
    expect(filtered.value?.length, 2);
    
    container.read(libraryCropFilterProvider.notifier).state = 'Corn';
    final filteredCorn = container.read(filteredLibraryDiseasesProvider);
    expect(filteredCorn.value?.length, 1);
  });

  test('filteredLibraryDiseasesProvider filters by health status', () async {
    await container.read(libraryDiseasesProvider.future);
    
    container.read(libraryHealthFilterProvider.notifier).state = 'Healthy';
    
    final filteredHealthy = container.read(filteredLibraryDiseasesProvider);
    expect(filteredHealthy.value?.length, 1);
    expect(filteredHealthy.value?.first.name, 'Apple Healthy');
    
    container.read(libraryHealthFilterProvider.notifier).state = 'Diseased';
    
    final filteredDiseased = container.read(filteredLibraryDiseasesProvider);
    expect(filteredDiseased.value?.length, 2);
  });

  test('libraryAvailableCropsProvider extracts unique sorted crops', () async {
    await container.read(libraryDiseasesProvider.future);
    
    final crops = container.read(libraryAvailableCropsProvider);
    expect(crops.value, ['Apple', 'Corn']);
  });

  test('Provider disposal cancels the request token', () async {
    // Trigger the provider creation
    final sub = container.listen(libraryDiseasesProvider, (_, __) {});
    
    // The request has been made
    expect(mockDataSource.lastCancelToken, isNotNull);
    final cancelToken = mockDataSource.lastCancelToken!;
    
    // Not cancelled yet
    expect(cancelToken.isCancelled, false);
    
    // Dispose the provider manually
    sub.close();
    container.dispose();
    
    // The token should be cancelled
    expect(cancelToken.isCancelled, true);
  });
}
