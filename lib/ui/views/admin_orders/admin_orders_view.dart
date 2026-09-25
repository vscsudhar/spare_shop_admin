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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('All Customer Transactions',
                      style: AdminTextStyles.sectionHeader),
                  const SizedBox(height: 4),
                  Text(
                    'View, filter by location hub, and assign fulfillment locations to orders',
                    style: AdminTextStyles.bodySecondary.copyWith(fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AdminColors.panelBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AdminColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 14, color: AdminColors.primaryGreen),
                        const SizedBox(width: 6),
                        Text(
                          '${viewModel.filteredOrders.length} Orders',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed:
                        viewModel.isBusy ? null : () => viewModel.loadOrders(),
                    icon: const Icon(Icons.refresh,
                        size: 18, color: Colors.white70),
                    tooltip: 'Refresh Orders',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Location Filter Section & Hub Quick Selector
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminColors.panelBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AdminColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16, color: AdminColors.primaryGreen),
                    const SizedBox(width: 6),
                    Text(
                      'Fulfillment Hub Filter:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    if (!viewModel.canChangeLocation &&
                        viewModel.userAssignedLocationName != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock,
                                size: 12, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              'Scoped to ${viewModel.userAssignedLocationName}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      AdminFilterChip(
                        label: 'All Locations (HQ)',
                        isSelected: viewModel.selectedLocationFilter == 'all',
                        onTap: () => viewModel.setSelectedLocationFilter('all'),
                      ),
                      ...viewModel.locations.map((loc) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: AdminFilterChip(
                            label: '${loc.name} Hub',
                            isSelected:
                                viewModel.selectedLocationFilter == loc.id,
                            onTap: () =>
                                viewModel.setSelectedLocationFilter(loc.id),
                          ),
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: AdminFilterChip(
                          label: viewModel.unassignedOrdersCount > 0
                              ? '⚠️ Unassigned (${viewModel.unassignedOrdersCount})'
                              : 'Unassigned',
                          isSelected:
                              viewModel.selectedLocationFilter == 'unassigned',
                          onTap: () =>
                              viewModel.setSelectedLocationFilter('unassigned'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Filter row: Channel & Status Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Channel filters
                AdminFilterChip(
                  label: 'All Channels',
                  isSelected: viewModel.selectedChannelFilter == 'all',
                  onTap: () => viewModel.setSelectedChannelFilter('all'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: '📱 Mobile App (${viewModel.appOrdersCount})',
                  isSelected: viewModel.selectedChannelFilter == 'app',
                  onTap: () => viewModel.setSelectedChannelFilter('app'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: '🏪 Store POS (${viewModel.posOrdersCount})',
                  isSelected: viewModel.selectedChannelFilter == 'pos',
                  onTap: () => viewModel.setSelectedChannelFilter('pos'),
                ),
                const SizedBox(width: 14),
                Container(
                  height: 22,
                  width: 1,
                  color: Colors.white24,
                ),
                const SizedBox(width: 14),
                // Status filters
                AdminFilterChip(
                  label: 'All Statuses',
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
          const SizedBox(height: 18),

          // Orders Data Table
          AdminDataTable(
            columns: const [
              'Order Number',
              'Date',
              'Customer',
              'Hub Location',
              'Amount',
              'Status',
              'Channel',
              'Actions'
            ],
            rows: viewModel.filteredOrders.map((order) {
              final hasLocation =
                  order.locationName != null && order.locationName!.isNotEmpty;
              return AdminTableRow(
                onTap: () => viewModel.openOrderDetail(order),
                cells: [
                  Text(order.orderNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      '${order.date.day}/${order.date.month}/${order.date.year}'),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(order.address.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (order.address.addressLine.isNotEmpty)
                        Text(
                          order.address.addressLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11, color: AdminColors.textSecondary),
                        ),
                    ],
                  ),
                  // Location Column
                  Align(
                    alignment: Alignment.centerLeft,
                    child: hasLocation
                        ? InkWell(
                            onTap: () => _showAssignLocationDialog(
                                context, viewModel, order),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AdminColors.primaryGreen
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: AdminColors.primaryGreen
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on,
                                      size: 13,
                                      color: AdminColors.primaryGreen),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${order.locationName!} Hub',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AdminColors.primaryGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.swap_horiz_rounded,
                                      size: 14, color: Colors.white70),
                                ],
                              ),
                            ),
                          )
                        : OutlinedButton.icon(
                            onPressed: () => _showAssignLocationDialog(
                                context, viewModel, order),
                            icon: const Icon(Icons.add_location_alt,
                                size: 12, color: Colors.amber),
                            label: const Text(
                              '+ Assign Hub',
                              style:
                                  TextStyle(fontSize: 11, color: Colors.amber),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Colors.amber.withValues(alpha: 0.5)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                  ),
                  Text('₹${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AdminStatusChip(
                      label: order.status.name,
                      color: _statusColor(order.status),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildChannelBadge(order),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => viewModel.openOrderDetail(order),
                        child: Text('Manage',
                            style: TextStyle(
                                color: AdminColors.primaryGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        onPressed: () => _showAssignLocationDialog(
                            context, viewModel, order),
                        icon: const Icon(Icons.edit_location_alt_outlined,
                            size: 16, color: Colors.white70),
                        tooltip: 'Reassign Hub (e.g. if product out of stock)',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  )
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showAssignLocationDialog(
    BuildContext context,
    AdminOrdersViewModel viewModel,
    OrderModel order,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AdminColors.panelBackground,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(Icons.hub_outlined,
                  color: AdminColors.primaryGreen, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Fulfillment Hub for ${order.orderNumber}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Address & Current Hub Box
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
                        'Customer Delivery Address:',
                        style: TextStyle(
                            fontSize: 11,
                            color: AdminColors.textSecondary,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order.address.name} - ${order.address.addressLine}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            'Current Assigned Hub: ',
                            style: TextStyle(
                                fontSize: 11, color: AdminColors.textSecondary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: order.locationName != null
                                  ? AdminColors.primaryGreen
                                      .withValues(alpha: 0.2)
                                  : Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              order.locationName != null
                                  ? '${order.locationName!} Hub'
                                  : '⚠️ Unassigned',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: order.locationName != null
                                    ? AdminColors.primaryGreen
                                    : Colors.amber,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Ordered Items Quick Summary
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ordered Items (${order.items.length}):',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      ...order.items.take(3).map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            child: Row(
                              children: [
                                const Icon(Icons.circle,
                                    size: 6, color: Colors.white54),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${item.product.name} (x${item.quantity})',
                                    style: const TextStyle(fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      if (order.items.length > 3)
                        Text(
                          '+ ${order.items.length - 3} more items',
                          style: TextStyle(
                              fontSize: 10, color: AdminColors.textSecondary),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Reassignment Notice for Out-of-Stock
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.lightBlueAccent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'If the current hub does not have product stock, reassign to another hub with available inventory below:',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.lightBlueAccent),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                const Text(
                  'Select Fulfillment Hub:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (viewModel.locations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'No locations registered in system. Please create locations in Locations Management.',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: viewModel.locations.length,
                      separatorBuilder: (_, __) => const Divider(height: 8),
                      itemBuilder: (context, index) {
                        final loc = viewModel.locations[index];
                        final isCurrent = order.locationId == loc.id ||
                            order.locationName?.toLowerCase() ==
                                loc.name.toLowerCase();
                        return ListTile(
                          dense: true,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          tileColor: isCurrent
                              ? AdminColors.primaryGreen.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.03),
                          leading: Icon(
                            Icons.storefront_outlined,
                            size: 18,
                            color: isCurrent
                                ? AdminColors.primaryGreen
                                : Colors.white70,
                          ),
                          title: Text(
                            '${loc.name} Hub',
                            style: TextStyle(
                              fontWeight:
                                  isCurrent ? FontWeight.bold : FontWeight.w600,
                              color: isCurrent
                                  ? AdminColors.primaryGreen
                                  : Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            'Coverage Radius: ${loc.radiusDisplay}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white54),
                          ),
                          trailing: isCurrent
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AdminColors.primaryGreen
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: AdminColors.primaryGreen,
                                          size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Active Hub',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AdminColors.primaryGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    viewModel.assignOrderLocation(order, loc);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Order ${order.orderNumber} re-assigned to ${loc.name} Hub successfully!'),
                                        backgroundColor:
                                            AdminColors.primaryGreen,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AdminColors.primaryGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6)),
                                  ),
                                  child: const Text('Reassign Here',
                                      style: TextStyle(fontSize: 11)),
                                ),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            viewModel.assignOrderLocation(order, loc);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Order ${order.orderNumber} re-assigned to ${loc.name} Hub'),
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
            if (order.locationId != null || order.locationName != null)
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  viewModel.assignOrderLocation(order, null);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Order ${order.orderNumber} location removed (Unassigned)'),
                      backgroundColor: Colors.grey[800],
                    ),
                  );
                },
                child: const Text('Clear Location',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            size: 13,
            color: isPos ? Colors.lightBlueAccent : AdminColors.primaryGreen,
          ),
          const SizedBox(width: 5),
          Text(
            order.channelDisplayName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isPos ? Colors.lightBlueAccent : AdminColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  @override
  AdminOrdersViewModel viewModelBuilder(BuildContext context) =>
      AdminOrdersViewModel();
}
