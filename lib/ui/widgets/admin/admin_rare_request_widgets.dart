import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';

class RareRequestCard extends StatelessWidget {
  final RareProductRequestModel request;
  final VoidCallback onTap;

  const RareRequestCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (request.status) {
      case RareRequestStatus.submitted:
        statusColor = AdminColors.pending;
        break;
      case RareRequestStatus.approved:
      case RareRequestStatus.convertedToOrder:
        statusColor = AdminColors.success;
        break;
      case RareRequestStatus.cancelled:
        statusColor = AdminColors.cancelled;
        break;
      default:
        statusColor = AdminColors.inProgress;
    }

    return Card(
      color: AdminColors.panelBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminRadius.card),
        side: BorderSide(color: AdminColors.border),
      ),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: AdminSpacing.s),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(AdminSpacing.m),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AdminColors.background,
                  borderRadius: BorderRadius.circular(AdminRadius.card),
                  border: Border.all(color: AdminColors.border),
                ),
                child: Icon(Icons.support_agent_rounded,
                    color: AdminColors.primaryGreen, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.partName ?? 'Unknown / Unspecified Part Request',
                      style: AdminTextStyles.body
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Request ID: ${request.id} • Vehicle: ${request.vehicle.displayName}',
                      style: AdminTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AdminRadius.chip),
                    ),
                    child: Text(
                      request.status.name.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (request.quotation != null)
                    Text(
                      '₹${request.quotation!.grandTotal.toStringAsFixed(0)}',
                      style: AdminTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AdminColors.primaryGreen),
                    )
                  else if (request.budget != null)
                    Text(
                      'Budget: ₹${request.budget!.toStringAsFixed(0)}',
                      style: AdminTextStyles.bodySecondary,
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AdminChatBubble extends StatelessWidget {
  final RareChatMessageModel message;

  const AdminChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = message.sender == RareChatSender.admin;
    final isSystem = message.sender == RareChatSender.system;

    if (isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AdminColors.background,
            borderRadius: BorderRadius.circular(AdminRadius.chip),
            border: Border.all(color: AdminColors.border),
          ),
          child: Text(
            message.message,
            style: TextStyle(
              color: AdminColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isAdmin ? AdminColors.primaryGreen : Colors.white,
          border: isAdmin ? null : Border.all(color: AdminColors.border),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isAdmin ? const Radius.circular(12) : Radius.zero,
            bottomRight: isAdmin ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isAdmin ? Colors.white : AdminColors.textPrimary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isAdmin ? Colors.white60 : AdminColors.textLight,
                      fontSize: 10,
                    ),
                  ),
                  if (isAdmin) _buildStatusTicks(message),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTicks(RareChatMessageModel msg) {
    if (msg.id.startsWith('temp_')) {
      return const Padding(
        padding: EdgeInsets.only(left: 4.0),
        child: Icon(
          Icons.access_time_rounded,
          size: 11,
          color: Colors.white60,
        ),
      );
    }

    if (msg.readBy.length > 1) {
      return const Padding(
        padding: EdgeInsets.only(left: 4.0),
        child: Icon(
          Icons.done_all_rounded,
          size: 13,
          color: Colors.lightBlueAccent,
        ),
      );
    } else if (msg.receivedBy.length > 1) {
      return const Padding(
        padding: EdgeInsets.only(left: 4.0),
        child: Icon(
          Icons.done_all_rounded,
          size: 13,
          color: Colors.white60,
        ),
      );
    } else {
      return const Padding(
        padding: EdgeInsets.only(left: 4.0),
        child: Icon(
          Icons.check_rounded,
          size: 13,
          color: Colors.white60,
        ),
      );
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class QuotationSummaryCard extends StatelessWidget {
  final RareQuotationModel quotation;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final bool showActions;

  const QuotationSummaryCard({
    super.key,
    required this.quotation,
    this.onAccept,
    this.onDecline,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminSpacing.m),
      decoration: BoxDecoration(
        color: AdminColors.sidebarBackground,
        borderRadius: BorderRadius.circular(AdminRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: AdminColors.accentLime, size: 20),
              const SizedBox(width: 8),
              const Text(
                'OFFICIAL PRICE QUOTATION',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quotation.partName,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Timeline: ${quotation.deliveryTimeline}',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Price:',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(
                '₹${quotation.grandTotal.toStringAsFixed(2)}',
                style: TextStyle(
                    color: AdminColors.accentLime,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white30),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }
}
