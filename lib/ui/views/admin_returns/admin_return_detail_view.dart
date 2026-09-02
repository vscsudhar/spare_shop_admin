import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/return_exchange_models.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_return_detail_viewmodel.dart';

class AdminReturnDetailView extends StackedView<AdminReturnDetailViewModel> {
  final String caseId;

  const AdminReturnDetailView({Key? key, required this.caseId}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminReturnDetailViewModel viewModel,
    Widget? child,
  ) {
    final kase = viewModel.kase;

    return AdminShell(
      title: 'Return Case Details',
      selectedItem: AdminNavigationItem.returnsExchanges,
      child: viewModel.isBusy && kase == null
          ? const Center(child: CircularProgressIndicator())
          : kase == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Case not found or failed to load'),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => viewModel.handleBack(),
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Back to Returns & Exchanges'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.primaryGreen,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      TextButton.icon(
                        onPressed: () => viewModel.handleBack(),
                        icon: Icon(Icons.arrow_back,
                            size: 16, color: AdminColors.textSecondary),
                        label: Text('Back to Returns & Exchanges',
                            style: TextStyle(color: AdminColors.textSecondary)),
                      ),
                      const SizedBox(height: 12),

                      // Header Row
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => viewModel.handleBack(),
                            icon: const Icon(Icons.arrow_back, color: Colors.white70),
                            tooltip: 'Back to Returns List',
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(kase.caseNumber,
                                        style: AdminTextStyles.sectionHeader),
                                    const SizedBox(width: 12),
                                    _typeBadge(kase.type),
                                    const SizedBox(width: 8),
                                    AdminStatusChip(
                                      label: kase.status.toUpperCase(),
                                      color: _statusColor(kase.status),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Linked Bill: ${kase.billNumber} | Customer: ${kase.customerName} (${kase.customerPhone})',
                                  style: AdminTextStyles.bodySecondary,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: viewModel.isBusy
                                ? null
                                : () => viewModel.loadCase(),
                            icon: const Icon(Icons.refresh, color: Colors.white70),
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Layout: 2 Columns on wide screen, 1 column on narrow
                      LayoutBuilder(builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 900;

                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left: Items breakdown & summary
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    _buildCaseSummaryCard(kase),
                                    const SizedBox(height: 20),
                                    _buildItemsList(kase),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),

                              // Right: Status update actions & History timeline
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    if (viewModel.availableNextStatuses.isNotEmpty)
                                      _buildStatusActionCard(context, viewModel),
                                    const SizedBox(height: 20),
                                    _buildHistoryTimelineCard(kase),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              _buildCaseSummaryCard(kase),
                              const SizedBox(height: 20),
                              if (viewModel.availableNextStatuses.isNotEmpty) ...[
                                _buildStatusActionCard(context, viewModel),
                                const SizedBox(height: 20),
                              ],
                              _buildItemsList(kase),
                              const SizedBox(height: 20),
                              _buildHistoryTimelineCard(kase),
                            ],
                          );
                        }
                      }),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCaseSummaryCard(ReturnExchangeCase kase) {
    return AdminPanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Case Overview',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const Divider(height: 20),
          Wrap(
            spacing: 32,
            runSpacing: 12,
            children: [
              _infoLine('Case Number', kase.caseNumber),
              _infoLine('Bill Number', kase.billNumber),
              if (kase.invoiceNumber.isNotEmpty)
                _infoLine('Invoice Number', kase.invoiceNumber),
              _infoLine('Customer', '${kase.customerName} (${kase.customerPhone})'),
              _infoLine('Created Date',
                  '${kase.createdAt.day}/${kase.createdAt.month}/${kase.createdAt.year} ${kase.createdAt.hour}:${kase.createdAt.minute.toString().padLeft(2, '0')}'),
              _infoLine('Last Updated',
                  '${kase.updatedAt.day}/${kase.updatedAt.month}/${kase.updatedAt.year} ${kase.updatedAt.hour}:${kase.updatedAt.minute.toString().padLeft(2, '0')}'),
              _infoLine('Handled By', kase.createdByName),
              if (kase.totalRefundAmount > 0)
                _infoLine('Refund Amount', '₹${kase.totalRefundAmount.toStringAsFixed(2)}',
                    color: Colors.orangeAccent),
              if (kase.totalPayableAmount > 0)
                _infoLine('Payable Amount', '₹${kase.totalPayableAmount.toStringAsFixed(2)}',
                    color: Colors.greenAccent),
            ],
          ),
          if (kase.adminNotes.isNotEmpty) ...[
            const Divider(height: 24),
            Text('Admin Notes: ${kase.adminNotes}',
                style: const TextStyle(
                    fontSize: 12, color: Colors.white70, fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  Widget _infoLine(String label, String val, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(val,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color ?? Colors.white)),
      ],
    );
  }

  Widget _buildItemsList(ReturnExchangeCase kase) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Processed Items (${kase.items.length})',
            style: AdminTextStyles.sectionHeader),
        const SizedBox(height: 12),
        ...kase.items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: AdminPanelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            if (item.sku.isNotEmpty)
                              Text('SKU: ${item.sku}',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      _typeBadge(item.action),
                    ],
                  ),
                  const Divider(height: 20),
                  Wrap(
                    spacing: 24,
                    runSpacing: 10,
                    children: [
                      _infoLine('Quantity Processed',
                          '${item.processedQty} of ${item.originalQty}'),
                      _infoLine('Unit Price', '₹${item.unitPrice.toStringAsFixed(2)}'),
                      _infoLine('Reason', item.reasonText),
                      _infoLine('Condition', item.condition.toUpperCase()),
                      _infoLine('Inventory Action',
                          item.inventoryDisposition.toUpperCase()),
                    ],
                  ),
                  if (item.action == 'return' && item.refundRequired) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.currency_rupee,
                              size: 16, color: Colors.orangeAccent),
                          const SizedBox(width: 6),
                          Text(
                            'Refund: ₹${item.refundAmount.toStringAsFixed(2)} (${item.refundMethod.toUpperCase()}) - Status: ${item.refundStatus.toUpperCase()}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orangeAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (item.action == 'exchange') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Replacement: ${item.replacementProductName} (Qty: ${item.replacementQty})',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.purpleAccent),
                          ),
                          const SizedBox(height: 4),
                          if (item.differenceType == 'payable')
                            Text(
                              'Customer to pay: ₹${item.differenceAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.greenAccent),
                            )
                          else if (item.differenceType == 'refundable')
                            Text(
                              'Refund to customer: ₹${item.differenceAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.orangeAccent),
                            )
                          else
                            const Text('Even exchange (₹0 difference)',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                  if (item.action == 'damage') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Damage: ${item.damageType.toUpperCase()} | Location: ${item.damageDiscoveredAt.toUpperCase()} | Resolution: ${item.damageResolution.toUpperCase()}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.redAccent),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatusActionCard(
      BuildContext context, AdminReturnDetailViewModel viewModel) {
    final statuses = viewModel.availableNextStatuses;

    return AdminPanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Manage Case Lifecycle',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const Divider(height: 20),
          DropdownButtonFormField<String>(
            initialValue: viewModel.selectedNewStatus,
            hint: const Text('Select Next Status Transition'),
            dropdownColor: AdminColors.panelBackground,
            items: statuses.map((s) {
              return DropdownMenuItem(
                value: s,
                child: Text(s.toUpperCase()),
              );
            }).toList(),
            onChanged: (val) => viewModel.setSelectedNewStatus(val),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: viewModel.statusNoteController,
            decoration: const InputDecoration(
              labelText: 'Update Notes / Audit Reason',
              hintText: 'e.g. Items physically received and inspected...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: viewModel.selectedNewStatus != null && !viewModel.isBusy
                  ? () => viewModel.updateStatus(context)
                  : null,
              icon: viewModel.isBusy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check, size: 16),
              label: const Text('Update Status'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTimelineCard(ReturnExchangeCase kase) {
    return AdminPanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, size: 18, color: AdminColors.primaryGreen),
              const SizedBox(width: 8),
              const Text('Audit Trail & Event History',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Immutable chronological record of all lifecycle events',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const Divider(height: 20),
          ...kase.history.asMap().entries.map((entry) {
            final idx = entry.key;
            final event = entry.value;
            final isLast = idx == kase.history.length - 1;

            final timeStr =
                '${event.timestamp.day}/${event.timestamp.month}/${event.timestamp.year} at ${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}';

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isLast
                              ? AdminColors.primaryGreen
                              : Colors.white24,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: Colors.white12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                event.toStatus.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isLast
                                      ? AdminColors.primaryGreen
                                      : Colors.white,
                                ),
                              ),
                              Text(timeStr,
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          if (event.notes.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(event.notes,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white70)),
                          ],
                          const SizedBox(height: 2),
                          Text('By: ${event.changedByName}',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _typeBadge(String type) {
    Color bg = Colors.blue.withValues(alpha: 0.15);
    Color fg = Colors.lightBlueAccent;
    String label = type.toUpperCase();

    if (type.toLowerCase() == 'damage') {
      bg = Colors.red.withValues(alpha: 0.15);
      fg = Colors.redAccent;
    } else if (type.toLowerCase() == 'exchange') {
      bg = Colors.purple.withValues(alpha: 0.15);
      fg = Colors.purpleAccent;
    } else if (type.toLowerCase() == 'mixed') {
      bg = Colors.amber.withValues(alpha: 0.15);
      fg = Colors.amberAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'received':
        return Colors.teal;
      case 'processing':
        return Colors.blue;
      case 'approved':
        return Colors.amber;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  AdminReturnDetailViewModel viewModelBuilder(BuildContext context) =>
      AdminReturnDetailViewModel(caseId: caseId);
}
