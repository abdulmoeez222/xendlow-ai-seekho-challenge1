import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:insight_engine/screens/impact_screen.dart';
import 'package:insight_engine/providers/pipeline_provider.dart';
import 'package:insight_engine/models/final_report.dart';
import 'package:insight_engine/widgets/metric_card.dart';

void main() {
  testWidgets('ImpactScreen renders mission metrics and handles reset', (WidgetTester tester) async {
    final provider = PipelineProvider();
    provider.finalReport = FinalReport(
      insight: 'Insight',
      causalChain: 'Chain',
      severity: 8.0,
      selectedAction: 'Action',
      reasoning: 'Reason',
      simulationsExecuted: 3,
      projectedRevenueRecovery: 'PKR 1M',
      projectedReach: 5000,
      executionTimeMs: 1200,
      beforeState: {},
      afterState: {},
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: ImpactScreen(),
        ),
      ),
    );

    // 1. Verify "MISSION COMPLETE" text
    expect(find.text('MISSION COMPLETE'), findsOneWidget);

    // 2. Verify all 4 MetricCard labels render
    expect(find.text('Revenue Recovery'), findsOneWidget);
    expect(find.text('Customer Reach'), findsOneWidget);
    expect(find.text('Actions Executed'), findsOneWidget);
    expect(find.text('Pipeline Time'), findsOneWidget);

    // 3. Verify values render
    expect(find.text('PKR 1M'), findsOneWidget);
    expect(find.text('5000 users'), findsOneWidget);

    // 4. Verify "Run Again" button exists and tap it
    final runAgainFinder = find.widgetWithText(ElevatedButton, 'Run Again');
    expect(runAgainFinder, findsOneWidget);

    // Scroll and tap
    await tester.ensureVisible(runAgainFinder);
    await tester.tap(runAgainFinder);
    
    // Use pump instead of pumpAndSettle because reset triggers CircularProgressIndicator (infinite animation)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    
    // 5. Test Reset Logic
    expect(provider.finalReport, isNull);
  });
}
