import React from 'react';
import { render, cleanup } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { useRealtime } from './useRealtime';
import { supabase } from '../lib/supabase';
import { usePipelineStore } from '../store/pipelineStore';

// Mock the supabase client functions
vi.mock('../lib/supabase', () => ({
  supabase: {
    channel: vi.fn(),
    removeChannel: vi.fn(),
  }
}));

const TestComponent = ({ planId }) => {
  useRealtime(planId);
  return <div />;
};

describe('useRealtime Hook', () => {
  let mockOn;
  let mockSubscribe;
  let registeredCallbacks;

  beforeEach(() => {
    usePipelineStore.getState().reset();
    registeredCallbacks = {};

    mockSubscribe = vi.fn().mockReturnThis();
    mockOn = vi.fn().mockImplementation((event, filter, callback) => {
      // Store the callback so we can trigger it manually in tests
      registeredCallbacks[filter.table] = callback;
      return { subscribe: mockSubscribe };
    });

    supabase.channel.mockReturnValue({ on: mockOn });
    supabase.removeChannel.mockClear();
  });

  afterEach(cleanup);

  it('does nothing if planId is missing', () => {
    render(<TestComponent planId={null} />);
    expect(supabase.channel).not.toHaveBeenCalled();
  });

  it('subscribes to all 3 channels with the correct planId filter', () => {
    render(<TestComponent planId="plan-999" />);

    expect(supabase.channel).toHaveBeenCalledTimes(3);
    expect(supabase.channel).toHaveBeenCalledWith('campaigns-changes');
    expect(supabase.channel).toHaveBeenCalledWith('pricing-changes');
    expect(supabase.channel).toHaveBeenCalledWith('notif-changes');

    expect(mockOn).toHaveBeenCalledTimes(3);
    // Verify filter syntax
    expect(mockOn.mock.calls[0][1].filter).toBe('plan_id=eq.plan-999');
    
    expect(mockSubscribe).toHaveBeenCalledTimes(3);
  });

  it('updates Zustand store when payloads are received', () => {
    render(<TestComponent planId="plan-999" />);

    // Trigger campaign insert
    registeredCallbacks['campaigns']({ new: { id: 1, name: 'Promo' } });
    
    // Trigger pricing insert
    registeredCallbacks['pricing_log']({ new: { price: 100 } });
    
    // Trigger notification insert
    registeredCallbacks['notifications']({ new: { msg: 'Hello' } });

    const state = usePipelineStore.getState();
    expect(state.liveCampaigns).toEqual([{ id: 1, name: 'Promo' }]);
    expect(state.livePricingLog).toEqual([{ price: 100 }]);
    expect(state.liveNotifications).toEqual([{ msg: 'Hello' }]);
  });

  it('cleans up channels on unmount', () => {
    const { unmount } = render(<TestComponent planId="plan-999" />);
    
    unmount();
    
    expect(supabase.removeChannel).toHaveBeenCalledTimes(3);
  });
});
