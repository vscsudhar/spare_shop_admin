import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/app/app.router.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/theme/theme_service.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';

enum AdminNavigationItem {
  dashboard,
  orders,
  rareRequests,
  products,
  inventory,
  purchases,
  suppliers,
  customers,
  billing,
  reports,
  staffRoles,
  settings,
}

// Global role state for local visual demo
String activeAdminRole = 'Owner / Admin';

class AdminShell extends StatelessWidget with NavigationMixin {
  final String title;
  final AdminNavigationItem selectedItem;
  final Widget child;
  final VoidCallback? onCreateOrder;
  final ValueChanged<String>? onSearch;

  AdminShell({
    super.key,
    required this.title,
    required this.selectedItem,
    required this.child,
    this.onCreateOrder,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= AdminBreakpoints.tablet;

        return Scaffold(
          backgroundColor: AdminColors.background,
          drawer: isDesktop
              ? null
              : Drawer(
                  child: Builder(
                    builder: (drawerContext) =>
                        _buildSidebarContent(drawerContext),
                  ),
                ),
          appBar: isDesktop
              ? null
              : AppBar(
                  backgroundColor: AdminColors.sidebarBackground,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: Row(
                    children: [
                      Icon(Icons.electric_bolt_rounded,
                          color: AdminColors.accentLime, size: 22),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          body: Row(
            children: [
              if (isDesktop) _buildSidebarContent(context),
              Expanded(
                child: Column(
                  children: [
                    if (isDesktop) _buildTopBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AdminSpacing.l),
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        border: Border(
          bottom: BorderSide(color: AdminColors.border),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AdminSpacing.l),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AdminTextStyles.header.copyWith(fontSize: 20),
          ),
          if (onSearch != null)
            SizedBox(
              width: 300,
              height: 40,
              child: TextField(
                onChanged: onSearch,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AdminRadius.chip),
                    borderSide: BorderSide(color: AdminColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AdminRadius.chip),
                    borderSide: BorderSide(color: AdminColors.border),
                  ),
                ),
              ),
            ),
          Row(
            children: [
              _buildRoleSelector(context),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(AdminColors.isDarkTheme
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined),
                onPressed: () {
                  final themeService = locator<ThemeService>();
                  if (AdminColors.isDarkTheme) {
                    themeService.setLightTheme();
                  } else {
                    themeService.setDarkTheme();
                  }
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No new notifications')),
                  );
                },
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 18,
                backgroundColor: AdminColors.primaryGreen,
                child: const Text('VS',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRoleSelector(BuildContext context, {bool isCompact = false}) {
    final List<String> roles = [
      'Owner / Admin',
      'Inventory Staff',
      'Sales Staff',
      'Delivery Staff',
    ];

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isCompact ? Colors.white12 : AdminColors.background,
            borderRadius: BorderRadius.circular(8),
            border: isCompact ? null : Border.all(color: AdminColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: activeAdminRole,
              dropdownColor: AdminColors.panelBackground,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    activeAdminRole = newValue;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Role switched to: $newValue')),
                  );
                }
              },
              items: roles.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: isCompact ? Colors.white : AdminColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebarContent(BuildContext context) {
    return Container(
      width: 250,
      color: AdminColors.sidebarBackground,
      child: Column(
        children: [
          Container(
            height: 70,
            padding: const EdgeInsets.all(AdminSpacing.m),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(Icons.electric_bolt_rounded,
                    color: AdminColors.accentLime, size: 28),
                const SizedBox(width: 8),
                Text(
                  'VoltSpare Console',
                  style: AdminTextStyles.header
                      .copyWith(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          // Role selector inside mobile drawer (prevents header overflow)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildRoleSelector(context, isCompact: true),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              children: [
                _sidebarItem(context, Icons.dashboard_rounded, 'Dashboard',
                    AdminNavigationItem.dashboard),
                _sidebarItem(context, Icons.shopping_bag_rounded, 'Orders',
                    AdminNavigationItem.orders),
                _sidebarItem(context, Icons.support_agent_rounded,
                    'Rare Requests', AdminNavigationItem.rareRequests),
                _sidebarItem(context, Icons.build_rounded, 'Products',
                    AdminNavigationItem.products),
                _sidebarItem(context, Icons.inventory_2_rounded, 'Inventory',
                    AdminNavigationItem.inventory),
                _sidebarItem(context, Icons.receipt_long_rounded, 'Purchases',
                    AdminNavigationItem.purchases),
                _sidebarItem(context, Icons.warehouse_rounded, 'Suppliers',
                    AdminNavigationItem.suppliers),
                _sidebarItem(context, Icons.people_alt_rounded, 'Customers',
                    AdminNavigationItem.customers),
                _sidebarItem(context, Icons.payment_rounded, 'Billing / POS',
                    AdminNavigationItem.billing),
                _sidebarItem(context, Icons.analytics_rounded, 'Reports',
                    AdminNavigationItem.reports),
                _sidebarItem(context, Icons.badge_rounded, 'Staff & Roles',
                    AdminNavigationItem.staffRoles),
                _sidebarItem(context, Icons.settings_rounded, 'Settings',
                    AdminNavigationItem.settings),
              ],
            ),
          ),
          const Divider(color: Colors.white12),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white70),
            title: const Text('Exit Console',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            onTap: () {
              goToAdminLogin();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sidebarItem(
    BuildContext context,
    IconData icon,
    String title,
    AdminNavigationItem item,
  ) {
    final isSelected = selectedItem == item;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: ListTile(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminRadius.chip)),
        selectedTileColor: AdminColors.primaryGreen.withValues(alpha: 0.15),
        selected: isSelected,
        leading: Icon(
          icon,
          color: isSelected ? AdminColors.sidebarActiveText : Colors.white70,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AdminColors.sidebarActiveText : Colors.white,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          if (!isSelected) {
            _navigate(context, item);
          }
        },
      ),
    );
  }

  void _navigate(BuildContext context, AdminNavigationItem item) {
    // If mobile, close the drawer first
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null && scaffold.isDrawerOpen) {
      scaffold.closeDrawer();
    }

    switch (item) {
      case AdminNavigationItem.dashboard:
        goToAdminDashboard();
        break;
      case AdminNavigationItem.orders:
        goToAdminOrders();
        break;
      case AdminNavigationItem.rareRequests:
        goToAdminRareRequests();
        break;
      case AdminNavigationItem.products:
        goToAdminProducts();
        break;
      case AdminNavigationItem.inventory:
        goToAdminInventory();
        break;
      case AdminNavigationItem.purchases:
        goToAdminPurchases();
        break;
      case AdminNavigationItem.suppliers:
        goToAdminSuppliers();
        break;
      case AdminNavigationItem.customers:
        goToAdminCustomers();
        break;
      case AdminNavigationItem.billing:
        goToAdminBilling();
        break;
      case AdminNavigationItem.reports:
        goToAdminReports();
        break;
      case AdminNavigationItem.staffRoles:
        goToAdminStaffRoles();
        break;
      case AdminNavigationItem.settings:
        goToAdminSettings();
        break;
    }
  }
}
