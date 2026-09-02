import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_rare_request_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_cancelled_request_viewmodel.dart';

class AdminCancelledRequestView
    extends StackedView<AdminCancelledRequestViewModel> {
  final String requestId;

  const AdminCancelledRequestView({
    Key? key,
    required this.requestId,
  }) : super(key: key);

  @override
  void onViewModelReady(AdminCancelledRequestViewModel viewModel) {
    viewModel.initialize(requestId);
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    AdminCancelledRequestViewModel viewModel,
    Widget? child,
  ) {
    final req = viewModel.request;

    if (req == null) {
      return AdminShell(
        title: 'Cancelled Request',
        selectedItem: AdminNavigationItem.rareRequests,
        child: const Center(child: Text('Request not found.')),
      );
    }

    return AdminShell(
      title: 'Quotation Cancelled: #${req.id}',
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
                  // Left Column: Cancellation Details
                  Expanded(
                    flex: isWide ? 2 : 3,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AdminSpacing.m),
                          decoration: BoxDecoration(
                            color:
                                AdminColors.cancelled.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AdminRadius.card),
                            border: Border.all(
                                color: AdminColors.cancelled
                                    .withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.cancel_rounded,
                                  color: AdminColors.cancelled, size: 32),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PRICE QUOTATION DECLINED / SOURCING CANCELLED',
                                      style: TextStyle(
                                          color: AdminColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'The price quotation was declined by customer ${req.customerName}. Sourcing logs have been archived.',
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
                        const SizedBox(height: 20),
                        AdminPanelCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Cancellation Audit Log Details',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Text(
                                'Decline Reason: "${req.cancellationReason ?? "No reason specified by customer."}"',
                                style: TextStyle(
                                    color: AdminColors.textSecondary,
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Archived Date: ${req.date.toString().substring(0, 10)} • Customer Contact: ${req.phone}',
                                style: TextStyle(
                                    fontSize: 11, color: AdminColors.textLight),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isWide) ...[
                    const SizedBox(width: 24),

                    // Right Column: Reopen Actions
                    Expanded(
                      child: AdminPanelCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Audit Actions Center',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: viewModel.reopenRequest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AdminColors.primaryGreen,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Reopen Request Sourcing'),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Request ticket archived successfully.')),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AdminColors.textSecondary,
                                side: BorderSide(color: AdminColors.border),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Archive Ticket Permanently'),
                            )
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

  @override
  AdminCancelledRequestViewModel viewModelBuilder(BuildContext context) =>
      AdminCancelledRequestViewModel();
}
