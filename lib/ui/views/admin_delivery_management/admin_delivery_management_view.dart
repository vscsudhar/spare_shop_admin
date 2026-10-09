import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:spare_shop_admin/core/models/delivery_models.dart';
import 'package:spare_shop_admin/core/services/delivery_service.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/views/admin_delivery_management/admin_delivery_management_viewmodel.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:stacked/stacked.dart';

class AdminDeliveryManagementView
    extends StackedView<AdminDeliveryManagementViewModel> {
  const AdminDeliveryManagementView({super.key});

  @override
  AdminDeliveryManagementViewModel viewModelBuilder(BuildContext context) =>
      AdminDeliveryManagementViewModel();

  @override
  void onViewModelReady(AdminDeliveryManagementViewModel viewModel) =>
      viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    AdminDeliveryManagementViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: 'Delivery Management',
      selectedItem: AdminNavigationItem.deliveryManagement,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, viewModel),
          const SizedBox(height: AdminSpacing.m),
          _buildTabBar(context, viewModel),
          const SizedBox(height: AdminSpacing.l),
          if (viewModel.isBusy)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48.0),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            if (viewModel.currentTabIndex == 0)
              _buildAssignDeliveriesTab(context, viewModel)
            else if (viewModel.currentTabIndex == 1)
              _buildDeliveryAssignmentsTab(context, viewModel)
            else
              _buildMonitorTab(context, viewModel),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AdminDeliveryManagementViewModel viewModel,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Management',
              style: AdminTextStyles.header.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              'Assign customer orders to delivery partners, optimize routes, and manage dispatch batches.',
              style: AdminTextStyles.bodySecondary,
            ),
          ],
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminRadius.chip),
            ),
          ),
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Refresh Data'),
          onPressed: viewModel.loadData,
        ),
      ],
    );
  }

  Widget _buildTabBar(
    BuildContext context,
    AdminDeliveryManagementViewModel viewModel,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tabButton(
            context,
            title: '1. Assign Deliveries',
            icon: Icons.person_add_alt_1_rounded,
            isSelected: viewModel.currentTabIndex == 0,
            badgeCount: viewModel.totalSelectedOrdersCount > 0
                ? viewModel.totalSelectedOrdersCount
                : null,
            onTap: () => viewModel.setTabIndex(0),
          ),
          const SizedBox(width: 6),
          _tabButton(
            context,
            title: '2. Delivery Assignments',
            icon: Icons.local_shipping_rounded,
            isSelected: viewModel.currentTabIndex == 1,
            badgeCount: viewModel.assignments.isNotEmpty
                ? viewModel.assignments.length
                : null,
            onTap: () => viewModel.setTabIndex(1),
          ),
          const SizedBox(width: 6),
          _tabButton(
            context,
            title: '3. Monitor',
            icon: Icons.radar_rounded,
            isSelected: viewModel.currentTabIndex == 2,
            onTap: () => viewModel.setTabIndex(2),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AdminColors.primaryGreen.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AdminColors.primaryGreen.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AdminColors.primaryGreen
                  : AdminColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AdminColors.primaryGreen
                    : AdminColors.textPrimary,
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AdminColors.primaryGreen
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =============================================================
  // TAB 1: ASSIGN DELIVERIES CONTENT
  // =============================================================

  Widget _buildAssignDeliveriesTab(
    BuildContext context,
    AdminDeliveryManagementViewModel viewModel,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1050;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPartnerSelectorSection(context, viewModel),
            const SizedBox(height: AdminSpacing.l),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildEligibleOrdersList(context, viewModel),
                  ),
                  const SizedBox(width: AdminSpacing.l),
                  Expanded(
                    flex: 6,
                    child: _buildRouteAndSummaryPanel(context, viewModel),
                  ),
                ],
              )
            else ...[
              _buildEligibleOrdersList(context, viewModel),
              const SizedBox(height: AdminSpacing.l),
              _buildRouteAndSummaryPanel(context, viewModel),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPartnerSelectorSection(
    BuildContext context,
    AdminDeliveryManagementViewModel viewModel,
  ) {
    final activeStaff = viewModel.deliveryPartners
        .where((p) => p.isActive)
        .toList();

    return Container(
      padding: const EdgeInsets.all(AdminSpacing.m),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AdminColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.badge_rounded,
                  color: AdminColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step 1: Select Delivery Partner from Staff & Roles',
                    style: AdminTextStyles.cardTitle.copyWith(fontSize: 15),
                  ),
                  Text(
                    'Only active staff with delivery permissions are listed. You can reassign or split at any time.',
                    style: AdminTextStyles.bodySecondary.copyWith(fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),
              if (viewModel.totalSelectedOrdersCount > 10 &&
                  !viewModel.isSplitMode)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFF59E0B),
                  ),
                  icon: const Icon(Icons.call_split_rounded, size: 18),
                  label: const Text('Split with 2nd Partner'),
                  onPressed: viewModel.enableSplitMode,
                )
              else if (viewModel.isSplitMode)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Disable Split Mode'),
                  onPressed: viewModel.disableSplitMode,
                ),
            ],
          ),
          const Divider(height: 24),
          if (viewModel.deliveryPartners.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'No active delivery partners found in Staff & Roles. Please check staff settings.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            viewModel.isSplitMode
                                ? 'Primary Partner (Partner 1):'
                                : 'Select Delivery Partner:',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (viewModel.selectedPartner1 != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AdminColors.primaryGreen
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${viewModel.partner1Orders.length} orders assigned',
                                style: TextStyle(
                                  color: AdminColors.primaryGreen,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AdminColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: viewModel.selectedPartner1?.id,
                            hint: const Text('Select Staff Name ▼'),
                            onChanged: (id) {
                              if (id != null) {
                                final p = viewModel.deliveryPartners
                                    .firstWhere((item) => item.id == id);
                                viewModel.setPartner1(p);
                              }
                            },
                            items: activeStaff.map((p) {
                              return DropdownMenuItem<String>(
                                value: p.id,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: AdminColors.primaryGreen
                                          .withValues(alpha: 0.2),
                                      child: Text(
                                        p.name.isNotEmpty
                                            ? p.name[0].toUpperCase()
                                            : 'D',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AdminColors.primaryGreen,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      p.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${p.role})',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (p.activeOrdersCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${p.activeOrdersCount} in transit',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (viewModel.isSplitMode) ...[
                  const SizedBox(width: AdminSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Secondary Partner (Partner 2):',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (viewModel.selectedPartner2 != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${viewModel.partner2Orders.length} orders assigned',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.5)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: viewModel.selectedPartner2?.id,
                              hint: const Text('Select Second Staff Name ▼'),
                              onChanged: (id) {
                                if (id != null) {
                                  final p = viewModel.deliveryPartners
                                      .firstWhere((item) => item.id == id);
                                  viewModel.setPartner2(p);
                                }
                              },
                              items: activeStaff
                                  .where((p) =>
                                      p.id != viewModel.selectedPartner1?.id)
                                  .map((p) {
                                return DropdownMenuItem<String>(
                                  value: p.id,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor:
                                            Colors.blue.withValues(alpha: 0.2),
                                        child: Text(
                                          p.name.isNotEmpty
                                              ? p.name[0].toUpperCase()
                                              : 'D',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        p.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${p.role})',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEligibleOrdersList(
    BuildContext context,
    AdminDeliveryManagementViewModel viewModel,
  ) {
    final list = viewModel.filteredEligibleOrders;

    return Container(
      padding: const EdgeInsets.all(AdminSpacing.m),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step 2: Eligible Orders (${list.length} available)',
                style: AdminTextStyles.cardTitle.copyWith(fontSize: 15),
              ),
              Text(
                'Assign One-by-One',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search and Direction Filters
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Search order #, customer, address...',
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon:
                        const Icon(Icons.search_rounded, size: 18),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AdminColors.border),
                    ),
                  ),
                  onChanged: viewModel.setOrderSearchQuery,
                ),
              ),
              const SizedBox(width: 8),
              _directionFilterChip(viewModel, 'All'),
              const SizedBox(width: 4),
              _directionFilterChip(viewModel, 'North'),
              const SizedBox(width: 4),
              _directionFilterChip(viewModel, 'South'),
              const SizedBox(width: 4),
              _directionFilterChip(viewModel, 'East'),
              const SizedBox(width: 4),
              _directionFilterChip(viewModel, 'West'),
            ],
          ),
          const Divider(height: 20),
          if (list.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'No eligible orders match your criteria.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final order = list[index];
                final isSelected = viewModel.isOrderSelected(order);

                return _buildOrderCard(context, viewModel, order, isSelected);
              },
            ),
        ],
      ),
    );
  }

  Widget _directionFilterChip(
      AdminDeliveryManagementViewModel viewModel, String dir) {
    final isSelected = viewModel.selectedDirectionFilter == dir;
    return InkWell(
      onTap: () => viewModel.setDirectionFilter(dir),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AdminColors.primaryGreen.withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? AdminColors.primaryGreen
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          dir,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AdminColors.primaryGreen : AdminColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    AdminDeliveryManagementViewModel viewModel,
    DeliveryOrderModel order,
    bool isSelected,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? AdminColors.primaryGreen.withValues(alpha: 0.06)
            : AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? AdminColors.primaryGreen.withValues(alpha: 0.5)
              : AdminColors.border,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                order.orderNumber,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '🧭 ${order.direction}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              if (order.distanceKm != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '📍 ${order.distanceKm} km',
                    style: const TextStyle(
                      color: Colors.purple,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                '₹${order.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF0F9F59),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? Colors.red.shade400
                      : AdminColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: const Size(60, 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () =>
                    viewModel.toggleOrderSelection(order, context),
                child: Text(
                  isSelected ? 'Remove' : '+ Assign',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                order.customerName,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                order.customerPhone,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: order.paymentStatus.toLowerCase() == 'paid'
                      ? Colors.green.withValues(alpha: 0.12)
                      : Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      order.paymentStatus.toLowerCase() == 'paid'
                          ? Icons.check_circle_outline
                          : Icons.pending_outlined,
                      size: 11,
                      color: order.paymentStatus.toLowerCase() == 'paid'
                          ? Colors.green.shade700
                          : Colors.amber.shade800,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      order.paymentStatus.toLowerCase() == 'paid'
                          ? 'PAID (${order.paymentMethod.toUpperCase()})'
                          : 'UNPAID (${order.paymentMethod.toUpperCase()})',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: order.paymentStatus.toLowerCase() == 'paid'
                            ? Colors.green.shade700
                            : Colors.amber.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.address,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (order.hasCoordinates)
                const Icon(Icons.check_circle, size: 12, color: Colors.green)
              else
                const Icon(Icons.warning_amber_rounded,
                    size: 12, color: Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================
  // TAB 1 RIGHT PANEL: SELECTED STOPS, OSM ROUTE & CONFIRMATION
  // =============================================================

  Widget _buildRouteAndSummaryPanel(
    BuildContext context,
    AdminDeliveryManagementViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Map Container
        _buildOpenStreetMapSection(context, viewModel),
        const SizedBox(height: AdminSpacing.m),

        // Partner 1 Assigned Orders Bucket
        _buildPartnerOrdersBucket(
          context,
          viewModel,
          partnerNum: 1,
          partner: viewModel.selectedPartner1,
          orders: viewModel.partner1Orders,
          route: viewModel.partner1Route,
          isCalculating: viewModel.isCalculatingRoute1,
        ),

        // Partner 2 Assigned Orders Bucket (if in split mode)
        if (viewModel.isSplitMode) ...[
          const SizedBox(height: AdminSpacing.m),
          _buildPartnerOrdersBucket(
            context,
            viewModel,
            partnerNum: 2,
            partner: viewModel.selectedPartner2,
            orders: viewModel.partner2Orders,
            route: viewModel.partner2Route,
            isCalculating: viewModel.isCalculatingRoute2,
          ),
        ],

        const SizedBox(height: AdminSpacing.l),
        // Confirm Button
        Builder(
          builder: (context) {
            final totalAmt = viewModel.partner1Orders.fold(0.0, (sum, o) => sum + o.amount) +
                viewModel.partner2Orders.fold(0.0, (sum, o) => sum + o.amount);
            return SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F9F59),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: Text(
                  'Confirm & Dispatch Assignment (${viewModel.totalSelectedOrdersCount} Orders • ₹${totalAmt.toStringAsFixed(2)})',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                onPressed: viewModel.totalSelectedOrdersCount > 0
                    ? () => viewModel.confirmAssignment(context)
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOpenStreetMapSection(
    BuildContext context,
    AdminDeliveryManagementViewModel viewModel,
  ) {
    // Combine stops for map markers
    final allStops = [
      ...viewModel.partner1Orders,
      ...viewModel.partner2Orders,
    ];

    final markers = <Marker>[
      // Hub marker
      Marker(
        point: const LatLng(DeliveryService.hubLatitude, DeliveryService.hubLongitude),
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F9F59),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
        ),
      ),
    ];

    // Numbered Pin Markers
    for (int i = 0; i < viewModel.partner1Orders.length; i++) {
      final ord = viewModel.partner1Orders[i];
      if (ord.hasCoordinates) {
        markers.add(
          Marker(
            point: LatLng(ord.latitude!, ord.longitude!),
            width: 34,
            height: 34,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              alignment: Alignment.center,
              child: Text(
                '${i + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }
    }

    if (viewModel.isSplitMode) {
      for (int k = 0; k < viewModel.partner2Orders.length; k++) {
        final ord = viewModel.partner2Orders[k];
        if (ord.hasCoordinates) {
          markers.add(
            Marker(
              point: LatLng(ord.latitude!, ord.longitude!),
              width: 34,
              height: 34,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                alignment: Alignment.center,
                child: Text(
                  '${k + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    final polylines = <Polyline>[];
    if (viewModel.partner1Route != null &&
        viewModel.partner1Route!.polyline.isNotEmpty) {
      polylines.add(
        Polyline(
          points: viewModel.partner1Route!.polyline,
          color: const Color(0xFF10B981),
          strokeWidth: 4.0,
        ),
      );
    }
    if (viewModel.partner2Route != null &&
        viewModel.partner2Route!.polyline.isNotEmpty) {
      polylines.add(
        Polyline(
          points: viewModel.partner2Route!.polyline,
          color: Colors.blue.shade600,
          strokeWidth: 4.0,
        ),
      );
    }

    final totalKm = (viewModel.partner1Route?.totalDistanceKm ?? 0) +
        (viewModel.partner2Route?.totalDistanceKm ?? 0);
    final totalMin = (viewModel.partner1Route?.totalDurationMinutes ?? 0) +
        (viewModel.partner2Route?.totalDurationMinutes ?? 0);

    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(DeliveryService.hubLatitude, DeliveryService.hubLongitude),
              initialZoom: 12.8,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.voltspare.spare_shop_admin',
              ),
              PolylineLayer(polylines: polylines),
              MarkerLayer(markers: markers),
            ],
          ),
          // Route Stats Floating Banner
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.route_rounded, color: Colors.greenAccent, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Route Sequence: ${allStops.length} Stops',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (totalKm > 0) ...[
                    Text(
                      '~${totalKm.toStringAsFixed(1)} km  •  ~${totalMin.toStringAsFixed(0)} mins',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerOrdersBucket(
    BuildContext context,
    AdminDeliveryManagementViewModel viewModel, {
    required int partnerNum,
    required DeliveryPartnerModel? partner,
    required List<DeliveryOrderModel> orders,
    required RouteResult? route,
    required bool isCalculating,
  }) {
    final themeColor =
        partnerNum == 1 ? const Color(0xFF0F9F59) : Colors.blue.shade600;

    return Container(
      padding: const EdgeInsets.all(AdminSpacing.m),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: themeColor.withValues(alpha: 0.2),
                child: Text(
                  '$partnerNum',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Partner $partnerNum: ${partner?.name ?? "Select Staff"}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${orders.length} Stops  •  ₹${orders.fold(0.0, (sum, o) => sum + o.amount).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
              ),
            ],
          ),
          if (orders.length > 10 && partnerNum == 1 && !viewModel.isSplitMode) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'More than 10 orders assigned to this partner. Delivery capacity high.',
                      style: TextStyle(fontSize: 11, color: Colors.brown),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Divider(height: 20),
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No orders selected yet for Partner $partnerNum.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              onReorder: (oldIdx, newIdx) {
                if (partnerNum == 1) {
                  viewModel.movePartner1Stop(oldIdx, newIdx);
                } else {
                  viewModel.movePartner2Stop(oldIdx, newIdx);
                }
              },
              itemBuilder: (context, index) {
                final ord = orders[index];
                return ListTile(
                  key: ValueKey('stop_${partnerNum}_${ord.id}'),
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: themeColor.withValues(alpha: 0.15),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        '${ord.orderNumber} – ${ord.customerName}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${ord.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F9F59),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    ord.address,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (viewModel.isSplitMode) ...[
                        if (partnerNum == 1)
                          IconButton(
                            icon: const Icon(Icons.arrow_downward_rounded, size: 16),
                            tooltip: 'Transfer to Partner 2',
                            onPressed: () => viewModel.transferToPartner2(ord),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                            tooltip: 'Transfer to Partner 1',
                            onPressed: () => viewModel.transferToPartner1(ord),
                          ),
                      ],
                      IconButton(
                        icon: const Icon(Icons.close, size: 16, color: Colors.red),
                        tooltip: 'Remove from assignment',
                        onPressed: () => viewModel.removePendingOrder(ord),
                      ),
                      const Icon(Icons.drag_indicator, size: 16, color: Colors.grey),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // =============================================================
  // TAB 2: DELIVERY ASSIGNMENTS CONTENT
  // =============================================================

  Widget _buildDeliveryAssignmentsTab(
    BuildContext context,
    AdminDeliveryManagementViewModel viewModel,
  ) {
    final list = viewModel.filteredAssignments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.all(AdminSpacing.m),
          decoration: BoxDecoration(
            color: AdminColors.panelBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AdminColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Search batch #, delivery partner, order #...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AdminColors.border),
                    ),
                  ),
                  onChanged: viewModel.setAssignmentSearchQuery,
                ),
              ),
              const SizedBox(width: AdminSpacing.m),
              // Status filter
              DropdownButton<String>(
                value: viewModel.assignmentStatusFilter,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
                items: ['All', 'Assigned', 'In Transit', 'Completed', 'Cancelled']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) viewModel.setAssignmentStatusFilter(val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AdminSpacing.m),

        if (list.isEmpty)
          Container(
            padding: const EdgeInsets.all(48),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AdminColors.panelBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.local_shipping_outlined,
                    size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text(
                  'No delivery assignments found.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create new assignments from the "Assign Deliveries" tab.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: AdminSpacing.m),
            itemBuilder: (context, index) {
              final assignment = list[index];
              return _buildAssignmentCard(context, viewModel, assignment);
            },
          ),
      ],
    );
  }

  Color _getStopStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'delivered' || s == 'completed') return Colors.green;
    if (s == 'shipped' || s == 'in_transit' || s == 'out_for_delivery') {
      return Colors.blue;
    }
    if (s == 'cancelled' || s == 'returned') return Colors.red;
    return Colors.orange;
  }

  Widget _buildAssignmentCard(
    BuildContext context,
    AdminDeliveryManagementViewModel viewModel,
    DeliveryAssignmentModel assignment,
  ) {
    Color statusColor;
    if (assignment.status == 'completed') {
      statusColor = Colors.green;
    } else if (assignment.status == 'in_transit') {
      statusColor = Colors.blue;
    } else if (assignment.status == 'cancelled') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.orange;
    }

    return Container(
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminColors.border),
      ),
      padding: const EdgeInsets.all(AdminSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AdminColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  assignment.batchNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AdminColors.primaryGreen,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.blue.withValues(alpha: 0.15),
                child: const Icon(Icons.person, size: 14, color: Colors.blue),
              ),
              const SizedBox(width: 6),
              Text(
                assignment.driverName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Spacer(),
              // Clickable Batch Status Dropdown Selector
              PopupMenuButton<String>(
                tooltip: 'Change Batch Status (Syncs to Orders Module)',
                initialValue: assignment.status,
                onSelected: (newStatus) {
                  viewModel.updateBatchStatus(assignment, newStatus, context);
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'assigned',
                    child: Row(
                      children: [
                        Icon(Icons.assignment_outlined, size: 16, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Assigned (Processing)', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'in_transit',
                    child: Row(
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('In Transit (Shipped)', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'completed',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Completed (Delivered)', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'cancelled',
                    child: Row(
                      children: [
                        Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Cancelled', style: TextStyle(fontSize: 12, color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        assignment.status.toUpperCase().replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, size: 16, color: statusColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${assignment.orders.length} Orders  •  Total: ₹${assignment.totalAmount.toStringAsFixed(2)}  •  Dispatched by: ${assignment.assignedByName}  •  ${assignment.assignedAt.toString().substring(0, 16)}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const Spacer(),
              if (assignment.totalDistanceKm != null)
                Text(
                  '~${assignment.totalDistanceKm} km (${assignment.estimatedDurationMin?.toStringAsFixed(0)} mins)',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple),
                ),
            ],
          ),
          const Divider(height: 16),
          // Ordered Stops
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assignment.orders.length,
            separatorBuilder: (_, __) => Divider(height: 8, color: Colors.grey.shade200),
            itemBuilder: (context, idx) {
              final ord = assignment.orders[idx];
              final stopColor = _getStopStatusColor(ord.orderStatus);
              return Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.grey.shade300,
                    child: Text(
                      '${idx + 1}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ord.orderNumber,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ord.customerName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ord.address,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (ord.distanceKm != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '📍 ${ord.distanceKm} km',
                        style: const TextStyle(
                          color: Colors.purple,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    '₹${ord.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F9F59),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: ord.paymentStatus.toLowerCase() == 'paid'
                          ? Colors.green.withValues(alpha: 0.12)
                          : Colors.amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ord.paymentStatus.toLowerCase() == 'paid'
                          ? (ord.paymentMethod.isNotEmpty
                              ? 'PAID (${ord.paymentMethod.toUpperCase()})'
                              : 'PAID')
                          : (ord.paymentMethod.isNotEmpty
                              ? 'UNPAID (${ord.paymentMethod.toUpperCase()})'
                              : 'UNPAID (COD)'),
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: ord.paymentStatus.toLowerCase() == 'paid'
                            ? Colors.green.shade700
                            : Colors.amber.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Stop Status Selector Popup
                  PopupMenuButton<String>(
                    tooltip: 'Change Stop Order Status (Reflects in Orders Module)',
                    initialValue: ord.orderStatus,
                    onSelected: (newStatus) {
                      viewModel.updateOrderStopStatus(
                        assignment,
                        ord,
                        newStatus,
                        context,
                      );
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'processing',
                        child: Row(
                          children: [
                            Icon(Icons.hourglass_top, size: 14, color: Colors.orange),
                            SizedBox(width: 6),
                            Text('Processing', style: TextStyle(fontSize: 11.5)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'shipped',
                        child: Row(
                          children: [
                            Icon(Icons.local_shipping_outlined, size: 14, color: Colors.blue),
                            SizedBox(width: 6),
                            Text('In Transit (Shipped)', style: TextStyle(fontSize: 11.5)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delivered',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
                            SizedBox(width: 6),
                            Text('Delivered', style: TextStyle(fontSize: 11.5)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'cancelled',
                        child: Row(
                          children: [
                            Icon(Icons.cancel_outlined, size: 14, color: Colors.red),
                            SizedBox(width: 6),
                            Text('Cancelled', style: TextStyle(fontSize: 11.5, color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: stopColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: stopColor.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ord.orderStatus.toUpperCase().replaceAll('_', ' '),
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              color: stopColor,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.arrow_drop_down, size: 12, color: stopColor),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    tooltip: 'Remove order from batch',
                    onPressed: () => viewModel.removeOrderFromBatch(
                      assignment,
                      ord,
                      context,
                    ),
                  ),
                ],
              );
            },
          ),
          const Divider(height: 16),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  side: BorderSide(color: Colors.blue.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                icon: const Icon(Icons.person_search_rounded, size: 16),
                label: const Text('Reassign Partner', style: TextStyle(fontSize: 11)),
                onPressed: () => _showReassignPartnerModal(context, viewModel, assignment),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AdminColors.primaryGreen,
                  side: BorderSide(color: AdminColors.primaryGreen),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text('+ Add Order', style: TextStyle(fontSize: 11)),
                onPressed: () => _showAddOrderModal(context, viewModel, assignment),
              ),
              const SizedBox(width: 8),
              if (assignment.status == 'assigned')
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  onPressed: () => viewModel.updateBatchStatus(
                      assignment, 'in_transit', context),
                  child: const Text('Mark In Transit', style: TextStyle(fontSize: 11)),
                )
              else if (assignment.status == 'in_transit')
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  onPressed: () => viewModel.updateBatchStatus(
                      assignment, 'completed', context),
                  child: const Text('Mark Completed', style: TextStyle(fontSize: 11)),
                ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                tooltip: 'All Status Options',
                onSelected: (newStatus) {
                  viewModel.updateBatchStatus(assignment, newStatus, context);
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'assigned',
                    child: Text('Set: Assigned (Processing)', style: TextStyle(fontSize: 12)),
                  ),
                  const PopupMenuItem(
                    value: 'in_transit',
                    child: Text('Set: In Transit (Shipped)', style: TextStyle(fontSize: 12)),
                  ),
                  const PopupMenuItem(
                    value: 'completed',
                    child: Text('Set: Completed (Delivered)', style: TextStyle(fontSize: 12)),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'cancelled',
                    child: Text('Cancel Batch', style: TextStyle(fontSize: 12, color: Colors.red)),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.more_vert, size: 16, color: Colors.black87),
                      SizedBox(width: 4),
                      Text('Status Options', style: TextStyle(fontSize: 11, color: Colors.black87)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReassignPartnerModal(
    BuildContext context,
    AdminDeliveryManagementViewModel viewModel,
    DeliveryAssignmentModel assignment,
  ) {
    DeliveryPartnerModel? selected;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setLocalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Reassign ${assignment.batchNumber}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select new delivery partner from Staff & Roles:'),
                const SizedBox(height: 12),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selected?.id,
                  hint: const Text('Select Partner'),
                  items: viewModel.deliveryPartners
                      .where((p) => p.id != assignment.driverId && p.isActive)
                      .map((p) => DropdownMenuItem(
                            value: p.id,
                            child: Text('${p.name} (${p.role})'),
                          ))
                      .toList(),
                  onChanged: (id) {
                    if (id != null) {
                      setLocalState(() {
                        selected = viewModel.deliveryPartners
                            .firstWhere((p) => p.id == id);
                      });
                    }
                  },
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
                  backgroundColor: AdminColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: selected != null
                    ? () {
                        Navigator.of(ctx).pop();
                        viewModel.reassignDriverInBatch(
                            assignment, selected!, context);
                      }
                    : null,
                child: const Text('Reassign'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddOrderModal(
    BuildContext context,
    AdminDeliveryManagementViewModel viewModel,
    DeliveryAssignmentModel assignment,
  ) {
    final eligible = viewModel.eligibleOrders;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Order to ${assignment.batchNumber}'),
        content: SizedBox(
          width: 500,
          child: eligible.isEmpty
              ? const Text('No available unassigned orders.')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: eligible.length,
                  separatorBuilder: (_, __) => const Divider(height: 8),
                  itemBuilder: (context, idx) {
                    final ord = eligible[idx];
                    return ListTile(
                      dense: true,
                      title: Text('${ord.orderNumber} – ${ord.customerName}'),
                      subtitle: Text(ord.address, maxLines: 1),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.primaryGreen,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          viewModel.addOrderToBatch(assignment, ord, context);
                        },
                        child: const Text('+ Add', style: TextStyle(fontSize: 11)),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // TAB 3: MONITOR CONTENT (PLACEHOLDER ONLY)
  // =============================================================

  Widget _buildMonitorTab(
    BuildContext context,
    AdminDeliveryManagementViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(AdminSpacing.l),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.radar_rounded, color: Colors.blue, size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Partner Live Monitoring',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'View assigned delivery partner status and launch partner monitoring.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 32),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.monitorPartners.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final partner = viewModel.monitorPartners[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AdminColors.primaryGreen.withValues(alpha: 0.2),
                  child: Text(
                    partner.name.isNotEmpty ? partner.name[0].toUpperCase() : 'D',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AdminColors.primaryGreen,
                    ),
                  ),
                ),
                title: Text(
                  partner.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  '${partner.role}  •  ${partner.phone.isNotEmpty ? partner.phone : "+91 98765 00000"}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: partner.activeOrdersCount > 0
                            ? Colors.green.withValues(alpha: 0.12)
                            : Colors.grey.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${partner.activeOrdersCount} Assigned Orders',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: partner.activeOrdersCount > 0
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.radar, size: 16),
                      label: const Text('Monitor', style: TextStyle(fontSize: 12)),
                      onPressed: () => viewModel.showMonitorPlaceholder(context, partner),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
