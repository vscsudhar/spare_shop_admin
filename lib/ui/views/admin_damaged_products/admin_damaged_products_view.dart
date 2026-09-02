import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_table_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_damaged_products_viewmodel.dart';

class AdminDamagedProductsView extends StackedView<AdminDamagedProductsViewModel> {
  const AdminDamagedProductsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminDamagedProductsViewModel viewModel,
    Widget? child,
  ) {
    final metrics = viewModel.metrics;

    return AdminShell(
      title: 'Damaged Products',
      selectedItem: AdminNavigationItem.damagedProducts,
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
                  Text('Damaged Products & Loss Tracking',
                      style: AdminTextStyles.sectionHeader),
                  const SizedBox(height: 4),
                  Text(
                    'Track write-offs, scrap items, and warranty claims across all returns and intakes',
                    style: AdminTextStyles.bodySecondary,
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${viewModel.damagedItems.length} damaged items recorded',
                    style: AdminTextStyles.bodySecondary,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: viewModel.isBusy
                        ? null
                        : () => viewModel.loadDamagedProducts(),
                    icon: const Icon(Icons.refresh,
                        size: 20, color: Colors.white70),
                    tooltip: 'Refresh Damaged List',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // KPI Metric Cards
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            final cards = [
              AdminMetricCard(
                title: 'Total Damaged Units',
                value: '${metrics?.totalDamagedQty ?? 0}',
                icon: Icons.broken_image_outlined,
                iconColor: Colors.redAccent,
                subtitle: 'Cumulative damaged inventory',
              ),
              AdminMetricCard(
                title: 'Total Loss Valuation',
                value: '₹${(metrics?.totalLossValue ?? 0).toStringAsFixed(2)}',
                icon: Icons.currency_rupee,
                iconColor: Colors.orangeAccent,
                subtitle: 'Direct financial write-off',
              ),
              AdminMetricCard(
                title: 'Scrapped Items',
                value: '${metrics?.scrappedCount ?? 0} units',
                icon: Icons.delete_sweep_outlined,
                iconColor: Colors.deepOrangeAccent,
                subtitle: 'Discarded without recovery',
              ),
              AdminMetricCard(
                title: 'Vendor Warranty Claims',
                value: '${metrics?.vendorClaimCount ?? 0} units',
                icon: Icons.assignment_return_outlined,
                iconColor: Colors.blueAccent,
                subtitle: 'Eligible for manufacturer credit',
              ),
            ];

            if (isWide) {
              return Row(
                children: cards
                    .map((c) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: c,
                          ),
                        ))
                    .toList(),
              );
            } else {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: cards
                    .map((c) => SizedBox(
                          width: (constraints.maxWidth - 12) / 2,
                          child: c,
                        ))
                    .toList(),
              );
            }
          }),
          const SizedBox(height: 24),

          // Filter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Damage Type: ',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70)),
                const SizedBox(width: 6),
                AdminFilterChip(
                  label: 'All Types',
                  isSelected: viewModel.selectedDamageType == 'all',
                  onTap: () => viewModel.setFilterDamageType('all'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Broken',
                  isSelected: viewModel.selectedDamageType == 'broken',
                  onTap: () => viewModel.setFilterDamageType('broken'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Physical',
                  isSelected: viewModel.selectedDamageType == 'physical',
                  onTap: () => viewModel.setFilterDamageType('physical'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Scratched',
                  isSelected: viewModel.selectedDamageType == 'scratched',
                  onTap: () => viewModel.setFilterDamageType('scratched'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Electrical',
                  isSelected: viewModel.selectedDamageType == 'electrical',
                  onTap: () => viewModel.setFilterDamageType('electrical'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Packaging',
                  isSelected: viewModel.selectedDamageType == 'packaging',
                  onTap: () => viewModel.setFilterDamageType('packaging'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Defect',
                  isSelected: viewModel.selectedDamageType == 'defect',
                  onTap: () => viewModel.setFilterDamageType('defect'),
                ),
                const SizedBox(width: 24),
                const Text('Resolution: ',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70)),
                const SizedBox(width: 6),
                AdminFilterChip(
                  label: 'All Resolutions',
                  isSelected: viewModel.selectedResolution == 'all',
                  onTap: () => viewModel.setFilterResolution('all'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Scrap',
                  isSelected: viewModel.selectedResolution == 'scrap',
                  onTap: () => viewModel.setFilterResolution('scrap'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Vendor Claim',
                  isSelected: viewModel.selectedResolution == 'vendor_claim',
                  onTap: () => viewModel.setFilterResolution('vendor_claim'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Refund',
                  isSelected: viewModel.selectedResolution == 'refund',
                  onTap: () => viewModel.setFilterResolution('refund'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Replacement',
                  isSelected: viewModel.selectedResolution == 'replacement',
                  onTap: () => viewModel.setFilterResolution('replacement'),
                ),
                const SizedBox(width: 8),
                AdminFilterChip(
                  label: 'Record Only',
                  isSelected: viewModel.selectedResolution == 'no_refund',
                  onTap: () => viewModel.setFilterResolution('no_refund'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Damaged Products Table
          if (viewModel.isBusy)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (viewModel.damagedItems.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 56, color: Colors.green),
                    const SizedBox(height: 16),
                    Text('No Damaged Products Found',
                        style: AdminTextStyles.sectionHeader),
                    const SizedBox(height: 8),
                    const Text(
                      'No products currently flagged as damaged for the selected filters.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            AdminDataTable(
              columns: const [
                'Product',
                'Classification',
                'Discovered At',
                'Qty',
                'Unit Price',
                'Total Loss',
                'Resolution',
                'Case Number',
                'Date',
                'Actions',
              ],
              rows: viewModel.damagedItems.map((item) {
                final dateStr =
                    '${item.createdAt.day.toString().padLeft(2, '0')}/${item.createdAt.month.toString().padLeft(2, '0')}/${item.createdAt.year}';

                return AdminTableRow(
                  cells: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: item.image.isNotEmpty
                              ? Image.network(item.image, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.broken_image,
                                      size: 16,
                                      color: Colors.grey))
                              : const Icon(Icons.broken_image,
                                  size: 16, color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item.productName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12),
                                  overflow: TextOverflow.ellipsis),
                              if (item.sku.isNotEmpty)
                                Text('SKU: ${item.sku}',
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    _damageTypeBadge(item.damageType),
                    Text(item.damageDiscoveredAt.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 11, color: Colors.white70)),
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text('₹${item.unitPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 12)),
                    Text(
                      '₹${item.totalLoss.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          fontSize: 12),
                    ),
                    _resolutionBadge(item.damageResolution),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.caseNumber,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AdminColors.primaryGreen)),
                        Text(item.billNumber,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    Text(dateStr,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.white70)),
                    TextButton.icon(
                      onPressed: () => viewModel.openCaseDetail(item.caseId),
                      icon: const Icon(Icons.remove_red_eye, size: 14),
                      label: const Text('View Case'),
                      style: TextButton.styleFrom(
                        foregroundColor: AdminColors.primaryGreen,
                        textStyle: const TextStyle(fontSize: 11),
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

  Widget _damageTypeBadge(String type) {
    Color bg = Colors.red.withValues(alpha: 0.15);
    Color fg = Colors.redAccent;

    if (type == 'electrical') {
      bg = Colors.amber.withValues(alpha: 0.15);
      fg = Colors.amberAccent;
    } else if (type == 'scratched' || type == 'packaging') {
      bg = Colors.orange.withValues(alpha: 0.15);
      fg = Colors.orangeAccent;
    } else if (type == 'defect') {
      bg = Colors.purple.withValues(alpha: 0.15);
      fg = Colors.purpleAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _resolutionBadge(String resolution) {
    Color bg = Colors.grey.withValues(alpha: 0.15);
    Color fg = Colors.white70;
    String label = resolution.replaceAll('_', ' ').toUpperCase();

    if (resolution == 'scrap') {
      bg = Colors.deepOrange.withValues(alpha: 0.15);
      fg = Colors.deepOrangeAccent;
    } else if (resolution == 'vendor_claim') {
      bg = Colors.blue.withValues(alpha: 0.15);
      fg = Colors.lightBlueAccent;
    } else if (resolution == 'refund') {
      bg = Colors.green.withValues(alpha: 0.15);
      fg = Colors.greenAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  AdminDamagedProductsViewModel viewModelBuilder(BuildContext context) =>
      AdminDamagedProductsViewModel();
}
