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

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final clean = url.startsWith('/') ? url.substring(1) : url;
    return 'http://127.0.0.1:5000/$clean';
  }

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

    final hasThumbnail = request.images.isNotEmpty;
    final thumbUrl = hasThumbnail ? _formatImageUrl(request.images.first) : '';

    final shortId = request.id.length > 8
        ? request.id.substring(request.id.length - 8).toUpperCase()
        : request.id;

    final vehicleText = request.vehicle.displayName.trim();

    return Material(
      color: Colors.transparent,
      child: Card(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail or Icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(AdminRadius.card),
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AdminColors.background,
                      borderRadius: BorderRadius.circular(AdminRadius.card),
                      border: Border.all(color: AdminColors.border),
                    ),
                    child: hasThumbnail && thumbUrl.isNotEmpty
                        ? Image.network(
                            thumbUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.support_agent_rounded,
                              color: AdminColors.primaryGreen,
                              size: 26,
                            ),
                          )
                        : Icon(
                            Icons.support_agent_rounded,
                            color: AdminColors.primaryGreen,
                            size: 26,
                          ),
                  ),
                ),
                const SizedBox(width: 16),

                // Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AdminColors.border.withValues(alpha: 0.3),
                              borderRadius:
                                  BorderRadius.circular(AdminRadius.chip),
                            ),
                            child: Text(
                              '#$shortId',
                              style: TextStyle(
                                color: AdminColors.accentLime,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              request.partName ?? 'Rare Spare Part Request',
                              style: AdminTextStyles.body.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Customer info & vehicle
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_outline,
                                  size: 13, color: AdminColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                request.customerName,
                                style: AdminTextStyles.bodySecondary
                                    .copyWith(fontSize: 12),
                              ),
                              if (request.phone.isNotEmpty) ...[
                                Text(
                                  ' (${request.phone})',
                                  style: AdminTextStyles.bodySecondary.copyWith(
                                      fontSize: 12, color: Colors.white38),
                                ),
                              ],
                            ],
                          ),
                          if (vehicleText.isNotEmpty) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.two_wheeler_outlined,
                                    size: 13, color: AdminColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  vehicleText,
                                  style: AdminTextStyles.bodySecondary
                                      .copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.pin_outlined,
                                  size: 13, color: AdminColors.textSecondary),
                              const SizedBox(width: 2),
                              Text(
                                'Qty: ${request.quantity}',
                                style: AdminTextStyles.bodySecondary
                                    .copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 12, color: AdminColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(request.date),
                                style: AdminTextStyles.bodySecondary
                                    .copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Status and Price / Budget
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AdminRadius.chip),
                        border: Border.all(
                            color: statusColor.withValues(alpha: 0.3)),
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
                    const SizedBox(height: 8),
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
                        style: AdminTextStyles.bodySecondary.copyWith(
                          color: AdminColors.accentLime,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ],
            ),
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
