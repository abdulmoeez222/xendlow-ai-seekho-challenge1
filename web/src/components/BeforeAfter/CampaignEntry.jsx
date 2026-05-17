import React from 'react';
import { motion } from 'framer-motion';
import { Badge } from '../shared/Badge';

export function CampaignEntry({ campaign }) {
  if (!campaign) {
    return (
      <div className="text-gray-400 text-sm italic py-2 text-center bg-gray-50 rounded-md border border-dashed border-gray-200">
        No active campaigns
      </div>
    );
  }

  const name = campaign.region || campaign.name || campaign.campaignName || campaign.campaign_name || "—";
  const discount = campaign.discount_percent ?? campaign.discountPercent ?? campaign.discount ?? "—";

  return (
    <motion.div
      initial={{ opacity: 0, x: -10 }}
      animate={{ opacity: 1, x: 0 }}
      style={{ background: '#F0FDF4', borderLeft: '3px solid #22C55E', padding: '10px 14px', borderRadius: '0 8px 8px 0', marginBottom: '8px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}
    >
      <div>
        <div style={{ fontWeight: 600, color: '#166534', fontSize: '13px' }}>{name}</div>
        <div style={{ color: '#15803D', fontSize: '11px', marginTop: '2px' }}>{discount}% Discount</div>
      </div>
      <div style={{ background: '#DCFCE7', color: '#16A34A', fontSize: '10px', fontWeight: 600, padding: '3px 8px', borderRadius: '12px' }}>
        ACTIVE
      </div>
    </motion.div>
  );
}
