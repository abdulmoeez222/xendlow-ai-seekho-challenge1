import React from 'react';
import { render, screen, fireEvent, cleanup } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { InputPanel } from './InputPanel';
import { usePipelineStore } from '../../store/pipelineStore';

describe('InputPanel Module', () => {
  afterEach(cleanup);
  beforeEach(() => {
    usePipelineStore.getState().reset();
  });

  it('renders 3 scenario buttons', () => {
    render(<InputPanel />);
    expect(screen.getByText('Regional Sales Drop + Fuel Shock')).toBeDefined();
    expect(screen.getByText('Competitor Price Drop + Stock Surplus')).toBeDefined();
    expect(screen.getByText('Forex Shock + Import Dependency')).toBeDefined();
  });

  it('scenario buttons call onRunScenario with correct ID', () => {
    const handleRunScenario = vi.fn();
    render(<InputPanel onRunScenario={handleRunScenario} />);
    
    fireEvent.click(screen.getByText('Regional Sales Drop + Fuel Shock'));
    expect(handleRunScenario).toHaveBeenCalledWith(1);
  });

  it('disables buttons and shows "Pipeline Running..." when isRunning is true', () => {
    usePipelineStore.setState({ isRunning: true });
    render(<InputPanel />);
    
    // Check scenario button is disabled
    const btn1Text = screen.getByText('Regional Sales Drop + Fuel Shock');
    const btn1 = btn1Text.closest('button');
    expect(btn1.disabled).toBe(true);

    // Check submit button
    const submitBtn = screen.getByText('Pipeline Running...');
    expect(submitBtn.closest('button').disabled).toBe(true);
  });

  it('switches tabs and calls onRunCustom on submit', () => {
    const handleRunCustom = vi.fn();
    render(<InputPanel onRunCustom={handleRunCustom} />);
    
    // Switch to URL tab
    fireEvent.click(screen.getByText('URL'));
    
    const input = screen.getByPlaceholderText('https://example.com/report.pdf');
    fireEvent.change(input, { target: { value: 'https://test.com' } });
    
    fireEvent.click(screen.getByText('Analyze Signals'));
    
    expect(handleRunCustom).toHaveBeenCalledWith({ type: 'url', value: 'https://test.com' });
  });
});
