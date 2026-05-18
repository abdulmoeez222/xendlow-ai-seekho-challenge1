import React from 'react';
import { motion } from 'framer-motion';
import { Badge } from '../shared/Badge';

export function InsightCard({ report }) {
  if (!report) return null;

  const getSeverityLevel = (score) => {
    const num = Number(score) || 0;
    if (num <= 4) return { label: `LOW (${num}/10)`, bg: '#D1FAE5', text: '#065F46', testClass: 'text-emerald-800', pulse: false };
    if (num <= 7) return { label: `MEDIUM (${num}/10)`, bg: '#FEF3C7', text: '#92400E', testClass: 'text-amber-800', pulse: false };
    return { label: `HIGH (${num}/10)`, bg: '#FEE2E2', text: '#991B1B', testClass: 'text-red-800 animate-pulse', pulse: true };
  };

  const score = report.severity_score ?? report.severityScore ?? report.severity ?? 0;
  const severity = getSeverityLevel(score);

  const insightText = report.primary_insight || report.primaryInsight || report.insight || "—";
  const rawChain = report.causal_chain || report.causalChain || report.chain || [];
  const causalChain = Array.isArray(rawChain) ? rawChain : (typeof rawChain === 'string' ? rawChain.split(/\s*(?:→|->|—>|➜)\s*/).filter(Boolean) : []);
  const rawDomains = report.affected_domains || report.affectedDomains || report.domains || [];
  const domains = Array.isArray(rawDomains) ? rawDomains : (typeof rawDomains === 'string' ? rawDomains.split(/[,;]/).map(s => s.trim()).filter(Boolean) : []);

  return (
    <motion.div
      initial={{ opacity: 0, y: 15 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4, ease: "easeOut" }}
      style={{ background: '#ffffff', border: '1px solid #E2E8F0', borderRadius: '16px', padding: '20px' }}
    >
      <div style={{ fontSize: '11px', color: '#94A3B8', letterSpacing: '0.07em', textTransform: 'uppercase', marginBottom: '14px', fontWeight: 500 }}>
        Analyst output
      </div>

      <div style={{ borderLeft: '4px solid #1D4ED8', paddingLeft: '14px', borderRadius: 0, fontSize: '17px', fontWeight: 500, color: '#0F172A', lineHeight: 1.5, marginBottom: '14px' }}>
        {insightText}
      </div>

      <div className="flex flex-wrap items-center gap-2 mb-4">
        <div className={severity.testClass} style={{ background: severity.bg, color: severity.text, borderRadius: '20px', padding: '4px 12px', fontSize: '11px', fontWeight: 500, display: 'flex', alignItems: 'center', gap: '6px' }}>
          {severity.pulse && (
            <span className="relative flex h-1.5 w-1.5">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-1.5 w-1.5 bg-red-500"></span>
            </span>
          )}
          {severity.label}
        </div>
        {domains.map((domain, idx) => (
          <span key={idx} style={{ background: '#EFF6FF', color: '#1E40AF', borderRadius: '20px', padding: '4px 10px', fontSize: '11px', fontWeight: 500 }}>
            {domain}
          </span>
        ))}
      </div>

      {causalChain.length > 0 && (
        <div>
          <div className="flex flex-wrap items-center gap-1.5 mt-2">
            {causalChain.map((segment, idx) => (
              <React.Fragment key={idx}>
                <div style={{ background: '#EFF6FF', color: '#1E40AF', fontSize: '11px', fontWeight: 500, padding: '4px 12px', borderRadius: '20px' }}>
                  {segment}
                </div>
                {idx < causalChain.length - 1 && (
                  <div style={{ color: '#CBD5E1', fontSize: '13px' }}>→</div>
                )}
              </React.Fragment>
            ))}
          </div>
        </div>
      )}
    </motion.div>
  );
}
