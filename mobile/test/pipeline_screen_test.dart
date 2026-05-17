import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:insight_engine/screens/pipeline_screen.dart';
import 'package:insight_engine/providers/pipeline_provider.dart';
import 'package:insight_engine/widgets/step_tile.dart';

void main() {
  testWidgets('PipelineScreen renders steps with correct statuses', (WidgetTester tester) async {
    final provider = PipelineProvider();
    
    // Set mock state:
    // Step 1: Done
    // Step 2: Running
    // Step 3-5: Pending
    provider.setStepDone(PipelineStep.ingestor, {'data': 'test'});
    provider.setStepRunning(PipelineStep.analyst);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: PipelineScreen(),
        ),
      ),
    );

    // Verify 5 StepTile widgets
    expect(find.byType(StepTile), findsNWidgets(5));

    // Verify Ingestor is Done
    expect(
      find.descendant(
        of: find.widgetWithText(StepTile, 'Business Signal Ingestion'),
        matching: find.byIcon(Icons.check_circle),
      ),
      findsOneWidget,
    );

    // Verify Analyst is Running
    expect(
      find.descendant(
        of: find.widgetWithText(StepTile, 'Deep Volatility Analysis'),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );

    // Clean up to stop the periodic timer
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 5)); // Allow timer to settle/cancel
  });
}
