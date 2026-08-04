import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/scan/presentation/screens/scan_screen.dart';

void main() {
  testWidgets('ScanScreen renders initial placeholder and disabled button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ScanScreen(),
        ),
      ),
    );

    // Verify title
    expect(find.text('Scan Plant'), findsOneWidget);

    // Verify placeholder text
    expect(find.text('No image selected'), findsOneWidget);

    // Verify Camera and Gallery buttons
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);

    // Verify Crop Selector Chips
    expect(find.text('Select Crop Type'), findsOneWidget);
    expect(find.text('Blueberry'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    
    // Verify Analyze Plant button is disabled (onPressed is null)
    final analyzeButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(analyzeButton.onPressed, isNull);
  });

  testWidgets('ScanScreen selects crop and button remains disabled if no image', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ScanScreen(),
        ),
      ),
    );

    await tester.tap(find.text('Blueberry'));
    await tester.pumpAndSettle();

    // Still disabled
    final analyzeButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(analyzeButton.onPressed, isNull);
  });
}
