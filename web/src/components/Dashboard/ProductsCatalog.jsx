import React, { useEffect, useState } from 'react';
import { supabase } from '../../lib/supabase';

export function ProductsCatalog() {
  const [products, setProducts] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function fetchProducts() {
      const { data, error } = await supabase.from('shopify_products').select('*').order('sku');
      if (data) setProducts(data);
      setIsLoading(false);
    }
    fetchProducts();
  }, []);

  const lowStockCount = products.filter(p => p.stock_level < 15).length;

  return (
    <div className="flex-1 p-8 overflow-y-auto bg-[#0F172A] text-white">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold">Products Catalog</h2>
      </div>
      
      {lowStockCount > 0 && (
        <div className="mb-6 p-4 bg-red-900/20 border border-red-900/40 rounded-xl flex items-center gap-3">
          <svg className="w-5 h-5 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
          <span className="text-white font-medium">{lowStockCount} SKU near stockout — reorder threshold breached</span>
        </div>
      )}

      {isLoading ? (
        <div className="flex justify-center p-12">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
        </div>
      ) : (
        <div className="bg-slate-800/50 rounded-2xl border border-slate-700/50 overflow-hidden shadow-sm">
          <table className="w-full text-left">
            <thead className="bg-slate-900/80 text-slate-400 text-xs uppercase font-semibold">
              <tr>
                <th className="px-6 py-4">Product</th>
                <th className="px-6 py-4">SKU</th>
                <th className="px-6 py-4">Price</th>
                <th className="px-6 py-4">COGS</th>
                <th className="px-6 py-4">Margin</th>
                <th className="px-6 py-4 text-center">Stock</th>
                <th className="px-6 py-4 text-right">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-700/50">
              {products.map(p => {
                const margin = ((p.current_price - p.cost_of_goods) / p.current_price) * 100;
                const isLowStock = p.stock_level < 15;
                const isAtRisk = p.status.toLowerCase() === 'at risk';
                
                return (
                  <tr key={p.id} className="hover:bg-slate-800/80 transition-colors">
                    <td className="px-6 py-4 font-semibold text-white">{p.name}</td>
                    <td className="px-6 py-4 text-slate-400 text-sm">{p.sku}</td>
                    <td className="px-6 py-4 text-white font-medium">PKR {p.current_price.toLocaleString()}</td>
                    <td className="px-6 py-4 text-slate-400">PKR {p.cost_of_goods.toLocaleString()}</td>
                    <td className={`px-6 py-4 font-semibold ${margin < 20 ? 'text-red-400' : 'text-green-400'}`}>
                      {margin.toFixed(0)}%
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className={`px-3 py-1 rounded-full text-xs font-bold ${
                        isLowStock ? 'bg-red-500/20 text-red-500 border border-red-500/30' : 'text-slate-300'
                      }`}>
                        {p.stock_level}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <span className={`px-3 py-1 rounded-full text-xs font-bold ${
                        isAtRisk ? 'bg-red-500/20 text-red-500 border border-red-500/30' : 'bg-green-500/20 text-green-400 border border-green-500/30'
                      }`}>
                        {p.status}
                      </span>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
