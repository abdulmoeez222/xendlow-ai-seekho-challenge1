import { useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { usePipelineStore } from '../store/pipelineStore';

export function useRealtime(planId) {
  // It is safer to grab these directly from getState inside the callbacks
  // to avoid stale closures or unnecessary re-renders in the component using this hook.
  
  useEffect(() => {
    if (!planId) return;

    // Subscribe to campaigns
    const campaignSub = supabase
      .channel('campaigns-changes')
      .on('postgres_changes', {
        event: 'INSERT',
        schema: 'public',
        table: 'campaigns',
        filter: `plan_id=eq.${planId}`
      }, (payload) => {
        const store = usePipelineStore.getState();
        store.setLiveCampaigns([...store.liveCampaigns, payload.new]);
      })
      .subscribe();

    // Subscribe to pricing_log
    const pricingSub = supabase
      .channel('pricing-changes')
      .on('postgres_changes', {
        event: 'INSERT',
        schema: 'public',
        table: 'pricing_log',
        filter: `plan_id=eq.${planId}`
      }, (payload) => {
        const store = usePipelineStore.getState();
        store.setLivePricingLog([...store.livePricingLog, payload.new]);
      })
      .subscribe();

    // Subscribe to notifications
    const notifSub = supabase
      .channel('notif-changes')
      .on('postgres_changes', {
        event: 'INSERT',
        schema: 'public',
        table: 'notifications',
        filter: `plan_id=eq.${planId}`
      }, (payload) => {
        const store = usePipelineStore.getState();
        store.setLiveNotifications([...store.liveNotifications, payload.new]);
      })
      .subscribe();

    return () => {
      supabase.removeChannel(campaignSub);
      supabase.removeChannel(pricingSub);
      supabase.removeChannel(notifSub);
    };
  }, [planId]);
}
