import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/admin_support_ticket_models.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_support_tickets_viewmodel.dart';

class AdminSupportTicketsView
    extends StackedView<AdminSupportTicketsViewModel> {
  const AdminSupportTicketsView({Key? key}) : super(key: key);

  @override
  void onViewModelReady(AdminSupportTicketsViewModel viewModel) {
    WidgetsBinding.instance.addPostFrameCallback((_) => viewModel.init());
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    AdminSupportTicketsViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: 'Customer Support Tickets',
      selectedItem: AdminNavigationItem.supportTickets,
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
                  Text('Support Inquiries & Customer Care',
                      style: AdminTextStyles.sectionHeader),
                  const SizedBox(height: 4),
                  Text(
                    'Showing ${viewModel.filteredTickets.length} of ${viewModel.allCount} tickets',
                    style: AdminTextStyles.bodySecondary,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: viewModel.isBusy ? null : viewModel.loadTickets,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.panelBackground,
                  foregroundColor: AdminColors.textPrimary,
                  elevation: 0,
                  side: BorderSide(color: AdminColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
                  label: 'All Tickets (${viewModel.allCount})',
                  isSelected: viewModel.selectedStatus == 'All',
                  onTap: () => viewModel.setSelectedStatus('All'),
                ),
                _filterChip(
                  label: 'Open (${viewModel.openCount})',
                  isSelected: viewModel.selectedStatus == 'Open',
                  onTap: () => viewModel.setSelectedStatus('Open'),
                  badgeColor: const Color(0xFF0070F3),
                ),
                _filterChip(
                  label: 'Pending (${viewModel.pendingCount})',
                  isSelected: viewModel.selectedStatus == 'Pending',
                  onTap: () => viewModel.setSelectedStatus('Pending'),
                  badgeColor: const Color(0xFFFF9800),
                ),
                _filterChip(
                  label: 'Resolved (${viewModel.resolvedCount})',
                  isSelected: viewModel.selectedStatus == 'Resolved',
                  onTap: () => viewModel.setSelectedStatus('Resolved'),
                  badgeColor: const Color(0xFF00B156),
                ),
                _filterChip(
                  label: 'Closed (${viewModel.closedCount})',
                  isSelected: viewModel.selectedStatus == 'Closed',
                  onTap: () => viewModel.setSelectedStatus('Closed'),
                  badgeColor: const Color(0xFF757575),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tickets List
          if (viewModel.isBusy)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: CircularProgressIndicator(
                    color: AdminColors.primaryGreen),
              ),
            )
          else if (viewModel.filteredTickets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: AdminEmptyState(
                message: viewModel.searchQuery.isNotEmpty
                    ? 'No support tickets match "${viewModel.searchQuery}".'
                    : 'No support tickets match the "${viewModel.selectedStatus}" filter.',
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.filteredTickets.length,
              itemBuilder: (context, index) {
                final ticket = viewModel.filteredTickets[index];
                return _buildTicketCard(context, viewModel, ticket);
              },
            ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AdminColors.primaryGreen.withValues(alpha: 0.15)
                : AdminColors.panelBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AdminColors.primaryGreen
                  : AdminColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (badgeColor != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AdminColors.sidebarActiveText
                      : AdminColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    AdminSupportTicketsViewModel viewModel,
    AdminSupportTicket ticket,
  ) {
    final status = ticket.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(AdminRadius.card),
        border: Border.all(color: AdminColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => viewModel.openTicketChat(ticket),
          borderRadius: BorderRadius.circular(AdminRadius.card),
          hoverColor: AdminColors.primaryGreen.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: status.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.headset_mic_rounded,
                    color: status.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),

                // Middle Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '#${ticket.ticketNumber}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AdminColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AdminColors.background,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AdminColors.border),
                            ),
                            child: Text(
                              ticket.category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AdminColors.textSecondary,
                              ),
                            ),
                          ),
                          if (ticket.photos.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.photo_outlined,
                                      size: 11, color: Colors.blue),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${ticket.photos.length}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (ticket.priority.toLowerCase() == 'urgent' ||
                              ticket.priority.toLowerCase() == 'high') ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                ticket.priority.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ticket.subject,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        ticket.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AdminColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 13, color: AdminColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            ticket.customerName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AdminColors.textPrimary,
                            ),
                          ),
                          if (ticket.customerPhone.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '•  ${ticket.customerPhone}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AdminColors.textSecondary,
                              ),
                            ),
                          ],
                          if (ticket.customerEmail.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '•  ${ticket.customerEmail}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AdminColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Right Badges & Action
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: status.backgroundColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.displayName,
                        style: TextStyle(
                          color: status.color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${ticket.createdAt.day.toString().padLeft(2, '0')}/${ticket.createdAt.month.toString().padLeft(2, '0')}/${ticket.createdAt.year}',
                      style: TextStyle(
                        color: AdminColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Open Chat',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 10, color: AdminColors.primaryGreen),
                      ],
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

  @override
  AdminSupportTicketsViewModel viewModelBuilder(BuildContext context) =>
      AdminSupportTicketsViewModel();
}
