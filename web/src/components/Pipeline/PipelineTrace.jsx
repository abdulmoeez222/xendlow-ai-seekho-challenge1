import React from 'react';
import { usePipelineStore } from '../../store/pipelineStore';
import { PipelineStep } from './PipelineStep';

export const STEPS = [
  { id: 0, name: "Ingestor Agent",  icon: "📥", desc: "Normalizing inputs into signal objects" },
  { id: 1, name: "Analyst Agent",   icon: "🔍", desc: "Finding causal relationships" },
  { id: 2, name: "Planner Agent",   icon: "🎯", desc: "Committing to action decision" },
  { id: 3, name: "Executor Agent",  icon: "⚡", desc: "Writing state to database" },
  { id: 4, name: "Reporter Agent",  icon: "📊", desc: "Generating final impact report" },
];

export function PipelineTrace({ renderStepContent }) {
  const currentStep = usePipelineStore(state => state.currentStep);
  const completedSteps = usePipelineStore(state => state.completedSteps);

  const getStepStatus = (id) => {
    if (completedSteps.includes(id)) return 'done';
    if (currentStep === id) return 'running';
    return 'pending';
  };

  // Only show the trace if the pipeline has started or finished
  if (currentStep === null && completedSteps.length === 0) {
    return null;
  }

  return (
    <section className="max-w-4xl mx-auto w-full mb-10">
      <div className="bg-white rounded-[16px] border border-[#E2E8F0] p-[24px]">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: '8px', marginBottom: '16px' }}>
          {STEPS.map((step, index) => {
            const status = getStepStatus(step.id);
            return <PipelineStep key={step.id} step={step} status={status} />;
          })}
        </div>
        <div style={{ marginBottom: '16px' }}>
          <div style={{ display: 'none' }}>
            {renderStepContent && renderStepContent(0)}
          </div>
          {/* Steps 1 & 2 side by side */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', marginBottom: '16px' }}>
            {renderStepContent && renderStepContent(1)}
            {renderStepContent && renderStepContent(2)}
          </div>
          {/* Steps 3 & 4 full width */}
          <div>
            {renderStepContent && renderStepContent(3)}
            <div style={{ marginTop: '16px' }}>
              {renderStepContent && renderStepContent(4)}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
