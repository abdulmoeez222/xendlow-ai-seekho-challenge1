import React from 'react';

export function Sidebar({ currentTab, setCurrentTab }) {
  const tabs = [
    { id: 'chat', label: 'Chat Console', icon: 'M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z' },
    { id: 'store', label: 'Store Dashboard', icon: 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6' },
    { id: 'products', label: 'Products Inventory', icon: 'M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4' },
    { id: 'sales', label: 'Sales Ledger', icon: 'M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z' },
    { id: 'ads', label: 'Ad Campaigns', icon: 'M11 3.055A9.001 9.001 0 1020.945 13H11V3.055z M20.488 9H15V3.512A9.025 9.025 0 0120.488 9z' },
  ];

  return (
    <div className="w-64 bg-[#0A0A0A] border-r border-[#1F1F1F] h-screen sticky top-0 flex flex-col shrink-0">
      <div className="p-6">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 bg-white rounded-lg flex items-center justify-center text-[#0A0A0A]">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
            </svg>
          </div>
          <div>
            <div className="text-white font-semibold text-sm tracking-tight">Insight AI</div>
            <div className="text-[#555555] text-xs font-semibold tracking-wider uppercase">Console</div>
          </div>
        </div>
      </div>
      
      <div className="flex-1 px-3 py-2 space-y-0.5">
        <div className="px-3 mb-2 text-[10px] font-bold text-[#555555] tracking-widest uppercase">
          Navigation
        </div>
        {tabs.map(tab => {
          const isSelected = currentTab === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => setCurrentTab(tab.id)}
              className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-lg transition-all text-xs ${
                isSelected 
                  ? 'bg-[#161616] text-white font-medium border border-[#222222]' 
                  : 'text-[#8C8C8C] hover:bg-[#111111] hover:text-white border border-transparent'
              }`}
            >
              <svg className="w-4 h-4 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d={tab.icon} />
              </svg>
              {tab.label}
            </button>
          );
        })}
      </div>
      
      <div className="p-4 border-t border-[#1F1F1F]">
        <button 
          onClick={() => window.location.reload()}
          className="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-[#8C8C8C] hover:bg-[#161616] hover:text-white transition-all text-xs border border-transparent hover:border-[#222222]"
        >
          <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
          </svg>
          Sign Out
        </button>
      </div>
    </div>
  );
}
