import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_table_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_orders_viewmodel.dart';

class AdminOrdersView extends StackedView<AdminOrdersViewModel> {
  const AdminOrdersView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminOrdersViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: 'Customer Orders',
      selectedItem: AdminNavigationItem.orders,
      onSearch: viewModel.setSearchQuery,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('All Customer Transactions',
                  style: AdminTextStyles.sectionHeader),
              Row(
                children: [
                  Text(
                    'Showing ${viewModel.filteredOrders.length} orders',
                    style: AdminTextStyles.bodySecondary,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: viewModel.isBusy ? null : () => viewModel.loadOrders(),
                    icon: const Icon(Icons.refresh, size: 18, color: Colors.white70),
                    tooltip: 'Refresh Orders',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AdminFilterChip(
                  label: 'All',
                  isSelected: viewModel.selectedStatus == null,
                  onTap: () => viewModel.setFilterStatus(null),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Processing',
                  isSelected:
                      viewModel.selectedStatus == OrderStatus.processing,
                  onTap: () =>
                      viewModel.setFilterStatus(OrderStatus.processing),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Shipped',
                  isSelected: viewModel.selectedStatus == OrderStatus.shipped,
                  onTap: () => viewModel.setFilterStatus(OrderStatus.shipped),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Delivered',
                  isSelected: viewModel.selectedStatus == OrderStatus.delivered,
                  onTap: () => viewModel.setFilterStatus(OrderStatus.delivered),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Cancelled',
                  isSelected: viewModel.selectedStatus == OrderStatus.cancelled,
                  onTap: () => viewModel.setFilterStatus(OrderStatus.cancelled),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Orders Data Table
          AdminDataTable(
            columns: const [
              'Order Number',
              'Date',
              'Customer',
              'Amount',
              'Status',
              'Channel',
              'Details'
            ],
            rows: viewModel.filteredOrders.map((order) {
              return AdminTableRow(
                onTap: () => viewModel.openOrderDetail(order),
                cells: [
                  Text(order.orderNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      '${order.date.day}/${order.date.month}/${order.date.year}'),
                  Text(order.address.name),
                  Text('₹${order.total}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AdminStatusChip(
                      label: order.status.name,
                      color: _statusColor(order.status),
                    ),
                  ),
                  Text(order.paymentMethod.contains('UPI')
                      ? 'Online'
                      : 'POS Store'),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => viewModel.openOrderDetail(order),
                      child: Text('Manage',
                          style: TextStyle(
                              color: AdminColors.primaryGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ),
                  )
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
  AdminOrdersViewModel viewModelBuilder(BuildContext context) =>
      AdminOrdersViewModel();
}
