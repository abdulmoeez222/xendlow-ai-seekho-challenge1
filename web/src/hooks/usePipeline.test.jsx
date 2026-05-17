import React from 'react';
import { render, cleanup } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { usePipeline } from './usePipeline';
import { api } from '../lib/api';
import { usePipelineStore } from '../store/pipelineStore';

vi.mock('../lib/api', () => ({
  api: {
    runScenario: vi.fn(),
    runCustom: vi.fn(),
    getStateBefore: vi.fn(),
    getStateAfter: vi.fn(),
    getLogs: vi.fn()
  }
}));

const TestComponent = ({ action, payload }) => {
  const { runScenario, runCustom } = usePipeline();
  
  // Expose methods to global for testing triggers
  global.triggerRunScenario = () => runScenario(payload);
  global.triggerRunCustom = () => runCustom(payload);
  
  return null;
};

describe('usePipeline Hook', () => {
  beforeEach(() => {
    vi.useFakeTimers();
    usePipelineStore.getState().reset();
    vi.clearAllMocks();
  });

  afterEach(() => {
    vi.useRealTimers();
    cleanup();
    delete global.triggerRunScenario;
    delete global.triggerRunCustom;
  });

  it('initializes pipeline correctly on runScenario', async () => {
    api.getStateBefore.mockResolvedValueOnce({ price: 100 });
    api.runScenario.mockResolvedValueOnce({ plan_id: 'plan-123' });
    api.getLogs.mockResolvedValue({});

    render(<TestComponent payload={1} />);
    
    // Trigger run
    global.triggerRunScenario();

    // Zustand state should immediately flip to running
    expect(usePipelineStore.getState().isRunning).toBe(true);
    expect(usePipelineStore.getState().currentStep).toBe(0);

    // Wait for async
    await vi.waitFor(() => {
      expect(api.getStateBefore).toHaveBeenCalled();
      expect(api.runScenario).toHaveBeenCalledWith(1);
      expect(usePipelineStore.getState().planId).toBe('plan-123');
    });
  });

  it('progresses steps correctly based on polled logs', async () => {
    api.getStateBefore.mockResolvedValueOnce({});
    api.runScenario.mockResolvedValueOnce({ plan_id: 'plan-123' });
    
    // Sequence of log returns
    api.getLogs
      .mockResolvedValueOnce({}) // Tick 1: nothing yet
      .mockResolvedValueOnce({ signals: { raw: 'test' } }) // Tick 2: Step 0 done
      .mockResolvedValueOnce({ signals: {}, insight_report: { severity: 5 } }); // Tick 3: Step 1 done

    render(<TestComponent payload={1} />);
    global.triggerRunScenario();

    // Fast forward async start
    await vi.waitFor(() => expect(api.runScenario).toHaveBeenCalled());

    // Advance 2 seconds (Tick 1)
    await vi.advanceTimersByTimeAsync(2000);
    expect(usePipelineStore.getState().currentStep).toBe(0); // Still 0

    // Advance 2 seconds (Tick 2)
    await vi.advanceTimersByTimeAsync(2000);
    expect(usePipelineStore.getState().completedSteps).toContain(0);
    expect(usePipelineStore.getState().currentStep).toBe(1);

    // Advance 2 seconds (Tick 3)
    await vi.advanceTimersByTimeAsync(2000);
    expect(usePipelineStore.getState().completedSteps).toContain(1);
    expect(usePipelineStore.getState().currentStep).toBe(2);
    expect(usePipelineStore.getState().insightReport).toEqual({ severity: 5 });
  });

  it('completes pipeline and fetches stateAfter when Reporter finishes', async () => {
    api.getStateBefore.mockResolvedValueOnce({});
    api.runScenario.mockResolvedValueOnce({ plan_id: 'plan-123' });
    
    // Jump straight to final report
    api.getLogs.mockResolvedValueOnce({ 
      final_report: { reach: 100 } 
    });
    api.getStateAfter.mockResolvedValueOnce({ price: 200 });

    render(<TestComponent payload={1} />);
    global.triggerRunScenario();

    await vi.waitFor(() => expect(api.runScenario).toHaveBeenCalled());

    // Advance 2 seconds (Tick 1)
    await vi.advanceTimersByTimeAsync(2000);

    const state = usePipelineStore.getState();
    expect(state.completedSteps).toContain(4);
    expect(state.isRunning).toBe(false);
    expect(state.currentStep).toBeNull();
    
    // Ensure stateAfter was fetched
    expect(api.getStateAfter).toHaveBeenCalledWith('plan-123');
    expect(state.stateAfter).toEqual({ price: 200 });
  });
});
