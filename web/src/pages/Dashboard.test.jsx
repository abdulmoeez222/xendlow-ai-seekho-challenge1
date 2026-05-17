import React from 'react';
import { render, screen, cleanup } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { Dashboard } from './Dashboard';
import { usePipelineStore } from '../store/pipelineStore';

// Mock components that we've already tested to keep this test clean
vi.mock('./InputPanel/InputPanel', () => ({ InputPanel: () => <div data-testid="input-panel" /> }));
vi.mock('./Pipeline/PipelineTrace', () => ({
  PipelineTrace: ({ renderStepContent }) => (
    <div data-testid="pipeline-trace">
      {/* We can manually call renderStepContent for testing */}
      <div data-testid="step-1">{renderStepContent(1)}</div>
      <div data-testid="step-3">{renderStepContent(3)}</div>
    </div>
  )
}));
vi.mock('./AgentTrace/TracePanel', () => ({ TracePanel: () => <div data-testid="trace-panel" /> }));
vi.mock('./Cards/InsightCard', () => ({ InsightCard: () => <div data-testid="insight-card" /> }));
vi.mock('./Cards/ActionPlanCard', () => ({ ActionPlanCard: () => <div data-testid="action-plan-card" /> }));
vi.mock('./Cards/ImpactCard', () => ({ ImpactCard: () => <div data-testid="impact-card" /> }));
vi.mock('./BeforeAfter/BeforeAfterPanel', () => ({ BeforeAfterPanel: () => <div data-testid="before-after-panel" /> }));
vi.mock('./shared/Skeleton', () => ({ Skeleton: () => <div data-testid="skeleton" /> }));
vi.mock('../hooks/useRealtime', () => ({ useRealtime: vi.fn() }));
vi.mock('../hooks/usePipeline', () => ({
  usePipeline: () => ({ runScenario: vi.fn(), runCustom: vi.fn() })
}));

describe('Dashboard Module', () => {
  afterEach(cleanup);
  beforeEach(() => {
    usePipelineStore.getState().reset();
    vi.clearAllMocks();
  });

  it('renders header, input panel, pipeline trace, and trace panel', () => {
    render(<Dashboard />);
    expect(screen.getByText('Insight Engine')).toBeDefined();
    expect(screen.getByTestId('input-panel')).toBeDefined();
    expect(screen.getByTestId('pipeline-trace')).toBeDefined();
    expect(screen.getByTestId('trace-panel')).toBeDefined();
  });

  it('renders skeleton for running steps (e.g. Analyst running)', () => {
    usePipelineStore.setState({ currentStep: 1, completedSteps: [0] });
    render(<Dashboard />);
    // Step 1 is running, should yield a skeleton
    const skeletons = screen.getAllByTestId('skeleton');
    expect(skeletons).toBeDefined();
  });

  it('renders actual card when step is done (e.g. Analyst done)', () => {
    usePipelineStore.setState({ currentStep: 2, completedSteps: [0, 1] });
    render(<Dashboard />);
    // Step 1 is done, should yield InsightCard
    expect(screen.getByTestId('insight-card')).toBeDefined();
  });

  it('renders BeforeAfterPanel when Executor is running', () => {
    usePipelineStore.setState({ currentStep: 3, completedSteps: [0, 1, 2] });
    render(<Dashboard />);
    // Step 3 is running, shouldn't be a skeleton, it should be the BeforeAfterPanel itself
    expect(screen.getByTestId('before-after-panel')).toBeDefined();
  });
});
