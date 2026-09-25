import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/suggestion_models.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_suggestions_viewmodel.dart';

class AdminSuggestionsView extends StackedView<AdminSuggestionsViewModel> {
  const AdminSuggestionsView({super.key});

  @override
  void onViewModelReady(AdminSuggestionsViewModel viewModel) {
    WidgetsBinding.instance.addPostFrameCallback((_) => viewModel.init());
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    AdminSuggestionsViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: 'Customer Feedback & Suggestions',
      selectedItem: AdminNavigationItem.suggestions,
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
                  Text('Feedback & Improvement Suggestions',
                      style: AdminTextStyles.sectionHeader),
                  const SizedBox(height: 4),
                  Text(
                    'Review feedback, feature requests, and suggestions submitted by customers.',
                    style: AdminTextStyles.bodySecondary,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: viewModel.fetchSuggestions,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AdminRadius.chip),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminSpacing.l),

          // Stat Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 800;
              return GridView.count(
                crossAxisCount: isNarrow ? 2 : 4,
                crossAxisSpacing: AdminSpacing.m,
                mainAxisSpacing: AdminSpacing.m,
                childAspectRatio: isNarrow ? 2.0 : 2.4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  AdminMetricCard(
                    title: 'Total Feedback',
                    value: viewModel.totalCount.toString(),
                    icon: Icons.lightbulb_outline,
                    iconColor: const Color(0xFF6366F1),
                  ),
                  AdminMetricCard(
                    title: 'Pending Review',
                    value: viewModel.pendingCount.toString(),
                    icon: Icons.hourglass_empty,
                    iconColor: AdminColors.pending,
                  ),
                  AdminMetricCard(
                    title: 'Reviewed',
                    value: viewModel.reviewedCount.toString(),
                    icon: Icons.rate_review_outlined,
                    iconColor: AdminColors.inProgress,
                  ),
                  AdminMetricCard(
                    title: 'Resolved / Implemented',
                    value: viewModel.resolvedCount.toString(),
                    icon: Icons.check_circle_outline,
                    iconColor: AdminColors.success,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AdminSpacing.l),

          // Filter bar & Search
          Container(
            padding: const EdgeInsets.all(AdminSpacing.m),
            decoration: BoxDecoration(
              color: AdminColors.panelBackground,
              borderRadius: BorderRadius.circular(AdminRadius.card),
              border: Border.all(color: AdminColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: viewModel.onSearch,
                    decoration: InputDecoration(
                      hintText:
                          'Search by user name, phone number, or feedback text...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AdminRadius.chip),
                        borderSide: BorderSide(color: AdminColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AdminSpacing.m,
                        vertical: AdminSpacing.s,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: AdminSpacing.m),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AdminRadius.chip),
                    border: Border.all(color: AdminColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: viewModel.selectedFilter,
                      items: const [
                        DropdownMenuItem(
                            value: 'all', child: Text('All Statuses')),
                        DropdownMenuItem(
                            value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(
                            value: 'reviewed', child: Text('Reviewed')),
                        DropdownMenuItem(
                            value: 'resolved', child: Text('Resolved')),
                      ],
                      onChanged: (val) => viewModel.setFilter(val ?? 'all'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AdminSpacing.l),

          // Main Suggestions List / Table
          if (viewModel.isBusy)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (viewModel.suggestions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AdminSpacing.xl),
              decoration: BoxDecoration(
                color: AdminColors.panelBackground,
                borderRadius: BorderRadius.circular(AdminRadius.card),
                border: Border.all(color: AdminColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mark_chat_unread_outlined,
                      size: 56, color: AdminColors.textLight),
                  const SizedBox(height: 12),
                  Text(
                    'No suggestions found',
                    style: AdminTextStyles.sectionHeader,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Any feedback submitted from the customer app will appear here.',
                    style: AdminTextStyles.bodySecondary,
                  ),
                ],
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AdminColors.panelBackground,
                borderRadius: BorderRadius.circular(AdminRadius.card),
                border: Border.all(color: AdminColors.border),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AdminSpacing.m),
                itemCount: viewModel.suggestions.length,
                separatorBuilder: (_, __) => Divider(
                  color: AdminColors.border,
                  height: AdminSpacing.l,
                ),
                itemBuilder: (context, index) {
                  final item = viewModel.suggestions[index];
                  return _buildSuggestionItem(context, viewModel, item);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    AdminSuggestionsViewModel viewModel,
    SuggestionModel item,
  ) {
    Color statusColor;
    switch (item.status.toLowerCase()) {
      case 'pending':
        statusColor = AdminColors.pending;
        break;
      case 'reviewed':
        statusColor = AdminColors.inProgress;
        break;
      case 'resolved':
        statusColor = AdminColors.success;
        break;
      default:
        statusColor = AdminColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.all(AdminSpacing.m),
      decoration: BoxDecoration(
        color: AdminColors.background,
        borderRadius: BorderRadius.circular(AdminRadius.card),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Information & Status Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    AdminColors.primaryGreen.withValues(alpha: 0.15),
                child: Text(
                  item.name.isNotEmpty ? item.name[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: AdminColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: AdminSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.name,
                          style: AdminTextStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: AdminSpacing.s),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AdminRadius.chip),
                            border: Border.all(
                                color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            item.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined,
                            size: 14, color: AdminColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          item.phone.isNotEmpty ? item.phone : 'Not provided',
                          style: AdminTextStyles.bodySecondary.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: AdminSpacing.m),
                        Icon(Icons.access_time,
                            size: 14, color: AdminColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          item.formattedDate,
                          style: AdminTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: () =>
                        _showUpdateDialog(context, viewModel, item),
                    icon: const Icon(Icons.edit_note, size: 16),
                    label: const Text('Update Status'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminColors.primaryGreen,
                      side: BorderSide(color: AdminColors.primaryGreen),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AdminRadius.chip),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        color: AdminColors.cancelled, size: 20),
                    tooltip: 'Delete Feedback',
                    onPressed: () => _confirmDelete(context, viewModel, item),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AdminSpacing.m),

          // Suggestion Content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AdminSpacing.m),
            decoration: BoxDecoration(
              color: AdminColors.panelBackground,
              borderRadius: BorderRadius.circular(AdminRadius.chip),
              border:
                  Border.all(color: AdminColors.border.withValues(alpha: 0.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.format_quote,
                        size: 16, color: AdminColors.primaryGreen),
                    const SizedBox(width: 6),
                    Text(
                      'Customer Suggestion / Feedback:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.suggestion,
                  style: AdminTextStyles.body.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Admin notes if present
          if (item.adminNotes != null &&
              item.adminNotes!.trim().isNotEmpty) ...[
            const SizedBox(height: AdminSpacing.s),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AdminSpacing.s + 2),
              decoration: BoxDecoration(
                color: AdminColors.primaryGreen.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AdminRadius.chip),
                border: Border.all(
                    color: AdminColors.primaryGreen.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.admin_panel_settings_outlined,
                      size: 16, color: AdminColors.primaryGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Internal Admin Notes:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.adminNotes!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showUpdateDialog(
    BuildContext context,
    AdminSuggestionsViewModel viewModel,
    SuggestionModel item,
  ) {
    String currentStatus = item.status;
    final notesController = TextEditingController(text: item.adminNotes ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminRadius.card),
          ),
          title: Row(
            children: [
              Icon(Icons.rate_review, color: AdminColors.primaryGreen),
              const SizedBox(width: 8),
              const Text('Update Suggestion Status'),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feedback from: ${item.name} (${item.phone})',
                  style: AdminTextStyles.bodySecondary,
                ),
                const SizedBox(height: AdminSpacing.m),
                const Text('Status',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: currentStatus,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AdminRadius.chip),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(
                        value: 'reviewed', child: Text('Reviewed')),
                    DropdownMenuItem(
                        value: 'resolved',
                        child: Text('Resolved / Implemented')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => currentStatus = val);
                  },
                ),
                const SizedBox(height: AdminSpacing.m),
                const Text('Internal Admin Notes',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add remarks, actions taken, or team notes...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AdminRadius.chip),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await viewModel.updateStatus(
                  item.id,
                  currentStatus,
                  adminNotes: notesController.text.trim(),
                  context: context,
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    AdminSuggestionsViewModel viewModel,
    SuggestionModel item,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Suggestion?'),
        content: Text(
            'Are you sure you want to delete feedback submitted by ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.cancelled,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await viewModel.deleteSuggestion(item.id, context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  AdminSuggestionsViewModel viewModelBuilder(BuildContext context) =>
      AdminSuggestionsViewModel();
}
