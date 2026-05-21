import React, { useEffect, useState } from 'react';
import { supabase } from '../../lib/supabase';

export function AdsManager() {
  const [campaigns, setCampaigns] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function fetchCampaigns() {
      const { data, error } = await supabase.from('marketing_campaigns').select('*').order('campaign_name');
      if (data) setCampaigns(data);
      setIsLoading(false);
    }
    fetchCampaigns();
  }, []);

  return (
    <div className="flex-1 p-8 overflow-y-auto bg-[#0A0A0A] text-white">
      <div className="flex justify-between items-center mb-8 border-b border-[#1F1F1F] pb-4">
        <h2 className="text-sm font-semibold tracking-tight uppercase">Ad Campaigns</h2>
        <div className="bg-[#111111] px-3 py-1 rounded-full border border-[#222222] flex items-center gap-2 text-xs">
          <span className="text-[#555555]">Daily Spend:</span>
          <span className="text-white font-semibold">PKR 34,500</span>
        </div>
      </div>

      {isLoading ? (
        <div className="flex justify-center p-12">
          <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-white"></div>
        </div>
      ) : (
        <div className="grid gap-4 max-w-4xl">
          {campaigns.map(c => {
            const isActive = c.active;
            const roas = c.roas || 0;
            const isUnderperforming = roas < 2.0;

            return (
              <div key={c.id} className="bg-[#111111] rounded-xl border border-[#222222] p-5 flex items-center justify-between transition-all hover:border-[#333333]">
                <div className="flex items-center gap-5">
                  <div className="w-10 h-10 rounded-lg flex items-center justify-center shrink-0 bg-[#161616] border border-[#222222] text-[#8C8C8C]">
                    {c.network.toLowerCase() === 'meta' ? (
                      <svg className="w-5 h-5 fill-current" viewBox="0 0 24 24"><path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.469h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.469h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/></svg>
                    ) : (
                      <svg className="w-5 h-5 fill-current" viewBox="0 0 24 24"><path d="M12.48 10.92v3.28h7.84c-.24 1.84-.853 3.187-1.787 4.133-1.147 1.147-2.933 2.4-6.053 2.4-4.827 0-8.6-3.893-8.6-8.72s3.773-8.72 8.6-8.72c2.6 0 4.507 1.027 5.907 2.347l2.307-2.307C18.747 1.44 16.133 0 12.48 0 5.867 0 .307 5.387.307 12s5.56 12 12.173 12c3.573 0 6.267-1.173 8.373-3.36 2.16-2.16 2.84-5.213 2.84-7.667 0-.76-.053-1.467-.173-2.053H12.48z"/></svg>
                    )}
                  </div>
                  <div>
                    <h3 className="text-xs font-semibold text-white mb-1.5">{c.campaign_name}</h3>
                    <div className="flex items-center gap-4 text-xs">
                      <span className="text-[#555555]">Daily Spend: <span className="text-[#8C8C8C]">PKR {c.spend.toLocaleString()}</span></span>
                      <span className="text-[#555555]">Conversions: <span className="text-[#8C8C8C]">{c.conversions}</span></span>
                      <span className="text-[#555555]">Clicks: <span className="text-[#8C8C8C]">{c.clicks}</span></span>
                    </div>
                  </div>
                </div>

                <div className="flex items-center gap-6">
                  <div className="text-right">
                    <div className="text-[10px] text-[#555555] font-bold uppercase tracking-wider mb-0.5">ROAS</div>
                    <div className={`text-sm font-bold ${isUnderperforming ? 'text-[#FF9999]' : 'text-white'}`}>
                      {roas.toFixed(2)}x
                    </div>
                  </div>
                  
                  <div className={`px-3 py-1.5 rounded-lg text-[10px] font-bold w-20 text-center border ${
                    isActive 
                      ? 'bg-transparent text-white border-[#444444]' 
                      : 'bg-transparent text-[#555555] border-[#222222]'
                  }`}>
                    {isActive ? 'ACTIVE' : 'PAUSED'}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
