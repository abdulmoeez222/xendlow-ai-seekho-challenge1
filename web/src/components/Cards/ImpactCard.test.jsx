import React from 'react';
import { render, screen, cleanup, fireEvent } from '@testing-library/react';
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { ImpactCard } from './ImpactCard';
import { usePipelineStore } from '../../store/pipelineStore';

describe('ImpactCard Module', () => {
  afterEach(cleanup);
  beforeEach(() => {
    usePipelineStore.getState().reset();
  });

  const mockReport = {
    projected_revenue_recovery: 'PKR 1.2M',
    projected_reach: 45000,
    simulations_executed: 3,
    execution_time_ms: 1250
  };

  it('renders nothing if report is missing', () => {
    const { container } = render(<ImpactCard />);
    expect(container.firstChild).toBeNull();
  });

  it('renders 4 metric cards', () => {
    render(<ImpactCard report={mockReport} />);
    
    // Check titles
    expect(screen.getByText('Revenue Recovery')).toBeDefined();
    expect(screen.getByText('Customer Reach')).toBeDefined();
    expect(screen.getByText('Actions Executed')).toBeDefined();
    expect(screen.getByText('Pipeline Time')).toBeDefined();
  });

  it('renders the reset button and fires reset action', () => {
    // Setup some dirty state
    usePipelineStore.setState({ planId: 'dirty-123' });
    
    render(<ImpactCard report={mockReport} />);
    
    const resetBtn = screen.getByText('Reset Pipeline');
    expect(resetBtn).toBeDefined();

    // Click reset
    fireEvent.click(resetBtn);

    // Verify Zustand state is wiped
    expect(usePipelineStore.getState().planId).toBeNull();
  });
});
