import 'package:flutter/material.dart';
import 'package:spare_shop_admin/core/models/notification_model.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:stacked/stacked.dart';
import 'admin_notifications_viewmodel.dart';

class AdminNotificationsView
    extends StackedView<AdminNotificationsViewModel> {
  const AdminNotificationsView({super.key});

  @override
  AdminNotificationsViewModel viewModelBuilder(BuildContext context) =>
      AdminNotificationsViewModel();

  @override
  void onViewModelReady(AdminNotificationsViewModel viewModel) =>
      viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    AdminNotificationsViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: 'Customer Notifications',
      selectedItem: AdminNavigationItem.settings, // Fallback or active item
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, viewModel),
          const SizedBox(height: 20),
          _buildTabButtons(context, viewModel),
          const SizedBox(height: 20),
          if (viewModel.currentTabIndex == 0)
            _buildSendNotificationTab(context, viewModel)
          else
            _buildHistoryTab(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AdminNotificationsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(AdminRadius.card),
        border: Border.all(color: AdminColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;
          return Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AdminColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.campaign_rounded,
                  color: AdminColors.primaryGreen,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Notification Center',
                      style: AdminTextStyles.header.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dispatch targeted push & in-app alerts, broadcast marketing promos with image banners, and track deliverability history.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AdminColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isNarrow) ...[
                const SizedBox(width: 16),
                _buildQuickStatChip(
                  icon: Icons.history_rounded,
                  label: 'History Logs',
                  value: '${viewModel.totalHistoryCount}',
                  color: Colors.blue,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButtons(
      BuildContext context, AdminNotificationsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabButton(
            context,
            title: 'Compose & Send',
            icon: Icons.send_rounded,
            isSelected: viewModel.currentTabIndex == 0,
            onTap: () => viewModel.setTabIndex(0),
          ),
          const SizedBox(width: 4),
          _buildTabButton(
            context,
            title: 'Audit & History Log (${viewModel.totalHistoryCount})',
            icon: Icons.receipt_long_rounded,
            isSelected: viewModel.currentTabIndex == 1,
            onTap: () => viewModel.setTabIndex(1),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AdminColors.primaryGreen
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AdminColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AdminColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendNotificationTab(
      BuildContext context, AdminNotificationsViewModel viewModel) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 960;

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: _buildFormCard(context, viewModel),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 5,
                child: _buildRightPanel(context, viewModel),
              ),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFormCard(context, viewModel),
              const SizedBox(height: 24),
              _buildRightPanel(context, viewModel),
            ],
          );
        }
      },
    );
  }

  Widget _buildFormCard(
      BuildContext context, AdminNotificationsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(AdminRadius.card),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dispatch Mode',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AdminColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildModeOption(
                  context,
                  title: 'Single Customer',
                  description: 'Targeted message to a specific customer',
                  icon: Icons.person_rounded,
                  isSelected: viewModel.sendMode == 'single',
                  onTap: () => viewModel.setSendMode('single'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModeOption(
                  context,
                  title: 'Bulk Broadcast',
                  description: 'Blast to all registered customer devices',
                  icon: Icons.campaign_rounded,
                  isSelected: viewModel.sendMode == 'bulk',
                  onTap: () => viewModel.setSendMode('bulk'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Customer search if single
          if (viewModel.sendMode == 'single') ...[
            Text(
              'Select Customer *',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AdminColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            if (viewModel.selectedCustomer != null)
              _buildSelectedCustomerCard(context, viewModel)
            else
              _buildCustomerSearchField(context, viewModel),
            const SizedBox(height: 20),
          ] else ...[
            Text(
              'Target Audience',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AdminColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AdminColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AdminColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: viewModel.targetAudience,
                  isExpanded: true,
                  dropdownColor: AdminColors.panelBackground,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: const [
                    DropdownMenuItem(
                      value: 'all_customers',
                      child: Text('All Registered Customers (Broadcast)'),
                    ),
                    DropdownMenuItem(
                      value: 'active_customers',
                      child: Text('Active Customers Only'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) viewModel.setTargetAudience(val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Notification type dropdown
          Text(
            'Notification Category',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AdminColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AdminColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AdminColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: viewModel.selectedType,
                isExpanded: true,
                dropdownColor: AdminColors.panelBackground,
                icon: const Icon(Icons.arrow_drop_down),
                items: const [
                  DropdownMenuItem(
                    value: 'promotional',
                    child: Text('🎉 Promotional Offer / Sale'),
                  ),
                  DropdownMenuItem(
                    value: 'manual_single',
                    child: Text('💬 Direct Account Notice'),
                  ),
                  DropdownMenuItem(
                    value: 'broadcast',
                    child: Text('📢 General Announcement'),
                  ),
                  DropdownMenuItem(
                    value: 'order_status',
                    child: Text('🚚 Order & Delivery Update'),
                  ),
                  DropdownMenuItem(
                    value: 'rare_product_chat',
                    child: Text('🔍 Sourcing & Rare Product Notice'),
                  ),
                  DropdownMenuItem(
                    value: 'ticket_chat',
                    child: Text('🎫 Support Ticket Update'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) viewModel.setSelectedType(val);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notification Title *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
              Text(
                '${viewModel.titleController.text.length}/150',
                style: TextStyle(
                  fontSize: 11,
                  color: AdminColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: viewModel.titleController,
            maxLength: 150,
            style: TextStyle(color: AdminColors.textPrimary, fontSize: 13.5),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'e.g. Flash Sale: 20% Off EV Batteries Today! ⚡',
              hintStyle: TextStyle(color: AdminColors.textSecondary, fontSize: 13),
              filled: true,
              fillColor: AdminColors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AdminColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AdminColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AdminColors.primaryGreen, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Message
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Message Body *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
              Text(
                '${viewModel.messageController.text.length}/1000',
                style: TextStyle(
                  fontSize: 11,
                  color: AdminColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: viewModel.messageController,
            maxLines: 4,
            maxLength: 1000,
            style: TextStyle(color: AdminColors.textPrimary, fontSize: 13.5),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Write the complete notification message shown to the customer...',
              hintStyle: TextStyle(color: AdminColors.textSecondary, fontSize: 13),
              filled: true,
              fillColor: AdminColors.background,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AdminColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AdminColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AdminColors.primaryGreen, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Attached Image
          Text(
            'Attached Image Banner (Optional)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AdminColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: viewModel.imageUrlController,
                  style: TextStyle(color: AdminColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'https://example.com/banner.jpg',
                    hintStyle: TextStyle(color: AdminColors.textSecondary, fontSize: 12.5),
                    prefixIcon: const Icon(Icons.link_rounded, size: 18),
                    filled: true,
                    fillColor: AdminColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AdminColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AdminColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AdminColors.primaryGreen, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: viewModel.isUploadingImage
                    ? null
                    : () => viewModel.pickAndUploadImage(),
                icon: viewModel.isUploadingImage
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.upload_file_rounded, size: 16),
                label: Text(
                  viewModel.isUploadingImage ? 'Uploading...' : 'Upload Image',
                  style: const TextStyle(fontSize: 12.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              if (viewModel.previewImage != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Remove Image',
                  icon: const Icon(Icons.clear, color: Colors.red, size: 20),
                  onPressed: viewModel.clearImage,
                ),
              ],
            ],
          ),
          const SizedBox(height: 28),

          // Send button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: viewModel.isBusy
                  ? null
                  : () => viewModel.sendNotification(context),
              icon: viewModel.isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                viewModel.isBusy
                    ? 'Dispatching Notification...'
                    : (viewModel.sendMode == 'single'
                        ? 'Send Direct Notification'
                        : 'Broadcast Push to All Customers'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AdminColors.primaryGreen.withValues(alpha: 0.08)
              : AdminColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AdminColors.primaryGreen
                : AdminColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AdminColors.primaryGreen
                  : AdminColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AdminColors.primaryGreen
                          : AdminColors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSearchField(
      BuildContext context, AdminNotificationsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: viewModel.customerSearchController,
          onChanged: (val) => viewModel.searchCustomers(val),
          style: TextStyle(color: AdminColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Search customer by name, email, or phone...',
            hintStyle: TextStyle(color: AdminColors.textSecondary, fontSize: 13),
            prefixIcon: const Icon(Icons.search, size: 18),
            suffixIcon: viewModel.isSearchingCustomers
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            filled: true,
            fillColor: AdminColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AdminColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AdminColors.border),
            ),
          ),
        ),
        if (viewModel.customerSuggestions.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: AdminColors.panelBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AdminColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: viewModel.customerSuggestions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final cust = viewModel.customerSuggestions[index];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: AdminColors.primaryGreen.withValues(alpha: 0.15),
                    child: Text(
                      cust.name.isNotEmpty ? cust.name[0].toUpperCase() : 'C',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.primaryGreen,
                      ),
                    ),
                  ),
                  title: Text(
                    cust.name,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${cust.phone.isNotEmpty ? cust.phone : 'No phone'} • ${cust.email}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                  onTap: () => viewModel.selectCustomer(cust),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedCustomerCard(
      BuildContext context, AdminNotificationsViewModel viewModel) {
    final cust = viewModel.selectedCustomer!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AdminColors.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminColors.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AdminColors.primaryGreen,
            child: Text(
              cust.name.isNotEmpty ? cust.name[0].toUpperCase() : 'C',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cust.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textPrimary,
                  ),
                ),
                Text(
                  '${cust.phone.isNotEmpty ? cust.phone : 'No phone'} • ${cust.email}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AdminColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Clear customer',
            icon: const Icon(Icons.close, size: 18),
            onPressed: viewModel.clearSelectedCustomer,
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(
      BuildContext context, AdminNotificationsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-tabs for Right Panel: Templates vs Device Preview
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AdminColors.panelBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AdminColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSubTabButton(
                  title: '⚡ Quick Templates (${viewModel.templates.length})',
                  isSelected: viewModel.rightPanelTabIndex == 0,
                  onTap: () => viewModel.setRightPanelTabIndex(0),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildSubTabButton(
                  title: '📱 Live Device Preview',
                  isSelected: viewModel.rightPanelTabIndex == 1,
                  onTap: () => viewModel.setRightPanelTabIndex(1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (viewModel.rightPanelTabIndex == 0)
          _buildTemplatesCard(context, viewModel)
        else
          _buildLivePreviewCard(context, viewModel),
      ],
    );
  }

  Widget _buildSubTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AdminColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AdminColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTemplatesCard(
      BuildContext context, AdminNotificationsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(AdminRadius.card),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.flash_on_rounded, size: 18, color: Colors.amber),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready-to-Send Broadcast Templates',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Tap any card to auto-fill broadcast form, or tap Broadcast Now to send.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.templates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final template = viewModel.templates[index];
              return _buildTemplateItem(context, viewModel, template);
            },
          ),
          const SizedBox(height: 16),
          // Tip banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminColors.primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AdminColors.primaryGreen.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates_outlined, size: 18, color: AdminColors.primaryGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tapping a template sets mode to Bulk Broadcast, populates the image banner, and updates the live device push preview immediately.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AdminColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateItem(
    BuildContext context,
    AdminNotificationsViewModel viewModel,
    NotificationTemplate template,
  ) {
    final isSelected = viewModel.selectedTemplate?.id == template.id;
    final tagColor = _getTemplateTagColor(template.iconCode);

    return InkWell(
      onTap: () => viewModel.applyTemplate(template, context),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AdminColors.primaryGreen.withValues(alpha: 0.08)
              : AdminColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AdminColors.primaryGreen
                : AdminColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Category Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tagColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    template.categoryTag,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: tagColor,
                    ),
                  ),
                ),
                const Spacer(),
                if (template.image != null && template.image!.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.image_outlined, size: 14, color: Colors.blue.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Image Banner',
                        style: TextStyle(fontSize: 10, color: Colors.blue.shade600, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              template.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? AdminColors.primaryGreen : AdminColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              template.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                color: AdminColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Fill & Edit Button
                OutlinedButton.icon(
                  onPressed: () => viewModel.applyTemplate(template, context),
                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                  label: const Text('Fill Form', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AdminColors.primaryGreen,
                    side: BorderSide(color: AdminColors.primaryGreen.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
                const SizedBox(width: 8),
                // Instant Broadcast Button
                ElevatedButton.icon(
                  onPressed: () => viewModel.sendTemplateDirectly(context, template),
                  icon: const Icon(Icons.campaign_rounded, size: 16),
                  label: const Text('Broadcast Now', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTemplateTagColor(String iconCode) {
    switch (iconCode) {
      case 'sale':
        return Colors.red.shade600;
      case 'inventory':
        return Colors.blue.shade700;
      case 'gift':
        return Colors.purple.shade600;
      case 'tuneup':
        return Colors.orange.shade700;
      case 'search':
        return Colors.teal.shade700;
      case 'shipping':
        return Colors.green.shade700;
      default:
        return Colors.blue.shade700;
    }
  }

  Widget _buildLivePreviewCard(
      BuildContext context, AdminNotificationsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(AdminRadius.card),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smartphone_rounded, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Live Device Push Preview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Simulated view of the push notification on the customer\'s mobile lock screen.',
            style: TextStyle(
              fontSize: 11.5,
              color: AdminColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Android / iOS Push Notification Mockup Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App header
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AdminColors.primaryGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '⚡',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'VoltSpare',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '• now',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  viewModel.previewTitle,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),

                // Message
                Text(
                  viewModel.previewMessage,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.35,
                  ),
                ),

                // Image Banner Preview
                if (viewModel.previewImage != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      viewModel.previewImage!,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 100,
                        color: Colors.white10,
                        alignment: Alignment.center,
                        child: const Text(
                          'Image preview unavailable',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // In-App Notification List Preview Card
          Text(
            'In-App Notification List Preview',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: AdminColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AdminColors.primaryGreen.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.notifications_active_rounded,
                    size: 18,
                    color: AdminColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              viewModel.previewTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AdminColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        viewModel.previewMessage,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AdminColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Just now',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (viewModel.previewImage != null) ...[
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      viewModel.previewImage!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(
      BuildContext context, AdminNotificationsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(AdminRadius.card),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: viewModel.historySearchController,
                  onSubmitted: (_) => viewModel.loadHistory(page: 1),
                  style: TextStyle(color: AdminColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search sent notifications by title or message...',
                    hintStyle: TextStyle(color: AdminColors.textSecondary, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    filled: true,
                    fillColor: AdminColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AdminColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AdminColors.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AdminColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AdminColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: viewModel.historyTypeFilter,
                    dropdownColor: AdminColors.panelBackground,
                    icon: const Icon(Icons.filter_list, size: 18),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Types')),
                      DropdownMenuItem(value: 'promotional', child: Text('Promotional')),
                      DropdownMenuItem(value: 'manual_single', child: Text('Direct Single')),
                      DropdownMenuItem(value: 'manual_bulk', child: Text('Bulk Broadcast')),
                      DropdownMenuItem(value: 'order_status', child: Text('Order Updates')),
                      DropdownMenuItem(value: 'rare_product_chat', child: Text('Rare Products')),
                      DropdownMenuItem(value: 'ticket_chat', child: Text('Support Tickets')),
                    ],
                    onChanged: (val) {
                      if (val != null) viewModel.setHistoryTypeFilter(val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => viewModel.loadHistory(page: viewModel.currentPage),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Content
          if (viewModel.isLoadingHistory)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (viewModel.historyItems.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 48,
                      color: AdminColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      viewModel.historySearchController.text.isNotEmpty || viewModel.historyTypeFilter != 'all'
                          ? 'No notifications found matching your filter'
                          : 'No notifications created yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: AdminColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      viewModel.historySearchController.text.isNotEmpty || viewModel.historyTypeFilter != 'all'
                          ? 'Try clearing the search or category filter.'
                          : 'When you create a broadcast or targeted push notification, it will appear here.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AdminColors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.historyItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = viewModel.historyItems[index];
                return _buildHistoryRow(context, viewModel, item);
              },
            ),

          // Pagination
          if (viewModel.totalPages > 1) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Page ${viewModel.currentPage} of ${viewModel.totalPages} (${viewModel.totalHistoryCount} total records)',
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: viewModel.currentPage > 1
                          ? () => viewModel.loadHistory(page: viewModel.currentPage - 1)
                          : null,
                    ),
                    Text('${viewModel.currentPage}'),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: viewModel.currentPage < viewModel.totalPages
                          ? () => viewModel.loadHistory(page: viewModel.currentPage + 1)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryRow(
    BuildContext context,
    AdminNotificationsViewModel viewModel,
    AdminNotificationItem item,
  ) {
    final isBulk = item.user == null || item.targetAudience.contains('bulk') || item.targetAudience.contains('all');
    final formattedTime = item.createdAt != null
        ? '${item.createdAt!.day}/${item.createdAt!.month}/${item.createdAt!.year} ${item.createdAt!.hour.toString().padLeft(2, '0')}:${item.createdAt!.minute.toString().padLeft(2, '0')}'
        : 'Recent';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isBulk
                  ? Colors.purple.withValues(alpha: 0.12)
                  : AdminColors.primaryGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isBulk ? Icons.campaign_rounded : Icons.person_rounded,
              color: isBulk ? Colors.purple : AdminColors.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Recipient Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isBulk
                            ? Colors.purple.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isBulk
                            ? '📢 All Customers'
                            : '👤 ${item.user?.name ?? 'Customer'}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isBulk ? Colors.purple : Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Type Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.type.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 11,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          // Attached Image Thumbnail
          if (item.image != null && item.image!.isNotEmpty) ...[
            const SizedBox(width: 12),
            InkWell(
              onTap: () => _showImageDialog(context, item.image!),
              borderRadius: BorderRadius.circular(6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  item.image!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ],

          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Delete notification',
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            onPressed: () => viewModel.deleteHistoryItem(context, item.id),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.black,
                  child: const Text('Image could not be loaded', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
