import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:insight_engine/screens/home_screen.dart';
import 'package:insight_engine/widgets/scenario_card.dart';
import 'package:insight_engine/providers/pipeline_provider.dart';

void main() {
  testWidgets('HomeScreen renders scenarios and input field', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => PipelineProvider(),
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // 1. Verify 3 ScenarioCard widgets are present
    expect(find.byType(ScenarioCard), findsNWidgets(3));

    // 2. Verify text input field exists
    expect(find.byType(TextField), findsOneWidget);

    // 3. Verify each card has distinct color logic (Checking names as proxy for different scenarios)
    expect(find.text('Regional Sales Drop + Fuel Shock'), findsOneWidget);
    expect(find.text('Competitor Price Drop + Inventory Surplus'), findsOneWidget);
    expect(find.text('Rupee Devaluation + Import Pipeline Exposure'), findsOneWidget);

    // 4. Verify "Analyze & Act" button exists
    expect(find.text('Analyze & Act'), findsOneWidget);
  });
}
