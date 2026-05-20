import React from 'react';

export function StoreMetrics() {
  return (
    <div className="flex-1 p-8 overflow-y-auto bg-[#0F172A] text-white">
      <h2 className="text-2xl font-bold mb-6">Store Dashboard</h2>
      
      <div className="grid grid-cols-2 gap-6 mb-8 max-w-4xl">
        <div className="p-6 bg-slate-800/50 rounded-2xl border border-slate-700/50 shadow-sm">
          <div className="text-slate-400 text-sm font-medium mb-2">Revenue</div>
          <div className="text-3xl font-bold tracking-tight">PKR 2.4M</div>
          <div className="mt-3 flex items-center text-green-400 text-sm font-semibold">
            <svg className="w-4 h-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 10l7-7m0 0l7 7m-7-7v18" />
            </svg>
            +12.4%
          </div>
        </div>

        <div className="p-6 bg-slate-800/50 rounded-2xl border border-slate-700/50 shadow-sm">
          <div className="text-slate-400 text-sm font-medium mb-2">Ad Costs</div>
          <div className="text-3xl font-bold tracking-tight">PKR 850K</div>
          <div className="mt-3 flex items-center text-red-400 text-sm font-semibold">
            <svg className="w-4 h-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 10l7-7m0 0l7 7m-7-7v18" />
            </svg>
            +8.2%
          </div>
        </div>

        <div className="p-6 bg-slate-800/50 rounded-2xl border border-slate-700/50 shadow-sm">
          <div className="text-slate-400 text-sm font-medium mb-2">Net Profit</div>
          <div className="text-3xl font-bold tracking-tight">PKR 1.2M</div>
          <div className="mt-3 flex items-center text-green-400 text-sm font-semibold">
            <svg className="w-4 h-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 10l7-7m0 0l7 7m-7-7v18" />
            </svg>
            +15.1%
          </div>
        </div>

        <div className="p-6 bg-slate-800/50 rounded-2xl border border-slate-700/50 shadow-sm">
          <div className="text-slate-400 text-sm font-medium mb-2">Conversion Rate</div>
          <div className="text-3xl font-bold tracking-tight">3.2%</div>
          <div className="mt-3 flex items-center text-red-400 text-sm font-semibold">
            <svg className="w-4 h-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M19 14l-7 7m0 0l-7-7m7 7V3" />
            </svg>
            -0.4pp
          </div>
        </div>
      </div>

      <div className="max-w-4xl p-6 bg-slate-800/30 rounded-2xl border border-slate-700/50 shadow-sm">
        <h3 className="text-lg font-bold mb-1">Revenue this week</h3>
        <p className="text-slate-400 text-sm mb-8">Last 30 days · May 2026</p>
        
        <div className="h-64 flex items-end justify-around px-8 pb-4">
          {[
            { day: 'M', h: '35%' },
            { day: 'T', h: '48%' },
            { day: 'W', h: '62%' },
            { day: 'T', h: '55%' },
            { day: 'F', h: '95%', active: true },
            { day: 'S', h: '75%' },
            { day: 'S', h: '40%' }
          ].map((bar, i) => (
            <div key={i} className="flex flex-col items-center gap-4 w-12 h-full justify-end">
              <div 
                className={`w-full rounded-md transition-all duration-1000 ${
                  bar.active ? 'bg-blue-500 shadow-[0_0_15px_rgba(59,130,246,0.5)]' : 'bg-slate-700'
                }`} 
                style={{ height: bar.h }}
              ></div>
              <div className={`text-sm ${bar.active ? 'text-white font-bold' : 'text-slate-500'}`}>
                {bar.day}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
