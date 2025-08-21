import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:posapp/storage/bloc_statemanager.dart';
import 'package:posapp/storage/db_helper.dart';

class POSHeader extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  
  final void Function(String route)? onNavigate;

  const POSHeader({super.key, this.onNavigate}) : preferredSize = const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if screen is small (mobile/tablet)
        bool isSmallScreen = constraints.maxWidth < 768;
        
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.black.withOpacity(0.1),
          surfaceTintColor: Colors.transparent,
          titleSpacing: 0,
          
          // Custom bottom border for subtle separation
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.withOpacity(0.1),
                    Colors.grey.withOpacity(0.3),
                    Colors.grey.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
          
          leading: Builder( 
            builder: (context) => Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.black87),
                onPressed: () => Scaffold.of(context).openDrawer(),
                splashRadius: 20,
              ),
            ),
          ),
          
          title: Row(
            children: [
              // Brand Logo/Title with enhanced styling
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16, 
                  vertical: 8
                ),
                margin: EdgeInsets.only(
                  left: 8, 
                  right: isSmallScreen ? 8 : 16
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4D5DF3),
                      Color(0xFF6366F1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4D5DF3).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  "BITE SERVE",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              
              // New Order Button with enhanced styling - hide text on small screens
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<OrderBloc>().add(ClearCartEvent());
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: isSmallScreen 
                    ? const SizedBox.shrink()
                    : const Text(
                        "NEW ORDER",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 20, 
                      vertical: 12
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    minimumSize: isSmallScreen ? const Size(44, 44) : null,
                  ),
                ),
              ),
            ],
          ),
          
          actions: isSmallScreen 
            ? [_buildMobileActionsDropdown(context)]
            : [
                // Desktop actions - show all icons
                _buildActionButton(
                  Icons.support_agent_rounded,
                  "Support",
                  () => _showComingSoon(context, "Support"),
                ),
                _buildActionButton(
                  Icons.receipt_long_rounded,
                  "Receipts",
                  () => _showComingSoon(context, "Receipts"),
                ),
                _buildActionButton(
                  Icons.print_rounded,
                  "Print",
                  () => _showComingSoon(context, "Print"),
                ),
                _buildActionButton(
                  Icons.notifications_rounded,
                  "Notifications",
                  () => _showComingSoon(context, "Notifications"),
                  showBadge: true,
                ),
                _buildActionButton(
                  Icons.account_circle_rounded,
                  "Profile",
                  () => _showComingSoon(context, "Profile"),
                ),
                
                // Logout button with special styling
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.power_settings_new_rounded, color: Colors.red),
                    onPressed: () => _showLogoutConfirmation(context),
                    tooltip: "Logout",
                    splashRadius: 20,
                  ),
                ),
                const SizedBox(width: 12),
              ],
        );
      },
    );
  }

  Widget _buildMobileActionsDropdown(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: PopupMenuButton<String>(
        icon: Stack(
          children: [
            const Icon(Icons.more_vert_rounded, color: Colors.black87),
            // Notification badge
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        offset: const Offset(0, 50),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          _buildPopupMenuItem(
            'support',
            Icons.support_agent_rounded,
            'Support',
            Colors.blue,
          ),
          _buildPopupMenuDivider(),
          _buildPopupMenuItem(
            'receipts',
            Icons.receipt_long_rounded,
            'Receipts',
            Colors.green,
          ),
          _buildPopupMenuDivider(),
          _buildPopupMenuItem(
            'print',
            Icons.print_rounded,
            'Print',
            Colors.purple,
          ),
          _buildPopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'notifications',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Icon(Icons.notifications_rounded, 
                           color: Colors.orange.shade600, size: 20),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Notifications',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          _buildPopupMenuDivider(),
          _buildPopupMenuItem(
            'profile',
            Icons.account_circle_rounded,
            'Profile',
            Colors.indigo,
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'logout',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.power_settings_new_rounded, 
                           color: Colors.red.shade600, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
        onSelected: (String value) {
          switch (value) {
            case 'support':
              _showComingSoon(context, "Support");
              break;
            case 'receipts':
              _showComingSoon(context, "Receipts");
              break;
            case 'print':
              _showComingSoon(context, "Print");
              break;
            case 'notifications':
              _showComingSoon(context, "Notifications");
              break;
            case 'profile':
              _showComingSoon(context, "Profile");
              break;
            case 'logout':
              _showLogoutConfirmation(context);
              break;
          }
        },
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    String value, 
    IconData icon, 
    String text, 
    Color color
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color.shade600, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  PopupMenuDivider _buildPopupMenuDivider() {
    return const PopupMenuDivider(height: 1);
  }

  Widget _buildActionButton(IconData icon, String tooltip, VoidCallback onPressed, {bool showBadge = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        children: [
          IconButton(
            icon: Icon(icon, color: Colors.black87),
            onPressed: onPressed,
            tooltip: tooltip,
            splashRadius: 20,
          ),
          if (showBadge)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: const Color(0xFF4D5DF3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

extension on Color {
  get shade600 => null;
}