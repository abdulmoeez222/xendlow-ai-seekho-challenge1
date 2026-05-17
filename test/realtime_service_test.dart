import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:insight_engine/services/realtime_service.dart';

class MockSupabaseClient extends Fake implements SupabaseClient {
  final MockRealtimeChannel channelStub = MockRealtimeChannel();
  
  @override
  RealtimeChannel channel(String name, {RealtimeChannelConfig opts = const RealtimeChannelConfig()}) {
    channelStub.topicName = name;
    return channelStub;
  }

  @override
  Future<String> removeChannel(RealtimeChannel channel) async {
    return 'ok';
  }
}

class MockRealtimeChannel extends Fake implements RealtimeChannel {
  String topicName = '';
  bool subscribeCalled = false;
  int listenerCount = 0;

  @override
  String get topic => topicName;

  @override
  RealtimeChannel onPostgresChanges({
    required PostgresChangeEvent event,
    String? schema,
    String? table,
    PostgresChangeFilter? filter,
    required void Function(PostgresChangePayload payload) callback,
  }) {
    listenerCount++;
    return this;
  }

  @override
  RealtimeChannel subscribe([void Function(RealtimeSubscribeStatus status, Object? error)? callback, Duration? timeout]) {
    subscribeCalled = true;
    return this;
  }
}

void main() {
  group('RealtimeService Tests', () {
    late MockSupabaseClient mockClient;

    setUp(() {
      mockClient = MockSupabaseClient();
      RealtimeService.setMockClient(mockClient);
    });

    test('subscribe sets up correct channel and listeners', () {
      RealtimeService.subscribe(
        planId: 'plan_123',
        onCampaign: (_) {},
        onPricing: (_) {},
        onNotify: (_) {},
      );

      expect(mockClient.channelStub.topicName, 'results_plan_123');
      expect(mockClient.channelStub.listenerCount, 3); // campaigns, pricing_log, notifications
      expect(mockClient.channelStub.subscribeCalled, true);
    });

    test('unsubscribe cleans up channel', () {
      RealtimeService.subscribe(
        planId: 'plan_123',
        onCampaign: (_) {},
        onPricing: (_) {},
        onNotify: (_) {},
      );
      
      RealtimeService.unsubscribe();
    });
  });
}
