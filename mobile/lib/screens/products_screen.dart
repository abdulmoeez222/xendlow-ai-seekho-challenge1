import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart';

const _bg            = Color(0xFF0A0A0A);
const _surface       = Color(0xFF111111);
const _border        = Color(0xFF1F1F1F);
const _borderSubtle  = Color(0xFF161616);
const _textPrimary   = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFF8C8C8C);
const _textTertiary  = Color(0xFF444444);

AppBar _appBar(String title) => AppBar(
  backgroundColor: _bg, elevation: 0, scrolledUnderElevation: 0,
  iconTheme: const IconThemeData(color: _textPrimary),
  title: Text(title, style: const TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
  bottom: const PreferredSize(
    preferredSize: Size.fromHeight(1),
    child: Divider(height: 1, color: Color(0xFF1A1A1A)),
  ),
);

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
  void initState() { super.initState(); _fetchProducts(); }

  Future<void> _fetchProducts() async {
    try {
      final list = (await _supabase.from('shopify_products').select().order('sku')) as List<dynamic>? ?? [];
      int low = 0;
      for (var p in list) if ((p['stock_level'] ?? 0) < 15) low++;
      if (mounted) setState(() { _products = list; _lowStockCount = low; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      drawer: const AppDrawer(currentRoute: 'products'),
      appBar: _appBar('Products'),
      body: RefreshIndicator(
        color: _textPrimary,
        backgroundColor: _surface,
        onRefresh: _fetchProducts,
        child: Column(
          children: [
            if (_isLoading)
              const LinearProgressIndicator(color: _textPrimary, backgroundColor: _borderSubtle, minHeight: 1),

            if (_lowStockCount > 0)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFF9999)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$_lowStockCount SKU near stockout — reorder threshold breached',
                      style: const TextStyle(color: _textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: _products.isEmpty && !_isLoading
                  ? const Center(child: Text('No products found.', style: TextStyle(color: _textTertiary, fontSize: 14)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: _products.length,
                      itemBuilder: (ctx, i) {
                        final p = _products[i];
                        final double price  = (p['current_price'] ?? 0).toDouble();
                        final double cogs   = (p['cost_of_goods']  ?? 0).toDouble();
                        final double margin = price > 0 ? (price - cogs) / price : 0;
                        final int    stock  = p['stock_level'] ?? 0;
                        final String name   = p['name']   ?? '';
                        final String sku    = p['sku']    ?? '';
                        final String status = p['status'] ?? 'Active';
                        final bool   atRisk = status.toLowerCase() == 'at risk' || stock < 5;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _border),
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
                                      style: const TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  if (atRisk)
                                    Container(
                                      width: 6, height: 6,
                                      margin: const EdgeInsets.only(left: 8),
                                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFF9999)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text('SKU: $sku', style: const TextStyle(color: _textTertiary, fontSize: 11)),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _Stat(label: 'Price',  value: 'PKR ${price.toStringAsFixed(0)}'),
                                  _Stat(label: 'COGS',   value: 'PKR ${cogs.toStringAsFixed(0)}'),
                                  _Stat(
                                    label: 'Margin',
                                    value: '${(margin * 100).toStringAsFixed(0)}%',
                                    dimmed: margin < 0.2,
                                  ),
                                  _Stat(
                                    label: 'Stock',
                                    value: stock.toString(),
                                    dimmed: stock < 15,
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

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool dimmed;
  const _Stat({required this.label, required this.value, this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _textTertiary, fontSize: 10)),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: dimmed ? const Color(0xFFFF9999) : _textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
