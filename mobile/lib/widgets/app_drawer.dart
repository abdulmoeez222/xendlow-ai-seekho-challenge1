import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/products_screen.dart';
import '../screens/sales_screen.dart';
import '../screens/ads_screen.dart';
import '../screens/login_screen.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String route,
    required VoidCallback onTap,
  }) {
    final isSelected = currentRoute == route;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2563EB).withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF2563EB) : Colors.grey[400],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF2563EB) : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A), // Dark slate
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(
                bottom: BorderSide(color: Color(0xFF334155), width: 1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2563EB), width: 1.5),
                      ),
                      child: const Icon(
                        Icons.rocket_launch_rounded,
                        color: Color(0xFF3B82F6),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Insight AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'E-Commerce Copilot',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'AI Chat Console',
                  route: 'chat',
                  onTap: () {
                    if (currentRoute != 'chat') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Store Dashboard',
                  route: 'dashboard',
                  onTap: () {
                    if (currentRoute != 'dashboard') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Product Catalog',
                  route: 'products',
                  onTap: () {
                    if (currentRoute != 'products') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const ProductsScreen()),
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Sales & Order Log',
                  route: 'sales',
                  onTap: () {
                    if (currentRoute != 'sales') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SalesScreen()),
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.campaign_outlined,
                  title: 'Ads Campaign Manager',
                  route: 'ads',
                  onTap: () {
                    if (currentRoute != 'ads') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const AdsScreen()),
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF334155)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildDrawerItem(
              icon: Icons.logout_rounded,
              title: 'Sign Out',
              route: 'logout',
              onTap: () => _logout(context),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
