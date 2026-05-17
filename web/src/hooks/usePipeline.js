import { useRef, useCallback } from 'react';
import { api } from '../lib/api';
import { usePipelineStore } from '../store/pipelineStore';

export function usePipeline() {
  const pollIntervalRef = useRef(null);

  const pollLogs = useCallback((planId) => {
    if (pollIntervalRef.current) clearInterval(pollIntervalRef.current);
    
    pollIntervalRef.current = setInterval(async () => {
      try {
        const data = await api.getLogs(planId);
        if (!data) return;

        const store = usePipelineStore.getState();
        let step = store.currentStep;
        let completed = [...store.completedSteps];
        const updates = {};

        // Step 0: Ingestor
        if (data.signals && !completed.includes(0)) {
          completed.push(0);
          updates.signals = data.signals;
          step = 1;
        }

        // Step 1: Analyst -> yields insightReport
        if (data.insight_report && !completed.includes(1)) {
          completed.push(1);
          updates.insightReport = data.insight_report;
          step = 2;
        }

        // Step 2: Planner -> yields actionPlan
        if (data.action_plan && !completed.includes(2)) {
          completed.push(2);
          updates.actionPlan = data.action_plan;
          step = 3;
        }

        // Step 3: Executor -> yields executionLog
        if (data.execution_log && !completed.includes(3)) {
          completed.push(3);
          updates.executionLog = data.execution_log;
          step = 4;
        }

        // Step 4: Reporter -> yields finalReport (Pipeline finished)
        if (data.final_report && !completed.includes(4)) {
          completed.push(4);
          updates.finalReport = data.final_report;
          updates.isRunning = false;
          step = null; 

          clearInterval(pollIntervalRef.current);

          // Fetch final stateAfter
          try {
            const stateAfter = await api.getStateAfter(planId);
            updates.stateAfter = stateAfter;
          } catch (e) {
            console.error("Failed to fetch stateAfter", e);
          }
        }

        usePipelineStore.setState({
          currentStep: step,
          completedSteps: completed,
          ...updates
        });

      } catch (err) {
        console.error("Polling error:", err);
      }
    }, 2000);
  }, []);

  const startPipeline = useCallback(async (startApiCall) => {
    const store = usePipelineStore.getState();
    store.reset();
    usePipelineStore.setState({ isRunning: true, currentStep: 0 });

    try {
      // Fetch Before State
      const stateBefore = await api.getStateBefore();
      usePipelineStore.setState({ stateBefore });

      // Trigger Execution
      const res = await startApiCall();
      const planId = res.planId || res.plan_id; // accommodate slight key differences
      
      if (planId) {
        usePipelineStore.setState({ planId });
        pollLogs(planId);
      } else {
        throw new Error("No plan ID returned from backend");
      }

    } catch (err) {
      console.error("Pipeline start failed:", err);
      usePipelineStore.setState({ isRunning: false, currentStep: null });
    }
  }, [pollLogs]);

  const runScenario = useCallback((id) => startPipeline(() => api.runScenario(id)), [startPipeline]);
  const runCustom = useCallback((signals) => startPipeline(() => api.runCustom(signals)), [startPipeline]);

  return { runScenario, runCustom };
}
