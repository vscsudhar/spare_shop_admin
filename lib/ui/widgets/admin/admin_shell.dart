import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/token_service.dart';
import 'package:spare_shop_admin/core/services/location_service.dart';
import 'package:spare_shop_admin/core/services/staff_service.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:spare_shop_admin/core/theme/theme_service.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';

enum AdminNavigationItem {
  dashboard,
  orders,
  returnsExchanges,
  damagedProducts,
  rareRequests,
  supportTickets,
  suggestions,
  categories,
  products,
  inventory,
  purchases,
  suppliers,
  locations,
  deliveryCharges,
  customers,
  billing,
  reports,
  staffRoles,
  settings,
}

// Global role state for local visual demo
String activeAdminRole = 'Owner / Admin';

String normalizeAdminRole(String role) {
  final lower = role.toLowerCase().replaceAll('_', ' ').trim();
  if (lower.contains('owner') ||
      lower.contains('admin') ||
      lower.contains('manager')) {
    return 'Owner / Admin';
  }
  if (lower.contains('inventory')) {
    return 'Inventory Staff';
  }
  if (lower.contains('sales')) {
    return 'Sales Staff';
  }
  if (lower.contains('delivery')) {
    return 'Delivery Staff';
  }
  return 'Owner / Admin';
}

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
              _buildLocationBadge(),
              const SizedBox(width: 12),
              _buildRoleSelector(context),
              const SizedBox(width: 12),
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

  Widget _buildLocationBadge() {
    return ListenableBuilder(
      listenable: TokenService.locationNotifier,
      builder: (context, _) {
        final currentLocId = TokenService.locationNotifier.locationId;
        final currentLocationName = TokenService.locationNotifier.locationName;
        final hasSpecificLocation = currentLocId != null &&
            currentLocId.isNotEmpty &&
            currentLocId != 'all';

        return FutureBuilder<List<LocationModel>>(
          future: locator<LocationService>().getLocations(),
          builder: (context, snapshot) {
            final locations = snapshot.data ?? [];

            String displayTitle = 'Global (HQ)';
            if (hasSpecificLocation) {
              if (currentLocationName != null &&
                  currentLocationName.isNotEmpty &&
                  currentLocationName != 'All Locations (HQ)') {
                displayTitle =
                    '${currentLocationName.replaceAll(RegExp(r'\\s*hub', caseSensitive: false), '')} Hub';
              } else {
                final match = locations.where((l) => l.id == currentLocId);
                if (match.isNotEmpty) {
                  displayTitle =
                      '${match.first.name.replaceAll(RegExp(r'\\s*hub', caseSensitive: false), '')} Hub';
                } else {
                  displayTitle = 'Location Hub';
                }
              }
            }

            return PopupMenuButton<String>(
              tooltip: 'Switch Working Location (Global / Hub)',
              onSelected: (String selectedLocId) async {
                final tokenService = locator<TokenService>();
                if (selectedLocId == 'all') {
                  await tokenService.saveUserLocation(
                    locationId: null,
                    locationName: 'All Locations (HQ)',
                  );
                } else {
                  final loc = locations.firstWhere(
                    (l) => l.id == selectedLocId,
                    orElse: () => LocationModel(
                      id: selectedLocId,
                      name: 'Location Hub',
                      latitude: 0,
                      longitude: 0,
                      radiusKm: 10.0,
                      isActive: true,
                    ),
                  );
                  await tokenService.saveUserLocation(
                    locationId: loc.id,
                    locationName: loc.name,
                  );
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        selectedLocId == 'all'
                            ? 'Switched to Global (HQ) mode.'
                            : 'Working location changed to ${TokenService.locationNotifier.locationName}.',
                      ),
                      backgroundColor: AdminColors.primaryGreen,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'all',
                  child: Row(
                    children: [
                      Icon(Icons.public, size: 16, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Global (All HQ Branches)'),
                    ],
                  ),
                ),
                ...locations.map((loc) {
                  final isSelected = loc.id == currentLocId;
                  return PopupMenuItem<String>(
                    value: loc.id,
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: isSelected
                              ? AdminColors.primaryGreen
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${loc.name} (${loc.radiusDisplay})',
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? AdminColors.primaryGreen : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: hasSpecificLocation
                      ? AdminColors.primaryGreen.withValues(alpha: 0.12)
                      : Colors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasSpecificLocation
                        ? AdminColors.primaryGreen.withValues(alpha: 0.3)
                        : Colors.blue.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasSpecificLocation ? Icons.location_on : Icons.public,
                      size: 14,
                      color: hasSpecificLocation
                          ? AdminColors.primaryGreen
                          : Colors.blue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      displayTitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: hasSpecificLocation
                            ? AdminColors.primaryGreen
                            : Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
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
        final currentNormalized = normalizeAdminRole(activeAdminRole);
        final selectedValue =
            roles.contains(currentNormalized) ? currentNormalized : roles.first;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isCompact ? Colors.white12 : AdminColors.background,
            borderRadius: BorderRadius.circular(8),
            border: isCompact ? null : Border.all(color: AdminColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
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
    return Material(
      color: AdminColors.sidebarBackground,
      child: SizedBox(
        width: 250,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined,
                      color: Colors.white70, size: 18),
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
                  _sidebarItem(
                      context,
                      Icons.published_with_changes_rounded,
                      'Returns & Exchanges',
                      AdminNavigationItem.returnsExchanges),
                  _sidebarItem(context, Icons.broken_image_rounded,
                      'Damaged Products', AdminNavigationItem.damagedProducts),
                  _sidebarItem(context, Icons.support_agent_rounded,
                      'Rare Requests', AdminNavigationItem.rareRequests),
                  _sidebarItem(context, Icons.headset_mic_rounded,
                      'Support Tickets', AdminNavigationItem.supportTickets),
                  _sidebarItem(context, Icons.lightbulb_outline_rounded,
                      'Suggestions', AdminNavigationItem.suggestions),
                  _sidebarItem(context, Icons.category_rounded, 'Categories',
                      AdminNavigationItem.categories),
                  _sidebarItem(context, Icons.build_rounded, 'Products',
                      AdminNavigationItem.products),
                  _sidebarItem(context, Icons.inventory_2_rounded, 'Inventory',
                      AdminNavigationItem.inventory),
                  _sidebarItem(context, Icons.receipt_long_rounded, 'Purchases',
                      AdminNavigationItem.purchases),
                  _sidebarItem(context, Icons.warehouse_rounded, 'Suppliers',
                      AdminNavigationItem.suppliers),
                  _sidebarItem(context, Icons.location_on_rounded, 'Locations',
                      AdminNavigationItem.locations),
                  _sidebarItem(context, Icons.local_shipping_rounded,
                      'Delivery Charges', AdminNavigationItem.deliveryCharges),
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
            const Divider(color: Colors.white12, height: 1),
            FutureBuilder<Map<String, String?>>(
              future: () async {
                final tokenService = locator<TokenService>();
                final email = await tokenService.getUserEmail();
                final locId = await tokenService.getUserLocationId();
                var loc = await tokenService.getUserLocationName();

                if ((loc == null || loc.isEmpty || loc == 'Global HQ') &&
                    locId != null &&
                    locId.isNotEmpty) {
                  try {
                    final locations =
                        await locator<LocationService>().getLocations();
                    final match = locations.where((l) => l.id == locId);
                    if (match.isNotEmpty) {
                      loc = match.first.name;
                      await tokenService.saveUserLocation(
                        locationId: locId,
                        locationName: loc,
                      );
                    }
                  } catch (_) {}
                }

                if ((loc == null || loc.isEmpty || loc == 'Global HQ') &&
                    email != null &&
                    email.isNotEmpty) {
                  try {
                    final staffList =
                        await locator<StaffService>().getStaffMembers();
                    final member = staffList.where((s) =>
                        s.email.toLowerCase() == email.toLowerCase().trim());
                    if (member.isNotEmpty &&
                        member.first.locationName.isNotEmpty &&
                        member.first.locationName != 'All Locations (HQ)') {
                      loc = member.first.locationName;
                      await tokenService.saveUserLocation(
                        locationId: member.first.locationId,
                        locationName: loc,
                      );
                    }
                  } catch (_) {}
                }

                final canChange = await tokenService.canChangeLocation();
                if (loc == null || loc.isEmpty) {
                  loc = canChange ? 'All Locations (HQ)' : 'Assigned Hub';
                }

                return {'email': email, 'location': loc};
              }(),
              builder: (context, snapshot) {
                final email = snapshot.data?['email'] ?? 'Console User';
                final loc = snapshot.data?['location'] ?? 'Assigned Hub';
                final displayLoc = loc.toLowerCase().contains('hq') ||
                        loc.toLowerCase().contains('hub') ||
                        loc.toLowerCase().contains('all')
                    ? loc
                    : '$loc Hub';

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            AdminColors.primaryGreen.withValues(alpha: 0.2),
                        child: Icon(Icons.person,
                            size: 16, color: AdminColors.accentLime),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '📍 $displayLoc',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AdminColors.accentLime
                                    .withValues(alpha: 0.8),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(color: Colors.white12, height: 1),
            Material(
              color: Colors.transparent,
              child: ListTile(
                dense: true,
                leading:
                    const Icon(Icons.logout, color: Colors.white70, size: 18),
                title: const Text('Exit Console',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                onTap: () async {
                  await locator<TokenService>().clearTokens();
                  goToAdminLogin();
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
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
      child: Material(
        color: Colors.transparent,
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
      case AdminNavigationItem.returnsExchanges:
        goToReturnsExchanges();
        break;
      case AdminNavigationItem.damagedProducts:
        goToAdminDamagedProducts();
        break;
      case AdminNavigationItem.rareRequests:
        goToAdminRareRequests();
        break;
      case AdminNavigationItem.supportTickets:
        goToAdminSupportTickets();
        break;
      case AdminNavigationItem.suggestions:
        goToAdminSuggestions();
        break;
      case AdminNavigationItem.categories:
        goToAdminCategories();
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
      case AdminNavigationItem.locations:
        goToAdminLocations();
        break;
      case AdminNavigationItem.deliveryCharges:
        goToAdminDeliveryCharges();
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
