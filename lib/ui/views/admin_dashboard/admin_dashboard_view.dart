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
                    SizedBox(
                      width: double.infinity,
                      child: actionButton,
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  welcomeSection,
                  actionButton,
                ],
              );
            },
          ),
          const SizedBox(height: 24),

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
                children: [
                  AdminMetricCard(
                    title: "Today's Sales",
                    value: '₹${viewModel.todaySales.toStringAsFixed(0)}',
                    icon: Icons.payments_outlined,
                    iconColor: Colors.green,
                    subtitle: "+14.2% from yesterday",
                  ),
                  AdminMetricCard(
                    title: "Total Orders",
                    value: '${viewModel.ordersCount}',
                    icon: Icons.shopping_bag_outlined,
                    iconColor: Colors.blue,
                    subtitle: "+2 new orders",
                  ),
                  AdminMetricCard(
                    title: "Low Stock Spares",
                    value: '${viewModel.lowStockCount}',
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.orange,
                    subtitle: "Needs replenishment",
                  ),
                  AdminMetricCard(
                    title: "Pending Requests",
                    value: '${viewModel.pendingRequestsCount}',
                    icon: Icons.support_agent_rounded,
                    iconColor: Colors.red,
                    subtitle: "Chats awaiting reply",
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
                              'Low Stock Alerts',
                              style: AdminTextStyles.body
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            if (viewModel.lowStockProducts.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Text('No low stock alerts',
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
              'Total',
              'Status',
              'Action'
            ],
            rows: viewModel.recentOrders.map((order) {
              return AdminTableRow(
                onTap: () => viewModel.openOrderDetail(order),
                cells: [
                  Text(order.orderNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      '${order.date.day}/${order.date.month}/${order.date.year}'),
                  Text(order.address.name),
                  Text('₹${order.total}'),
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
