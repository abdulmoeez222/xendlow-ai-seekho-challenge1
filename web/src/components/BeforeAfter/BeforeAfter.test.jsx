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
      // Bug 3 fix: stateBefore uses last_pricing (not base_pricing) as the real price field.
      // The test was previously setting base_pricing: 250 directly on stateBefore, which
      // only works as a fallback. Use last_pricing to match what executionLog.before_snapshot
      // actually sends.
      stateBefore: {
        campaigns: [],
        last_pricing: 250
      },
      executionLog: null,
    });

    render(<BeforeAfterPanel />);

    // Should show empty state for campaigns on both sides
    expect(screen.getAllByText('No active campaigns').length).toBe(2);

    // Should show the real baseline price from last_pricing
    expect(screen.getByText('PKR 250')).toBeDefined();

    // Should show no notifications on both sides
    expect(screen.getAllByText('None queued').length).toBe(2);
  });

  it('renders live data side-by-side with before state', () => {
    usePipelineStore.setState({
      stateBefore: {
        campaigns: [],
        last_pricing: 250
      },
      // Bug 2 fix: after-state data must come through executionLog.after_snapshot,
      // not through a stateAfter object (which is counts-only).
      executionLog: {
        before_snapshot: {
          campaigns: [],
          last_pricing: 250
        },
        after_snapshot: {
          campaigns: [
            { region: 'North', discount_pct: 15, status: 'active' }
          ],
          last_pricing: 280,
          notifications: [
            // Bug 1 fix: backend field is message_body, not message.
            { message_body: 'Pricing updated successfully!' }
          ]
        }
      },
      isRunning: false,
      liveCampaigns: [],
      livePricingLog: [],
      liveNotifications: [],
    });

    render(<BeforeAfterPanel />);

    // Left side (Before) — before state should still show empty
    expect(screen.getAllByText('No active campaigns').length).toBe(1); // Only on left now
    expect(screen.getAllByText('None queued').length).toBe(1);         // Only on left now

    // Right side (Live) — campaign from after_snapshot
    expect(screen.getByText('North')).toBeDefined();
    expect(screen.getByText('15% Discount')).toBeDefined();
    expect(screen.getByText('ACTIVE')).toBeDefined();

    // PricingDiff — old price struck through, new price highlighted
    expect(screen.getByText('PKR 280')).toBeDefined();

    // Notification — reads message_body correctly
    expect(screen.getByText('Pricing updated successfully!')).toBeDefined();
  });

  it('shows INTERNAL badge and hides discount line for internal campaigns', () => {
    usePipelineStore.setState({
      stateBefore: { campaigns: [], last_pricing: 35000 },
      executionLog: {
        before_snapshot: { campaigns: [], last_pricing: 35000 },
        after_snapshot: {
          campaigns: [
            { name: 'Client Negotiation — Ayesha Weddings', discount_pct: 0, status: 'internal' }
          ],
          last_pricing: 35000,
          notifications: [
            { message_body: 'Sales team — initiate negotiation with Ayesha Weddings within 48h.' }
          ]
        }
      },
      isRunning: false,
      liveCampaigns: [],
      livePricingLog: [],
      liveNotifications: [],
    });

    render(<BeforeAfterPanel />);

    expect(screen.getByText('INTERNAL')).toBeDefined();
    expect(screen.queryByText('0% Discount')).toBeNull(); // must be hidden
    expect(screen.queryByText('ACTIVE')).toBeNull();
  });
});