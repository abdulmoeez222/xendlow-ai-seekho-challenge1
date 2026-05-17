import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insight_engine/screens/action_screen.dart';
import 'package:insight_engine/models/action_plan.dart';

void main() {
  testWidgets('ActionScreen renders plan details and fallbacks', (WidgetTester tester) async {
    final mockPlan = ActionPlan(
      id: 'ap1',
      selectedAction: 'Strategic Price Adjustment',
      reasoning: 'To maintain margin targets amidst fuel volatility.',
      parameters: {'adj': 0.05},
      fallbackActions: [
        {'action': 'Re-route shipments'},
        {'action': 'Volume discount'},
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ActionScreen(plan: mockPlan),
      ),
    );

    // 1. Verify "COMMITTED DECISION" badge
    expect(find.text('COMMITTED DECISION'), findsOneWidget);

    // 2. Verify selected action
    expect(find.text('Strategic Price Adjustment'), findsOneWidget);

    // 3. Verify reasoning text
    expect(find.text('To maintain margin targets amidst fuel volatility.'), findsOneWidget);

    // 4. Verify fallback section and chips
    expect(find.byType(ExpansionTile), findsOneWidget);
    
    // Tap to expand
    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();

    expect(find.byType(Chip), findsNWidgets(2));
    expect(find.text('Re-route shipments'), findsOneWidget);
    expect(find.text('Volume discount'), findsOneWidget);
  });
}
