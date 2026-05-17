import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:insight_engine/screens/simulation_screen.dart';
import 'package:insight_engine/providers/pipeline_provider.dart';
import 'package:insight_engine/widgets/campaign_card.dart';
import 'package:insight_engine/widgets/pricing_diff.dart';
import 'package:insight_engine/widgets/whatsapp_bubble.dart';

void main() {
  testWidgets('SimulationScreen renders execution widgets with real-time data', (WidgetTester tester) async {
    final provider = PipelineProvider();
    
    // Add mock real-time data
    provider.addLiveCampaign({'region': 'Lahore', 'discount_pct': 15});
    provider.addLivePricing({'item_name': 'Electronics', 'old_price': 5000, 'new_price': 4250});
    provider.addLiveNotification({'message_body': 'New discount active!', 'recipient_count': 1200});

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: SimulationScreen(),
        ),
      ),
    );

    // Trigger animations
    await tester.pump(const Duration(milliseconds: 500));

    // 1. Verify all 3 widgets render
    expect(find.byType(CampaignCard), findsOneWidget);
    expect(find.byType(PricingDiff), findsOneWidget);
    expect(find.byType(WhatsAppBubble), findsOneWidget);

    // 2. Verify PricingDiff details
    expect(find.text('Electronics'), findsOneWidget);
    expect(find.text('5000'), findsOneWidget);
    expect(find.text('4250'), findsOneWidget);

    // 3. Verify CampaignCard details
    expect(find.text('Lahore'), findsOneWidget);
    expect(find.textContaining('15% discount'), findsOneWidget);

    // 4. Verify WhatsAppBubble details
    expect(find.text('New discount active!'), findsOneWidget);
    expect(find.text('1200 recipients'), findsOneWidget);
  });
}
