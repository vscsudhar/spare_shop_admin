import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/return_exchange_models.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_table_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_returns_list_viewmodel.dart';

class AdminReturnsListView extends StackedView<AdminReturnsListViewModel> {
  const AdminReturnsListView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminReturnsListViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: 'Returns & Exchanges',
      selectedItem: AdminNavigationItem.returnsExchanges,
      onSearch: viewModel.setSearchQuery,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('After-Sales Management',
                      style: AdminTextStyles.sectionHeader),
                  const SizedBox(height: 4),
                  Text(
                    'Track online app return claims and in-store walk-in returns by location hub',
                    style: AdminTextStyles.bodySecondary.copyWith(fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed:
                        viewModel.isBusy ? null : () => viewModel.loadCases(),
                    icon: const Icon(Icons.refresh,
                        size: 20, color: Colors.white70),
                    tooltip: 'Refresh Cases',
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.openNewReturn(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Return / Exchange'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Location Filter Section
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
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    if (!viewModel.canChangeLocation &&
                        viewModel.userAssignedLocationName != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock,
                                size: 12, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              'Scoped to ${viewModel.userAssignedLocationName}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      AdminFilterChip(
                        label: 'All Locations (HQ)',
                        isSelected: viewModel.selectedLocationFilter == 'all',
                        onTap: () => viewModel.setSelectedLocationFilter('all'),
                      ),
                      ...viewModel.locations.map((loc) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: AdminFilterChip(
                            label: '${loc.name} Hub',
                            isSelected:
                                viewModel.selectedLocationFilter == loc.id,
                            onTap: () =>
                                viewModel.setSelectedLocationFilter(loc.id),
                          ),
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: AdminFilterChip(
                          label: viewModel.unassignedCasesCount > 0
                              ? '⚠️ Unassigned (${viewModel.unassignedCasesCount})'
                              : 'Unassigned',
                          isSelected:
                              viewModel.selectedLocationFilter == 'unassigned',
                          onTap: () =>
                              viewModel.setSelectedLocationFilter('unassigned'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Return Channel Filter (Online App vs In-Store Visit)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Channel: ',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70)),
                const SizedBox(width: 6),
                AdminFilterChip(
                  label: 'All Channels',
                  isSelected: viewModel.selectedChannel == 'all',
                  onTap: () => viewModel.setSelectedChannel('all'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label:
                      '📱 Online Mobile App (${viewModel.onlineClaimsCount})',
                  isSelected: viewModel.selectedChannel == 'online',
                  onTap: () => viewModel.setSelectedChannel('online'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label:
                      '🏬 Store Visit / Walk-in (${viewModel.storeVisitsCount})',
                  isSelected: viewModel.selectedChannel == 'in_store',
                  onTap: () => viewModel.setSelectedChannel('in_store'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Type & Status Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Type: ',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70)),
                const SizedBox(width: 6),
                AdminFilterChip(
                  label: 'All Types',
                  isSelected: viewModel.selectedType == 'all',
                  onTap: () => viewModel.setFilterType('all'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Return',
                  isSelected: viewModel.selectedType == 'return',
                  onTap: () => viewModel.setFilterType('return'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Damage',
                  isSelected: viewModel.selectedType == 'damage',
                  onTap: () => viewModel.setFilterType('damage'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Exchange',
                  isSelected: viewModel.selectedType == 'exchange',
                  onTap: () => viewModel.setFilterType('exchange'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Mixed',
                  isSelected: viewModel.selectedType == 'mixed',
                  onTap: () => viewModel.setFilterType('mixed'),
                ),
                const SizedBox(width: 24),
                const Text('Status: ',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70)),
                const SizedBox(width: 6),
                AdminFilterChip(
                  label: 'All',
                  isSelected: viewModel.selectedStatus == 'all',
                  onTap: () => viewModel.setFilterStatus('all'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Pending',
                  isSelected: viewModel.selectedStatus == 'pending',
                  onTap: () => viewModel.setFilterStatus('pending'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Approved',
                  isSelected: viewModel.selectedStatus == 'approved',
                  onTap: () => viewModel.setFilterStatus('approved'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Received',
                  isSelected: viewModel.selectedStatus == 'received',
                  onTap: () => viewModel.setFilterStatus('received'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Completed',
                  isSelected: viewModel.selectedStatus == 'completed',
                  onTap: () => viewModel.setFilterStatus('completed'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Cases Table
          if (viewModel.isBusy)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (viewModel.filteredCases.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  children: [
                    const Icon(Icons.assignment_return_outlined,
                        size: 56, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('No Return / Exchange cases found',
                        style: AdminTextStyles.sectionHeader),
                    const SizedBox(height: 8),
                    const Text(
                      'Search by bill number or create a new return case to get started.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => viewModel.openNewReturn(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Process First Return'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            AdminDataTable(
              columns: const [
                'Case Number',
                'Bill Reference',
                'Customer',
                'Hub Location',
                'Channel',
                'Type',
                'Status',
                'Items',
                'Adjustment',
                'Updated',
                'Actions',
              ],
              rows: viewModel.filteredCases.map((c) {
                final dateStr =
                    '${c.updatedAt.day.toString().padLeft(2, '0')}/${c.updatedAt.month.toString().padLeft(2, '0')}/${c.updatedAt.year}';

                String adjustmentLabel = '₹0.00';
                if (c.totalRefundAmount > 0) {
                  adjustmentLabel =
                      'Refund: ₹${c.totalRefundAmount.toStringAsFixed(2)}';
                } else if (c.totalPayableAmount > 0) {
                  adjustmentLabel =
                      'Payable: ₹${c.totalPayableAmount.toStringAsFixed(2)}';
                }

                final hasLocation =
                    c.locationName != null && c.locationName!.isNotEmpty;

                return AdminTableRow(
                  cells: [
                    Text(
                      c.caseNumber,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AdminColors.primaryGreen),
                    ),
                    Text(c.billNumber),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(c.customerName,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        if (c.customerPhone.isNotEmpty)
                          Text(c.customerPhone,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    // Location Hub Cell
                    Align(
                      alignment: Alignment.centerLeft,
                      child: hasLocation
                          ? InkWell(
                              onTap: () => _showAssignLocationDialog(
                                  context, viewModel, c),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AdminColors.primaryGreen
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: AdminColors.primaryGreen
                                          .withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_on,
                                        size: 13,
                                        color: AdminColors.primaryGreen),
                                    const SizedBox(width: 4),
                                    Text(
                                      c.locationName!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AdminColors.primaryGreen,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_drop_down,
                                        size: 14, color: Colors.white54),
                                  ],
                                ),
                              ),
                            )
                          : OutlinedButton.icon(
                              onPressed: () => _showAssignLocationDialog(
                                  context, viewModel, c),
                              icon: const Icon(Icons.add_location_alt,
                                  size: 12, color: Colors.amber),
                              label: const Text(
                                '+ Add Hub',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.amber),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Colors.amber.withValues(alpha: 0.5)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                    ),
                    // Channel Cell
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _channelBadge(c.channel),
                    ),
                    _typeBadge(c.type),
                    AdminStatusChip(
                      label: c.status.toUpperCase(),
                      color: _statusColor(c.status),
                    ),
                    Text(
                        '${c.items.length} item${c.items.length > 1 ? 's' : ''}'),
                    Text(
                      adjustmentLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: c.totalRefundAmount > 0
                            ? Colors.orangeAccent
                            : (c.totalPayableAmount > 0
                                ? Colors.greenAccent
                                : Colors.white70),
                      ),
                    ),
                    Text(dateStr,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70)),
                    TextButton.icon(
                      onPressed: () => viewModel.openCaseDetail(c),
                      icon: const Icon(Icons.remove_red_eye, size: 16),
                      label: const Text('View'),
                      style: TextButton.styleFrom(
                        foregroundColor: AdminColors.primaryGreen,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _channelBadge(String channel) {
    final isOnline = channel.toLowerCase().contains('online') ||
        channel.toLowerCase().contains('app');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isOnline
            ? Colors.cyan.withValues(alpha: 0.15)
            : Colors.purple.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isOnline
              ? Colors.cyan.withValues(alpha: 0.35)
              : Colors.purple.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline
                ? Icons.phone_android
                : Icons.store_mall_directory_outlined,
            size: 11,
            color: isOnline ? Colors.cyanAccent : Colors.purpleAccent,
          ),
          const SizedBox(width: 4),
          Text(
            isOnline ? 'Online App' : 'Store Visit',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isOnline ? Colors.cyanAccent : Colors.purpleAccent,
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignLocationDialog(
    BuildContext context,
    AdminReturnsListViewModel viewModel,
    ReturnExchangeCase kase,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AdminColors.panelBackground,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(Icons.location_on,
                  color: AdminColors.primaryGreen, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Assign Hub for ${kase.caseNumber}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer: ${kase.customerName} (Bill #${kase.billNumber})',
                  style:
                      TextStyle(fontSize: 12, color: AdminColors.textSecondary),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Select Receiving / Fulfillment Hub:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (viewModel.locations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'No locations registered in system.',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: viewModel.locations.length,
                      separatorBuilder: (_, __) => const Divider(height: 8),
                      itemBuilder: (context, index) {
                        final loc = viewModel.locations[index];
                        final isCurrent = kase.locationId == loc.id ||
                            kase.locationName?.toLowerCase() ==
                                loc.name.toLowerCase();
                        return ListTile(
                          dense: true,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          tileColor: isCurrent
                              ? AdminColors.primaryGreen.withValues(alpha: 0.15)
                              : Colors.transparent,
                          leading: Icon(
                            Icons.storefront_outlined,
                            size: 18,
                            color: isCurrent
                                ? AdminColors.primaryGreen
                                : Colors.white70,
                          ),
                          title: Text(
                            '${loc.name} Hub',
                            style: TextStyle(
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isCurrent
                                  ? AdminColors.primaryGreen
                                  : Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            'Coverage: ${loc.radiusDisplay}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white54),
                          ),
                          trailing: isCurrent
                              ? Icon(Icons.check_circle,
                                  color: AdminColors.primaryGreen, size: 18)
                              : null,
                          onTap: () {
                            Navigator.of(ctx).pop();
                            viewModel.assignCaseLocation(kase, loc);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Case ${kase.caseNumber} assigned to ${loc.name} Hub'),
                                backgroundColor: AdminColors.primaryGreen,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            if (kase.locationId != null || kase.locationName != null)
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  viewModel.assignCaseLocation(kase, null);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Case ${kase.caseNumber} location removed (Unassigned)'),
                      backgroundColor: Colors.grey[800],
                    ),
                  );
                },
                child: const Text('Clear Location',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _typeBadge(String type) {
    Color bg = Colors.blue.withValues(alpha: 0.15);
    Color fg = Colors.lightBlueAccent;
    String label = 'RETURN';

    if (type.toLowerCase() == 'damage') {
      bg = Colors.red.withValues(alpha: 0.15);
      fg = Colors.redAccent;
      label = 'DAMAGE';
    } else if (type.toLowerCase() == 'exchange') {
      bg = Colors.purple.withValues(alpha: 0.15);
      fg = Colors.purpleAccent;
      label = 'EXCHANGE';
    } else if (type.toLowerCase() == 'mixed') {
      bg = Colors.amber.withValues(alpha: 0.15);
      fg = Colors.amberAccent;
      label = 'MIXED';
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
        style: TextStyle(
          fontSize: 10,
          color: fg,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AdminColors.pending;
      case 'approved':
      case 'completed':
        return AdminColors.success;
      case 'received':
      case 'processing':
        return AdminColors.inProgress;
      case 'rejected':
      case 'cancelled':
        return AdminColors.cancelled;
      default:
        return Colors.grey;
    }
  }

  @override
  AdminReturnsListViewModel viewModelBuilder(BuildContext context) =>
      AdminReturnsListViewModel();
}
