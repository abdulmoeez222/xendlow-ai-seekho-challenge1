import React from 'react';
import { usePipelineStore } from '../store/pipelineStore';
import { usePipeline } from '../hooks/usePipeline';
import { useRealtime } from '../hooks/useRealtime';

import { InputPanel } from '../components/InputPanel/InputPanel';
import { PipelineTrace } from '../components/Pipeline/PipelineTrace';
import { InsightCard } from '../components/Cards/InsightCard';
import { ActionPlanCard } from '../components/Cards/ActionPlanCard';
import { ImpactCard } from '../components/Cards/ImpactCard';
import { BeforeAfterPanel } from '../components/BeforeAfter/BeforeAfterPanel';
import { TracePanel } from '../components/AgentTrace/TracePanel';
import { Skeleton } from '../components/shared/Skeleton';

export function Dashboard() {
  const { runScenario, runCustom } = usePipeline();

  const planId = usePipelineStore(state => state.planId);
  const currentStep = usePipelineStore(state => state.currentStep);
  const completedSteps = usePipelineStore(state => state.completedSteps);

  // Data blocks
  const insightReport = usePipelineStore(state => state.insightReport);
  const actionPlan = usePipelineStore(state => state.actionPlan);
  const finalReport = usePipelineStore(state => state.finalReport);

  // Activate realtime Subscriptions once we have a planId
  useRealtime(planId);

  const renderStepContent = (stepId) => {
    const isDone = completedSteps.includes(stepId);
    const isRunning = currentStep === stepId;

    if (!isDone && !isRunning) return null;

    // We only show cards for steps 1 to 4
    switch (stepId) {
      case 1: // Analyst -> InsightCard
        if (isRunning) return <Skeleton className="h-48 w-full" />;
        return <InsightCard report={insightReport} />;

      case 2: // Planner -> ActionPlanCard
        if (isRunning) return <Skeleton className="h-40 w-full" />;
        return <ActionPlanCard plan={actionPlan} />;

      case 3: // Executor -> BeforeAfterPanel
        // The BeforeAfterPanel is special: we want to see it updating *while* running
        if (isRunning || isDone) return <BeforeAfterPanel />;
        return null;

      case 4: // Reporter -> ImpactCard
        if (isRunning) return <Skeleton className="h-64 w-full" />;
        return <ImpactCard report={finalReport} />;

      default:
        // Ingestor (Step 0) doesn't have a specific card in the design
        return null;
    }
  };

  return (
    <div style={{ minHeight: '100vh', paddingBottom: '32px' }}>
      {/* Header */}
      <header style={{ background: '#0F172A', padding: '14px 28px', position: 'sticky', top: 0, zIndex: 50, marginBottom: '20px' }}>
        <div style={{ maxWidth: '100%', margin: '0 auto', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div style={{ width: '32px', height: '32px', background: '#1E40AF', borderRadius: '8px', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#60A5FA' }}>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="16"></line><line x1="8" y1="12" x2="16" y2="12"></line></svg>
            </div>
            <div>
              <div style={{ color: '#F8FAFC', fontSize: '16px', fontWeight: 500, lineHeight: 1.2 }}>Insight Engine</div>
              <div style={{ color: '#64748B', fontSize: '12px' }}>Autonomous Operations Pipeline</div>
            </div>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div style={{ background: '#1E293B', color: '#64748B', border: '1px solid #334155', borderRadius: '6px', fontSize: '11px', padding: '4px 10px' }}>
              Vercel · Production
            </div>
            <div style={{ background: 'rgba(52,211,153,0.1)', border: '1px solid rgba(52,211,153,0.2)', color: '#34D399', borderRadius: '20px', padding: '4px 12px', fontSize: '12px', fontWeight: 500, display: 'flex', alignItems: 'center', gap: '6px' }}>
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
              </span>
              Agents Online
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main style={{ padding: '0 20px', maxWidth: '896px', margin: '0 auto', display: 'flex', flexDirection: 'column', gap: '16px' }}>
        {/* Input Panel (Always visible at top) */}
        <InputPanel onRunScenario={runScenario} onRunCustom={runCustom} />

        {/* Pipeline Execution Trace */}
        <PipelineTrace renderStepContent={renderStepContent} />

        {/* Trace Panel (Collapsible JSON logs) */}
        <TracePanel />
      </main>
    </div>
  );
}
