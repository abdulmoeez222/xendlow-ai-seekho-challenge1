import 'package:flutter_test/flutter_test.dart';
import 'package:insight_engine/models/signal.dart';
import 'package:insight_engine/models/insight_report.dart';
import 'package:insight_engine/models/action_plan.dart';
import 'package:insight_engine/models/execution_log.dart';
import 'package:insight_engine/models/final_report.dart';

void main() {
  group('Model Parsings', () {
    test('Signal fromJson', () {
      final json = {'type': 'text', 'content': 'Test signal'};
      final model = Signal.fromJson(json);
      expect(model.type, 'text');
      expect(model.content, 'Test signal');
    });

    test('InsightReport fromJson', () {
      final json = {
        'id': 'ir123',
        'primary_insight': 'Sales drop detected',
        'causal_chain': 'Fuel ^ -> Cost ^',
        'severity_score': 8.5,
        'affected_domains': ['Logistics', 'Retail']
      };
      final model = InsightReport.fromJson(json);
      expect(model.id, 'ir123');
      expect(model.severityScore, 8.5);
      expect(model.affectedDomains, contains('Logistics'));
    });

    test('ActionPlan fromJson', () {
      final json = {
        'id': 'ap456',
        'selected_action': 'Increase prices',
        'reasoning': 'Offset fuel costs',
        'parameters': {'increase_pct': 10},
        'fallback_actions': [
          {'action': 'Reduce marketing'}
        ]
      };
      final model = ActionPlan.fromJson(json);
      expect(model.id, 'ap456');
      expect(model.selectedAction, 'Increase prices');
      expect(model.parameters['increase_pct'], 10);
    });

    test('ExecutionLog fromJson', () {
      final json = {
        'plan_id': 'ap456',
        'steps': [
          {'name': 'Signal received', 'status': 'success'}
        ]
      };
      final model = ExecutionLog.fromJson(json);
      expect(model.planId, 'ap456');
      expect(model.steps.length, 1);
    });

    test('FinalReport fromJson', () {
      final json = {
        'insight': 'Sales drop detected',
        'causal_chain': 'Fuel ^ -> Cost ^',
        'severity': 8.5,
        'selected_action': 'Increase prices',
        'reasoning': 'Offset fuel costs',
        'simulations_executed': 3,
        'projected_revenue_recovery': 'PKR 1.2M',
        'projected_reach': 5000,
        'execution_time_ms': 1200,
        'before_state': {'margin': 0.15},
        'after_state': {'margin': 0.18}
      };
      final model = FinalReport.fromJson(json);
      expect(model.simulationsExecuted, 3);
      expect(model.projectedReach, 5000);
      expect(model.beforeState['margin'], 0.15);
    });
  });
}
