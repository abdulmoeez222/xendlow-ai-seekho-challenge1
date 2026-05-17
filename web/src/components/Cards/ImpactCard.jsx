import React from 'react';
import { motion } from 'framer-motion';
import { MetricCard } from '../shared/MetricCard';
import { usePipelineStore } from '../../store/pipelineStore';

export function ImpactCard({ report }) {
  const reset = usePipelineStore(state => state.reset);

  if (!report) return null;

  const getNum = (val) => {
    const n = Number(val);
    return isNaN(n) ? null : n;
  };

  const revenue = report.projected_revenue_recovery || report.revenueRecovery || report.revenue_recovery || "—";
  
  const reachVal = getNum(report.projected_reach || report.reach || report.customer_reach);
  const reach = reachVal !== null ? `${reachVal.toLocaleString()} users` : "—";

  const simVal = report.simulations_executed || report.simulations || report.actions_executed;
  const sims = simVal ? `${simVal} simulations` : "—";

  const timeVal = getNum(report.execution_time_ms || report.pipeline_time_ms || report.time_ms);
  const time = timeVal !== null ? `${timeVal}ms` : "—";

  const metrics = [
    { label: "Revenue Recovery", value: revenue, icon: "💰", color: "#166534" },
    { label: "Customer Reach",   value: reach, icon: "👥", color: "#1E40AF" },
    { label: "Actions Executed", value: sims, icon: "⚡", color: "#6D28D9" },
    { label: "Pipeline Time",    value: time, icon: "⏱", color: "#92400E" },
  ];

  return (
    <motion.div
      initial={{ opacity: 0, y: 15 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, ease: "easeOut" }}
      style={{ background: '#ffffff', border: '1px solid #E2E8F0', borderRadius: '16px', padding: '20px', width: '100%', marginBottom: '16px' }}
    >
      <div style={{ fontSize: '11px', color: '#94A3B8', letterSpacing: '0.07em', textTransform: 'uppercase', marginBottom: '14px', fontWeight: 500 }}>
        Impact report
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
        {metrics.map((m, idx) => (
          <div key={idx} style={{ background: '#F8FAFC', borderRadius: '12px', padding: '16px' }}>
            <div style={{ fontSize: '20px', marginBottom: '8px' }}>{m.icon}</div>
            <div style={{ fontSize: '11px', color: '#64748B', marginBottom: '4px' }}>{m.label}</div>
            <div style={{ fontSize: '22px', fontWeight: 500, color: m.color }}>{m.value}</div>
          </div>
        ))}
      </div>

      <button
        onClick={reset}
        style={{ width: '100%', padding: '10px', marginTop: '14px', background: '#ffffff', border: '1px solid #E2E8F0', borderRadius: '10px', color: '#64748B', fontSize: '13px', cursor: 'pointer', transition: 'background 0.2s' }}
        onMouseOver={(e) => e.target.style.background = '#F8FAFC'}
        onMouseOut={(e) => e.target.style.background = '#ffffff'}
      >
        Reset Pipeline
      </button>
    </motion.div>
  );
}
