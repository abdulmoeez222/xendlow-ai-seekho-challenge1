import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeService {
  static RealtimeChannel? _channel;
  static SupabaseClient? _mockClient;

  static void setMockClient(SupabaseClient client) {
    _mockClient = client;
  }

  static SupabaseClient get _client => _mockClient ?? Supabase.instance.client;

  static void subscribe({
    required String planId,
    required Function(Map<String, dynamic>) onCampaign,
    required Function(Map<String, dynamic>) onPricing,
    required Function(Map<String, dynamic>) onNotify,
  }) {
    _channel = _client.channel('results_$planId');

    _channel!
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'campaigns',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'plan_id',
          value: planId,
        ),
        callback: (payload) => onCampaign(payload.newRecord),
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'pricing_log',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'plan_id',
          value: planId,
        ),
        callback: (payload) => onPricing(payload.newRecord),
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'notifications',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'plan_id',
          value: planId,
        ),
        callback: (payload) => onNotify(payload.newRecord),
      )
      .subscribe();
  }

  static void unsubscribe() {
    if (_channel != null) {
      _client.removeChannel(_channel!);
      _channel = null;
    }
  }
}
