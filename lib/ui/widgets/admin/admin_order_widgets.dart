import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';

class OrderSummaryCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const OrderSummaryCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AdminColors.panelBackground,
      margin: const EdgeInsets.symmetric(vertical: AdminSpacing.s),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminRadius.card),
        side: BorderSide(color: AdminColors.border),
      ),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(AdminSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumber,
                    style: AdminTextStyles.body
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹${order.total}',
                    style: AdminTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AdminColors.primaryGreen,
                    ),
                  )
                ],
              ),
              const SizedBox(height: AdminSpacing.s),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date: ${_formatDate(order.date)}',
                    style: AdminTextStyles.bodySecondary,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _statusColor(order.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AdminRadius.chip),
                    ),
                    child: Text(
                      order.status.name.toUpperCase(),
                      style: TextStyle(
                        color: _statusColor(order.status),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: AdminSpacing.s),
              Text(
                'Customer: ${order.address.name}',
                style: AdminTextStyles.bodySecondary,
              ),
              Text(
                'Address: ${order.address.addressLine}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AdminTextStyles.bodySecondary
                    .copyWith(color: AdminColors.textLight),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
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
}

class OrderItemTile extends StatelessWidget {
  final CartItemModel item;

  const OrderItemTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AdminSpacing.s),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AdminColors.background,
              borderRadius: BorderRadius.circular(AdminRadius.chip),
              border: Border.all(color: AdminColors.border),
            ),
            child: Icon(Icons.build_outlined,
                size: 18, color: AdminColors.textSecondary),
          ),
          const SizedBox(width: AdminSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AdminTextStyles.body
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Fitment: ${item.product.fitmentBadge}',
                  style: AdminTextStyles.bodySecondary,
                )
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${item.product.price * item.quantity}',
                style:
                    AdminTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Qty: x${item.quantity}',
                style: AdminTextStyles.bodySecondary,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class CustomerSummaryCard extends StatelessWidget {
  final String name;
  final String email;
  final String spend;
  final int ordersCount;

  const CustomerSummaryCard({
    super.key,
    required this.name,
    required this.email,
    required this.spend,
    required this.ordersCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminSpacing.m),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(AdminRadius.card),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AdminColors.primaryGreen.withValues(alpha: 0.1),
            child: Icon(Icons.person, color: AdminColors.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AdminTextStyles.body
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(email, style: AdminTextStyles.bodySecondary),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(spend,
                  style: AdminTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AdminColors.primaryGreen)),
              Text('$ordersCount orders', style: AdminTextStyles.bodySecondary),
            ],
          )
        ],
      ),
    );
  }
}
