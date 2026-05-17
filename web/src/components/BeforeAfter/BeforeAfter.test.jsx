import React from 'react';
import { render, screen, cleanup } from '@testing-library/react';
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { BeforeAfterPanel } from './BeforeAfterPanel';
import { usePipelineStore } from '../../store/pipelineStore';

describe('BeforeAfterPanel Module', () => {
  afterEach(cleanup);
  beforeEach(() => {
    usePipelineStore.getState().reset();
  });

  it('renders nothing if stateBefore is null', () => {
    const { container } = render(<BeforeAfterPanel />);
    expect(container.firstChild).toBeNull();
  });

  it('renders before state correctly', () => {
    usePipelineStore.setState({
      stateBefore: {
        campaigns: [],
        base_pricing: 250
      }
    });

    render(<BeforeAfterPanel />);
    
    // Should show empty state for campaigns
    expect(screen.getAllByText('No active campaigns').length).toBe(2); // One on left, one on right
    
    // Should show initial pricing
    expect(screen.getAllByText('PKR 250').length).toBe(2); // One left, one right
    
    // Should show no notifications
    expect(screen.getAllByText('None queued').length).toBe(2); // One left, one right
  });

  it('renders live data side-by-side with before state', () => {
    usePipelineStore.setState({
      stateBefore: {
        campaigns: [],
        base_pricing: 250
      },
      liveCampaigns: [
        { region: 'North', discount_percent: 15 }
      ],
      livePricingLog: [
        { new_price: 280 }
      ],
      liveNotifications: [
        { message: 'Pricing updated successfully!' }
      ]
    });

    render(<BeforeAfterPanel />);
    
    // Left side (Before) assertions
    expect(screen.getAllByText('No active campaigns').length).toBe(1); // Only on left now
    expect(screen.getAllByText('None queued').length).toBe(1); // Only on left now

    // Right side (Live) assertions
    expect(screen.getByText('North')).toBeDefined();
    expect(screen.getByText('15% Discount')).toBeDefined();
    expect(screen.getByText('ACTIVE')).toBeDefined();

    // PricingDiff component test (strikethrough old, highlight new)
    expect(screen.getByText('PKR 280')).toBeDefined();
    
    // Notification test
    expect(screen.getByText('Pricing updated successfully!')).toBeDefined();
  });
});
