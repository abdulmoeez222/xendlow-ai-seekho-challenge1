import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _products = [];
  int _lowStockCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final res = await _supabase
          .from('shopify_products')
          .select()
          .order('sku', ascending: true);
      
      final list = res as List<dynamic>? ?? [];
      int lowStock = 0;
      for (var p in list) {
        final stock = p['stock_level'] ?? 0;
        if (stock < 15) {
          lowStock++;
        }
      }
      
      if (mounted) {
        setState(() {
          _products = list;
          _lowStockCount = lowStock;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      drawer: const AppDrawer(currentRoute: 'products'),
      appBar: AppBar(
        title: const Text(
          'Products Catalog',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: const Row(
              children: [
                Icon(Icons.dark_mode_rounded, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  '15',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProducts,
        child: Column(
          children: [
            if (_isLoading)
              const LinearProgressIndicator(color: Color(0xFF2563EB), backgroundColor: Color(0xFF1E293B)),
            
            // Warnings Banner
            if (_lowStockCount > 0)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF7F1D1D).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB91C1C).withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$_lowStockCount SKU near stockout — reorder threshold breached',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            
            Expanded(
              child: _products.isEmpty && !_isLoading
                  ? const Center(
                      child: Text(
                        'No products found.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final p = _products[index];
                        final double price = (p['current_price'] ?? 0).toDouble();
                        final double cogs = (p['cost_of_goods'] ?? 0).toDouble();
                        final double marginPct = price > 0 ? (price - cogs) / price : 0;
                        final int stock = p['stock_level'] ?? 0;
                        final String name = p['name'] ?? '';
                        final String sku = p['sku'] ?? '';
                        final String status = p['status'] ?? 'Active';

                        // Decide colors based on inventory metrics
                        Color stockColor = Colors.greenAccent;
                        if (stock < 5) {
                          stockColor = Colors.redAccent;
                        } else if (stock < 15) {
                          stockColor = Colors.orangeAccent;
                        }

                        Color statusColor = status.toLowerCase() == 'at risk' ? Colors.redAccent : Colors.greenAccent;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: statusColor.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'SKU: $sku',
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Price', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                      const SizedBox(height: 2),
                                      Text(
                                        'PKR ${price.toStringAsFixed(0)}',
                                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('COGS', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                      const SizedBox(height: 2),
                                      Text(
                                        'PKR ${cogs.toStringAsFixed(0)}',
                                        style: const TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Margin', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${(marginPct * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          color: marginPct < 0.2 ? Colors.redAccent : Colors.greenAccent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Stock', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                      const SizedBox(height: 2),
                                      Text(
                                        stock.toString(),
                                        style: TextStyle(
                                          color: stockColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
