import 'package:flutter_test/flutter_test.dart';
import 'package:insight_engine/providers/pipeline_provider.dart';

void main() {
  group('PipelineProvider Tests', () {
    late PipelineProvider provider;

    setUp(() {
      provider = PipelineProvider();
    });

    test('Initial state is correct', () {
      expect(provider.isRunning, false);
      expect(provider.stepStatuses[PipelineStep.ingestor], StepStatus.pending);
      expect(provider.liveCampaigns, isEmpty);
    });

    test('setStepRunning updates status', () {
      provider.setStepRunning(PipelineStep.ingestor);
      expect(provider.stepStatuses[PipelineStep.ingestor], StepStatus.running);
    });

    test('setStepDone updates status and data', () {
      final mockData = {'signals': []};
      provider.setStepDone(PipelineStep.ingestor, mockData);
      expect(provider.stepStatuses[PipelineStep.ingestor], StepStatus.done);
      expect(provider.signalsData, mockData);
    });

    test('addLiveCampaign adds to list', () {
      final campaign = {'id': 1, 'name': 'Test'};
      provider.addLiveCampaign(campaign);
      expect(provider.liveCampaigns.length, 1);
      expect(provider.liveCampaigns.first['name'], 'Test');
    });

    test('reset clears all state', () {
      provider.setStepDone(PipelineStep.ingestor, {'data': 1});
      provider.addLiveCampaign({'id': 1});
      
      provider.reset();
      
      expect(provider.signalsData, isNull);
      expect(provider.liveCampaigns, isEmpty);
      expect(provider.stepStatuses[PipelineStep.ingestor], StepStatus.pending);
    });
  });
}
