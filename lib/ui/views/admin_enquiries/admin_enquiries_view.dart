import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/enquiry_models.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_enquiries_viewmodel.dart';

class AdminEnquiriesView extends StackedView<AdminEnquiriesViewModel> {
  const AdminEnquiriesView({super.key});

  @override
  void onViewModelReady(AdminEnquiriesViewModel viewModel) {
    WidgetsBinding.instance.addPostFrameCallback((_) => viewModel.init());
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    AdminEnquiriesViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: 'Website Part Enquiries',
      selectedItem: AdminNavigationItem.enquiries,
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
                  Text('Website Part Enquiries',
                      style: AdminTextStyles.sectionHeader),
                  const SizedBox(height: 4),
                  Text(
                    'Track, call, and manage spare part enquiries submitted by visitors on the VoltSpare website.',
                    style: AdminTextStyles.bodySecondary,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: viewModel.fetchEnquiries,
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

          // Stat Metric Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 900;
              return GridView.count(
                crossAxisCount: isNarrow ? 2 : 5,
                crossAxisSpacing: AdminSpacing.m,
                mainAxisSpacing: AdminSpacing.m,
                childAspectRatio: isNarrow ? 2.0 : 2.2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  AdminMetricCard(
                    title: 'Total Enquiries',
                    value: viewModel.totalCount.toString(),
                    icon: Icons.question_answer_outlined,
                    iconColor: const Color(0xFF6366F1),
                  ),
                  AdminMetricCard(
                    title: 'Pending Action',
                    value: viewModel.pendingCount.toString(),
                    icon: Icons.hourglass_empty_rounded,
                    iconColor: const Color(0xFFF59E0B),
                  ),
                  AdminMetricCard(
                    title: 'Call User',
                    value: viewModel.callUserCount.toString(),
                    icon: Icons.phone_in_talk_rounded,
                    iconColor: const Color(0xFF3B82F6),
                  ),
                  AdminMetricCard(
                    title: 'Denied User',
                    value: viewModel.deniedCount.toString(),
                    icon: Icons.cancel_outlined,
                    iconColor: const Color(0xFFEF4444),
                  ),
                  AdminMetricCard(
                    title: 'Completed',
                    value: viewModel.completedCount.toString(),
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: const Color(0xFF10B981),
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
                          'Search by customer name, phone number, vehicle brand, model, or part...',
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
                      dropdownColor: AdminColors.panelBackground,
                      items: const [
                        DropdownMenuItem(
                            value: 'all', child: Text('All Statuses')),
                        DropdownMenuItem(
                            value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(
                            value: 'call_user', child: Text('Call User')),
                        DropdownMenuItem(
                            value: 'denied', child: Text('Denied User')),
                        DropdownMenuItem(
                            value: 'completed', child: Text('Completed')),
                      ],
                      onChanged: (val) => viewModel.setFilter(val ?? 'all'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AdminSpacing.l),

          // Main Enquiries List
          if (viewModel.isBusy)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (viewModel.enquiries.isEmpty)
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
                  Icon(Icons.inbox_outlined,
                      size: 56, color: AdminColors.textLight),
                  const SizedBox(height: 12),
                  Text(
                    'No website enquiries found',
                    style: AdminTextStyles.sectionHeader,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'New customer enquiries submitted on the website contact form will appear here with full date and time.',
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
                itemCount: viewModel.enquiries.length,
                separatorBuilder: (_, __) => Divider(
                  color: AdminColors.border,
                  height: AdminSpacing.l,
                ),
                itemBuilder: (context, index) {
                  final item = viewModel.enquiries[index];
                  return _buildEnquiryCard(context, viewModel, item);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnquiryCard(
    BuildContext context,
    AdminEnquiriesViewModel viewModel,
    EnquiryModel item,
  ) {
    final statusColor = item.statusColor;

    return Container(
      padding: const EdgeInsets.all(AdminSpacing.m),
      decoration: BoxDecoration(
        color: AdminColors.background,
        borderRadius: BorderRadius.circular(AdminRadius.card),
        border: Border.all(
          color: item.status.toLowerCase() == 'pending'
              ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
              : AdminColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Header - Avatar, Customer Info, Date & Time, Status, Action Buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: statusColor.withValues(alpha: 0.15),
                child: Icon(
                  item.statusIcon,
                  color: statusColor,
                  size: 22,
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
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AdminRadius.chip),
                            border: Border.all(
                                color: statusColor.withValues(alpha: 0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item.statusIcon,
                                  size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                item.statusDisplay.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone_android_rounded,
                                size: 14, color: Color(0xFF10B981)),
                            const SizedBox(width: 4),
                            SelectableText(
                              item.phone.isNotEmpty ? item.phone : 'No phone',
                              style: AdminTextStyles.bodySecondary.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AdminColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 13, color: AdminColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              item.formattedDateOnly,
                              style: AdminTextStyles.bodySecondary,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 13, color: AdminColors.primaryGreen),
                            const SizedBox(width: 4),
                            Text(
                              item.formattedTimeOnly,
                              style: AdminTextStyles.bodySecondary.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AdminColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () =>
                        _showUpdateStatusDialog(context, viewModel, item),
                    icon: const Icon(Icons.edit_note_rounded, size: 16),
                    label: const Text('Change Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AdminRadius.chip),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        color: AdminColors.cancelled, size: 20),
                    tooltip: 'Delete Enquiry',
                    onPressed: () => _confirmDelete(context, viewModel, item),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AdminSpacing.m),

          // Row 2: Part & Vehicle Specs
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VEHICLE DETAILS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AdminColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AdminColors.primaryGreen
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AdminColors.primaryGreen
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  item.brand.isNotEmpty
                                      ? item.brand
                                      : 'Generic EV',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AdminColors.primaryGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.model.isNotEmpty
                                    ? item.model
                                    : 'Not Specified',
                                style: AdminTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AdminSpacing.m),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REQUIRED SPARE PART',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AdminColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.build_rounded,
                                  size: 14, color: Color(0xFF6366F1)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.partName.isNotEmpty
                                      ? item.partName
                                      : 'General Enquiry',
                                  style: AdminTextStyles.body.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF6366F1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Customer message / description if available
                if (item.message.trim().isNotEmpty) ...[
                  const SizedBox(height: AdminSpacing.s + 2),
                  const Divider(height: 1, color: Colors.black12),
                  const SizedBox(height: AdminSpacing.s),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.notes_rounded,
                          size: 14, color: AdminColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.message,
                          style: AdminTextStyles.body.copyWith(
                            fontSize: 13,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Admin Internal Notes / Follow-up remarks
          if (item.adminNotes != null &&
              item.adminNotes!.trim().isNotEmpty) ...[
            const SizedBox(height: AdminSpacing.s),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AdminSpacing.s + 2),
              decoration: BoxDecoration(
                color: AdminColors.primaryGreen.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AdminRadius.chip),
                border: Border.all(
                    color: AdminColors.primaryGreen.withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.support_agent_rounded,
                      size: 16, color: AdminColors.primaryGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Staff / Admin Follow-up Note:',
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

          // Quick status action chips
          const SizedBox(height: AdminSpacing.s + 4),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Quick Status Update:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.textSecondary,
                ),
              ),
              _quickStatusChip(
                label: 'Pending',
                status: 'pending',
                currentStatus: item.status,
                color: const Color(0xFFF59E0B),
                onTap: () => viewModel.updateStatus(
                  item.id,
                  'pending',
                  adminNotes: item.adminNotes,
                  context: context,
                ),
              ),
              _quickStatusChip(
                label: 'Call User',
                status: 'call_user',
                currentStatus: item.status,
                color: const Color(0xFF3B82F6),
                onTap: () => viewModel.updateStatus(
                  item.id,
                  'call_user',
                  adminNotes: item.adminNotes,
                  context: context,
                ),
              ),
              _quickStatusChip(
                label: 'Denied User',
                status: 'denied',
                currentStatus: item.status,
                color: const Color(0xFFEF4444),
                onTap: () => viewModel.updateStatus(
                  item.id,
                  'denied',
                  adminNotes: item.adminNotes,
                  context: context,
                ),
              ),
              _quickStatusChip(
                label: 'Completed',
                status: 'completed',
                currentStatus: item.status,
                color: const Color(0xFF10B981),
                onTap: () => viewModel.updateStatus(
                  item.id,
                  'completed',
                  adminNotes: item.adminNotes,
                  context: context,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickStatusChip({
    required String label,
    required String status,
    required String currentStatus,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isSelected = currentStatus.toLowerCase() == status.toLowerCase();

    return InkWell(
      onTap: isSelected ? null : onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.check, size: 12, color: Colors.white),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStatusDialog(
    BuildContext context,
    AdminEnquiriesViewModel viewModel,
    EnquiryModel item,
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
              Icon(Icons.edit_note, color: AdminColors.primaryGreen),
              const SizedBox(width: 8),
              const Text('Update Enquiry Status'),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AdminColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AdminColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            item.phone,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vehicle: ${item.brand} ${item.model} • Part: ${item.partName}',
                        style: AdminTextStyles.bodySecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AdminSpacing.m),
                const Text('Select Status',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: currentStatus,
                  dropdownColor: AdminColors.panelBackground,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AdminRadius.chip),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'pending',
                      child: Row(
                        children: [
                          Icon(Icons.hourglass_empty_rounded,
                              size: 16, color: Color(0xFFF59E0B)),
                          SizedBox(width: 8),
                          Text('Pending'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'call_user',
                      child: Row(
                        children: [
                          Icon(Icons.phone_in_talk_rounded,
                              size: 16, color: Color(0xFF3B82F6)),
                          SizedBox(width: 8),
                          Text('Call User'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'denied',
                      child: Row(
                        children: [
                          Icon(Icons.cancel_outlined,
                              size: 16, color: Color(0xFFEF4444)),
                          SizedBox(width: 8),
                          Text('Denied User'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 16, color: Color(0xFF10B981)),
                          SizedBox(width: 8),
                          Text('Completed'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => currentStatus = val);
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  '💡 Note: If status is marked as Denied, you can still edit or re-open it anytime.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AdminColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: AdminSpacing.m),
                const Text('Follow-up / Admin Notes',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'Add remarks, call summary, customer response, or parts availability...',
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
    AdminEnquiriesViewModel viewModel,
    EnquiryModel item,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Enquiry?'),
        content: Text(
            'Are you sure you want to delete the enquiry from "${item.name}" for "${item.partName}"?'),
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
              await viewModel.deleteEnquiry(item.id, context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  AdminEnquiriesViewModel viewModelBuilder(BuildContext context) =>
      AdminEnquiriesViewModel();
}
