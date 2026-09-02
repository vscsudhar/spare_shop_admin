import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_rare_request_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_rare_request_chat_viewmodel.dart';

class AdminRareRequestChatView
    extends StackedView<AdminRareRequestChatViewModel> {
  final String requestId;

  const AdminRareRequestChatView({
    Key? key,
    this.requestId = '',
  }) : super(key: key);

  @override
  void onViewModelReady(AdminRareRequestChatViewModel viewModel) {
    if (requestId.isNotEmpty) {
      viewModel.initialize(requestId);
    }
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    AdminRareRequestChatViewModel viewModel,
    Widget? child,
  ) {
    final req = viewModel.request;

    if (viewModel.isBusy && req == null) {
      return AdminShell(
        title: 'Support Ticket',
        selectedItem: AdminNavigationItem.rareRequests,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 80.0),
            child: CircularProgressIndicator(color: AdminColors.primaryGreen),
          ),
        ),
      );
    }

    if (req == null) {
      return AdminShell(
        title: 'Support Ticket',
        selectedItem: AdminNavigationItem.rareRequests,
        child: const Center(child: Text('Ticket not found.')),
      );
    }

    return AdminShell(
      title: 'Sourcing Support Ticket: #${req.id}',
      selectedItem: AdminNavigationItem.rareRequests,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          TextButton.icon(
            onPressed: viewModel.closeRequest,
            icon: Icon(Icons.arrow_back,
                size: 16, color: AdminColors.textSecondary),
            label: Text('Back to Tickets List',
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
                  // Left Column: Chat Room
                  Expanded(
                    flex: isWide ? 2 : 3,
                    child: Container(
                      height: 550,
                      decoration: BoxDecoration(
                        color: AdminColors.panelBackground,
                        borderRadius: BorderRadius.circular(AdminRadius.card),
                        border: Border.all(color: AdminColors.border),
                      ),
                      child: Column(
                        children: [
                          // Collapsible Summary Header (visible on all screens)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AdminColors.background,
                              border: Border(
                                  bottom:
                                      BorderSide(color: AdminColors.border)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.directions_bike,
                                        color: AdminColors.primaryGreen,
                                        size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            req.partName ??
                                                'Rare Spare Part Request',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13),
                                          ),
                                          Text(
                                            'Vehicle: ${req.vehicle.displayName}',
                                            style: TextStyle(
                                                color:
                                                    AdminColors.textSecondary,
                                                fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: viewModel.toggleSummaryDetails,
                                      icon: Icon(
                                        viewModel.showSummaryDetails
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        size: 16,
                                        color: AdminColors.primaryGreen,
                                      ),
                                      label: Text(
                                        viewModel.showSummaryDetails
                                            ? 'Hide'
                                            : 'Details',
                                        style: TextStyle(
                                            color: AdminColors.primaryGreen,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                if (viewModel.showSummaryDetails) ...[
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text('Description:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: AdminColors.textLight)),
                                  const SizedBox(height: 2),
                                  Text(req.description,
                                      style: const TextStyle(fontSize: 12)),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _summaryField('Qty Requested',
                                          '${req.quantity} Units'),
                                      _summaryField(
                                          'Urgency Priority', req.urgency),
                                      if (req.budget != null)
                                        _summaryField('Target Budget',
                                            '₹${req.budget!.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                  if (req.images.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text('Uploaded Images:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: AdminColors.textLight)),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      height: 60,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: req.images.length,
                                        itemBuilder: (context, idx) {
                                          return Container(
                                            width: 60,
                                            margin:
                                                const EdgeInsets.only(right: 6),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                  color: AdminColors.border),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Image.network(
                                                req.images[idx],
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, e, s) =>
                                                    const Icon(
                                                        Icons.broken_image,
                                                        size: 16),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                          // Messages List
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: viewModel.chatMessages.length,
                              itemBuilder: (context, index) {
                                final msg = viewModel.chatMessages[index];
                                final quotation = msg.quotation ??
                                    (msg.messageType ==
                                            RareChatMessageType.quotation
                                        ? viewModel.request?.quotation
                                        : null);
                                if (msg.messageType ==
                                        RareChatMessageType.quotation &&
                                    quotation != null) {
                                  return Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      width: 300,
                                      child: QuotationSummaryCard(
                                        quotation: quotation,
                                        showActions: false,
                                      ),
                                    ),
                                  );
                                }
                                return AdminChatBubble(message: msg);
                              },
                            ),
                          ),
                          const Divider(height: 1),

                          // Text Input Row
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: viewModel.textController,
                                    onSubmitted: (text) =>
                                        viewModel.sendMessage(text),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Type your message to customer...',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(24)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  backgroundColor: AdminColors.primaryGreen,
                                  child: IconButton(
                                    icon: const Icon(Icons.send,
                                        color: Colors.white, size: 18),
                                    onPressed: () => viewModel.sendMessage(
                                        viewModel.textController.text),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  if (isWide) ...[
                    const SizedBox(width: 24),

                    // Right Column: Ticket Info & Actions
                    Expanded(
                      child: Column(
                        children: [
                          AdminPanelCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Customer Inquiry Details',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                _infoRow('Customer Name', req.customerName),
                                _infoRow('Phone Number', req.phone),
                                _infoRow('Inquiry Item',
                                    req.partName ?? 'Unknown Spare Part'),
                                _infoRow(
                                    'Vehicle Model', req.vehicle.displayName),
                                _infoRow('Quantity Requested',
                                    '${req.quantity} Units'),
                                _infoRow('Urgency Priority', req.urgency),
                                if (req.budget != null)
                                  _infoRow('Target Budget',
                                      '₹${req.budget!.toStringAsFixed(2)}'),
                                _infoRow('Ticket Status',
                                    req.status.name.toUpperCase()),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (req.images.isNotEmpty) ...[
                            AdminPanelCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Reference Images Uploaded',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 90,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: req.images.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          width: 90,
                                          margin:
                                              const EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            color: AdminColors.background,
                                            borderRadius: BorderRadius.circular(
                                                AdminRadius.card),
                                            border: Border.all(
                                                color: AdminColors.border),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                AdminRadius.card),
                                            child: Image.network(
                                              req.images[index],
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const Icon(
                                                    Icons.broken_image_outlined,
                                                    size: 28,
                                                    color: Colors.grey);
                                              },
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return const Center(
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          AdminPanelCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text('Ticket Action Center',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                if (req.status ==
                                    RareRequestStatus.submitted) ...[
                                  ElevatedButton(
                                    onPressed: viewModel.markSearching,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white),
                                    child:
                                        const Text('Mark Sourcing / Searching'),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                if (req.status == RareRequestStatus.searching ||
                                    req.status ==
                                        RareRequestStatus.submitted) ...[
                                  ElevatedButton(
                                    onPressed: viewModel.markProductFound,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal,
                                        foregroundColor: Colors.white),
                                    child: const Text('Mark Product Found'),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                if (req.status == RareRequestStatus.found ||
                                    req.status == RareRequestStatus.searching ||
                                    req.status == RareRequestStatus.submitted ||
                                    req.status ==
                                        RareRequestStatus.negotiation) ...[
                                  ElevatedButton(
                                    onPressed: viewModel.openQuotationBuilder,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AdminColors.primaryGreen,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text(
                                        'Create Official Price Quote'),
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton(
                                    onPressed: viewModel.markProductNotFound,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                    child: const Text(
                                        'Mark Product Not Found / Cancel'),
                                  ),
                                ],
                                if (req.status ==
                                    RareRequestStatus.approved) ...[
                                  ElevatedButton(
                                    onPressed:
                                        viewModel.convertApprovedRequestToOrder,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child:
                                        const Text('Convert Sourcing to Order'),
                                  ),
                                ],
                                if (req.status ==
                                    RareRequestStatus.convertedToOrder) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.green.withValues(alpha: 0.08),
                                      border: Border.all(color: Colors.green),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Order checkout completed for this rare request.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  ),
                                ],
                                if (req.status ==
                                    RareRequestStatus.cancelled) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.08),
                                      border: Border.all(color: Colors.red),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Ticket Cancelled.\nReason: ${req.cancellationReason ?? "None Specified"}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ]
                ],
              );
            },
          )
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: AdminColors.textLight,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  color: AdminColors.textPrimary,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _summaryField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 9,
                color: AdminColors.textLight,
                fontWeight: FontWeight.bold)),
        Text(value,
            style: TextStyle(
                fontSize: 11,
                color: AdminColors.textPrimary,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  AdminRareRequestChatViewModel viewModelBuilder(BuildContext context) =>
      AdminRareRequestChatViewModel();
}
