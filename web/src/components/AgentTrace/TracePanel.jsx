import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { usePipelineStore } from '../../store/pipelineStore';
import { Light as SyntaxHighlighter } from 'react-syntax-highlighter';
import json from 'react-syntax-highlighter/dist/esm/languages/hljs/json';
import { githubGist } from 'react-syntax-highlighter/dist/esm/styles/hljs';

SyntaxHighlighter.registerLanguage('json', json);

export function TracePanel() {
  const [isExpanded, setIsExpanded] = useState(false);
  const signals = usePipelineStore(state => state.signals);
  const insightReport = usePipelineStore(state => state.insightReport);
  const actionPlan = usePipelineStore(state => state.actionPlan);
  const executionLog = usePipelineStore(state => state.executionLog);
  const finalReport = usePipelineStore(state => state.finalReport);

  const agentSections = [
    { key: 'ingestor_log', label: 'Ingestor Log', data: signals },
    { key: 'analyst_log', label: 'Analyst Log', data: insightReport },
    { key: 'planner_log', label: 'Planner Log', data: actionPlan },
    { key: 'executor_log', label: 'Executor Log', data: executionLog },
    { key: 'reporter_log', label: 'Reporter Log', data: finalReport },
  ];

  // If we haven't even started, don't show the panel
  if (!signals && !executionLog) return null;

  return (
    <div style={{ background: '#0F172A', borderRadius: '12px', padding: '14px 20px', border: 'none', overflow: 'hidden' }}>
      <button
        onClick={() => setIsExpanded(!isExpanded)}
        style={{ width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'space-between', background: 'transparent', border: 'none', cursor: 'pointer', padding: 0 }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#7DD3FC" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="4 17 10 11 4 5"></polyline><line x1="12" y1="19" x2="20" y2="19"></line></svg>
          <h3 style={{ color: '#F8FAFC', fontSize: '13px', fontWeight: 500, margin: 0 }}>Agent Trace — Antigravity Logs</h3>
        </div>
        <div style={{ background: '#1E293B', color: '#475569', border: '1px solid #334155', borderRadius: '8px', padding: '4px 12px', fontSize: '12px' }}>
          {isExpanded ? 'Collapse' : 'Expand'}
        </div>
      </button>

      <AnimatePresence>
        {isExpanded && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.3 }}
            style={{ background: '#0F172A', borderRadius: '0 0 12px 12px', borderTop: '1px solid #1E293B', marginTop: '14px', paddingTop: '14px' }}
          >
            <div style={{ maxHeight: '600px', overflowY: 'auto' }}>
              {agentSections.map((section) => {
                if (!section.data) return null;
                
                return (
                  <div key={section.key} style={{ marginBottom: '16px' }}>
                    <h4 style={{ fontSize: '11px', fontWeight: 600, color: '#475569', textTransform: 'uppercase', letterSpacing: '0.07em', marginBottom: '8px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <span style={{ width: '6px', height: '6px', borderRadius: '50%', background: '#7DD3FC' }}></span>
                      {section.label}
                    </h4>
                    <div data-testid="syntax-highlighter" style={{ fontSize: '11px', lineHeight: 1.8, fontFamily: 'monospace', color: '#F8FAFC', whiteSpace: 'pre-wrap' }}>
                      {JSON.stringify(section.data, null, 2)}
                    </div>
                  </div>
                );
              })}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
