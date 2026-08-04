import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/scan/presentation/screens/scan_result_screen.dart';
import 'package:mobile/features/scan/presentation/providers/scan_provider.dart';
import 'package:mobile/features/scan/data/models/scan_result_model.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  const testData = ScanDataModel(
    diagnosisId: 'DG123',
    plant: PlantModel(name: 'Tomato', captureDate: '2023-10-10'),
    disease: DiseaseModel(name: 'Tomato Blight', scientificName: 'Sci Name', description: 'Desc'),
    analysis: AnalysisModel(confidence: 95, infectionArea: 20, severity: 'High', severityMessage: 'Severe'),
    causes: ['Fungus'],
    symptoms: [
      SymptomModel(title: 'Spots', description: 'Brown spots', imageUrl: '/spots.png'),
    ],
    highlight: HighlightModel(overlayImageUrl: '/cam.png', gradcamUrl: '/grad.png', spotlightUrl: '/spot.png', opacity: 60),
    treatment: TreatmentModel(
      organic: [OrganicTreatmentModel(step: 1, title: 'Oil', description: 'Apply oil')],
      chemical: ChemicalTreatmentModel(safetyMessage: 'Safe', products: [
        ChemicalProductModel(name: 'Fungicide', strength: 'Medium', description: 'Use', dosage: '1g')
      ]),
      preventive: ['Rotation'],
    ),
  );

  const testHealthyData = ScanDataModel(
    diagnosisId: 'DG124',
    plant: PlantModel(name: 'Tomato', captureDate: '2023-10-10'),
    disease: DiseaseModel(name: 'Tomato Healthy', scientificName: 'Sci Name', description: 'Desc'),
    analysis: AnalysisModel(confidence: 99, infectionArea: 0, severity: 'Low', severityMessage: 'Healthy'),
    causes: [],
    symptoms: [],
    highlight: HighlightModel(overlayImageUrl: '', gradcamUrl: '', spotlightUrl: '', opacity: 0),
    treatment: TreatmentModel(organic: [], chemical: null, preventive: []),
  );

  Widget createWidgetUnderTest(ScanResultModel? result) {
    return ProviderScope(
      overrides: [
        scanProvider.overrideWith((ref) {
          final notifier = ScanNotifier(ref: ref);
          notifier.state = ScanState(
            imageFile: null,
            scanResult: result,
          );
          return notifier;
        }),
      ],
      child: const MaterialApp(
        home: ScanResultScreen(),
      ),
    );
  }

  testWidgets('Renders fallback when result is null', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(null));

    expect(find.text('Scan result not found or expired.'), findsOneWidget);
    expect(find.text('Back to Dashboard'), findsOneWidget);
  });

  testWidgets('Renders diseased data correctly', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      const result = ScanResultModel(scanId: 1, data: testData);
      await tester.pumpWidget(createWidgetUnderTest(result));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('DISEASE DETECTED'), findsOneWidget);
      expect(find.text('Tomato Blight'), findsOneWidget);
      expect(find.text('95%'), findsOneWidget);
      expect(find.text('Causes'), findsOneWidget);
      expect(find.text('Symptoms'), findsOneWidget);
      expect(find.text('Treatment Plan'), findsOneWidget);
      
      expect(find.text('Organic Treatment'), findsOneWidget);
      expect(find.text('Spots'), findsOneWidget);
    });
  });

  testWidgets('Renders healthy data correctly (hides treatment/causes/visuals)', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      const result = ScanResultModel(scanId: 2, data: testHealthyData);
      await tester.pumpWidget(createWidgetUnderTest(result));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('HEALTHY'), findsOneWidget);
      expect(find.text('Tomato Healthy'), findsOneWidget);
      
      expect(find.text('Treatment Plan'), findsNothing);
      expect(find.text('Causes'), findsNothing);
      expect(find.text('Visual Analysis'), findsNothing);
    });
  });

  testWidgets('Expandable behavior works', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      const result = ScanResultModel(scanId: 1, data: testData);
      await tester.pumpWidget(createWidgetUnderTest(result));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Oil'), findsNothing);
      
      final titleFinder = find.text('Organic Treatment');
      await tester.ensureVisible(titleFinder);
      await tester.tap(titleFinder);
      
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      expect(find.text('Oil'), findsOneWidget);
    });
  });
}
