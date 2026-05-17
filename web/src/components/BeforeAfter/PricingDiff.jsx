import React from 'react';
import { motion } from 'framer-motion';

export function PricingDiff({ oldPrice, newPrice, currency = 'PKR' }) {
  if (oldPrice == null && newPrice == null) {
    return <div style={{ fontSize: '14px', color: '#94A3B8' }}>—</div>;
  }

  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
      {oldPrice != null && (
        <>
          <span style={{ fontSize: '13px', color: '#94A3B8', textDecoration: 'line-through' }}>
            {currency} {oldPrice}
          </span>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#94A3B8" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
        </>
      )}
      {newPrice != null ? (
        <motion.span 
          initial={{ scale: 0.8, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          style={{ background: '#FEF3C7', color: '#D97706', padding: '4px 8px', borderRadius: '4px', fontSize: '14px', fontWeight: 600 }}
        >
          {currency} {newPrice}
        </motion.span>
      ) : (
        <span style={{ fontSize: '14px', color: '#94A3B8' }}>—</span>
      )}
    </div>
  );
}
