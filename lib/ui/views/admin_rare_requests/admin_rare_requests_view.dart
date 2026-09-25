import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
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

          const SizedBox(height: 16),

          // Location Filter Section & Hub Selector
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminColors.panelBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AdminColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16, color: AdminColors.primaryGreen),
                    const SizedBox(width: 6),
                    Text(
                      'Store Hub Location:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (!viewModel.canChangeLocation)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              AdminColors.primaryGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Restricted to: ${viewModel.userAssignedLocationName ?? "My Hub"}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AdminColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (viewModel.canChangeLocation) ...[
                        _locationChip(
                            'all', 'All Locations / Global HQ', viewModel),
                        ...viewModel.locations.map((loc) {
                          return _locationChip(loc.id, loc.name, viewModel);
                        }),
                        _locationChip(
                            'unassigned', '⚠️ Unassigned HQ', viewModel),
                      ] else ...[
                        _locationChip(
                          viewModel.userAssignedLocationId ?? 'all',
                          viewModel.userAssignedLocationName ??
                              'My Hub Location',
                          viewModel,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Channel & Status Filters Row
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Channel selection
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Channel:',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 6),
                  _channelChip('all', 'All Channels', viewModel),
                  _channelChip('online', '📱 Online App', viewModel),
                  _channelChip('in_store', '🏬 Store Walk-in', viewModel),
                ],
              ),
              const SizedBox(width: 8),
              // Status selection
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('All', 'All Requests (${viewModel.allCount})',
                        viewModel),
                    _filterChip('Submitted',
                        'Submitted (${viewModel.submittedCount})', viewModel),
                    _filterChip('Searching',
                        'Searching (${viewModel.searchingCount})', viewModel),
                    _filterChip(
                        'Quotation Sent',
                        'Quotation Sent (${viewModel.quotationSentCount})',
                        viewModel),
                    _filterChip('Approved',
                        'Approved (${viewModel.approvedCount})', viewModel),
                    _filterChip('Cancelled',
                        'Cancelled (${viewModel.cancelledCount})', viewModel),
                  ],
                ),
              ),
            ],
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
                    : 'No rare product requests found for current filters.',
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
                  onAssignLocation: viewModel.canChangeLocation &&
                          viewModel.locations.isNotEmpty
                      ? () =>
                          _showAssignLocationDialog(context, viewModel, request)
                      : null,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _locationChip(
    String id,
    String label,
    AdminRareRequestsViewModel viewModel,
  ) {
    final isSelected = viewModel.selectedLocationFilter == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AdminColors.primaryGreen.withValues(alpha: 0.2),
        checkmarkColor: AdminColors.primaryGreen,
        labelStyle: TextStyle(
          color:
              isSelected ? AdminColors.primaryGreen : AdminColors.textSecondary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: AdminColors.background,
        side: BorderSide(
          color: isSelected ? AdminColors.primaryGreen : AdminColors.border,
        ),
        onSelected: (_) => viewModel.setSelectedLocationFilter(id),
      ),
    );
  }

  Widget _channelChip(
    String channel,
    String label,
    AdminRareRequestsViewModel viewModel,
  ) {
    final isSelected = viewModel.selectedChannel == channel;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AdminColors.primaryGreen.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color:
              isSelected ? AdminColors.primaryGreen : AdminColors.textSecondary,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: AdminColors.background,
        side: BorderSide(
          color: isSelected ? AdminColors.primaryGreen : AdminColors.border,
        ),
        onSelected: (val) {
          if (val) viewModel.setSelectedChannel(channel);
        },
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

  void _showAssignLocationDialog(
    BuildContext context,
    AdminRareRequestsViewModel viewModel,
    RareProductRequestModel request,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AdminColors.panelBackground,
          title: Row(
            children: [
              Icon(Icons.storefront_outlined,
                  color: AdminColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              const Text('Assign Request Hub / Store',
                  style: TextStyle(fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select the store hub to fulfill ticket #${request.id.length > 8 ? request.id.substring(request.id.length - 8).toUpperCase() : request.id}:',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ...viewModel.locations.map((loc) {
                  final isSelected = loc.id == request.locationId;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color:
                          isSelected ? AdminColors.primaryGreen : Colors.grey,
                      size: 18,
                    ),
                    title: Text(loc.name,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AdminColors.primaryGreen
                                : Colors.white)),
                    subtitle: Text('Radius: ${loc.radiusDisplay}',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey)),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      viewModel.updateRequestLocation(
                          request.id, loc.id, loc.name, context);
                    },
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  AdminRareRequestsViewModel viewModelBuilder(BuildContext context) =>
      AdminRareRequestsViewModel();
}
