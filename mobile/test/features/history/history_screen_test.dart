import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/history/presentation/screens/history_screen.dart';
import 'package:mobile/features/scan/data/models/scan_history_model.dart';
import 'package:mobile/features/scan/domain/repositories/scan_repository.dart';
import 'package:mobile/features/scan/data/repositories/scan_repository_impl.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:dio/dio.dart';
import 'package:mobile/features/scan/data/models/scan_result_model.dart';

class MockScanRepository implements ScanRepository {
  bool failHistory = false;
  bool failDelete = false;
  List<ScanHistoryModel> currentHistory = [
    const ScanHistoryModel(
      id: 1,
      prediction: 'Tomato Blight',
      confidence: 95,
      severity: 'High',
      crop: 'Tomato',
      imageUrl: '/img.png',
      timestamp: '2023-10-10T10:00:00Z',
    )
  ];

  @override
  Future<List<ScanHistoryModel>> getHistory(CancelToken cancelToken) async {
    if (failHistory) throw Exception('Network Error');
    return currentHistory;
  }

  @override
  Future<void> deleteScan(int scanId) async {
    if (failDelete) throw Exception('Delete Error');
    currentHistory.removeWhere((s) => s.id == scanId);
  }

  @override
  Future<ScanResultModel> getScanDetails(int scanId, CancelToken cancelToken) async {
    throw UnimplementedError();
  }

  @override
  Future<ScanResultModel> uploadScan(String imagePath, String cropType, CancelToken cancelToken) async {
    throw UnimplementedError();
  }
}

void main() {
  late MockScanRepository mockRepo;

  setUp(() {
    mockRepo = MockScanRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        scanRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const MaterialApp(
        home: HistoryScreen(),
      ),
    );
  }

  testWidgets('Renders loading then history items', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for fetchHistory to complete
      await tester.pump(const Duration(seconds: 1));
      
      expect(find.text('Tomato Blight'), findsOneWidget);
      expect(find.text('Crop: Tomato'), findsOneWidget);
      expect(find.text('Confidence: 95%'), findsOneWidget);
    });
  });

  testWidgets('Renders empty state when history is empty', (WidgetTester tester) async {
    mockRepo.currentHistory = [];
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();
    
    expect(find.text('No Scans Yet'), findsOneWidget);
    expect(find.text('Start Scanning'), findsOneWidget);
  });

  testWidgets('Delete scan flow works', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));
      
      expect(find.text('Tomato Blight'), findsOneWidget);
      
      // Tap delete
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump(const Duration(seconds: 1));
      
      expect(find.text('Are you sure you want to delete the scan for Tomato?'), findsOneWidget);
      
      // Confirm delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      
      // Item should be removed
      expect(find.text('Tomato Blight'), findsNothing);
      expect(find.text('Scan deleted successfully.'), findsOneWidget);
    });
  });
}
