import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_order_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_order_detail_viewmodel.dart';

class AdminOrderDetailView extends StackedView<AdminOrderDetailViewModel> {
  final OrderModel? order;

  const AdminOrderDetailView({
    Key? key,
    this.order,
  }) : super(key: key);

  @override
  void onViewModelReady(AdminOrderDetailViewModel viewModel) {
    if (order != null) {
      viewModel.initialize(order!);
    }
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    AdminOrderDetailViewModel viewModel,
    Widget? child,
  ) {
    if (order == null) {
      return AdminShell(
        title: 'Order Detail',
        selectedItem: AdminNavigationItem.orders,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 80.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_bag_outlined,
                    size: 48, color: Colors.white54),
                const SizedBox(height: 16),
                const Text(
                  'No order selected. Please select an order from the list.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.goBack(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Back to Orders'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return AdminShell(
      title: 'Order Detail: ${viewModel.order.orderNumber}',
      selectedItem: AdminNavigationItem.orders,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          TextButton.icon(
            onPressed: viewModel.goBack,
            icon: Icon(Icons.arrow_back,
                size: 16, color: AdminColors.textSecondary),
            label: Text('Back to Orders',
                style: TextStyle(color: AdminColors.textSecondary)),
          ),
          const SizedBox(height: 16),

          // Two-column layout
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Items & Fulfillment
                  Expanded(
                    flex: isWide ? 2 : 3,
                    child: Column(
                      children: [
                        AdminPanelCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Items Ordered',
                                    style: AdminTextStyles.body
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  AdminStatusChip(
                                    label: viewModel.order.status.name,
                                    color: _statusColor(viewModel.order.status),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ...viewModel.order.items.map((item) => Column(
                                    children: [
                                      OrderItemTile(item: item),
                                      const Divider(height: 24),
                                    ],
                                  )),

                              // Pricing summaries
                              const SizedBox(height: 12),
                              _priceRow('Subtotal',
                                  '₹${(viewModel.order.total - 150).toStringAsFixed(2)}'),
                              const SizedBox(height: 8),
                              _priceRow('Standard Shipping', '₹150.00'),
                              const Divider(height: 24),
                              _priceRow('Grand Total',
                                  '₹${viewModel.order.total.toStringAsFixed(2)}',
                                  isBold: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Status updates action card
                        AdminPanelCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Manage Order Progress',
                                style: AdminTextStyles.body
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<OrderStatus>(
                                      initialValue: viewModel.order.status,
                                      decoration: InputDecoration(
                                        labelText: 'Update Status',
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      items: OrderStatus.values.map((s) {
                                        return DropdownMenuItem(
                                            value: s,
                                            child: Text(s.name.toUpperCase()));
                                      }).toList(),
                                      onChanged: (s) {
                                        if (s != null) {
                                          viewModel.updateOrderStatus(s);
                                        }
                                      },
                                    ),
                                  ),
                                  if (viewModel.order.status ==
                                      OrderStatus.processing) ...[
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: viewModel.markOutForDelivery,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AdminColors.primaryGreen,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child:
                                          const Text('Mark Out for Delivery'),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // After-Sales / Returns & Exchanges Section
                        AdminPanelCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                          Icons.published_with_changes_rounded,
                                          size: 20,
                                          color: AdminColors.primaryGreen),
                                      const SizedBox(width: 8),
                                      Text(
                                        'After-Sales / Returns & Exchanges',
                                        style: AdminTextStyles.body.copyWith(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => viewModel.initiateReturn(),
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Initiate Return / RMA'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AdminColors.primaryGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              if (viewModel.linkedCases.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'No return, damage, or exchange cases initiated for this order.',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                )
                              else
                                ...viewModel.linkedCases.map((c) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.04),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.white12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(c.caseNumber,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AdminColors
                                                            .primaryGreen)),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue
                                                        .withValues(
                                                            alpha: 0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    c.type.toUpperCase(),
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors
                                                            .lightBlueAccent,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${c.items.length} item(s) processed | Status: ${c.status.toUpperCase()}',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white70),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              viewModel.openCaseDetail(c),
                                          child: const Text('View Case'),
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
                  if (isWide) ...[
                    const SizedBox(width: 24),

                    // Right Column: Customer & Timeline
                    Expanded(
                      child: Column(
                        children: [
                          AdminPanelCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Customer Details',
                                  style: AdminTextStyles.body
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AdminColors.primaryGreen
                                          .withValues(alpha: 0.1),
                                      child: Icon(Icons.person,
                                          color: AdminColors.primaryGreen),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            viewModel.order.address.name,
                                            style: AdminTextStyles.body
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                          Text('Registered Retail Account',
                                              style: AdminTextStyles
                                                  .bodySecondary),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 12),
                                Text(
                                  'Delivery Address',
                                  style: AdminTextStyles.bodySecondary
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  viewModel.order.address.addressLine,
                                  style: AdminTextStyles.bodySecondary.copyWith(
                                      color: AdminColors.textSecondary),
                                ),
                                Text(
                                  'Phone: ${viewModel.order.address.phone}',
                                  style: AdminTextStyles.bodySecondary
                                      .copyWith(color: AdminColors.textLight),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          AdminPanelCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fulfillment Timeline',
                                  style: AdminTextStyles.body
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                _timelineStep(
                                    'Order Placed',
                                    'Payment authorized successfully',
                                    '3 days ago',
                                    isCompleted: true),
                                _timelineStep(
                                    'Packed & Prepared',
                                    'Parts verified from warehouse ledger',
                                    '2 days ago',
                                    isCompleted: true),
                                _timelineStep(
                                    'Shipped / Dispatched',
                                    'Handed over to delivery driver',
                                    '1 day ago',
                                    isCompleted: viewModel.order.status ==
                                            OrderStatus.shipped ||
                                        viewModel.order.status ==
                                            OrderStatus.delivered),
                                _timelineStep('Delivered',
                                    'Recipient signature collected', 'Pending',
                                    isCompleted: viewModel.order.status ==
                                        OrderStatus.delivered),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          )
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? AdminColors.textPrimary : AdminColors.textSecondary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 15 : 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? AdminColors.primaryGreen : AdminColors.textPrimary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 13,
          ),
        ),
      ],
    );
  }

  Widget _timelineStep(String title, String desc, String time,
      {required bool isCompleted}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color:
                isCompleted ? AdminColors.primaryGreen : AdminColors.textLight,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AdminTextStyles.bodySecondary.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCompleted
                            ? AdminColors.textPrimary
                            : AdminColors.textLight)),
                Text(desc,
                    style: TextStyle(
                        fontSize: 10, color: AdminColors.textSecondary)),
              ],
            ),
          ),
          Text(time,
              style: TextStyle(fontSize: 10, color: AdminColors.textLight)),
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
  AdminOrderDetailViewModel viewModelBuilder(BuildContext context) =>
      AdminOrderDetailViewModel();
}
