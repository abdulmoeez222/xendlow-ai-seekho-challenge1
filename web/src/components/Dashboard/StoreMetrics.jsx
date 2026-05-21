import React from 'react';

export function StoreMetrics() {
  return (
    <div className="flex-1 p-8 overflow-y-auto bg-[#0A0A0A] text-white">
      <div className="flex justify-between items-center mb-8 border-b border-[#1F1F1F] pb-4">
        <h2 className="text-sm font-semibold tracking-tight uppercase">Store Metrics</h2>
        <span className="text-xs text-[#555555]">Realtime Dashboard</span>
      </div>
      
      <div className="grid grid-cols-2 gap-4 mb-8 max-w-4xl">
        <div className="p-5 bg-[#111111] rounded-xl border border-[#222222] shadow-sm">
          <div className="text-[#8C8C8C] text-xs font-semibold uppercase tracking-wider mb-2">Revenue</div>
          <div className="text-2xl font-bold tracking-tight text-white">PKR 2.4M</div>
          <div className="mt-2 flex items-center text-[#6EE7B7] text-xs font-semibold">
            <svg className="w-3.5 h-3.5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 10l7-7m0 0l7 7m-7-7v18" />
            </svg>
            +12.4%
          </div>
        </div>

        <div className="p-5 bg-[#111111] rounded-xl border border-[#222222] shadow-sm">
          <div className="text-[#8C8C8C] text-xs font-semibold uppercase tracking-wider mb-2">Ad Costs</div>
          <div className="text-2xl font-bold tracking-tight text-white">PKR 850K</div>
          <div className="mt-2 flex items-center text-[#FF9999] text-xs font-semibold">
            <svg className="w-3.5 h-3.5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 10l7-7m0 0l7 7m-7-7v18" />
            </svg>
            +8.2%
          </div>
        </div>

        <div className="p-5 bg-[#111111] rounded-xl border border-[#222222] shadow-sm">
          <div className="text-[#8C8C8C] text-xs font-semibold uppercase tracking-wider mb-2">Net Profit</div>
          <div className="text-2xl font-bold tracking-tight text-white">PKR 1.2M</div>
          <div className="mt-2 flex items-center text-[#6EE7B7] text-xs font-semibold">
            <svg className="w-3.5 h-3.5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 10l7-7m0 0l7 7m-7-7v18" />
            </svg>
            +15.1%
          </div>
        </div>

        <div className="p-5 bg-[#111111] rounded-xl border border-[#222222] shadow-sm">
          <div className="text-[#8C8C8C] text-xs font-semibold uppercase tracking-wider mb-2">Conversion Rate</div>
          <div className="text-2xl font-bold tracking-tight text-white">3.2%</div>
          <div className="mt-2 flex items-center text-[#FF9999] text-xs font-semibold">
            <svg className="w-3.5 h-3.5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M19 14l-7 7m0 0l-7-7m7 7V3" />
            </svg>
            -0.4pp
          </div>
        </div>
      </div>

      <div className="max-w-4xl p-5 bg-[#111111] rounded-xl border border-[#222222] shadow-sm">
        <h3 className="text-sm font-semibold tracking-tight text-white mb-0.5">Revenue This Week</h3>
        <p className="text-[#8C8C8C] text-xs mb-8">Last 7 Days · May 2026</p>
        
        <div className="h-44 flex items-end justify-around px-8 pb-2">
          {[
            { day: 'M', h: '35%' },
            { day: 'T', h: '48%' },
            { day: 'W', h: '62%' },
            { day: 'T', h: '55%' },
            { day: 'F', h: '95%', active: true },
            { day: 'S', h: '75%' },
            { day: 'S', h: '40%' }
          ].map((bar, i) => (
            <div key={i} className="flex flex-col items-center gap-3 w-12 h-full justify-end">
              <div 
                className={`w-4 rounded-t-sm transition-all duration-700 ${
                  bar.active ? 'bg-white' : 'bg-[#222222]'
                }`} 
                style={{ height: bar.h }}
              ></div>
              <div className={`text-xs ${bar.active ? 'text-white font-bold' : 'text-[#555555]'}`}>
                {bar.day}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
