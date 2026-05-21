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
    <div className="flex-1 p-8 overflow-y-auto bg-[#0A0A0A] text-white">
      <div className="flex justify-between items-center mb-8 border-b border-[#1F1F1F] pb-4">
        <h2 className="text-sm font-semibold tracking-tight uppercase">Products Catalog</h2>
        <span className="text-xs text-[#555555]">{products.length} Items Listed</span>
      </div>
      
      {lowStockCount > 0 && (
        <div className="mb-6 p-4 bg-[#111111] border border-[#222222] rounded-xl flex items-center gap-3">
          <div className="w-2 h-2 rounded-full bg-[#FF9999]" />
          <span className="text-[#8C8C8C] text-xs font-medium">
            {lowStockCount} SKU near stockout — reorder threshold breached
          </span>
        </div>
      )}

      {isLoading ? (
        <div className="flex justify-center p-12">
          <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-white"></div>
        </div>
      ) : (
        <div className="bg-[#111111] rounded-xl border border-[#222222] overflow-hidden shadow-sm">
          <table className="w-full text-left">
            <thead className="bg-[#161616] text-[#555555] text-[10px] uppercase font-bold tracking-wider border-b border-[#222222]">
              <tr>
                <th className="px-6 py-3.5">Product</th>
                <th className="px-6 py-3.5">SKU</th>
                <th className="px-6 py-3.5">Price</th>
                <th className="px-6 py-3.5">COGS</th>
                <th className="px-6 py-3.5">Margin</th>
                <th className="px-6 py-3.5 text-center">Stock</th>
                <th className="px-6 py-3.5 text-right">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#1F1F1F]">
              {products.map(p => {
                const margin = ((p.current_price - p.cost_of_goods) / p.current_price) * 100;
                const isLowStock = p.stock_level < 15;
                const isAtRisk = p.status.toLowerCase() === 'at risk';
                
                return (
                  <tr key={p.id} className="hover:bg-[#161616]/50 transition-colors">
                    <td className="px-6 py-4 text-xs font-semibold text-white">{p.name}</td>
                    <td className="px-6 py-4 text-[#8C8C8C] text-xs font-mono">{p.sku}</td>
                    <td className="px-6 py-4 text-white text-xs font-medium">PKR {p.current_price.toLocaleString()}</td>
                    <td className="px-6 py-4 text-[#8C8C8C] text-xs">PKR {p.cost_of_goods.toLocaleString()}</td>
                    <td className={`px-6 py-4 text-xs font-semibold ${margin < 20 ? 'text-[#FF9999]' : 'text-white'}`}>
                      {margin.toFixed(0)}%
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className={`text-xs font-medium ${
                        isLowStock ? 'text-[#FF9999]' : 'text-[#8C8C8C]'
                      }`}>
                        {p.stock_level}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <span className={`text-xs font-semibold uppercase tracking-wider ${
                        isAtRisk ? 'text-[#FF9999]' : 'text-[#8C8C8C]'
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
