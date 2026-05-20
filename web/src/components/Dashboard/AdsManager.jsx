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
    <div className="flex-1 p-8 overflow-y-auto bg-[#0F172A] text-white">
      <div className="flex justify-between items-center mb-8">
        <h2 className="text-2xl font-bold">Ad Campaigns</h2>
        <div className="bg-slate-800 px-4 py-2 rounded-full border border-slate-700 flex items-center gap-2 text-sm font-semibold">
          <span className="text-slate-400">Daily Spend:</span>
          <span className="text-white">PKR 34,500</span>
        </div>
      </div>

      {isLoading ? (
        <div className="flex justify-center p-12">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
        </div>
      ) : (
        <div className="grid gap-6 max-w-5xl">
          {campaigns.map(c => {
            const isActive = c.active;
            const roas = c.roas || 0;
            const isUnderperforming = roas < 2.0;

            return (
              <div key={c.id} className="bg-slate-800/50 rounded-2xl border border-slate-700/50 p-6 shadow-sm flex items-center justify-between">
                <div className="flex items-center gap-6">
                  <div className={`w-14 h-14 rounded-2xl flex items-center justify-center shrink-0 ${
                    c.network.toLowerCase() === 'meta' 
                      ? 'bg-blue-600/20 text-blue-500 border border-blue-500/30' 
                      : 'bg-red-500/20 text-red-500 border border-red-500/30'
                  }`}>
                    {c.network.toLowerCase() === 'meta' ? (
                      <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 24 24"><path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.469h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.469h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/></svg>
                    ) : (
                      <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 24 24"><path d="M12.48 10.92v3.28h7.84c-.24 1.84-.853 3.187-1.787 4.133-1.147 1.147-2.933 2.4-6.053 2.4-4.827 0-8.6-3.893-8.6-8.72s3.773-8.72 8.6-8.72c2.6 0 4.507 1.027 5.907 2.347l2.307-2.307C18.747 1.44 16.133 0 12.48 0 5.867 0 .307 5.387.307 12s5.56 12 12.173 12c3.573 0 6.267-1.173 8.373-3.36 2.16-2.16 2.84-5.213 2.84-7.667 0-.76-.053-1.467-.173-2.053H12.48z"/></svg>
                    )}
                  </div>
                  <div>
                    <h3 className="text-lg font-bold text-white mb-1">{c.campaign_name}</h3>
                    <div className="flex items-center gap-4 text-sm">
                      <span className="text-slate-400">Daily Spend: <span className="text-white font-medium">PKR {c.spend.toLocaleString()}</span></span>
                      <span className="text-slate-400">Conversions: <span className="text-white font-medium">{c.conversions}</span></span>
                      <span className="text-slate-400">Clicks: <span className="text-white font-medium">{c.clicks}</span></span>
                    </div>
                  </div>
                </div>

                <div className="flex items-center gap-6">
                  <div className="text-right">
                    <div className="text-xs text-slate-400 font-bold uppercase tracking-wider mb-1">ROAS</div>
                    <div className={`text-xl font-bold ${isUnderperforming ? 'text-red-400' : 'text-green-400'}`}>
                      {roas.toFixed(2)}x
                    </div>
                  </div>
                  
                  <div className={`px-4 py-2 rounded-xl text-sm font-bold w-24 text-center border ${
                    isActive 
                      ? 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20' 
                      : 'bg-slate-700/50 text-slate-400 border-slate-600/50'
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
