import 'package:flutter/foundation.dart';
import '../models/final_report.dart';
import '../services/realtime_service.dart';

enum PipelineStep { ingestor, analyst, planner, executor, reporter }
enum StepStatus { pending, running, done }

class PipelineProvider extends ChangeNotifier {
  bool isRunning = false;
  String? _planId;
  String? get planId => _planId;
  set planId(String? value) {
    _planId = value;
    if (value != null) {
      RealtimeService.subscribe(
        planId: value,
        onCampaign: addLiveCampaign,
        onPricing: addLivePricing,
        onNotify: addLiveNotification,
      );
    }
    notifyListeners();
  }

  Map<PipelineStep, StepStatus> stepStatuses = {
    for (var s in PipelineStep.values) s: StepStatus.pending
  };

  // Data from each step
  dynamic signalsData;
  dynamic insightData;
  dynamic actionData;
  dynamic executionData;
  FinalReport? finalReport;

  // Realtime state
  List<Map<String, dynamic>> liveCampaigns = [];
  List<Map<String, dynamic>> livePricing = [];
  List<Map<String, dynamic>> liveNotifications = [];

  // Before/after snapshots
  Map<String, dynamic>? stateBefore;
  Map<String, dynamic>? stateAfter;

  void setStepRunning(PipelineStep step) {
    stepStatuses[step] = StepStatus.running;
    notifyListeners();
  }

  void setStepDone(PipelineStep step, dynamic data) {
    stepStatuses[step] = StepStatus.done;
    switch (step) {
      case PipelineStep.ingestor:
        signalsData = data;
        break;
      case PipelineStep.analyst:
        insightData = data;
        break;
      case PipelineStep.planner:
        actionData = data;
        break;
      case PipelineStep.executor:
        executionData = data;
        break;
      case PipelineStep.reporter:
        finalReport = FinalReport.fromJson(data);
        break;
    }
    notifyListeners();
  }

  void addLiveCampaign(Map<String, dynamic> row) {
    liveCampaigns.add(row);
    notifyListeners();
  }

  void addLivePricing(Map<String, dynamic> row) {
    livePricing.add(row);
    notifyListeners();
  }

  void addLiveNotification(Map<String, dynamic> row) {
    liveNotifications.add(row);
    notifyListeners();
  }

  void reset() {
    RealtimeService.unsubscribe();
    isRunning = false;
    planId = null;
    stepStatuses = {for (var s in PipelineStep.values) s: StepStatus.pending};
    signalsData = null;
    insightData = null;
    actionData = null;
    executionData = null;
    finalReport = null;
    liveCampaigns = [];
    livePricing = [];
    liveNotifications = [];
    stateBefore = null;
    stateAfter = null;
    notifyListeners();
  }
}
