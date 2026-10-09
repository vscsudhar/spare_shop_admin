import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spare_shop_admin/core/models/bulk_quotation_model.dart';
import 'package:spare_shop_admin/core/services/admin_customer_service.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_invoice_dialog.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_quotation_dialog.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:stacked/stacked.dart';

import 'admin_bulk_product_sell_viewmodel.dart';

class AdminBulkProductSellView
    extends StackedView<AdminBulkProductSellViewModel> {
  const AdminBulkProductSellView({Key? key}) : super(key: key);

  @override
  AdminBulkProductSellViewModel viewModelBuilder(BuildContext context) =>
      AdminBulkProductSellViewModel();

  @override
  Widget builder(
    BuildContext context,
    AdminBulkProductSellViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: 'Bulk Product Sell & B2B Invoicing',
      selectedItem: AdminNavigationItem.bulkProductSell,
      onSearch: viewModel.setSearchQuery,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Navigation Header & Module Tabs
          _buildTopModuleHeader(context, viewModel),
          const SizedBox(height: 20),

          // Active Tab Content
          if (viewModel.selectedTabIndex == 0)
            _buildPriceManagementTab(context, viewModel)
          else if (viewModel.selectedTabIndex == 1)
            _buildCreateQuotationTab(context, viewModel)
          else
            _buildQuotationsDirectoryTab(context, viewModel),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // TOP NAVIGATION & TAB SELECTOR
  // --------------------------------------------------------------------------
  Widget _buildTopModuleHeader(
      BuildContext context, AdminBulkProductSellViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AdminColors.primaryGreen
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.sell_outlined,
                              color: AdminColors.primaryGreen,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Bulk Product Sell & B2B Hub',
                            style: AdminTextStyles.sectionHeader.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Set Least Selling Prices, create B2B Customer Quotations with GST, and convert them to GST Tax Invoices.',
                        style: TextStyle(
                          color: AdminColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (viewModel.selectedTabIndex == 0) ...[
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () =>
                              _showBulkRuleDialog(context, viewModel),
                          icon: const Icon(Icons.calculate_outlined, size: 16),
                          label: const Text('Auto-Calculate Rules'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AdminColors.primaryGreen,
                            side: BorderSide(color: AdminColors.primaryGreen),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (viewModel.modifiedCount > 0) ...[
                          OutlinedButton.icon(
                            onPressed: viewModel.isBusy
                                ? null
                                : viewModel.resetAllDrafts,
                            icon: const Icon(Icons.undo, size: 16),
                            label: const Text('Discard'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              side: BorderSide(color: Colors.red.shade300),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        ElevatedButton.icon(
                          onPressed:
                              (viewModel.modifiedCount > 0 && !viewModel.isBusy)
                                  ? viewModel.saveAllModifiedProducts
                                  : null,
                          icon: viewModel.isBusy
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_rounded, size: 16),
                          label: Text(
                            viewModel.modifiedCount > 0
                                ? 'Save Changes (${viewModel.modifiedCount})'
                                : 'All Saved',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: viewModel.modifiedCount > 0
                                ? AdminColors.primaryGreen
                                : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              // Pill Navigation Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _tabPill(
                      index: 0,
                      title: 'Bulk Price Setup',
                      subtitle: 'Least Selling Price 1 & 2',
                      icon: Icons.price_change_outlined,
                      badge: viewModel.modifiedCount > 0
                          ? '${viewModel.modifiedCount} unsaved'
                          : null,
                      badgeColor: Colors.amber,
                      viewModel: viewModel,
                    ),
                    const SizedBox(width: 8),
                    _tabPill(
                      index: 1,
                      title: 'Create B2B Quotation / Invoice',
                      subtitle: 'Customer GST, Tier Rates & Line Items',
                      icon: Icons.receipt_long_outlined,
                      badge: viewModel.quotationItems.isNotEmpty
                          ? '${viewModel.quotationItems.length} items'
                          : null,
                      badgeColor: AdminColors.primaryGreen,
                      viewModel: viewModel,
                    ),
                    const SizedBox(width: 8),
                    _tabPill(
                      index: 2,
                      title: 'Quotations & Invoices Directory',
                      subtitle: 'Search, Convert & Print Documents',
                      icon: Icons.folder_shared_outlined,
                      badge: '${viewModel.quotations.length}',
                      badgeColor: Colors.blueAccent,
                      viewModel: viewModel,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tabPill({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    String? badge,
    Color badgeColor = Colors.blue,
    required AdminBulkProductSellViewModel viewModel,
  }) {
    final isSelected = viewModel.selectedTabIndex == index;

    return InkWell(
      onTap: () => viewModel.setTabIndex(index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AdminColors.primaryGreen.withValues(alpha: 0.12)
              : AdminColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AdminColors.primaryGreen : AdminColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AdminColors.primaryGreen
                  : AdminColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
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
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: badgeColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: AdminColors.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // TAB 0: BULK PRICE SETUP (LEAST SELLING PRICE 1 & 2)
  // ==========================================================================
  Widget _buildPriceManagementTab(
      BuildContext context, AdminBulkProductSellViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricCards(viewModel),
        const SizedBox(height: 20),
        _buildFilterBar(viewModel),
        const SizedBox(height: 16),
        _buildProductsPricingTable(context, viewModel),
      ],
    );
  }

  Widget _buildMetricCards(AdminBulkProductSellViewModel viewModel) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 800;
        final double cardWidth = isNarrow
            ? (constraints.maxWidth - 12) / 2
            : (constraints.maxWidth - 36) / 4;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _metricCard(
              title: 'Total Catalog Products',
              value: '${viewModel.totalProducts}',
              subtitle: 'Active inventory items',
              icon: Icons.inventory_2_outlined,
              iconColor: Colors.blueAccent,
              width: cardWidth,
            ),
            _metricCard(
              title: 'Tier 1 Floor Configured',
              value: '${viewModel.tier1ConfiguredCount}',
              subtitle:
                  '${((viewModel.tier1ConfiguredCount / (viewModel.totalProducts == 0 ? 1 : viewModel.totalProducts)) * 100).toStringAsFixed(0)}% of catalog',
              icon: Icons.verified_outlined,
              iconColor: AdminColors.primaryGreen,
              width: cardWidth,
            ),
            _metricCard(
              title: 'Tier 2 Wholesale Configured',
              value: '${viewModel.tier2ConfiguredCount}',
              subtitle:
                  '${((viewModel.tier2ConfiguredCount / (viewModel.totalProducts == 0 ? 1 : viewModel.totalProducts)) * 100).toStringAsFixed(0)}% of catalog',
              icon: Icons.layers_outlined,
              iconColor: Colors.purpleAccent,
              width: cardWidth,
            ),
            _metricCard(
              title: 'Needs Floor Price Setup',
              value: '${viewModel.unconfiguredCount}',
              subtitle: 'Missing Tier 1 or Tier 2 price',
              icon: Icons.warning_amber_rounded,
              iconColor: viewModel.unconfiguredCount > 0
                  ? Colors.amber
                  : AdminColors.primaryGreen,
              width: cardWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: AdminColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(AdminBulkProductSellViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search Input
          SizedBox(
            width: 280,
            child: TextField(
              onChanged: viewModel.setSearchQuery,
              style: TextStyle(color: AdminColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search product, SKU, part no...',
                hintStyle:
                    TextStyle(color: AdminColors.textLight, fontSize: 13),
                prefixIcon:
                    Icon(Icons.search, size: 18, color: AdminColors.textLight),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: AdminColors.background,
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
                  borderSide: BorderSide(color: AdminColors.primaryGreen),
                ),
              ),
            ),
          ),

          // Status Filter Tabs
          Container(
            decoration: BoxDecoration(
              color: AdminColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AdminColors.border),
            ),
            padding: const EdgeInsets.all(2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _filterChip(
                  label: 'All (${viewModel.totalProducts})',
                  isSelected: viewModel.statusFilter == 'All',
                  onTap: () => viewModel.setStatusFilter('All'),
                ),
                _filterChip(
                  label: 'Missing Tier 1',
                  isSelected: viewModel.statusFilter == 'Missing Tier 1',
                  activeColor: Colors.amber,
                  onTap: () => viewModel.setStatusFilter('Missing Tier 1'),
                ),
                _filterChip(
                  label: 'Missing Tier 2',
                  isSelected: viewModel.statusFilter == 'Missing Tier 2',
                  activeColor: Colors.orange,
                  onTap: () => viewModel.setStatusFilter('Missing Tier 2'),
                ),
                _filterChip(
                  label: 'Configured',
                  isSelected: viewModel.statusFilter == 'Fully Configured',
                  activeColor: AdminColors.primaryGreen,
                  onTap: () => viewModel.setStatusFilter('Fully Configured'),
                ),
                if (viewModel.modifiedCount > 0)
                  _filterChip(
                    label: 'Unsaved (${viewModel.modifiedCount})',
                    isSelected: viewModel.statusFilter == 'Modified',
                    activeColor: Colors.blueAccent,
                    onTap: () => viewModel.setStatusFilter('Modified'),
                  ),
              ],
            ),
          ),

          // Category Dropdown Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AdminColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AdminColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: viewModel.categoryFilter,
                dropdownColor: AdminColors.panelBackground,
                style: TextStyle(color: AdminColors.textPrimary, fontSize: 13),
                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                items: [
                  const DropdownMenuItem(
                      value: 'All', child: Text('All Categories')),
                  ...viewModel.categories.map(
                    (cat) => DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name),
                    ),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) viewModel.setCategoryFilter(val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool isSelected,
    Color activeColor = const Color(0xFF10B981),
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? activeColor : AdminColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildProductsPricingTable(
      BuildContext context, AdminBulkProductSellViewModel viewModel) {
    if (viewModel.isBusy && viewModel.allProducts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final products = viewModel.filteredProducts;

    if (products.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AdminColors.panelBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminColors.border),
        ),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 48, color: AdminColors.textLight),
            const SizedBox(height: 12),
            Text(
              'No matching products found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AdminColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try changing your search terms or filter selection.',
              style: TextStyle(color: AdminColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AdminColors.background),
          dataRowMinHeight: 64,
          dataRowMaxHeight: 72,
          horizontalMargin: 20,
          columnSpacing: 24,
          columns: const [
            DataColumn(
                label: Text('Product & SKU',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(
                label: Text('Category',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(
                label: Text('Regular Selling Price (₹)',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(
                label: Text('Least Selling Price 1 (₹)',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(
                label: Text('Least Selling Price 2 (₹)',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            DataColumn(
                label: Text('Status & Actions',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ],
          rows: products.map((product) {
            final isModified = viewModel.isProductModified(product.id);
            final p1Controller = viewModel.getPrice1Controller(product);
            final p2Controller = viewModel.getPrice2Controller(product);

            final currentP1 = double.tryParse(p1Controller.text.trim()) ?? 0.0;
            final currentP2 = double.tryParse(p2Controller.text.trim()) ?? 0.0;

            final disc1 = product.price > 0 && currentP1 > 0
                ? ((1.0 - (currentP1 / product.price)) * 100)
                : 0.0;
            final disc2 = product.price > 0 && currentP2 > 0
                ? ((1.0 - (currentP2 / product.price)) * 100)
                : 0.0;

            return DataRow(
              color: isModified
                  ? WidgetStateProperty.all(
                      AdminColors.primaryGreen.withValues(alpha: 0.04))
                  : null,
              cells: [
                // 1. Product & SKU
                DataCell(
                  SizedBox(
                    width: 260,
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AdminColors.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AdminColors.border),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: product.imageAsset != null &&
                                    product.imageAsset!.isNotEmpty
                                ? Image.network(
                                    product.imageAsset!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                        Icons.build_circle_outlined,
                                        color: AdminColors.textLight,
                                        size: 22),
                                  )
                                : Icon(Icons.build_circle_outlined,
                                    color: AdminColors.textLight, size: 22),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AdminColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Fit: ${product.fitmentBadge ?? 'Direct Fit'} • ${product.vehicleType}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AdminColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Category
                DataCell(
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AdminColors.background,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AdminColors.border),
                    ),
                    child: Text(
                      product.vehicleType,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ),
                ),

                // 3. Regular Selling Price
                DataCell(
                  Text(
                    '₹${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                ),

                // 4. Least Selling Price 1 Input
                DataCell(
                  SizedBox(
                    width: 160,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: p1Controller,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onChanged: (_) =>
                              viewModel.onPriceChanged(product.id),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: currentP1 > 0
                                ? AdminColors.primaryGreen
                                : AdminColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            prefixText: '₹ ',
                            hintText: '0.00',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            filled: true,
                            fillColor: AdminColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: AdminColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: isModified
                                    ? AdminColors.primaryGreen
                                    : AdminColors.border,
                              ),
                            ),
                          ),
                        ),
                        if (disc1 > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 2, left: 4),
                            child: Text(
                              '${disc1.toStringAsFixed(1)}% off retail',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // 5. Least Selling Price 2 Input
                DataCell(
                  SizedBox(
                    width: 160,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: p2Controller,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onChanged: (_) =>
                              viewModel.onPriceChanged(product.id),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: currentP2 > 0
                                ? Colors.purpleAccent
                                : AdminColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            prefixText: '₹ ',
                            hintText: '0.00',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            filled: true,
                            fillColor: AdminColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: AdminColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: isModified
                                    ? Colors.purpleAccent
                                    : AdminColors.border,
                              ),
                            ),
                          ),
                        ),
                        if (disc2 > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 2, left: 4),
                            child: Text(
                              '${disc2.toStringAsFixed(1)}% off retail',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.purple.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // 6. Status & Quick Actions
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isModified) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: Colors.amber.withValues(alpha: 0.4)),
                          ),
                          child: const Text(
                            'Unsaved',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.save, size: 18),
                          tooltip: 'Save this product price',
                          color: AdminColors.primaryGreen,
                          onPressed: () => viewModel.saveSingleProduct(product),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: currentP1 > 0 && currentP2 > 0
                                ? AdminColors.primaryGreen
                                    .withValues(alpha: 0.12)
                                : Colors.grey.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            currentP1 > 0 && currentP2 > 0
                                ? 'Configured'
                                : 'Needs Pricing',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: currentP1 > 0 && currentP2 > 0
                                  ? AdminColors.primaryGreen
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                          tooltip: 'Add to B2B Quotation',
                          color: Colors.blueAccent,
                          onPressed: () {
                            viewModel.addItemToQuotation(product);
                            viewModel.setTabIndex(1);
                            viewModel.showFeedback(
                                'Added ${product.name} to Quotation draft.');
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ==========================================================================
  // TAB 1: CREATE B2B QUOTATION / DIRECT INVOICE
  // ==========================================================================
  Widget _buildCreateQuotationTab(
      BuildContext context, AdminBulkProductSellViewModel viewModel) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 1000;

        return isNarrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomerSelectionCard(context, viewModel),
                  const SizedBox(height: 16),
                  _buildQuotationItemsCard(context, viewModel),
                  const SizedBox(height: 16),
                  _buildQuotationSummaryCard(context, viewModel),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Customer & Parameters
                  SizedBox(
                    width: 380,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCustomerSelectionCard(context, viewModel),
                        const SizedBox(height: 16),
                        _buildQuotationSummaryCard(context, viewModel),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Right Column: Line Items & Pricing Tier Selector
                  Expanded(
                    child: _buildQuotationItemsCard(context, viewModel),
                  ),
                ],
              );
      },
    );
  }

  Widget _buildCustomerSelectionCard(
      BuildContext context, AdminBulkProductSellViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person_pin_circle_outlined,
                      color: AdminColors.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'B2B Customer Selection',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (viewModel.selectedCustomer != null)
                TextButton.icon(
                  onPressed: viewModel.clearCustomerSelection,
                  icon: const Icon(Icons.clear, size: 14),
                  label: const Text('Clear', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Dropdown picker from Customer Table
          DropdownButtonFormField<AdminCustomerModel?>(
            initialValue: viewModel.selectedCustomer,
            dropdownColor: AdminColors.panelBackground,
            decoration: InputDecoration(
              labelText: 'Select Registered Customer / Business',
              prefixIcon: const Icon(Icons.search, size: 18),
              filled: true,
              fillColor: AdminColors.background,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AdminColors.border),
              ),
            ),
            style: TextStyle(color: AdminColors.textPrimary, fontSize: 13),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('-- Choose from Customer Table or Type Manual --'),
              ),
              ...viewModel.customers.map((c) {
                final gstBadge =
                    c.gstNumber.isNotEmpty ? ' [GST: ${c.gstNumber}]' : '';
                return DropdownMenuItem(
                  value: c,
                  child: Text('${c.name} (${c.phone})$gstBadge'),
                );
              }),
            ],
            onChanged: (customer) => viewModel.selectCustomer(customer),
          ),
          const SizedBox(height: 14),

          // Customer Full Name
          TextFormField(
            controller: viewModel.customerNameController,
            style: TextStyle(color: AdminColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Customer / Contact Name *',
              prefixIcon: const Icon(Icons.person_outline, size: 18),
              filled: true,
              fillColor: AdminColors.background,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AdminColors.border)),
            ),
          ),
          const SizedBox(height: 10),

          // Phone & Email Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: viewModel.customerPhoneController,
                  style:
                      TextStyle(color: AdminColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Phone *',
                    prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                    filled: true,
                    fillColor: AdminColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AdminColors.border)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: viewModel.customerEmailController,
                  style:
                      TextStyle(color: AdminColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined, size: 18),
                    filled: true,
                    fillColor: AdminColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AdminColors.border)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Customer GSTIN Number (Highlighted)
          TextFormField(
            controller: viewModel.customerGstController,
            textCapitalization: TextCapitalization.characters,
            style: TextStyle(
                color: AdminColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Customer GSTIN / B2B Tax Identification *',
              hintText: 'e.g. 29AAAAA0000A1Z5',
              prefixIcon: const Icon(Icons.receipt_long,
                  size: 18, color: Colors.blueAccent),
              filled: true,
              fillColor: AdminColors.background,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AdminColors.border)),
            ),
          ),
          const SizedBox(height: 10),

          // Business Name & Address
          TextFormField(
            controller: viewModel.customerAddressController,
            style: TextStyle(color: AdminColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Billing / Delivery Address',
              prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
              filled: true,
              fillColor: AdminColors.background,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AdminColors.border)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotationItemsCard(
      BuildContext context, AdminBulkProductSellViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.format_list_bulleted,
                      color: AdminColors.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Quotation Line Items (${viewModel.quotationItems.length})',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showProductPickerModal(context, viewModel),
                icon: const Icon(Icons.add_shopping_cart, size: 16),
                label: const Text('Add Products to Quotation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (viewModel.quotationItems.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: AdminColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AdminColors.border),
              ),
              child: Column(
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 40, color: AdminColors.textLight),
                  const SizedBox(height: 10),
                  Text(
                    'No items in this quotation yet',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Click "Add Products to Quotation" to choose products and select between Retail, Least 1, or Least 2 prices.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AdminColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ] else ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(AdminColors.background),
                dataRowMinHeight: 64,
                dataRowMaxHeight: 74,
                horizontalMargin: 12,
                columnSpacing: 16,
                columns: const [
                  DataColumn(
                      label: Text('#',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(
                      label: Text('Product Item',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(
                      label: Text('Quantity',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(
                      label: Text('Price Tier Selector',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(
                      label: Text('Unit Price (₹)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(
                      label: Text('GST Rate',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(
                      label: Text('Total (₹)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(
                      label: Text('',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11))),
                ],
                rows: viewModel.quotationItems.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;

                  return DataRow(
                    cells: [
                      // S.No
                      DataCell(Text('${idx + 1}',
                          style: TextStyle(
                              fontSize: 12, color: AdminColors.textLight))),

                      // Product Info
                      DataCell(
                        SizedBox(
                          width: 220,
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AdminColors.background,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AdminColors.border),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: item.image.isNotEmpty
                                      ? Image.network(
                                          item.image,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(
                                              Icons.build,
                                              size: 18,
                                              color: AdminColors.textLight),
                                        )
                                      : Icon(Icons.build,
                                          size: 18,
                                          color: AdminColors.textLight),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item.productName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AdminColors.textPrimary),
                                    ),
                                    if (item.partNumber.isNotEmpty)
                                      Text(
                                        'Part: ${item.partNumber}',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AdminColors.textLight),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Quantity Stepper
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  size: 16),
                              onPressed: () => viewModel.updateItemQuantity(
                                  idx, item.quantity - 1),
                              color: AdminColors.textSecondary,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AdminColors.background,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AdminColors.border),
                              ),
                              child: Text(
                                '${item.quantity}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AdminColors.textPrimary),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  size: 16),
                              onPressed: () => viewModel.updateItemQuantity(
                                  idx, item.quantity + 1),
                              color: AdminColors.primaryGreen,
                            ),
                          ],
                        ),
                      ),

                      // Price Tier Dropdown Selector (Retail / Least 1 / Least 2 / Custom)
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AdminColors.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AdminColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<PriceTierType>(
                              value: item.priceTier,
                              dropdownColor: AdminColors.panelBackground,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AdminColors.textPrimary),
                              items: [
                                DropdownMenuItem(
                                  value: PriceTierType.retail,
                                  child: Text(
                                      '🏷️ Retail: ₹${item.retailPrice.toStringAsFixed(2)}'),
                                ),
                                DropdownMenuItem(
                                  value: PriceTierType.least1,
                                  child: Text(
                                      '⚡ Least 1: ₹${item.leastSellingPrice1 > 0 ? item.leastSellingPrice1.toStringAsFixed(2) : item.retailPrice.toStringAsFixed(2)}'),
                                ),
                                DropdownMenuItem(
                                  value: PriceTierType.least2,
                                  child: Text(
                                      '🔥 Least 2: ₹${item.leastSellingPrice2 > 0 ? item.leastSellingPrice2.toStringAsFixed(2) : (item.leastSellingPrice1 > 0 ? item.leastSellingPrice1.toStringAsFixed(2) : item.retailPrice.toStringAsFixed(2))}'),
                                ),
                                const DropdownMenuItem(
                                  value: PriceTierType.custom,
                                  child: Text('✏️ Custom Special Price'),
                                ),
                              ],
                              onChanged: (tier) {
                                if (tier != null) {
                                  if (tier == PriceTierType.custom) {
                                    _showCustomPriceDialog(
                                        context, viewModel, idx, item);
                                  } else {
                                    viewModel.updateItemPriceTier(idx, tier);
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ),

                      // Unit Price
                      DataCell(
                        Text(
                          '₹${item.unitPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                      ),

                      // GST Rate
                      DataCell(
                        Text('${item.gstRate.toStringAsFixed(0)}%',
                            style: TextStyle(
                                fontSize: 11, color: AdminColors.textLight)),
                      ),

                      // Line Total
                      DataCell(
                        Text(
                          '₹${item.grandTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.primaryGreen,
                          ),
                        ),
                      ),

                      // Remove
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent, size: 16),
                          onPressed: () =>
                              viewModel.removeItemFromQuotation(idx),
                          tooltip: 'Remove Item',
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuotationSummaryCard(
      BuildContext context, AdminBulkProductSellViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  color: AdminColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Financial Breakdown & Actions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _summaryRow('Taxable Subtotal:',
              '₹${viewModel.quotationSubtotal.toStringAsFixed(2)}'),
          _summaryRow('CGST (9%):',
              '₹${(viewModel.quotationTotalTax / 2).toStringAsFixed(2)}'),
          _summaryRow('SGST (9%):',
              '₹${(viewModel.quotationTotalTax / 2).toStringAsFixed(2)}'),
          const Divider(height: 16),
          _summaryRow('Grand Total (INR):',
              '₹${viewModel.quotationGrandTotal.toStringAsFixed(2)}',
              isGrand: true),
          const SizedBox(height: 16),

          // Action Buttons: Generate Quotation vs Create Invoice
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: viewModel.isBusy
                      ? null
                      : () async {
                          final quotation = await viewModel.createQuotation();
                          if (quotation != null && context.mounted) {
                            AdminQuotationDialog.show(
                              context,
                              quotation,
                              onConvertToInvoice: () async {
                                final invoice = await viewModel
                                    .convertQuotationToInvoice(quotation);
                                if (invoice != null && context.mounted) {
                                  AdminInvoiceDialog.show(context, invoice);
                                }
                              },
                            );
                          }
                        },
                  icon: const Icon(Icons.description_outlined, size: 16),
                  label: const Text('Generate Quotation'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AdminColors.textPrimary,
                    side: BorderSide(color: AdminColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: viewModel.isBusy
                      ? null
                      : () async {
                          final invoice =
                              await viewModel.createDirectB2BInvoice();
                          if (invoice != null && context.mounted) {
                            AdminInvoiceDialog.show(context, invoice);
                          }
                        },
                  icon: const Icon(Icons.receipt_long, size: 16),
                  label: const Text('Create B2B Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isGrand = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isGrand ? 13 : 12,
              fontWeight: isGrand ? FontWeight.bold : FontWeight.w500,
              color:
                  isGrand ? AdminColors.textPrimary : AdminColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isGrand ? 16 : 13,
              fontWeight: FontWeight.bold,
              color:
                  isGrand ? AdminColors.primaryGreen : AdminColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 2: QUOTATIONS DIRECTORY & CONVERT TO INVOICE
  // ==========================================================================
  Widget _buildQuotationsDirectoryTab(
      BuildContext context, AdminBulkProductSellViewModel viewModel) {
    final list = viewModel.filteredQuotations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search & Filter Toolbar
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AdminColors.panelBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AdminColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 320,
                    child: TextField(
                      onChanged: viewModel.setQuotationSearch,
                      style: TextStyle(
                          color: AdminColors.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText:
                            'Search quotation #, customer, GST, invoice...',
                        hintStyle: TextStyle(
                            color: AdminColors.textLight, fontSize: 13),
                        prefixIcon: Icon(Icons.search,
                            size: 18, color: AdminColors.textLight),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        filled: true,
                        fillColor: AdminColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AdminColors.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AdminColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AdminColors.border),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _filterChip(
                          label: 'All (${viewModel.quotations.length})',
                          isSelected: viewModel.quotationStatusFilter == 'All',
                          onTap: () =>
                              viewModel.setQuotationStatusFilter('All'),
                        ),
                        _filterChip(
                          label: 'Active Quotations',
                          isSelected:
                              viewModel.quotationStatusFilter == 'Active',
                          activeColor: Colors.amber,
                          onTap: () =>
                              viewModel.setQuotationStatusFilter('Active'),
                        ),
                        _filterChip(
                          label: 'Converted to Invoice',
                          isSelected:
                              viewModel.quotationStatusFilter == 'Converted',
                          activeColor: AdminColors.primaryGreen,
                          onTap: () =>
                              viewModel.setQuotationStatusFilter('Converted'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => viewModel.setTabIndex(1),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Create New Quotation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quotations Table
        if (list.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: AdminColors.panelBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminColors.border),
            ),
            child: Column(
              children: [
                Icon(Icons.folder_open_outlined,
                    size: 48, color: AdminColors.textLight),
                const SizedBox(height: 12),
                Text(
                  'No Quotations Found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create your first quotation by switching to the "Create B2B Quotation / Invoice" tab.',
                  style:
                      TextStyle(color: AdminColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            decoration: BoxDecoration(
              color: AdminColors.panelBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminColors.border),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(AdminColors.background),
                dataRowMinHeight: 64,
                dataRowMaxHeight: 74,
                horizontalMargin: 16,
                columnSpacing: 20,
                columns: const [
                  DataColumn(
                      label: Text('Quotation # & Date',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(
                      label: Text('Customer & GSTIN',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(
                      label: Text('Items Count',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(
                      label: Text('Grand Total (₹)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(
                      label: Text('Status / Invoice',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(
                      label: Text('Actions',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12))),
                ],
                rows: list.map((quotation) {
                  return DataRow(
                    cells: [
                      // 1. Quotation # & Date
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              quotation.quotationNumber,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AdminColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${quotation.createdAt.day.toString().padLeft(2, '0')}/${quotation.createdAt.month.toString().padLeft(2, '0')}/${quotation.createdAt.year}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AdminColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 2. Customer & GSTIN
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              quotation.customerName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AdminColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  quotation.customerPhone,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AdminColors.textSecondary,
                                  ),
                                ),
                                if (quotation.customerGst.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      'GST: ${quotation.customerGst}',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 3. Items Count
                      DataCell(
                        Text(
                          '${quotation.items.length} item${quotation.items.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                      ),

                      // 4. Grand Total
                      DataCell(
                        Text(
                          '₹${quotation.grandTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.primaryGreen,
                          ),
                        ),
                      ),

                      // 5. Status / Invoice Link
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: quotation.isConverted
                                    ? Colors.green.withValues(alpha: 0.12)
                                    : Colors.amber.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: quotation.isConverted
                                      ? Colors.green.withValues(alpha: 0.3)
                                      : Colors.amber.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                quotation.isConverted
                                    ? 'Converted to Invoice'
                                    : 'Active Quotation',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: quotation.isConverted
                                      ? Colors.green.shade700
                                      : Colors.amber.shade800,
                                ),
                              ),
                            ),
                            if (quotation.invoiceNumber != null &&
                                quotation.invoiceNumber!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                quotation.invoiceNumber!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // 6. Action Buttons
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                AdminQuotationDialog.show(
                                  context,
                                  quotation,
                                  onConvertToInvoice: () async {
                                    final invoice = await viewModel
                                        .convertQuotationToInvoice(quotation);
                                    if (invoice != null && context.mounted) {
                                      AdminInvoiceDialog.show(context, invoice);
                                    }
                                  },
                                );
                              },
                              icon: const Icon(Icons.visibility_outlined,
                                  size: 14),
                              label: const Text('View Quotation'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                textStyle: const TextStyle(fontSize: 11),
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (!quotation.isConverted) ...[
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final invoice = await viewModel
                                      .convertQuotationToInvoice(quotation);
                                  if (invoice != null && context.mounted) {
                                    AdminInvoiceDialog.show(context, invoice);
                                  }
                                },
                                icon: const Icon(Icons.transform, size: 14),
                                label: const Text('Convert to Invoice'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AdminColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  textStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ] else ...[
                              ElevatedButton.icon(
                                onPressed: () {
                                  final invoice = quotation.toInvoiceModel();
                                  AdminInvoiceDialog.show(context, invoice);
                                },
                                icon: const Icon(Icons.receipt_long, size: 14),
                                label: const Text('View Invoice'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  textStyle: const TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent, size: 16),
                              onPressed: () =>
                                  viewModel.deleteQuotation(quotation.id),
                              tooltip: 'Delete Quotation',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // --------------------------------------------------------------------------
  // MODALS & DIALOGS
  // --------------------------------------------------------------------------
  void _showProductPickerModal(
      BuildContext context, AdminBulkProductSellViewModel viewModel) {
    viewModel.setProductPickerSearch('');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final items = viewModel.pickerFilteredProducts;

            return Dialog(
              backgroundColor: AdminColors.panelBackground,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: 720,
                height: 600,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.add_shopping_cart,
                                color: AdminColors.primaryGreen, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'Add Products to Quotation',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AdminColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Search input
                    TextField(
                      onChanged: (val) {
                        viewModel.setProductPickerSearch(val);
                        setState(() {});
                      },
                      style: TextStyle(
                          color: AdminColors.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText:
                            'Search product name, category, SKU, part no...',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        filled: true,
                        fillColor: AdminColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AdminColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Products list
                    Expanded(
                      child: items.isEmpty
                          ? Center(
                              child: Text(
                                'No matching products found.',
                                style: TextStyle(
                                    color: AdminColors.textLight, fontSize: 13),
                              ),
                            )
                          : ListView.separated(
                              itemCount: items.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, i) {
                                final product = items[i];
                                final isAlreadyAdded = viewModel.quotationItems
                                    .any(
                                        (item) => item.productId == product.id);

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  leading: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AdminColors.background,
                                      borderRadius: BorderRadius.circular(6),
                                      border:
                                          Border.all(color: AdminColors.border),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: product.imageAsset != null &&
                                              product.imageAsset!.isNotEmpty
                                          ? Image.network(
                                              product.imageAsset!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(Icons.build,
                                                      size: 20),
                                            )
                                          : const Icon(Icons.build, size: 20),
                                    ),
                                  ),
                                  title: Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AdminColors.textPrimary,
                                    ),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        'Retail: ₹${product.price.toStringAsFixed(0)}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: AdminColors.textSecondary),
                                      ),
                                      if (product.leastSellingPrice1 > 0) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          '• Least 1: ₹${product.leastSellingPrice1.toStringAsFixed(0)}',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: AdminColors.primaryGreen,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                      if (product.leastSellingPrice2 > 0) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          '• Least 2: ₹${product.leastSellingPrice2.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.purpleAccent,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ],
                                  ),
                                  trailing: ElevatedButton.icon(
                                    onPressed: () {
                                      viewModel.addItemToQuotation(product);
                                      setState(() {});
                                    },
                                    icon: Icon(
                                      isAlreadyAdded
                                          ? Icons.add
                                          : Icons.add_shopping_cart,
                                      size: 14,
                                    ),
                                    label: Text(isAlreadyAdded
                                        ? 'Add More'
                                        : 'Add Item'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isAlreadyAdded
                                          ? Colors.blueAccent
                                          : AdminColors.primaryGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      textStyle: const TextStyle(fontSize: 11),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCustomPriceDialog(
    BuildContext context,
    AdminBulkProductSellViewModel viewModel,
    int index,
    BulkQuotationItemModel item,
  ) {
    final controller = TextEditingController(
      text: item.unitPrice.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AdminColors.panelBackground,
          title: Text(
            'Set Custom Rate for ${item.productName}',
            style: TextStyle(fontSize: 15, color: AdminColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Retail MRP: ₹${item.retailPrice.toStringAsFixed(2)} | Least 1: ₹${item.leastSellingPrice1.toStringAsFixed(2)} | Least 2: ₹${item.leastSellingPrice2.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 11, color: AdminColors.textLight),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Custom Unit Selling Rate (₹)',
                  prefixText: '₹ ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final customVal =
                    double.tryParse(controller.text.trim()) ?? 0.0;
                if (customVal > 0) {
                  viewModel.updateItemCustomPrice(index, customVal);
                  Navigator.of(ctx).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Apply Rate'),
            ),
          ],
        );
      },
    );
  }

  void _showBulkRuleDialog(
    BuildContext context,
    AdminBulkProductSellViewModel viewModel,
  ) {
    double tier1Discount = 10.0;
    double tier2Discount = 20.0;
    String selectedCat = 'All';
    bool overwrite = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AdminColors.panelBackground,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: Row(
                children: [
                  Icon(Icons.calculate_outlined,
                      color: AdminColors.primaryGreen, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Auto-Calculate Bulk Floor Prices',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.textPrimary),
                  ),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apply automated formula-based minimum selling price tiers to catalog products.',
                      style: TextStyle(
                          fontSize: 12, color: AdminColors.textSecondary),
                    ),
                    const SizedBox(height: 16),

                    // Target Category
                    DropdownButtonFormField<String>(
                      initialValue: selectedCat,
                      dropdownColor: AdminColors.panelBackground,
                      decoration: const InputDecoration(
                        labelText: 'Apply to Category',
                        prefixIcon: Icon(Icons.category_outlined, size: 18),
                      ),
                      items: [
                        const DropdownMenuItem(
                            value: 'All', child: Text('All Categories')),
                        ...viewModel.categories.map((c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name))),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => selectedCat = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Tier 1 % discount slider/number
                    Text(
                      'Least Selling Price 1 Discount: ${tier1Discount.toStringAsFixed(0)}% off Retail',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.textPrimary),
                    ),
                    Slider(
                      value: tier1Discount,
                      min: 1,
                      max: 40,
                      divisions: 39,
                      activeColor: AdminColors.primaryGreen,
                      onChanged: (val) => setState(() => tier1Discount = val),
                    ),

                    // Tier 2 % discount slider/number
                    Text(
                      'Least Selling Price 2 Discount: ${tier2Discount.toStringAsFixed(0)}% off Retail',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.textPrimary),
                    ),
                    Slider(
                      value: tier2Discount,
                      min: 5,
                      max: 60,
                      divisions: 55,
                      activeColor: Colors.purpleAccent,
                      onChanged: (val) => setState(() => tier2Discount = val),
                    ),
                    const SizedBox(height: 8),

                    // Overwrite checkbox
                    CheckboxListTile(
                      value: overwrite,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Overwrite existing configured prices',
                        style: TextStyle(
                            fontSize: 12, color: AdminColors.textPrimary),
                      ),
                      onChanged: (val) =>
                          setState(() => overwrite = val ?? false),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    viewModel.applyBulkRule(
                      tier1DiscountPercent: tier1Discount,
                      tier2DiscountPercent: tier2Discount,
                      targetCategory: selectedCat,
                      overwriteExisting: overwrite,
                    );
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply Formula'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
