import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insight_engine/screens/insight_screen.dart';
import 'package:insight_engine/models/insight_report.dart';
import 'package:insight_engine/widgets/severity_badge.dart';
import 'package:insight_engine/widgets/causal_chain.dart';

void main() {
  testWidgets('InsightScreen renders all components correctly', (WidgetTester tester) async {
    final mockReport = InsightReport(
      id: 'ir1',
      primaryInsight: 'Major Regional Revenue Gap',
      causalChain: 'Fuel ^ → Cost ^ → Margin v',
      severityScore: 8.7,
      affectedDomains: ['Logistics', 'Retail'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: InsightScreen(report: mockReport),
      ),
    );

    // 1. Verify primary insight text
    expect(find.text('Major Regional Revenue Gap'), findsOneWidget);

    // 2. Verify severity badge (8.7 should be CRITICAL and Red)
    final badgeFinder = find.byType(SeverityBadge);
    expect(badgeFinder, findsOneWidget);
    expect(find.textContaining('CRITICAL'), findsOneWidget);
    
    // Check for red color in the badge container
    final container = tester.widget<Container>(
      find.descendant(of: badgeFinder, matching: find.byType(Container)).first
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.border?.top.color, Colors.red);

    // 3. Verify causal chain pills (check segments)
    expect(find.byType(CausalChainWidget), findsOneWidget);
    expect(find.text('Fuel ^'), findsOneWidget);
    expect(find.text('Cost ^'), findsOneWidget);
    expect(find.text('Margin v'), findsOneWidget);

    // 4. Verify arrows in causal chain
    expect(find.byIcon(Icons.arrow_forward_rounded), findsNWidgets(2));

    // 5. Verify chips for affected domains
    expect(find.byType(Chip), findsNWidgets(2));
    expect(find.text('Logistics'), findsOneWidget);
    expect(find.text('Retail'), findsOneWidget);
  });
}
