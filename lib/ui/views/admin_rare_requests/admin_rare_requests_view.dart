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
  Widget builder(
    BuildContext context,
    AdminRareRequestsViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: 'Rare Product Requests',
      selectedItem: AdminNavigationItem.rareRequests,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Inbound Custom Spares Sourcing Tickets',
                  style: AdminTextStyles.sectionHeader),
              Text(
                'Showing ${viewModel.filteredRequests.length} requests',
                style: AdminTextStyles.bodySecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filters Row
          Row(
            children: [
              'All',
              'Submitted',
              'Searching',
              'Quotation Sent',
              'Approved',
              'Cancelled'
            ].map((status) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: AdminFilterChip(
                  label: status == 'All' ? 'All Requests' : status,
                  isSelected: viewModel.selectedStatus == status,
                  onTap: () => viewModel.setSelectedStatus(status),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Tickets List
          if (viewModel.filteredRequests.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: AdminEmptyState(
                  message:
                      'No rare product requests match this status filter.'),
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

  @override
  AdminRareRequestsViewModel viewModelBuilder(BuildContext context) =>
      AdminRareRequestsViewModel();
}
