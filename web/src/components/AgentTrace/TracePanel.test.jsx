import React from 'react';
import { render, screen, cleanup, fireEvent } from '@testing-library/react';
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { TracePanel } from './TracePanel';
import { usePipelineStore } from '../../store/pipelineStore';

// Mock react-syntax-highlighter to avoid ESM/Vitest transform issues in testing
vi.mock('react-syntax-highlighter', () => ({
  Light: Object.assign(({ children }) => <pre data-testid="syntax-highlighter">{children}</pre>, {
    registerLanguage: vi.fn(),
  }),
}));

describe('TracePanel Module', () => {
  afterEach(cleanup);
  beforeEach(() => {
    usePipelineStore.getState().reset();
  });

  const mockExecutionLog = {
    ingestor_log: { signal_count: 5 },
    analyst_log: { identified_cause: 'fuel' },
    planner_log: { selected_action: 'discount' },
  };

  it('renders nothing if executionLog is empty', () => {
    const { container } = render(<TracePanel />);
    expect(container.firstChild).toBeNull();
  });

  it('renders title and expand button if executionLog exists', () => {
    usePipelineStore.setState({ executionLog: mockExecutionLog });
    render(<TracePanel />);
    expect(screen.getByText('Agent Trace — Antigravity Logs')).toBeDefined();
    expect(screen.getByText('Expand')).toBeDefined();
  });

  it('expands on click and renders syntax highlighted logs', () => {
    usePipelineStore.setState({
      signals: mockExecutionLog.ingestor_log,
      insightReport: mockExecutionLog.analyst_log,
      actionPlan: mockExecutionLog.planner_log,
    });
    render(<TracePanel />);
    
    // Initially hidden (Framer motion removes it from DOM or zero height)
    expect(screen.queryByText('Ingestor Log')).toBeNull();

    // Click to expand
    fireEvent.click(screen.getByText('Agent Trace — Antigravity Logs'));

    // Verify UI toggles to Collapse
    expect(screen.getByText('Collapse')).toBeDefined();
    
    // Verify sections render
    expect(screen.getByText('Ingestor Log')).toBeDefined();
    expect(screen.getByText('Analyst Log')).toBeDefined();
    expect(screen.getByText('Planner Log')).toBeDefined();

    // Verify syntax highlighters are present
    const codeBlocks = screen.getAllByTestId('syntax-highlighter');
    expect(codeBlocks.length).toBe(3); // Since we provided 3 mock logs

    // Verify content is stringified JSON
    expect(codeBlocks[0].textContent).toContain('"signal_count": 5');
  });
});
