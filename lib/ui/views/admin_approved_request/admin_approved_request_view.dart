import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_rare_request_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_approved_request_viewmodel.dart';

class AdminApprovedRequestView
    extends StackedView<AdminApprovedRequestViewModel> {
  final String requestId;

  const AdminApprovedRequestView({
    Key? key,
    required this.requestId,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminApprovedRequestViewModel viewModel,
    Widget? child,
  ) {
    viewModel.initialize(requestId);
    final req = viewModel.request;

    if (req == null) {
      return AdminShell(
        title: 'Approved Request',
        selectedItem: AdminNavigationItem.rareRequests,
        child: const Center(child: Text('Request not found.')),
      );
    }

    return AdminShell(
      title: 'Quotation Approved: #${req.id}',
      selectedItem: AdminNavigationItem.rareRequests,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          TextButton.icon(
            onPressed: viewModel.goBack,
            icon: Icon(Icons.arrow_back,
                size: 16, color: AdminColors.textSecondary),
            label: Text('Back to Chat Room',
                style: TextStyle(color: AdminColors.textSecondary)),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Approval Details
                  Expanded(
                    flex: isWide ? 2 : 3,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AdminSpacing.m),
                          decoration: BoxDecoration(
                            color: AdminColors.primaryGreen.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AdminRadius.card),
                            border: Border.all(
                                color:
                                    AdminColors.primaryGreen.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: AdminColors.primaryGreen, size: 32),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      req.status ==
                                              RareRequestStatus.convertedToOrder
                                          ? 'CONVERTED TO CUSTOMER CHECKOUT ORDER'
                                          : 'PRICING QUOTATION APPROVED BY CUSTOMER',
                                      style: TextStyle(
                                          color: AdminColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      req.status ==
                                              RareRequestStatus.convertedToOrder
                                          ? 'This rare request has been successfully checkout processed as Order #VS-${req.id}.'
                                          : 'Customer Suresh Kumar has approved the price quote contract. Click the action button to convert it into a standard catalog order.',
                                      style: TextStyle(
                                          color: AdminColors.textSecondary,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (req.quotation != null)
                          QuotationSummaryCard(
                            quotation: req.quotation!,
                            showActions: false,
                          ),
                        const SizedBox(height: 24),
                        if (req.status == RareRequestStatus.approved)
                          ElevatedButton(
                            onPressed: viewModel.convertApprovedRequestToOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                                'Convert Sourcing Request to Catalog Checkout Order',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                      ],
                    ),
                  ),
                  if (isWide) ...[
                    const SizedBox(width: 24),

                    // Right Column: Timeline Log
                    Expanded(
                      child: AdminPanelCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Request Sourcing Timeline',
                              style: AdminTextStyles.body
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            _timelineStep(
                                'Order Registered',
                                req.status == RareRequestStatus.convertedToOrder
                                    ? 'Converted successfully to checkout Order #VS-${req.id}'
                                    : 'Awaiting conversion execution...',
                                'Just now',
                                isDone: req.status ==
                                    RareRequestStatus.convertedToOrder),
                            _timelineStep(
                                'Client Approved',
                                'Approved quote grand total amount of ₹${req.quotation?.grandTotal.toStringAsFixed(2) ?? "0"}',
                                '5 mins ago',
                                isDone: true),
                            _timelineStep(
                                'Quotation Sent',
                                'Official pricing quote sent to client chat room',
                                '10 mins ago',
                                isDone: true),
                            _timelineStep(
                                'Product Sourced',
                                'Catalog logs marked item found at Chennai warehouse',
                                '30 mins ago',
                                isDone: true),
                          ],
                        ),
                      ),
                    )
                  ],
                ],
              );
            },
          )
        ],
      ),
    );
  }

  Widget _timelineStep(String title, String desc, String time,
      {required bool isDone}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? AdminColors.primaryGreen : AdminColors.textLight,
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
                        color: isDone
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

  @override
  AdminApprovedRequestViewModel viewModelBuilder(BuildContext context) =>
      AdminApprovedRequestViewModel();
}
