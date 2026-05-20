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
    <div className="flex-1 p-8 overflow-y-auto bg-[#0F172A] text-white">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold">Sales Ledger</h2>
        <div className="bg-slate-800 px-4 py-2 rounded-full border border-slate-700 flex items-center gap-2">
          <svg className="w-4 h-4 text-green-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
          </svg>
          <span className="text-white font-medium text-sm">PKR 116K Today</span>
        </div>
      </div>

      <div className="bg-slate-800/50 rounded-2xl border border-slate-700/50 overflow-hidden shadow-sm">
        <table className="w-full text-left">
          <thead className="bg-slate-900/80 text-slate-400 text-xs uppercase font-semibold">
            <tr>
              <th className="px-6 py-4">Order ID</th>
              <th className="px-6 py-4">Date & Time</th>
              <th className="px-6 py-4">Customer</th>
              <th className="px-6 py-4 text-center">Items</th>
              <th className="px-6 py-4 text-right">Total (PKR)</th>
              <th className="px-6 py-4 text-center">Status</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-700/50">
            {transactions.map(t => {
              let statusColors = '';
              if (t.status === 'Fulfilled') statusColors = 'bg-green-500/20 text-green-400 border border-green-500/30';
              else if (t.status === 'Shipped') statusColors = 'bg-blue-500/20 text-blue-400 border border-blue-500/30';
              else if (t.status === 'Processing') statusColors = 'bg-purple-500/20 text-purple-400 border border-purple-500/30';
              else statusColors = 'bg-amber-500/20 text-amber-400 border border-amber-500/30';

              return (
                <tr key={t.id} className="hover:bg-slate-800/80 transition-colors">
                  <td className="px-6 py-4 font-semibold text-white">{t.id}</td>
                  <td className="px-6 py-4 text-slate-400 text-sm">{t.date}</td>
                  <td className="px-6 py-4 text-slate-300">{t.customer}</td>
                  <td className="px-6 py-4 text-center text-slate-400">{t.items}</td>
                  <td className="px-6 py-4 text-right font-medium text-white">{t.total.toLocaleString()}</td>
                  <td className="px-6 py-4 text-center">
                    <span className={`px-3 py-1 rounded-full text-xs font-bold ${statusColors}`}>
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
