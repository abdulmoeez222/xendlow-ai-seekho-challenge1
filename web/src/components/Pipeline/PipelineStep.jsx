import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { AgentIcon } from './AgentIcon';
import { Badge } from '../shared/Badge';

export function PipelineStep({ step, status }) {
  const isDone = status === 'done';
  const isRunning = status === 'running';
  const isPending = status === 'pending';

  let borderColor = '#E2E8F0';
  let bgColor = '#ffffff';
  let iconBg = '#F1F5F9';
  let badgeBg = '#F1F5F9';
  let badgeColor = '#94A3B8';
  let badgeText = 'Pending';

  if (isDone) {
    borderColor = '#BBF7D0';
    bgColor = '#F0FDF4';
    iconBg = '#DCFCE7';
    badgeBg = '#DCFCE7';
    badgeColor = '#166534';
    badgeText = 'Complete';
  } else if (isRunning) {
    borderColor = '#BFDBFE';
    bgColor = '#EFF6FF';
    iconBg = '#DBEAFE';
    badgeBg = '#DBEAFE';
    badgeColor = '#1E40AF';
    badgeText = 'Running';
  }

  return (
    <div
      style={{
        background: bgColor,
        border: `1px solid ${borderColor}`,
        borderRadius: '12px',
        padding: '14px 12px',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '6px',
        opacity: isPending ? 0.5 : 1,
        transition: 'all 0.3s'
      }}
    >
      <div style={{ background: iconBg, width: '36px', height: '36px', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '18px' }}>
        {step.icon}
      </div>
      
      <div style={{ fontSize: '11px', fontWeight: 500, color: '#1E293B', textAlign: 'center' }}>
        {step.name}
      </div>

      <div style={{ background: badgeBg, color: badgeColor, fontSize: '10px', padding: '2px 8px', borderRadius: '20px', display: 'flex', alignItems: 'center', gap: '4px', fontWeight: 500 }}>
        {isRunning && (
          <span className="relative flex h-1.5 w-1.5">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-blue-400 opacity-75"></span>
            <span className="relative inline-flex rounded-full h-1.5 w-1.5 bg-blue-500"></span>
          </span>
        )}
        {badgeText}
      </div>
    </div>
  );
}
