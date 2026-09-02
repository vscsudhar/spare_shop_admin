import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
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
                    'Track and process returns, damages, and product replacements',
                    style: AdminTextStyles.bodySecondary,
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
          const SizedBox(height: 20),

          // Filters row
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
          const SizedBox(height: 20),

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
                  adjustmentLabel = 'Refund: ₹${c.totalRefundAmount.toStringAsFixed(2)}';
                } else if (c.totalPayableAmount > 0) {
                  adjustmentLabel = 'Payable: ₹${c.totalPayableAmount.toStringAsFixed(2)}';
                }

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
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        if (c.customerPhone.isNotEmpty)
                          Text(c.customerPhone,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    _typeBadge(c.type),
                    AdminStatusChip(
                      label: c.status.toUpperCase(),
                      color: _statusColor(c.status),
                    ),
                    Text('${c.items.length} item${c.items.length > 1 ? 's' : ''}'),
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
        style:
            TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
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
  AdminReturnsListViewModel viewModelBuilder(BuildContext context) =>
      AdminReturnsListViewModel();
}
