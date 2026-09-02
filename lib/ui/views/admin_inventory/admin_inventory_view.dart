import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_table_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_inventory_viewmodel.dart';

class AdminInventoryView extends StackedView<AdminInventoryViewModel> {
  const AdminInventoryView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminInventoryViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: 'Warehouse Inventory',
      selectedItem: AdminNavigationItem.inventory,
      onSearch: viewModel.setSearchQuery,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Headers
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < AdminBreakpoints.mobile;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isMobile ? 1 : 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 3.5 : 2.5,
                children: [
                  AdminMetricCard(
                    title: 'Total Stock Valuation',
                    value: '₹${viewModel.totalStockValue.toStringAsFixed(0)}',
                    icon: Icons.monetization_on_outlined,
                    iconColor: Colors.blue,
                  ),
                  AdminMetricCard(
                    title: 'Low Stock warnings',
                    value:
                        '${viewModel.filteredInventory.where((p) => viewModel.getStockLevel(p.id) <= 5).length}',
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.orange,
                  ),
                  AdminMetricCard(
                    title: 'Out of Stock items',
                    value: '${viewModel.outOfStockCount}',
                    icon: Icons.cancel_presentation_outlined,
                    iconColor: Colors.red,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Tools row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Stock Ledger Table', style: AdminTextStyles.sectionHeader),
              Row(
                children: [
                  Text('Show Low Stock Only',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.textSecondary)),
                  const SizedBox(width: 4),
                  Switch(
                    value: viewModel.filterLowStockOnly,
                    activeThumbColor: AdminColors.primaryGreen,
                    onChanged: (val) => viewModel.toggleLowStockFilter(),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 12),

          // Ledger Table
          AdminDataTable(
            columns: const [
              'Part Number',
              'Part Name',
              'Storage Location',
              'Available stock',
              'Reorder Level',
              'Action'
            ],
            rows: viewModel.filteredInventory.map((product) {
              final stock = viewModel.getStockLevel(product.id);

              return AdminTableRow(
                cells: [
                  Text(product.id,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(product.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(viewModel.getStorageLocation(product.id)),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 14),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _showEditLocationDialog(
                            context, viewModel, product),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: StockLevelIndicator(stock: stock, reorderLevel: 5),
                  ),
                  const Text('5 units'),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Restock'),
                      onPressed: () {
                        viewModel.restockProduct(product, 20);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Restocked: Added +20 units to ${product.name}')),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AdminColors.primaryGreen,
                        textStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showEditLocationDialog(BuildContext context,
      AdminInventoryViewModel viewModel, ProductModel product) {
    final controller = TextEditingController(text: product.locationBin ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Storage Location'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Storage Bin / Rack Location',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                viewModel.updateStorageLocation(
                    product, controller.text.trim());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryGreen,
                  foregroundColor: Colors.white),
              child: const Text('Save'),
            )
          ],
        );
      },
    );
  }

  @override
  AdminInventoryViewModel viewModelBuilder(BuildContext context) =>
      AdminInventoryViewModel();
}
