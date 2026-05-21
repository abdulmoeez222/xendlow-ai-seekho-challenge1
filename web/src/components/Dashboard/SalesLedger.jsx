import React from 'react';

export function SalesLedger() {
  const transactions = [
    { id: 'ORD-4819', date: '2026-05-20 14:32', customer: 'Ahmed K.', items: 3, total: 12500, status: 'Fulfilled' },
    { id: 'ORD-4818', date: '2026-05-20 14:15', customer: 'Sara M.', items: 1, total: 4200, status: 'Processing' },
    { id: 'ORD-4817', date: '2026-05-20 13:45', customer: 'Ali R.', items: 2, total: 8900, status: 'Fulfilled' },
    { id: 'ORD-4816', date: '2026-05-20 12:30', customer: 'Zainab Q.', items: 5, total: 24500, status: 'Shipped' },
    { id: 'ORD-4815', date: '2026-05-20 11:10', customer: 'Omar F.', items: 1, total: 3100, status: 'Fulfilled' },
    { id: 'ORD-4814', date: '2026-05-20 10:45', customer: 'Fatima H.', items: 4, total: 18200, status: 'Pending' },
    { id: 'ORD-4813', date: '2026-05-20 09:20', customer: 'Bilal J.', items: 2, total: 7500, status: 'Fulfilled' },
    { id: 'ORD-4812', date: '2026-05-19 22:15', customer: 'Hassan A.', items: 1, total: 5400, status: 'Shipped' },
    { id: 'ORD-4811', date: '2026-05-19 20:30', customer: 'Ayesha N.', items: 3, total: 15600, status: 'Fulfilled' },
    { id: 'ORD-4810', date: '2026-05-19 19:45', customer: 'Usman S.', items: 2, total: 9800, status: 'Fulfilled' },
  ];

  return (
    <div className="flex-1 p-8 overflow-y-auto bg-[#0A0A0A] text-white">
      <div className="flex justify-between items-center mb-8 border-b border-[#1F1F1F] pb-4">
        <h2 className="text-sm font-semibold tracking-tight uppercase">Sales Ledger</h2>
        <div className="bg-[#111111] px-3 py-1 rounded-full border border-[#222222] flex items-center gap-2">
          <span className="text-[#8C8C8C] text-xs font-semibold">PKR 116K Today</span>
        </div>
      </div>

      <div className="bg-[#111111] rounded-xl border border-[#222222] overflow-hidden shadow-sm">
        <table className="w-full text-left">
          <thead className="bg-[#161616] text-[#555555] text-[10px] uppercase font-bold tracking-wider border-b border-[#222222]">
            <tr>
              <th className="px-6 py-3.5">Order ID</th>
              <th className="px-6 py-3.5">Date & Time</th>
              <th className="px-6 py-3.5">Customer</th>
              <th className="px-6 py-3.5 text-center">Items</th>
              <th className="px-6 py-3.5 text-right">Total (PKR)</th>
              <th className="px-6 py-3.5 text-center">Status</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-[#1F1F1F]">
            {transactions.map(t => {
              let statusStyle = 'text-[#8C8C8C]';
              if (t.status === 'Fulfilled') statusStyle = 'text-white font-medium';
              else if (t.status === 'Shipped') statusStyle = 'text-[#8C8C8C]';
              else if (t.status === 'Processing') statusStyle = 'text-[#8C8C8C] animate-pulse';
              else statusStyle = 'text-[#FF9999]';

              return (
                <tr key={t.id} className="hover:bg-[#161616]/50 transition-colors">
                  <td className="px-6 py-4 text-xs font-semibold text-white font-mono">{t.id}</td>
                  <td className="px-6 py-4 text-[#8C8C8C] text-xs">{t.date}</td>
                  <td className="px-6 py-4 text-[#8C8C8C] text-xs">{t.customer}</td>
                  <td className="px-6 py-4 text-center text-[#8C8C8C] text-xs">{t.items}</td>
                  <td className="px-6 py-4 text-right text-xs font-medium text-white">{t.total.toLocaleString()}</td>
                  <td className="px-6 py-4 text-center">
                    <span className={`text-xs uppercase tracking-wider ${statusStyle}`}>
                      {t.status}
                    </span>
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
