import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { usePipelineStore } from '../../store/pipelineStore';
import { CampaignEntry } from './CampaignEntry';
import { PricingDiff } from './PricingDiff';
import { NotificationPreview } from './NotificationPreview';

export function BeforeAfterPanel() {
  const initialBefore = usePipelineStore(state => state.stateBefore);
  const executionLog = usePipelineStore(state => state.executionLog);
  const stateBefore = executionLog?.before_snapshot || initialBefore;
  
  const stateAfter = usePipelineStore(state => state.stateAfter);
  const isRunning = usePipelineStore(state => state.isRunning);

  // Real-time arrays populated by Supabase insertions
  const liveCampaigns = usePipelineStore(state => state.liveCampaigns);
  const livePricingLog = usePipelineStore(state => state.livePricingLog);
  const liveNotifications = usePipelineStore(state => state.liveNotifications);

  if (!stateBefore) return null;

  // Deriving the "after" state
  // Because the backend executor is so fast, the frontend WebSocket subscription sometimes 
  // misses the INSERT events. So we fallback to stateAfter once the pipeline is finished!
  const finalCampaigns = (!isRunning && stateAfter?.campaigns) 
    ? stateAfter.campaigns 
    : liveCampaigns;

  const currentPricing = (!isRunning && stateAfter?.last_pricing != null)
    ? stateAfter.last_pricing
    : (livePricingLog[livePricingLog.length - 1]?.after_value ?? livePricingLog[livePricingLog.length - 1]?.new_price ?? livePricingLog[livePricingLog.length - 1]?.price);

  const latestNotification = (!isRunning && stateAfter?.notifications?.length > 0)
    ? stateAfter.notifications[0] // just grab the first one
    : (liveNotifications.length > 0 ? liveNotifications[liveNotifications.length - 1] : null);

  return (
    <motion.div
      initial={{ opacity: 0, y: 15 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4 }}
      style={{ background: '#ffffff', border: '1px solid #E2E8F0', borderRadius: '16px', padding: '20px', width: '100%', marginBottom: '16px' }}
    >
      <div style={{ fontSize: '11px', color: '#94A3B8', letterSpacing: '0.07em', textTransform: 'uppercase', marginBottom: '14px', fontWeight: 500 }}>
        State changes · live via Supabase Realtime
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
        
        {/* LEFT SIDE: BEFORE STATE */}
        <div style={{ border: '1px solid #E2E8F0', borderRadius: '12px', overflow: 'hidden' }}>
          <div style={{ background: '#F8FAFC', color: '#94A3B8', fontSize: '11px', fontWeight: 500, padding: '10px 14px', letterSpacing: '0.07em', textTransform: 'uppercase' }}>
            Before
          </div>
          <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <div>
              <h4 style={{ fontSize: '11px', fontWeight: 600, color: '#94A3B8', marginBottom: '8px', textTransform: 'uppercase' }}>Active Campaigns</h4>
              {stateBefore.campaigns && stateBefore.campaigns.length > 0 ? (
                stateBefore.campaigns.map((c, i) => <CampaignEntry key={`before-camp-${i}`} campaign={c} />)
              ) : (
                <CampaignEntry campaign={null} />
              )}
            </div>
            <div style={{ marginBottom: '20px' }}>
            <div style={{ fontSize: '11px', fontWeight: 600, color: '#94A3B8', marginBottom: '8px', textTransform: 'uppercase', letterSpacing: '0.05em' }}>Base Pricing</div>
            <div style={{ background: '#F8FAFC', padding: '12px', borderRadius: '8px', border: '1px solid #E2E8F0' }}>
              <span style={{ fontSize: '18px', fontWeight: 500, color: '#334155' }}>
                PKR {stateBefore?.last_pricing ?? stateBefore?.base_pricing ?? 295}
              </span>
            </div>
          </div>
            <div>
              <h4 style={{ fontSize: '11px', fontWeight: 600, color: '#94A3B8', marginBottom: '8px', textTransform: 'uppercase' }}>Notifications</h4>
              <NotificationPreview notification={null} />
            </div>
          </div>
        </div>

        {/* RIGHT SIDE: AFTER STATE (REAL-TIME) */}
        <div style={{ border: '1px solid #BBF7D0', borderRadius: '12px', overflow: 'hidden' }}>
          <div style={{ background: '#DCFCE7', color: '#166534', fontSize: '11px', fontWeight: 500, padding: '10px 14px', letterSpacing: '0.07em', textTransform: 'uppercase', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            After
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
              </span>
              Live
            </div>
          </div>
          <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <div>
              <h4 style={{ fontSize: '11px', fontWeight: 600, color: '#94A3B8', marginBottom: '8px', textTransform: 'uppercase' }}>Active Campaigns</h4>
              <AnimatePresence>
                {finalCampaigns && finalCampaigns.length > 0 ? (
                  finalCampaigns.map((c, i) => <CampaignEntry key={`live-camp-${i}`} campaign={c} />)
                ) : (
                  <motion.div exit={{ opacity: 0, height: 0 }}>
                    {stateBefore.campaigns && stateBefore.campaigns.length > 0 ? (
                      stateBefore.campaigns.map((c, i) => <CampaignEntry key={`before-camp-r-${i}`} campaign={c} />)
                    ) : (
                      <CampaignEntry campaign={null} />
                    )}
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
            <div>
              <h4 style={{ fontSize: '11px', fontWeight: 600, color: '#94A3B8', marginBottom: '8px', textTransform: 'uppercase', letterSpacing: '0.05em' }}>Pricing Diff</h4>
              <PricingDiff 
                oldPrice={stateBefore?.last_pricing ?? stateBefore?.base_pricing ?? 295} 
                newPrice={currentPricing} 
              />
            </div>
            <div>
              <h4 style={{ fontSize: '11px', fontWeight: 600, color: '#94A3B8', marginBottom: '8px', textTransform: 'uppercase' }}>Notifications</h4>
              <AnimatePresence mode="popLayout">
                {latestNotification ? (
                  <NotificationPreview key="live-notif" notification={latestNotification} />
                ) : (
                  <motion.div key="empty-notif" exit={{ opacity: 0, scale: 0.9 }}>
                    <NotificationPreview notification={null} />
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          </div>
        </div>

      </div>
    </motion.div>
  );
}
