import 'package:flutter/material.dart';

class OperationsPage extends StatelessWidget {
  final void Function(String route)? onNavigate;

  OperationsPage({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 600 ? 20 : 12,
            vertical: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 24 : 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Operations Dashboard",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width > 600 ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Manage your restaurant operations efficiently",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width > 600 ? 14 : 12,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Actions Section
                Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600 ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Access frequently used features",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600 ? 14 : 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                _buildGridSection(context, _topItems),
                const SizedBox(height: 32),

                // Configuration Section
                Text(
                  "Restaurant Configuration",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600 ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Customize settings and preferences",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600 ? 14 : 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                _buildGridSection(context, _bottomItems),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridSection(
      BuildContext context, List<Map<String, dynamic>> items) {
    final Map<String, String> routeMap = {
      'Menu': 'menu_items',
      'Orders': 'orders',
      'Online Orders': 'online-orders',
      'KOTs': 'kots',
      'Customers': 'customers',
      'Cash Flow': 'cash-flow',
      'Expense': 'expense',
      'Withdrawal': 'withdrawal',
      'Cash Top-Up': 'cash-top-up',
      'Inventory': 'inventory',
      'Notification': 'notification',
      'Table': 'table',
      'Reconciliation': 'reconciliation',
      'Manual Sync': 'manual-sync',
      'Help': 'help',
      'Live View': 'live-view',
      'Due Payment': 'due-payment',
      'Language Profiles': 'language-profiles',
      'Billing User Profile': 'billing-user-profile',
      'Currency Conversion': 'currency-conversion',
      'Feedback': 'feedback',
      'Delivery Boys': 'delivery-boys',
      'LED Display': 'led-display',
      'Dual Screen': 'dual-screen',
      'Marketplace': 'marketplace',
      'Bill / KOT Print': 'bill-kot-print',
      'Tax': 'tax',
      'Discount': 'discount',
      'Billing Screen': 'billing-screen',
      'Settings': 'settings',
      'Menu Item On/Off': 'menu-toggle',
      'Service Renewal': 'service-renewal',
      'Custom Order Status': 'order-status',
    };

    // Get color based on category
    Color _getItemColor(String label) {
      // Financial operations
      if (['Cash Flow', 'Expense', 'Withdrawal', 'Cash Top-Up', 'Due Payment', 'Tax'].contains(label)) {
        return const Color(0xFF10B981);
      }
      // Order management
      if (['Orders', 'Online Orders', 'KOTs', 'Custom Order Status'].contains(label)) {
        return const Color(0xFF3B82F6);
      }
      // Settings & Configuration
      if (['Settings', 'Billing Screen', 'Menu Item On/Off', 'Service Renewal'].contains(label)) {
        return const Color(0xFF8B5CF6);
      }
      // Customer & Communication
      if (['Customers', 'Notification', 'Feedback', 'Language Profiles'].contains(label)) {
        return const Color(0xFFF59E0B);
      }
      // Inventory & Menu
      if (['Menu', 'Inventory', 'Marketplace', 'Menu Item On/Off'].contains(label)) {
        return const Color(0xFFEF4444);
      }
      // Default
      return const Color(0xFF6B7280);
    }

    // Calculate responsive parameters
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    double childAspectRatio;
    
    if (screenWidth > 1400) {
      crossAxisCount = 10;
      childAspectRatio = 0.9;
    } else if (screenWidth > 1200) {
      crossAxisCount = 8;
      childAspectRatio = 0.95;
    } else if (screenWidth > 900) {
      crossAxisCount = 6;
      childAspectRatio = 1.0;
    } else if (screenWidth > 700) {
      crossAxisCount = 5;
      childAspectRatio = 1.0;
    } else if (screenWidth > 500) {
      crossAxisCount = 4;
      childAspectRatio = 1.0;
    } else {
      crossAxisCount = 3;
      childAspectRatio = 1.1;
    }

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: items.map((item) {
        final itemColor = _getItemColor(item['label']);
        
        return Material(
          elevation: 0,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              final route = routeMap[item['label']];
              if (route != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onNavigate?.call(route);
                });
              } else {
                debugPrint("Tapped: ${item['label']}");
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: EdgeInsets.all(screenWidth > 500 ? 12 : 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Container
                  Container(
                    padding: EdgeInsets.all(screenWidth > 500 ? 10 : 8),
                    decoration: BoxDecoration(
                      color: itemColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item['icon'],
                      size: screenWidth > 500 ? 24 : 20,
                      color: itemColor,
                    ),
                  ),
                  SizedBox(height: screenWidth > 500 ? 8 : 6),
                  // Label
                  Flexible(
                    child: Text(
                      item['label'],
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: screenWidth > 500 ? 11 : 9,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Sample top section icons
  final List<Map<String, dynamic>> _topItems = [
    {'icon': Icons.receipt_long, 'label': 'Orders'},
    {'icon': Icons.shopping_cart, 'label': 'Online Orders'},
    {'icon': Icons.library_books, 'label': 'KOTs'},
    {'icon': Icons.people, 'label': 'Customers'},
    {'icon': Icons.sync_alt, 'label': 'Cash Flow'},
    {'icon': Icons.money_off, 'label': 'Expense'},
    {'icon': Icons.arrow_upward, 'label': 'Withdrawal'},
    {'icon': Icons.account_balance_wallet, 'label': 'Cash Top-Up'},
    {'icon': Icons.inventory, 'label': 'Inventory'},
    {'icon': Icons.notifications, 'label': 'Notification'},
    {'icon': Icons.table_restaurant, 'label': 'Table'},
    {'icon': Icons.sync, 'label': 'Reconciliation'},
    {'icon': Icons.sync_problem, 'label': 'Manual Sync'},
    {'icon': Icons.help_outline, 'label': 'Help'},
    {'icon': Icons.live_tv, 'label': 'Live View'},
    {'icon': Icons.payments, 'label': 'Due Payment'},
    {'icon': Icons.language, 'label': 'Language Profiles'},
    {'icon': Icons.person, 'label': 'Billing User Profile'},
    {'icon': Icons.currency_exchange, 'label': 'Currency Conversion'},
    {'icon': Icons.feedback, 'label': 'Feedback'},
    {'icon': Icons.delivery_dining, 'label': 'Delivery Boys'},
    {'icon': Icons.display_settings, 'label': 'LED Display'},
    {'icon': Icons.monitor, 'label': 'Dual Screen'},
    {'icon': Icons.shopping_basket, 'label': 'Marketplace'},
  ];

  // Bottom section icons
  final List<Map<String, dynamic>> _bottomItems = [
    {'icon': Icons.menu_book, 'label': 'Menu'},
    {'icon': Icons.print, 'label': 'Bill / KOT Print'},
    {'icon': Icons.account_balance, 'label': 'Tax'},
    {'icon': Icons.local_offer, 'label': 'Discount'},
    {'icon': Icons.screen_share, 'label': 'Billing Screen'},
    {'icon': Icons.settings, 'label': 'Settings'},
    {'icon': Icons.remove_circle_outline, 'label': 'Menu Item On/Off'},
    {'icon': Icons.update, 'label': 'Service Renewal'},
    {'icon': Icons.assignment_turned_in, 'label': 'Custom Order Status'},
  ];
}