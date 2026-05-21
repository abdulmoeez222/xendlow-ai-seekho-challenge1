import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/products_screen.dart';
import '../screens/sales_screen.dart';
import '../screens/ads_screen.dart';
import '../screens/login_screen.dart';

const _bg            = Color(0xFF0A0A0A);
const _surface       = Color(0xFF111111);
const _border        = Color(0xFF1F1F1F);
const _textPrimary   = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFF8C8C8C);
const _textTertiary  = Color(0xFF444444);

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

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);
    Widget screen;
    switch (route) {
      case 'chat':      screen = const HomeScreen(); break;
      case 'dashboard': screen = const DashboardScreen(); break;
      case 'products':  screen = const ProductsScreen(); break;
      case 'sales':     screen = const SalesScreen(); break;
      case 'ads':       screen = const AdsScreen(); break;
      default: return;
    }
    if (currentRoute == route) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _bg,
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const SizedBox(height: 56),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: _textPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bolt, color: _bg, size: 18),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insight AI',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'E-Commerce Copilot',
                      style: TextStyle(color: _textTertiary, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Section label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              'NAVIGATION',
              style: TextStyle(
                color: _textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 4),

          _NavItem(label: 'Chat Console',     icon: Icons.chat_bubble_outline,  route: 'chat',      current: currentRoute, onTap: () => _navigate(context, 'chat')),
          _NavItem(label: 'Store Dashboard',  icon: Icons.grid_view_outlined,   route: 'dashboard', current: currentRoute, onTap: () => _navigate(context, 'dashboard')),
          _NavItem(label: 'Product Catalog',  icon: Icons.inventory_2_outlined, route: 'products',  current: currentRoute, onTap: () => _navigate(context, 'products')),
          _NavItem(label: 'Sales & Orders',   icon: Icons.receipt_long_outlined, route: 'sales',    current: currentRoute, onTap: () => _navigate(context, 'sales')),
          _NavItem(label: 'Ad Campaigns',     icon: Icons.campaign_outlined,    route: 'ads',       current: currentRoute, onTap: () => _navigate(context, 'ads')),

          const Spacer(),
          Container(height: 1, color: const Color(0xFF1A1A1A)),
          const SizedBox(height: 4),
          _NavItem(
            label: 'Sign Out',
            icon: Icons.logout_rounded,
            route: 'logout',
            current: currentRoute,
            onTap: () => _logout(context),
            isDestructive: true,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  final String current;
  final VoidCallback onTap;
  final bool isDestructive;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.current,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = current == route;
    final Color textColor = isDestructive
        ? _textSecondary
        : isSelected
            ? _textPrimary
            : _textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF161616) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 16),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
