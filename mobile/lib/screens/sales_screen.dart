import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  // Mock order data matching the store scale
  final List<Map<String, dynamic>> _orders = [
    {"id": "ORD-4819", "name": "Ayesha Khan", "date": "May 20, 2026", "amount": 28000.0, "city": "Lahore", "carrier": "TCS", "status": "Delivered", "items": "Smart Watch Pro"},
    {"id": "ORD-4818", "name": "Zubair Ahmed", "date": "May 20, 2026", "amount": 3500.0, "city": "Karachi", "carrier": "Leopards", "status": "In Transit", "items": "Wireless Charger"},
    {"id": "ORD-4817", "name": "Bilal Siddiqui", "date": "May 19, 2026", "amount": 15000.0, "city": "Islamabad", "carrier": "TCS", "status": "Dispatched", "items": "Premium Headphones"},
    {"id": "ORD-4816", "name": "Sana Fatima", "date": "May 19, 2026", "amount": 1200.0, "city": "Faisalabad", "carrier": "TCS", "status": "Delivered", "items": "Phone Case Bundle"},
    {"id": "ORD-4815", "name": "Hamza Ali", "date": "May 18, 2026", "amount": 4800.0, "city": "Rawalpindi", "carrier": "Leopards", "status": "Delivered", "items": "Laptop Stand"},
    {"id": "ORD-4814", "name": "Maryam Nawaz", "date": "May 18, 2026", "amount": 28000.0, "city": "Karachi", "carrier": "Leopards", "status": "Delivered", "items": "Smart Watch Pro"},
    {"id": "ORD-4813", "name": "Usman Sheikh", "date": "May 17, 2026", "amount": 30000.0, "city": "Lahore", "carrier": "TCS", "status": "Delivered", "items": "AC (Deposit)"},
    {"id": "ORD-4812", "name": "Zainab Bibi", "date": "May 17, 2026", "amount": 3500.0, "city": "Lahore", "carrier": "TCS", "status": "Delivered", "items": "Wireless Charger"},
    {"id": "ORD-4811", "name": "Omer Tariq", "date": "May 16, 2026", "amount": 15000.0, "city": "Peshawar", "carrier": "TCS", "status": "Delivered", "items": "Premium Headphones"},
    {"id": "ORD-4810", "name": "Amna Malik", "date": "May 16, 2026", "amount": 1200.0, "city": "Multan", "carrier": "Leopards", "status": "Delivered", "items": "Phone Case Bundle"}
  ];

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.greenAccent;
      case 'in transit':
        return Colors.blueAccent;
      case 'dispatched':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      drawer: const AppDrawer(currentRoute: 'sales'),
      appBar: AppBar(
        title: const Text(
          'Sales & Order Log',
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
      body: Column(
        children: [
          // Brief Statistics Bar
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Total Orders', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    SizedBox(height: 4),
                    Text('384', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                VerticalDivider(color: Colors.grey),
                Column(
                  children: [
                    Text('Avg Order Value', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    SizedBox(height: 4),
                    Text('PKR 6,250', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                VerticalDivider(color: Colors.grey),
                Column(
                  children: [
                    Text('Fulfillment Rate', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    SizedBox(height: 4),
                    Text('98.4%', style: TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final o = _orders[index];
                final String status = o['status'];
                final Color statusColor = _getStatusColor(status);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            o['id'],
                            style: const TextStyle(
                              color: Color(0xFF3B82F6),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            o['date'],
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                o['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${o['items']} · ${o['city']}',
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'PKR ${o['amount'].toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.local_shipping_outlined, color: Colors.grey[400], size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${o['carrier']}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: statusColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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
    );
  }
}
