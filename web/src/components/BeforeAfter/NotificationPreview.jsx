import React from 'react';
import { motion } from 'framer-motion';

export function NotificationPreview({ notification }) {
  if (!notification) {
    return (
      <div className="text-gray-400 text-sm italic py-2 text-center bg-gray-50 rounded-md border border-dashed border-gray-200">
        None queued
      </div>
    );
  }

  // Bug 1 fix: backend sends message_body, not message
  const messageText = notification.message_body ?? notification.message ?? '';

  return (
    <motion.div
      initial={{ opacity: 0, y: 10, scale: 0.95 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      style={{ background: '#DCFCE7', borderRadius: '4px 12px 12px 12px', padding: '10px 14px', fontSize: '12px', color: '#166534', lineHeight: 1.6, maxWidth: '24rem' }}
    >
      <div style={{ whiteSpace: 'pre-wrap' }}>{messageText}</div>
      <div style={{ fontSize: '10px', color: '#86EFAC', textAlign: 'right', marginTop: '4px' }}>✓✓ Delivered</div>
    </motion.div>
  );
}