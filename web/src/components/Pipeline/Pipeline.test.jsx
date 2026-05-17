import React from 'react';
import { render, screen, cleanup } from '@testing-library/react';
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { PipelineTrace, STEPS } from './PipelineTrace';
import { usePipelineStore } from '../../store/pipelineStore';

describe('Pipeline Module', () => {
  afterEach(cleanup);
  beforeEach(() => {
    usePipelineStore.getState().reset();
  });

  it('renders nothing when pipeline has not started', () => {
    const { container } = render(<PipelineTrace />);
    expect(container.firstChild).toBeNull();
  });

  it('renders 5 steps when pipeline is running', () => {
    usePipelineStore.setState({ currentStep: 0 });
    render(<PipelineTrace />);
    
    STEPS.forEach(step => {
      expect(screen.getByText(step.name)).toBeDefined();
    });
  });

  it('correctly calculates step status (pending, running, done)', () => {
    // Step 0 done, Step 1 running
    usePipelineStore.setState({ completedSteps: [0], currentStep: 1 });
    render(<PipelineTrace />);

    // Agent 0 should be complete
    const completeBadges = screen.getAllByText('Complete');
    expect(completeBadges.length).toBe(1);

    // Agent 1 should be running
    const runningBadges = screen.getAllByText('Running');
    expect(runningBadges.length).toBe(1);

    // Agents 2, 3, 4 should be pending
    const pendingBadges = screen.getAllByText('Pending');
    expect(pendingBadges.length).toBe(3);
  });

  it('renders step content when step is done via renderStepContent prop', () => {
    usePipelineStore.setState({ completedSteps: [0] });
    
    render(
      <PipelineTrace 
        renderStepContent={(stepId) => {
          if (stepId === 0) return <div data-testid="card-0">Output 0</div>;
          return null;
        }}
      />
    );

    // Since step 0 is done, card-0 should be in DOM
    expect(screen.getByTestId('card-0')).toBeDefined();
    
    // Step 1 is not done, shouldn't render its content even if we returned it, 
    // but our prop only returns for step 0 anyway. The PipelineStep only renders children if status === 'done'
  });
});
