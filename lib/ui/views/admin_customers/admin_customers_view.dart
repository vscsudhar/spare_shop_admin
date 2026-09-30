import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_customers_viewmodel.dart';

class AdminCustomersView extends StackedView<AdminCustomersViewModel> {
  const AdminCustomersView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminCustomersViewModel viewModel,
    Widget? child,
  ) {
    final isDark = AdminColors.isDarkTheme;

    return AdminShell(
      title: 'Customer Directory & App Users',
      selectedItem: AdminNavigationItem.customers,
      onSearch: viewModel.setSearchQuery,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Headers
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;
              final isTablet = constraints.maxWidth < 1100;
              final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 4);

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 3.5 : 2.2,
                children: [
                  AdminMetricCard(
                    title: 'Total Customers / Users',
                    value: '${viewModel.totalCustomersCount}',
                    icon: Icons.people_alt_outlined,
                    iconColor: Colors.blueAccent,
                    subtitle: '${viewModel.mobileUsersCount} Mobile • ${viewModel.storeUsersCount} In-Store',
                  ),
                  AdminMetricCard(
                    title: 'Workshop / Fleet Partners',
                    value: '${viewModel.workshopCustomersCount}',
                    icon: Icons.store_outlined,
                    iconColor: Colors.purpleAccent,
                    subtitle: '${viewModel.retailCustomersCount} retail consumers',
                  ),
                  AdminMetricCard(
                    title: 'Total Orders & GMV Spend',
                    value: '₹${viewModel.totalLifetimeSpend.toStringAsFixed(0)}',
                    icon: Icons.currency_rupee_rounded,
                    iconColor: AdminColors.primaryGreen,
                    subtitle: 'Lifetime gross revenue',
                  ),
                  AdminMetricCard(
                    title: 'Credit Dues Outstanding',
                    value: '₹${viewModel.totalOutstandingDue.toStringAsFixed(0)}',
                    icon: Icons.credit_card_off_outlined,
                    iconColor: viewModel.totalOutstandingDue > 0 ? Colors.redAccent : Colors.grey,
                    subtitle: 'Payable balance by users',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Action Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer & User Directory',
                    style: AdminTextStyles.sectionHeader,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track mobile app users vs in-store counter customers, order history, balances, and garage vehicles',
                    style: AdminTextStyles.bodySecondary.copyWith(fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => viewModel.loadCustomers(),
                    icon: viewModel.isLoadingData
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminColors.textPrimary,
                      side: BorderSide(color: AdminColors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showCustomerForm(context, viewModel),
                    icon: const Icon(Icons.person_add_alt_1, size: 16),
                    label: const Text('Add Customer / User'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filters & Hub Selector Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AdminColors.panelBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Search + Channel Tabs + Status Tabs + Type Dropdown
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Search Bar
                    SizedBox(
                      width: 270,
                      child: TextField(
                        onChanged: viewModel.setSearchQuery,
                        style: TextStyle(color: AdminColors.textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search name, phone, email, vehicle...',
                          hintStyle: TextStyle(color: AdminColors.textLight, fontSize: 13),
                          prefixIcon: Icon(Icons.search, size: 18, color: AdminColors.textLight),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: AdminColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AdminColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AdminColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AdminColors.primaryGreen),
                          ),
                        ),
                      ),
                    ),

                    // Channel Filter Tabs (Mobile App vs In-Store)
                    Container(
                      decoration: BoxDecoration(
                        color: AdminColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AdminColors.border),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildFilterTab(
                            label: 'All Channels (${viewModel.customers.length})',
                            isSelected: viewModel.selectedChannelFilter == 'all',
                            onTap: () => viewModel.setSelectedChannelFilter('all'),
                          ),
                          _buildFilterTab(
                            label: '📱 Mobile App (${viewModel.mobileUsersCount})',
                            isSelected: viewModel.selectedChannelFilter == 'mobile',
                            activeColor: Colors.blueAccent,
                            onTap: () => viewModel.setSelectedChannelFilter('mobile'),
                          ),
                          _buildFilterTab(
                            label: '🏬 In-Store (${viewModel.storeUsersCount})',
                            isSelected: viewModel.selectedChannelFilter == 'store',
                            activeColor: Colors.amber,
                            onTap: () => viewModel.setSelectedChannelFilter('store'),
                          ),
                        ],
                      ),
                    ),

                    // Status Filter Buttons
                    Container(
                      decoration: BoxDecoration(
                        color: AdminColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AdminColors.border),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildFilterTab(
                            label: 'All Status',
                            isSelected: viewModel.selectedStatusFilter == 'all',
                            onTap: () => viewModel.setSelectedStatusFilter('all'),
                          ),
                          _buildFilterTab(
                            label: 'Active (${viewModel.activeCustomersCount})',
                            isSelected: viewModel.selectedStatusFilter == 'Active',
                            activeColor: AdminColors.primaryGreen,
                            onTap: () => viewModel.setSelectedStatusFilter('Active'),
                          ),
                          _buildFilterTab(
                            label: 'Suspended (${viewModel.suspendedCustomersCount})',
                            isSelected: viewModel.selectedStatusFilter == 'Suspended',
                            activeColor: Colors.redAccent,
                            onTap: () => viewModel.setSelectedStatusFilter('Suspended'),
                          ),
                        ],
                      ),
                    ),

                    // Account Type Filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AdminColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AdminColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: viewModel.selectedTypeFilter,
                          dropdownColor: AdminColors.panelBackground,
                          style: TextStyle(color: AdminColors.textPrimary, fontSize: 13),
                          icon: Icon(Icons.filter_list, size: 16, color: AdminColors.textLight),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All Account Types')),
                            DropdownMenuItem(value: 'Retail', child: Text('Retail Customers')),
                            DropdownMenuItem(value: 'Workshop', child: Text('Workshop Owners')),
                            DropdownMenuItem(value: 'Fleet', child: Text('Fleet Owners')),
                          ],
                          onChanged: (val) {
                            if (val != null) viewModel.setSelectedTypeFilter(val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Location Hub Chips Row
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: AdminColors.primaryGreen),
                    const SizedBox(width: 6),
                    Text(
                      'Serving Hub Filter:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            AdminFilterChip(
                              label: 'All Hubs (HQ)',
                              isSelected: viewModel.selectedLocationFilter == 'all',
                              onTap: () => viewModel.setSelectedLocationFilter('all'),
                            ),
                            ...viewModel.locations.map((loc) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: AdminFilterChip(
                                  label: '${loc.name} Hub',
                                  isSelected: viewModel.selectedLocationFilter == loc.id,
                                  onTap: () => viewModel.setSelectedLocationFilter(loc.id),
                                ),
                              );
                            }),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: AdminFilterChip(
                                label: viewModel.unassignedCustomersCount > 0
                                    ? '⚠️ Unassigned (${viewModel.unassignedCustomersCount})'
                                    : 'Unassigned',
                                isSelected: viewModel.selectedLocationFilter == 'unassigned',
                                onTap: () => viewModel.setSelectedLocationFilter('unassigned'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // User Table / Cards
          if (viewModel.isLoadingData)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AdminColors.panelBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminColors.border),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (viewModel.filteredCustomers.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AdminColors.panelBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminColors.border),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_search, size: 48, color: AdminColors.textLight),
                    const SizedBox(height: 12),
                    Text(
                      'No customers found matching filter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Try adjusting your search query, origin channel, or hub filter',
                      style: TextStyle(fontSize: 13, color: AdminColors.textLight),
                    ),
                  ],
                ),
              ),
            )
          else
            _buildCustomerList(context, viewModel, isDark),
        ],
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? activeColor,
  }) {
    final color = activeColor ?? AdminColors.primaryGreen;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected ? Border.all(color: color.withValues(alpha: 0.4)) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : AdminColors.textLight,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerList(
    BuildContext context,
    AdminCustomersViewModel viewModel,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1080),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AdminColors.background),
              dataRowMinHeight: 68,
              dataRowMaxHeight: 78,
              horizontalMargin: 20,
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('USER PROFILE & IMAGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
                DataColumn(label: Text('USER ORIGIN / CHANNEL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
                DataColumn(label: Text('CONTACT & HUB', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
                DataColumn(label: Text('GARAGE / VEHICLES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
                DataColumn(label: Text('TYPE & STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
                DataColumn(label: Text('ORDERS & SPEND', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
                DataColumn(label: Text('BALANCE DUE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
                DataColumn(label: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
              ],
              rows: viewModel.filteredCustomers.map((customer) {
                final hasDue = customer.outstandingDue > 0;
                final isActive = customer.status.toLowerCase() == 'active';
                final isSuspended = customer.status.toLowerCase() == 'suspended';
                final isMobile = customer.isMobileUser;

                return DataRow(
                  cells: [
                    // 1. User Profile & Image Cell
                    DataCell(
                      InkWell(
                        onTap: () => _showCustomerDetailsDialog(context, viewModel, customer),
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildUserAvatar(customer, size: 44),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      customer.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AdminColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    if (customer.type.contains('Workshop'))
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.purple.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('PRO', style: TextStyle(fontSize: 9, color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  customer.email.isNotEmpty ? customer.email : 'No email provided',
                                  style: TextStyle(fontSize: 11, color: AdminColors.textLight),
                                ),
                                if (customer.createdAt != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Joined: ${_formatDate(customer.createdAt!)}',
                                    style: TextStyle(fontSize: 10, color: AdminColors.textLight.withValues(alpha: 0.8)),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. User Origin / Channel Column (Mobile App User vs Store / POS User)
                    DataCell(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isMobile
                                ? Colors.blue.withValues(alpha: 0.12)
                                : Colors.amber.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isMobile
                                  ? Colors.blue.withValues(alpha: 0.35)
                                  : Colors.amber.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isMobile ? Icons.smartphone : Icons.storefront,
                                size: 13,
                                color: isMobile ? Colors.blueAccent : Colors.amber,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isMobile ? 'Mobile App' : 'Store / POS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isMobile ? Colors.blueAccent : Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 3. Contact & Hub
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone, size: 12, color: AdminColors.primaryGreen),
                              const SizedBox(width: 4),
                              Text(
                                customer.phone,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () => _showAssignLocationDialog(context, viewModel, customer),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.storefront_outlined, size: 12, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  customer.locationName != null && customer.locationName!.isNotEmpty
                                      ? '${customer.locationName} Hub'
                                      : '⚠️ Unassigned Hub',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: customer.locationName != null ? AdminColors.textSecondary : Colors.amber,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 4. Garage / Vehicles
                    DataCell(
                      customer.vehicles.isEmpty
                          ? Text('No vehicles added', style: TextStyle(fontSize: 11, color: AdminColors.textLight, fontStyle: FontStyle.italic))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.two_wheeler, size: 14, color: AdminColors.primaryGreen),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${customer.vehicles.length} Vehicle${customer.vehicles.length > 1 ? 's' : ''}',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AdminColors.textPrimary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  customer.vehicles.first.displayName,
                                  style: TextStyle(fontSize: 11, color: AdminColors.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                    ),

                    // 5. Type & Status
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(customer.type, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AdminColors.textPrimary)),
                          const SizedBox(height: 4),
                          _buildStatusBadge(
                            customer: customer,
                            viewModel: viewModel,
                            context: context,
                            isActive: isActive,
                            isSuspended: isSuspended,
                          ),
                        ],
                      ),
                    ),

                    // 6. Orders & Spend (Accurately Populated)
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.receipt_long, size: 13, color: AdminColors.textLight),
                              const SizedBox(width: 4),
                              Text(
                                '${customer.ordersCount} Order${customer.ordersCount == 1 ? '' : 's'}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '₹${customer.totalSpend.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 7. Balance Due
                    DataCell(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: hasDue ? Colors.red.withValues(alpha: 0.12) : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: hasDue ? Colors.red.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '₹${customer.outstandingDue.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: hasDue ? Colors.redAccent : AdminColors.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 8. Action Buttons (View, Edit, Delete)
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility_outlined, size: 18),
                            color: Colors.blueAccent,
                            tooltip: 'View Profile & Garage',
                            onPressed: () => _showCustomerDetailsDialog(context, viewModel, customer),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            color: AdminColors.primaryGreen,
                            tooltip: 'Edit Details',
                            onPressed: () => _showCustomerForm(context, viewModel, customer),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            color: Colors.redAccent,
                            tooltip: 'Delete User Account',
                            onPressed: () => _showDeleteConfirmDialog(context, viewModel, customer),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(AdminCustomerModel customer, {double size = 44}) {
    final hasImage = customer.profileImage.isNotEmpty &&
        (customer.profileImage.startsWith('http://') || customer.profileImage.startsWith('https://'));

    final statusColor = customer.status.toLowerCase() == 'active'
        ? const Color(0xFF10B981)
        : (customer.status.toLowerCase() == 'suspended' ? Colors.amber : Colors.red);

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF0F9F59), Color(0xFF10B981), Color(0xFF047857)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: hasImage
                ? Image.network(
                    customer.profileImage,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          customer.initials,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: size * 0.38,
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      customer.initials,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: size * 0.38,
                      ),
                    ),
                  ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: size * 0.28,
            height: size * 0.28,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              border: Border.all(color: AdminColors.panelBackground, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge({
    required AdminCustomerModel customer,
    required AdminCustomersViewModel viewModel,
    required BuildContext context,
    required bool isActive,
    required bool isSuspended,
  }) {
    final color = isActive ? const Color(0xFF10B981) : (isSuspended ? Colors.amber : Colors.redAccent);

    return PopupMenuButton<String>(
      tooltip: 'Change Status',
      onSelected: (newStatus) async {
        final success = await viewModel.updateCustomerStatus(customer, newStatus);
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${customer.name} status changed to $newStatus'),
              backgroundColor: AdminColors.primaryGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem(
          value: 'Active',
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text('Active'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'Suspended',
          child: Row(
            children: [
              Icon(Icons.pause_circle_filled, size: 16, color: Colors.amber),
              SizedBox(width: 8),
              Text('Suspended'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'Disabled',
          child: Row(
            children: [
              Icon(Icons.cancel, size: 16, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Disabled'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(
              customer.status,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 12, color: color),
          ],
        ),
      ),
    );
  }

  void _showCustomerDetailsDialog(
    BuildContext context,
    AdminCustomersViewModel viewModel,
    AdminCustomerModel customer,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AdminColors.panelBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: 540,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile Header Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AdminColors.background,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      border: Border(bottom: BorderSide(color: AdminColors.border)),
                    ),
                    child: Row(
                      children: [
                        _buildUserAvatar(customer, size: 64),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AdminColors.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                customer.email.isNotEmpty ? customer.email : 'No email address registered',
                                style: TextStyle(fontSize: 12, color: AdminColors.textLight),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: customer.isMobileUser
                                          ? Colors.blue.withValues(alpha: 0.15)
                                          : Colors.amber.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          customer.isMobileUser ? Icons.smartphone : Icons.storefront,
                                          size: 11,
                                          color: customer.isMobileUser ? Colors.blueAccent : Colors.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          customer.sourceDisplayName,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: customer.isMobileUser ? Colors.blueAccent : Colors.amber,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AdminColors.primaryGreen.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      customer.type,
                                      style: TextStyle(fontSize: 11, color: AdminColors.primaryGreen, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (customer.status.toLowerCase() == 'active' ? Colors.green : Colors.amber).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      customer.status,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: customer.status.toLowerCase() == 'active' ? Colors.green : Colors.amber,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Metrics Summary
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildInfoTile('Total Orders', '${customer.ordersCount}', Icons.shopping_bag_outlined),
                            const SizedBox(width: 12),
                            _buildInfoTile('Total Spend', '₹${customer.totalSpend.toStringAsFixed(0)}', Icons.payments_outlined),
                            const SizedBox(width: 12),
                            _buildInfoTile('Balance Due', '₹${customer.outstandingDue.toStringAsFixed(0)}', Icons.account_balance_wallet_outlined,
                                isAlert: customer.outstandingDue > 0),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // Contact Details
                        Text('Contact & Location Info', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AdminColors.textPrimary)),
                        const SizedBox(height: 8),
                        _buildDetailRow(Icons.phone, 'Phone Number', customer.phone),
                        _buildDetailRow(Icons.email, 'Email Address', customer.email.isNotEmpty ? customer.email : 'N/A'),
                        _buildDetailRow(Icons.location_city, 'Serving Hub', customer.locationName != null ? '${customer.locationName} Hub' : 'Unassigned (HQ)'),
                        _buildDetailRow(Icons.home, 'Address', customer.address.isNotEmpty ? customer.address : 'No address provided'),

                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // Registered Garage Vehicles
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Garage Vehicles (${customer.vehicles.length})', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AdminColors.textPrimary)),
                            Icon(Icons.two_wheeler, size: 16, color: AdminColors.primaryGreen),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (customer.vehicles.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AdminColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text('No vehicles added in user garage yet.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ),
                          )
                        else
                          ...customer.vehicles.map((v) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AdminColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AdminColors.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AdminColors.primaryGreen.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.electric_scooter, size: 16, color: AdminColors.primaryGreen),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${v.brand} ${v.model}',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AdminColors.textPrimary),
                                        ),
                                        if (v.registrationNumber != null && v.registrationNumber!.isNotEmpty)
                                          Text('Reg: ${v.registrationNumber}', style: TextStyle(fontSize: 11, color: AdminColors.textLight)),
                                      ],
                                    ),
                                  ),
                                  if (v.year != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text('${v.year}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                                    ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                _showCustomerForm(context, viewModel, customer);
              },
              icon: const Icon(Icons.edit, size: 14),
              label: const Text('Edit Customer'),
              style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primaryGreen, foregroundColor: Colors.white),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, {bool isAlert = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AdminColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isAlert ? Colors.red.withValues(alpha: 0.4) : AdminColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: isAlert ? Colors.redAccent : AdminColors.primaryGreen),
                const SizedBox(width: 4),
                Text(label, style: TextStyle(fontSize: 10, color: AdminColors.textLight)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isAlert ? Colors.redAccent : AdminColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AdminColors.textLight),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(fontSize: 12, color: AdminColors.textLight)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  void _showCustomerForm(
    BuildContext context,
    AdminCustomersViewModel viewModel, [
    AdminCustomerModel? customer,
  ]) {
    final nameController = TextEditingController(text: customer?.name ?? '');
    final emailController = TextEditingController(text: customer?.email ?? '');
    final phoneController = TextEditingController(text: customer?.phone ?? '');
    final imageController = TextEditingController(text: customer?.profileImage ?? '');
    final addressController = TextEditingController(text: customer?.address ?? '');
    final dueController = TextEditingController(
      text: customer != null ? customer.outstandingDue.toStringAsFixed(2) : '0.00',
    );

    String selectedType = customer?.type ?? 'Retail Customer';
    String selectedStatus = customer?.status ?? 'Active';
    String selectedSource = customer?.source ?? 'Mobile App';
    String? selectedLocationId = customer?.locationId;
    if (selectedLocationId == null && customer?.locationName != null) {
      final match = viewModel.locations.where(
        (l) => l.name.toLowerCase() == customer!.locationName!.toLowerCase(),
      );
      if (match.isNotEmpty) selectedLocationId = match.first.id;
    }

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AdminColors.panelBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Row(
                children: [
                  Icon(
                    customer == null ? Icons.person_add_alt_1 : Icons.edit,
                    color: AdminColors.primaryGreen,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    customer == null ? 'Add New Customer' : 'Edit Customer Profile',
                    style: TextStyle(color: AdminColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Image Input + Preview
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AdminColors.background,
                                border: Border.all(color: AdminColors.border),
                              ),
                              child: ClipOval(
                                child: imageController.text.isNotEmpty
                                    ? Image.network(
                                        imageController.text,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 30, color: Colors.grey),
                                      )
                                    : const Icon(Icons.person, size: 30, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: imageController,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  labelText: 'Profile Image URL / Avatar',
                                  hintText: 'https://example.com/avatar.jpg',
                                  prefixIcon: Icon(Icons.image_outlined, size: 18),
                                ),
                                style: TextStyle(color: AdminColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Name
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Customer Full Name *',
                            prefixIcon: Icon(Icons.person_outline, size: 18),
                          ),
                          style: TextStyle(color: AdminColors.textPrimary),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 12),

                        // Phone & Email Row
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number *',
                                  prefixIcon: Icon(Icons.phone_outlined, size: 18),
                                ),
                                style: TextStyle(color: AdminColors.textPrimary),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Phone is required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email Address',
                                  prefixIcon: Icon(Icons.email_outlined, size: 18),
                                ),
                                style: TextStyle(color: AdminColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // User Origin / Channel + Account Type Row
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: selectedSource,
                                dropdownColor: AdminColors.panelBackground,
                                decoration: const InputDecoration(
                                  labelText: 'Origin / Channel *',
                                  prefixIcon: Icon(Icons.hub_outlined, size: 18),
                                ),
                                style: TextStyle(color: AdminColors.textPrimary),
                                items: const [
                                  DropdownMenuItem(value: 'Mobile App', child: Text('📱 Mobile App User')),
                                  DropdownMenuItem(value: 'Store / POS', child: Text('🏬 In-Store / POS User')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => selectedSource = val);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: selectedType,
                                dropdownColor: AdminColors.panelBackground,
                                decoration: const InputDecoration(
                                  labelText: 'Account Type',
                                  prefixIcon: Icon(Icons.badge_outlined, size: 18),
                                ),
                                style: TextStyle(color: AdminColors.textPrimary),
                                items: const [
                                  DropdownMenuItem(value: 'Retail Customer', child: Text('Retail Customer')),
                                  DropdownMenuItem(value: 'Workshop Owner', child: Text('Workshop Owner')),
                                  DropdownMenuItem(value: 'Fleet Owner', child: Text('Fleet Owner')),
                                  DropdownMenuItem(value: 'Wholesaler', child: Text('Wholesaler')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => selectedType = val);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Status & Due Row
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: selectedStatus,
                                dropdownColor: AdminColors.panelBackground,
                                decoration: const InputDecoration(
                                  labelText: 'Account Status',
                                  prefixIcon: Icon(Icons.toggle_on_outlined, size: 18),
                                ),
                                style: TextStyle(color: AdminColors.textPrimary),
                                items: const [
                                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                                  DropdownMenuItem(value: 'Suspended', child: Text('Suspended')),
                                  DropdownMenuItem(value: 'Disabled', child: Text('Disabled')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => selectedStatus = val);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: dueController,
                                decoration: const InputDecoration(
                                  labelText: 'Outstanding Balance (₹)',
                                  prefixIcon: Icon(Icons.currency_rupee, size: 18),
                                ),
                                style: TextStyle(color: AdminColors.textPrimary),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Due amount is required';
                                  if (double.tryParse(val) == null) return 'Must be a valid number';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Hub Location
                        DropdownButtonFormField<String?>(
                          initialValue: selectedLocationId,
                          dropdownColor: AdminColors.panelBackground,
                          decoration: const InputDecoration(
                            labelText: 'Assigned Serving Hub',
                            prefixIcon: Icon(Icons.location_on_outlined, size: 18),
                          ),
                          style: TextStyle(color: AdminColors.textPrimary),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Unassigned (HQ)'),
                            ),
                            ...viewModel.locations.map((loc) {
                              return DropdownMenuItem<String?>(
                                value: loc.id,
                                child: Text('${loc.name} Hub'),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setState(() => selectedLocationId = val);
                          },
                        ),
                        const SizedBox(height: 12),

                        // Address
                        TextFormField(
                          controller: addressController,
                          decoration: const InputDecoration(
                            labelText: 'Address / City / Region',
                            prefixIcon: Icon(Icons.home_outlined, size: 18),
                          ),
                          style: TextStyle(color: AdminColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      final due = double.parse(dueController.text);
                      String? locName;
                      if (selectedLocationId != null) {
                        final match = viewModel.locations.where((l) => l.id == selectedLocationId);
                        if (match.isNotEmpty) locName = match.first.name;
                      }

                      bool success;
                      if (customer == null) {
                        success = await viewModel.createCustomer(
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          phone: phoneController.text.trim(),
                          profileImage: imageController.text.trim(),
                          type: selectedType,
                          status: selectedStatus,
                          source: selectedSource,
                          outstandingDue: due,
                          locationId: selectedLocationId,
                          locationName: locName,
                          address: addressController.text.trim(),
                        );
                      } else {
                        success = await viewModel.updateCustomer(
                          customer.id,
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          phone: phoneController.text.trim(),
                          profileImage: imageController.text.trim(),
                          type: selectedType,
                          status: selectedStatus,
                          source: selectedSource,
                          outstandingDue: due,
                          locationId: selectedLocationId,
                          locationName: locName,
                          address: addressController.text.trim(),
                        );
                      }

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Customer saved successfully' : 'Failed to save customer'),
                            backgroundColor: success ? AdminColors.primaryGreen : Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Save Customer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    AdminCustomersViewModel viewModel,
    AdminCustomerModel customer,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AdminColors.panelBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
              SizedBox(width: 8),
              Text('Delete User Account?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to permanently delete the account for "${customer.name}" (${customer.phone})?',
                style: TextStyle(color: AdminColors.textPrimary, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                'Channel: ${customer.sourceDisplayName}. This will remove records, vehicles, and app access.',
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                final success = await viewModel.deleteCustomer(customer.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Customer account deleted' : 'Failed to delete customer'),
                      backgroundColor: success ? Colors.redAccent : Colors.grey,
                    ),
                  );
                }
              },
              child: const Text('Delete Permanently'),
            ),
          ],
        );
      },
    );
  }

  void _showAssignLocationDialog(
    BuildContext context,
    AdminCustomersViewModel viewModel,
    AdminCustomerModel customer,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AdminColors.panelBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(Icons.location_on, color: AdminColors.primaryGreen, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Assign Hub for ${customer.name}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer: ${customer.name} (${customer.phone}) • ${customer.sourceDisplayName}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      if (customer.locationName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Current Hub: ${customer.locationName}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AdminColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Serving Branch Hub:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (viewModel.locations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'No locations registered in system.',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: viewModel.locations.length,
                      separatorBuilder: (_, __) => const Divider(height: 8),
                      itemBuilder: (context, index) {
                        final loc = viewModel.locations[index];
                        final isCurrent = customer.locationId == loc.id ||
                            customer.locationName?.toLowerCase() == loc.name.toLowerCase();
                        return ListTile(
                          dense: true,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          tileColor: isCurrent ? AdminColors.primaryGreen.withValues(alpha: 0.15) : Colors.transparent,
                          leading: Icon(
                            Icons.storefront_outlined,
                            size: 18,
                            color: isCurrent ? AdminColors.primaryGreen : Colors.white70,
                          ),
                          title: Text(
                            '${loc.name} Hub',
                            style: TextStyle(
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: isCurrent ? AdminColors.primaryGreen : Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            'Coverage: ${loc.radiusDisplay}',
                            style: const TextStyle(fontSize: 11, color: Colors.white54),
                          ),
                          trailing: isCurrent ? Icon(Icons.check_circle, color: AdminColors.primaryGreen, size: 18) : null,
                          onTap: () {
                            Navigator.of(ctx).pop();
                            viewModel.assignCustomerLocation(customer, loc);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Customer ${customer.name} assigned to ${loc.name} Hub'),
                                backgroundColor: AdminColors.primaryGreen,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            if (customer.locationId != null || customer.locationName != null)
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  viewModel.assignCustomerLocation(customer, null);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Customer ${customer.name} location cleared (Unassigned)'),
                      backgroundColor: Colors.grey[800],
                    ),
                  );
                },
                child: const Text('Clear Hub', style: TextStyle(color: Colors.redAccent)),
              ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  AdminCustomersViewModel viewModelBuilder(BuildContext context) => AdminCustomersViewModel();
}
