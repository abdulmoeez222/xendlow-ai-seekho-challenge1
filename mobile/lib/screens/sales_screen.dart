import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

const _bg            = Color(0xFF0A0A0A);
const _surface       = Color(0xFF111111);
const _border        = Color(0xFF1F1F1F);
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

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final List<Map<String, dynamic>> _orders = [
    {"id": "ORD-4819", "name": "Ayesha Khan",    "date": "May 20", "amount": 28000.0, "city": "Lahore",     "carrier": "TCS",      "status": "Delivered",  "items": "Smart Watch Pro"},
    {"id": "ORD-4818", "name": "Zubair Ahmed",   "date": "May 20", "amount": 3500.0,  "city": "Karachi",    "carrier": "Leopards", "status": "In Transit", "items": "Wireless Charger"},
    {"id": "ORD-4817", "name": "Bilal Siddiqui", "date": "May 19", "amount": 15000.0, "city": "Islamabad",  "carrier": "TCS",      "status": "Dispatched", "items": "Premium Headphones"},
    {"id": "ORD-4816", "name": "Sana Fatima",    "date": "May 19", "amount": 1200.0,  "city": "Faisalabad", "carrier": "TCS",      "status": "Delivered",  "items": "Phone Case Bundle"},
    {"id": "ORD-4815", "name": "Hamza Ali",      "date": "May 18", "amount": 4800.0,  "city": "Rawalpindi", "carrier": "Leopards", "status": "Delivered",  "items": "Laptop Stand"},
    {"id": "ORD-4814", "name": "Maryam Nawaz",   "date": "May 18", "amount": 28000.0, "city": "Karachi",    "carrier": "Leopards", "status": "Delivered",  "items": "Smart Watch Pro"},
    {"id": "ORD-4813", "name": "Usman Sheikh",   "date": "May 17", "amount": 30000.0, "city": "Lahore",     "carrier": "TCS",      "status": "Delivered",  "items": "AC (Deposit)"},
    {"id": "ORD-4812", "name": "Zainab Bibi",    "date": "May 17", "amount": 3500.0,  "city": "Lahore",     "carrier": "TCS",      "status": "Delivered",  "items": "Wireless Charger"},
    {"id": "ORD-4811", "name": "Omer Tariq",     "date": "May 16", "amount": 15000.0, "city": "Peshawar",   "carrier": "TCS",      "status": "Delivered",  "items": "Premium Headphones"},
    {"id": "ORD-4810", "name": "Amna Malik",     "date": "May 16", "amount": 1200.0,  "city": "Multan",     "carrier": "Leopards", "status": "Delivered",  "items": "Phone Case Bundle"},
  ];

  Color _statusDot(String s) {
    switch (s.toLowerCase()) {
      case 'delivered':  return const Color(0xFF6EE7B7);
      case 'in transit': return const Color(0xFFFFFFFF);
      case 'dispatched': return const Color(0xFFD4D4D4);
      default:           return _textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      drawer: const AppDrawer(currentRoute: 'sales'),
      appBar: _appBar('Sales & Orders'),
      body: Column(
        children: [
          // Stats strip
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Strip(label: 'Total Orders',   value: '384'),
                  Container(width: 1, height: 28, color: _border),
                  _Strip(label: 'Avg Order',      value: 'PKR 6,250'),
                  Container(width: 1, height: 28, color: _border),
                  _Strip(label: 'Fulfillment',    value: '98.4%'),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: _orders.length,
              itemBuilder: (ctx, i) {
                final o = _orders[i];
                final dot = _statusDot(o['status']);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left col
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  o['id'],
                                  style: const TextStyle(color: _textTertiary, fontSize: 11, fontFamily: 'monospace'),
                                ),
                                const SizedBox(width: 8),
                                Text(o['date'], style: const TextStyle(color: _textTertiary, fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              o['name'],
                              style: const TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${o['items']} · ${o['city']}',
                              style: const TextStyle(color: _textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // Right col
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'PKR ${(o['amount'] as double).toStringAsFixed(0)}',
                            style: const TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(o['carrier'], style: const TextStyle(color: _textTertiary, fontSize: 11)),
                              const SizedBox(width: 6),
                              Container(
                                width: 5, height: 5,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: dot),
                              ),
                              const SizedBox(width: 4),
                              Text(o['status'], style: TextStyle(color: dot, fontSize: 11, fontWeight: FontWeight.w500)),
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
    );
  }
}

class _Strip extends StatelessWidget {
  final String label;
  final String value;
  const _Strip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: _textTertiary, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
