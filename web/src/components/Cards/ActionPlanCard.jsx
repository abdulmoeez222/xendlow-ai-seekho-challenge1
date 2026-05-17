import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Badge } from '../shared/Badge';

export function ActionPlanCard({ plan }) {
  const [showFallbacks, setShowFallbacks] = useState(false);

  if (!plan) return null;

  const actionName = plan.action_name || plan.actionName || plan.action || plan.name;
  const reasoning = plan.reasoning || plan.rationale || plan.description;

  return (
    <motion.div
      initial={{ opacity: 0, y: 15 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4, ease: "easeOut" }}
      style={{ background: '#ffffff', border: '1px solid #E2E8F0', borderRadius: '16px', padding: '20px', display: 'flex', flexDirection: 'column' }}
    >
      <div style={{ fontSize: '11px', color: '#94A3B8', letterSpacing: '0.07em', textTransform: 'uppercase', marginBottom: '14px', fontWeight: 500 }}>
        Planner decision
      </div>

      <div style={{ display: 'flex', alignItems: 'center', marginBottom: '12px' }}>
        <div style={{ background: '#DCFCE7', color: '#166534', borderRadius: '20px', padding: '4px 12px', fontSize: '11px', fontWeight: 500, display: 'flex', alignItems: 'center', gap: '6px' }}>
          <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
          COMMITTED ACTION
        </div>
      </div>

      <div style={{ fontSize: '16px', fontWeight: 500, color: '#0F172A', marginBottom: '10px' }}>
        {actionName ? actionName : <div style={{ background: '#E2E8F0', height: '24px', width: '200px', borderRadius: '4px' }}></div>}
      </div>

      <div style={{ borderLeft: '4px solid #16A34A', borderRadius: '0 8px 8px 0', background: '#F0FDF4', padding: '10px 14px', fontSize: '13px', color: '#166534', lineHeight: 1.6, fontStyle: 'italic', marginBottom: '16px' }}>
        {reasoning ? `"${reasoning}"` : <div style={{ background: '#E2E8F0', height: '40px', width: '100%', borderRadius: '4px' }}></div>}
      </div>

      {plan.fallbacks && plan.fallbacks.length > 0 && (
        <div className="mt-auto">
          <div 
            onClick={() => setShowFallbacks(!showFallbacks)}
            style={{ fontSize: '12px', color: '#94A3B8', display: 'flex', alignItems: 'center', gap: '4px', cursor: 'pointer', fontWeight: 500 }}
          >
            {showFallbacks ? 'Hide fallbacks' : 'Fallback Conditions'}
            <svg style={{ transform: showFallbacks ? 'rotate(180deg)' : 'none', transition: 'transform 0.2s' }} width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
          </div>
          
          <AnimatePresence>
            {showFallbacks && (
              <motion.div
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: 'auto', opacity: 1 }}
                exit={{ height: 0, opacity: 0 }}
                style={{ overflow: 'hidden' }}
              >
                <div style={{ padding: '8px 0', display: 'flex', flexDirection: 'column', gap: '6px' }}>
                  {plan.fallbacks.map((fb, idx) => (
                    <div key={idx} style={{ fontSize: '11px', color: '#64748B' }}>
                      <strong style={{ color: '#0F172A' }}>If {fb.condition}:</strong> {fb.action}
                    </div>
                  ))}
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      )}
    </motion.div>
  );
}
