import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_chart_widgets.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_table_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_dashboard_viewmodel.dart';

class AdminDashboardView extends StackedView<AdminDashboardViewModel> {
  const AdminDashboardView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminDashboardViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: 'Dashboard Overview',
      selectedItem: AdminNavigationItem.dashboard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final welcomeSection = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning, Admin',
                    style: AdminTextStyles.header.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Here is what is happening with your store today.',
                    style: AdminTextStyles.bodySecondary,
                  ),
                ],
              );

              final locationDropdown =
                  _buildLocationDropdown(context, viewModel);

              final actionButton = ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Please navigate to Billing/POS to create new orders.')),
                  );
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              );

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    welcomeSection,
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        locationDropdown,
                        actionButton,
                      ],
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  welcomeSection,
                  Row(
                    children: [
                      locationDropdown,
                      const SizedBox(width: 12),
                      actionButton,
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Location Filter Context Banner
          if (viewModel.isLocationSelected &&
              viewModel.selectedLocation != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AdminColors.primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AdminColors.primaryGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 18,
                    color: AdminColors.primaryGreen,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Viewing analytics for ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AdminColors.textPrimary,
                        ),
                        children: [
                          TextSpan(
                            text: viewModel.selectedLocation!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' (${viewModel.selectedLocation!.radiusDisplay} coverage)',
                            style: TextStyle(
                              color: AdminColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: viewModel.goToSelectedLocationInventory,
                    icon: const Icon(Icons.inventory_2_outlined, size: 15),
                    label: const Text('Manage Stock',
                        style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: AdminColors.primaryGreen,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  if (viewModel.canChangeLocation) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      tooltip: 'Clear location filter',
                      onPressed: () => viewModel.setLocation(null),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Metrics Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < AdminBreakpoints.mobile;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isMobile ? 2 : 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 1.4 : 1.7,
                children: viewModel.isLocationSelected
                    ? [
                        AdminMetricCard(
                          title: "Tracked Spares",
                          value: '${viewModel.trackedSparesCount}',
                          icon: Icons.inventory_2_outlined,
                          iconColor: Colors.blue,
                          subtitle: "Catalog items assigned",
                          onTap: viewModel.goToSelectedLocationInventory,
                        ),
                        AdminMetricCard(
                          title: "In Stock Units",
                          value: '${viewModel.inStockCount}',
                          icon: Icons.check_circle_outline,
                          iconColor: AdminColors.primaryGreen,
                          subtitle: "Ready for delivery",
                          onTap: viewModel.goToSelectedLocationInventory,
                        ),
                        AdminMetricCard(
                          title: "Low Stock Spares",
                          value: '${viewModel.lowStockCount}',
                          icon: Icons.warning_amber_rounded,
                          iconColor: Colors.orange,
                          subtitle: "Units < 10 threshold",
                          onTap: viewModel.goToSelectedLocationInventory,
                        ),
                        AdminMetricCard(
                          title: "Out of Stock",
                          value: '${viewModel.outOfStockCount}',
                          icon: Icons.error_outline_rounded,
                          iconColor: Colors.red,
                          subtitle: "0 stock records",
                          onTap: viewModel.goToSelectedLocationInventory,
                        ),
                      ]
                    : [
                        AdminMetricCard(
                          title: "Today's Sales",
                          value: '₹${viewModel.todaySales.toStringAsFixed(0)}',
                          icon: Icons.payments_outlined,
                          iconColor: Colors.green,
                          subtitle: "+14.2% from yesterday",
                          onTap: viewModel.goToAdminBilling,
                        ),
                        AdminMetricCard(
                          title: "Total Orders",
                          value: '${viewModel.ordersCount}',
                          icon: Icons.shopping_bag_outlined,
                          iconColor: Colors.blue,
                          subtitle: "+2 new orders",
                          onTap: viewModel.goToAdminOrders,
                        ),
                        AdminMetricCard(
                          title: "Low Stock Spares",
                          value: '${viewModel.lowStockCount}',
                          icon: Icons.warning_amber_rounded,
                          iconColor: Colors.orange,
                          subtitle: "Needs replenishment",
                          onTap: viewModel.goToAdminInventory,
                        ),
                        AdminMetricCard(
                          title: "Pending Requests",
                          value: '${viewModel.pendingRequestsCount}',
                          icon: Icons.support_agent_rounded,
                          iconColor: Colors.red,
                          subtitle: "Chats awaiting reply",
                          onTap: viewModel.goToAdminRareRequests,
                        ),
                      ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Chart & Alerts Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final alertTitle = viewModel.isLocationSelected
                  ? 'Low Stock Alerts (${viewModel.selectedLocation?.name ?? "Location"})'
                  : 'Low Stock Alerts';

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: isWide ? 2 : 3,
                    child: SalesBarChart(
                      values: viewModel.salesChartValues,
                      labels: viewModel.salesChartLabels,
                    ),
                  ),
                  if (isWide) ...[
                    const SizedBox(width: 24),
                    Expanded(
                      child: AdminPanelCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alertTitle,
                              style: AdminTextStyles.body
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            if (viewModel.lowStockProducts.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Text(
                                    'No low stock alerts for this selection',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                              )
                            else
                              ...viewModel.lowStockProducts.take(4).map((prod) {
                                return LowStockAlertTile(
                                  name: prod['name'] ?? 'Spare Part',
                                  qty: prod['currentStock'] ?? 0,
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                  ]
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Recent Orders Table
          AdminSectionHeader(
            title: 'Recent Orders',
            trailing: TextButton(
              onPressed: viewModel.goToAdminOrders,
              child: Text('View All',
                  style: TextStyle(
                      color: AdminColors.primaryGreen,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          AdminDataTable(
            columns: const [
              'Order Number',
              'Date',
              'Customer',
              'Hub Location',
              'Channel',
              'Total',
              'Status',
              'Action'
            ],
            rows: viewModel.recentOrders.map((order) {
              final hasLoc =
                  order.locationName != null && order.locationName!.isNotEmpty;
              return AdminTableRow(
                onTap: () => viewModel.openOrderDetail(order),
                cells: [
                  Text(order.orderNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      '${order.date.day}/${order.date.month}/${order.date.year}'),
                  Text(order.address.name),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: hasLoc
                            ? AdminColors.primaryGreen.withValues(alpha: 0.12)
                            : Colors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: hasLoc
                              ? AdminColors.primaryGreen.withValues(alpha: 0.3)
                              : Colors.amber.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: hasLoc
                              ? AdminColors.primaryGreen
                              : Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hasLoc
                                ? '${order.locationName!} Hub'
                                : 'Unassigned',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: hasLoc
                                  ? AdminColors.primaryGreen
                                  : Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildChannelBadge(order),
                  ),
                  Text('₹${order.total.toStringAsFixed(2)}'),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AdminStatusChip(
                      label: order.status.name,
                      color: _statusColor(order.status),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => viewModel.openOrderDetail(order),
                      child: Text('Details',
                          style: TextStyle(
                              color: AdminColors.primaryGreen, fontSize: 13)),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDropdown(
    BuildContext context,
    AdminDashboardViewModel viewModel,
  ) {
    if (!viewModel.canChangeLocation) {
      final assignedName =
          viewModel.selectedLocation?.name ?? 'Assigned Branch';
      return Tooltip(
        message:
            'Location is fixed to your assigned hub. Only Owner and Hub Manager can change location.',
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AdminColors.panelBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AdminColors.primaryGreen.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: AdminColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              Text(
                '$assignedName Hub',
                style: TextStyle(
                  fontSize: 13,
                  color: AdminColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: viewModel.selectedLocationId,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          borderRadius: BorderRadius.circular(8),
          dropdownColor: AdminColors.panelBackground,
          style: TextStyle(
            fontSize: 13,
            color: AdminColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          hint: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AdminColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              const Text('All Locations'),
            ],
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.public,
                    size: 16,
                    color: AdminColors.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  const Text('All Locations (Global)'),
                ],
              ),
            ),
            ...viewModel.locations.map((loc) {
              return DropdownMenuItem<String?>(
                value: loc.id,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color:
                          loc.isActive ? AdminColors.primaryGreen : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(loc.name),
                    const SizedBox(width: 6),
                    Text(
                      '(${loc.radiusDisplay})',
                      style: TextStyle(
                        fontSize: 11,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: (val) => viewModel.setLocation(val),
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return AdminColors.pending;
      case OrderStatus.shipped:
        return AdminColors.inProgress;
      case OrderStatus.delivered:
        return AdminColors.success;
      case OrderStatus.cancelled:
        return AdminColors.cancelled;
    }
  }

  Widget _buildChannelBadge(OrderModel order) {
    final isPos = order.isPosOrder;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPos
            ? Colors.blue.withValues(alpha: 0.12)
            : AdminColors.primaryGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isPos
              ? Colors.blue.withValues(alpha: 0.3)
              : AdminColors.primaryGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPos ? Icons.point_of_sale_rounded : Icons.phone_android_rounded,
            size: 11,
            color: isPos ? Colors.lightBlueAccent : AdminColors.primaryGreen,
          ),
          const SizedBox(width: 4),
          Text(
            order.channelDisplayName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isPos ? Colors.lightBlueAccent : AdminColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  @override
  AdminDashboardViewModel viewModelBuilder(BuildContext context) =>
      AdminDashboardViewModel();
}

class LowStockAlertTile extends StatelessWidget {
  final String name;
  final int qty;

  const LowStockAlertTile({super.key, required this.name, required this.qty});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(name,
                style: AdminTextStyles.bodySecondary
                    .copyWith(fontWeight: FontWeight.bold)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AdminColors.cancelled.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$qty left',
              style: TextStyle(
                  color: AdminColors.cancelled,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
