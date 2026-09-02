import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_rare_request_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_rare_requests_viewmodel.dart';

class AdminRareRequestsView extends StackedView<AdminRareRequestsViewModel> {
  const AdminRareRequestsView({Key? key}) : super(key: key);

  @override
  void onViewModelReady(AdminRareRequestsViewModel viewModel) {
    viewModel.initialise();
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    AdminRareRequestsViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: 'Rare Product Requests',
      selectedItem: AdminNavigationItem.rareRequests,
      onSearch: viewModel.onSearch,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inbound Custom Spares Sourcing Tickets',
                      style: AdminTextStyles.sectionHeader),
                  const SizedBox(height: 4),
                  Text(
                    'Review custom customer part sourcing inquiries, prepare quotations, and convert to orders.',
                    style: AdminTextStyles.bodySecondary.copyWith(fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Showing ${viewModel.filteredRequests.length} of ${viewModel.allCount} requests',
                    style: AdminTextStyles.bodySecondary,
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: viewModel.isBusy
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AdminColors.primaryGreen,
                            ),
                          )
                        : Icon(Icons.refresh_rounded,
                            color: AdminColors.primaryGreen),
                    tooltip: 'Refresh Requests',
                    onPressed: viewModel.isBusy
                        ? null
                        : () => viewModel.loadRequests(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filters Row with Counts
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip(
                    'All', 'All Requests (${viewModel.allCount})', viewModel),
                _filterChip('Submitted',
                    'Submitted (${viewModel.submittedCount})', viewModel),
                _filterChip('Searching',
                    'Searching (${viewModel.searchingCount})', viewModel),
                _filterChip(
                    'Quotation Sent',
                    'Quotation Sent (${viewModel.quotationSentCount})',
                    viewModel),
                _filterChip('Approved', 'Approved (${viewModel.approvedCount})',
                    viewModel),
                _filterChip('Cancelled',
                    'Cancelled (${viewModel.cancelledCount})', viewModel),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Content Area
          if (viewModel.isBusy)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AdminColors.primaryGreen),
                    const SizedBox(height: 16),
                    Text(
                      'Loading rare product requests...',
                      style: TextStyle(color: AdminColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else if (viewModel.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: AdminColors.cancelled, size: 42),
                    const SizedBox(height: 12),
                    Text(
                      viewModel.errorMessage!,
                      style: TextStyle(color: AdminColors.cancelled),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => viewModel.loadRequests(),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (viewModel.filteredRequests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: AdminEmptyState(
                message: viewModel.searchQuery.isNotEmpty
                    ? 'No rare product requests match "${viewModel.searchQuery}".'
                    : 'No rare product requests found for "${viewModel.selectedStatus}".',
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.filteredRequests.length,
              itemBuilder: (context, index) {
                final request = viewModel.filteredRequests[index];
                return RareRequestCard(
                  request: request,
                  onTap: () => viewModel.openChat(request),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _filterChip(
    String status,
    String label,
    AdminRareRequestsViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: AdminFilterChip(
        label: label,
        isSelected: viewModel.selectedStatus == status,
        onTap: () => viewModel.setSelectedStatus(status),
      ),
    );
  }

  @override
  AdminRareRequestsViewModel viewModelBuilder(BuildContext context) =>
      AdminRareRequestsViewModel();
}
