import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { usePipelineStore } from '../../store/pipelineStore';
import { CampaignEntry } from './CampaignEntry';
import { PricingDiff } from './PricingDiff';
import { NotificationPreview } from './NotificationPreview';

export function BeforeAfterPanel() {
  const initialBefore = usePipelineStore(state => state.stateBefore);
  const executionLog = usePipelineStore(state => state.executionLog);

  // Bug 3 fix: prefer executionLog.before_snapshot.last_pricing over the hardcoded
  // anchor (295) that GET /state/before returns. The real product price only arrives
  // once the Executor has run and written its before_snapshot.
  const resolvedBefore = executionLog?.before_snapshot || initialBefore;
  const stateBefore = resolvedBefore;

  // Bug 2 fix: stateAfter from GET /state/after/{plan_id} is counts-only
  // { campaigns_count, last_pricing, notifications_count }.
  // The actual arrays live in executionLog.after_snapshot — use that instead.
  const afterSnapshot = executionLog?.after_snapshot || null;

  const isRunning = usePipelineStore(state => state.isRunning);

  // Real-time arrays populated by Supabase insertions
  const liveCampaigns = usePipelineStore(state => state.liveCampaigns);
  const livePricingLog = usePipelineStore(state => state.livePricingLog);
  const liveNotifications = usePipelineStore(state => state.liveNotifications);

  if (!stateBefore) return null;

  // Deriving the "after" state
  // Bug 2 fix: read campaigns/notifications from afterSnapshot (arrays), not stateAfter (counts)
  const finalCampaigns = (!isRunning && afterSnapshot?.campaigns)
    ? afterSnapshot.campaigns
    : liveCampaigns;

  // Bug 2 fix: last_pricing from afterSnapshot is the correct scalar
  const currentPricing = (!isRunning && afterSnapshot?.last_pricing != null)
    ? afterSnapshot.last_pricing
    : (livePricingLog[livePricingLog.length - 1]?.after_value
      ?? livePricingLog[livePricingLog.length - 1]?.new_price
      ?? livePricingLog[livePricingLog.length - 1]?.price);

  // Bug 3 fix: last_pricing in before_snapshot is the real product baseline set by
  // `before['last_pricing'] = before_val` in execute.py. Fall back to base_pricing
  // then last_pricing from initialBefore, and only use 295 as a last resort.
  const beforePrice =
    stateBefore?.last_pricing ??
    stateBefore?.base_pricing ??
    295;

  const afterPrice =
    currentPricing ??
    beforePrice;

  // Bug 2 fix: notifications come from afterSnapshot.notifications array
  const latestNotification = (!isRunning && afterSnapshot?.notifications?.length > 0)
    ? afterSnapshot.notifications[0]
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
                  PKR {beforePrice?.toLocaleString?.() ?? beforePrice}
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
            {beforePrice !== afterPrice && (
              <div>
                <h4 style={{ fontSize: '11px', fontWeight: 600, color: '#94A3B8', marginBottom: '8px', textTransform: 'uppercase', letterSpacing: '0.05em' }}>Pricing Diff</h4>
                <PricingDiff
                  oldPrice={beforePrice}
                  newPrice={afterPrice}
                />
              </div>
            )}
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