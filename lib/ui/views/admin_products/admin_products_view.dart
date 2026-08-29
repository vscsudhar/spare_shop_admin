import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_table_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_products_viewmodel.dart';

class AdminProductsView extends StackedView<AdminProductsViewModel> {
  const AdminProductsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminProductsViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: 'Spare Parts Catalog',
      selectedItem: AdminNavigationItem.products,
      onSearch: viewModel.setSearchQuery,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Manage Parts Inventory',
                  style: AdminTextStyles.sectionHeader),
              ElevatedButton.icon(
                onPressed: () => _showAddProductDialog(context, viewModel),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),

          // Filters Row
          Row(
            children: [
              AdminFilterChip(
                label: 'All Parts',
                isSelected: viewModel.categoryFilter == 'All',
                onTap: () => viewModel.setCategoryFilter('All'),
              ),
              const SizedBox(width: 8),
              AdminFilterChip(
                label: 'EV Spares',
                isSelected: viewModel.categoryFilter == 'EV',
                onTap: () => viewModel.setCategoryFilter('EV'),
              ),
              const SizedBox(width: 8),
              AdminFilterChip(
                label: 'Petrol Spares',
                isSelected: viewModel.categoryFilter == 'Petrol',
                onTap: () => viewModel.setCategoryFilter('Petrol'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Catalog Table
          AdminDataTable(
            columns: const [
              'Part Number',
              'Product Name',
              'Compatible Vehicle',
              'Price',
              'Stock Level',
              'Actions'
            ],
            rows: viewModel.filteredProducts.map((product) {
              final stockLevel = product.stockCount;

              return AdminTableRow(
                cells: [
                  Text(product.id,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(product.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(product.fitmentBadge ?? 'Universal Fit',
                      style: TextStyle(color: AdminColors.textSecondary)),
                  Text('₹${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child:
                        StockLevelIndicator(stock: stockLevel, reorderLevel: 5),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.edit_outlined,
                          color: AdminColors.primaryGreen, size: 20),
                      tooltip: 'Edit Product Details',
                      onPressed: () =>
                          _showEditProductDialog(context, viewModel, product),
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

  void _showEditProductDialog(BuildContext context,
      AdminProductsViewModel viewModel, ProductModel product) {
    viewModel.resetImageState();
    final nameController = TextEditingController(text: product.name);
    final sellingPriceController =
        TextEditingController(text: product.price.toString());
    final purchasePriceController =
        TextEditingController(text: product.purchasePrice.toString());
    final taxPercentageController =
        TextEditingController(text: product.taxPercentage.toString());
    final stockCountController =
        TextEditingController(text: product.stockCount.toString());

    showDialog(
      context: context,
      barrierDismissible: !viewModel.isBusy,
      builder: (context) {
        return ViewModelBuilder<AdminProductsViewModel>.reactive(
          viewModelBuilder: () => viewModel,
          disposeViewModel: false,
          builder: (context, model, child) {
            return AlertDialog(
              title: const Text('Update Spare Part Details'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: sellingPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Selling Price (₹)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: purchasePriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Price (₹)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: taxPercentageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tax Percentage (%)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stockCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock Count',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (model.pickedImagePath != null) ...[
                      Stack(
                        children: [
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? Image.network(model.pickedImagePath!, fit: BoxFit.cover)
                                  : Image.file(io.File(model.pickedImagePath!), fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.red.withValues(alpha: 0.8),
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 12, color: Colors.white),
                                onPressed: model.clearPickedImage,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ] else if (!model.existingImageCleared &&
                        product.imageAsset != null &&
                        product.imageAsset!.isNotEmpty) ...[
                      Stack(
                        children: [
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.imageAsset!,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 30),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.red.withValues(alpha: 0.8),
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 12, color: Colors.white),
                                onPressed: model.clearExistingImage,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ] else ...[
                      OutlinedButton.icon(
                        onPressed: model.pickProductImage,
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: const Text('Select Product Image'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AdminColors.primaryGreen,
                          side: BorderSide(color: AdminColors.primaryGreen),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: model.isBusy ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: model.isBusy
                      ? null
                      : () async {
                          final double? sellPrice =
                              double.tryParse(sellingPriceController.text);
                          final double? buyPrice =
                              double.tryParse(purchasePriceController.text);
                          final double? taxVal =
                              double.tryParse(taxPercentageController.text);
                          final int? stockVal = int.tryParse(stockCountController.text);

                          if (nameController.text.isNotEmpty &&
                              sellPrice != null &&
                              buyPrice != null &&
                              taxVal != null &&
                              stockVal != null) {
                            await model.updateProductDetails(
                              productId: product.id,
                              name: nameController.text,
                              sellingPrice: sellPrice,
                              purchasePrice: buyPrice,
                              taxPercentage: taxVal,
                              stockCount: stockVal,
                              existingImageUrl: product.imageAsset,
                            );
                            if (!model.isBusy) {
                              Navigator.pop(context);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primaryGreen,
                      foregroundColor: Colors.white),
                  child: model.isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Update'),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showAddProductDialog(
      BuildContext context, AdminProductsViewModel viewModel) {
    viewModel.resetImageState();
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final purchasePriceController = TextEditingController();
    final taxPercentageController = TextEditingController(text: '18');
    final stockCountController = TextEditingController(text: '10');
    final partController = TextEditingController();
    final fitmentController = TextEditingController();
    String selectedCatId = 'cat_01';

    showDialog(
      context: context,
      barrierDismissible: !viewModel.isBusy,
      builder: (context) {
        return ViewModelBuilder<AdminProductsViewModel>.reactive(
          viewModelBuilder: () => viewModel,
          disposeViewModel: false,
          builder: (context, model, child) {
            return AlertDialog(
              title: const Text('Add New Product to Catalog'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          labelText: 'Product Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Selling Price (₹)',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: purchasePriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Purchase Price (₹)',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: taxPercentageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Tax Percentage (%)',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stockCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Stock Count', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: partController,
                      decoration: const InputDecoration(
                          labelText: 'Part Number', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: fitmentController,
                      decoration: const InputDecoration(
                          labelText: 'Fitment Badge (e.g. Ola S1)',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCatId,
                      decoration: const InputDecoration(
                          labelText: 'Category', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(
                            value: 'cat_01', child: Text('EV Batteries')),
                        DropdownMenuItem(
                            value: 'cat_02', child: Text('EV Motor Spares')),
                        DropdownMenuItem(
                            value: 'cat_03', child: Text('Petrol Engine Spares')),
                        DropdownMenuItem(
                            value: 'cat_04', child: Text('Petrol General Spares')),
                      ],
                      onChanged: (val) {
                        if (val != null) selectedCatId = val;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (model.pickedImagePath != null) ...[
                      Stack(
                        children: [
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? Image.network(model.pickedImagePath!, fit: BoxFit.cover)
                                  : Image.file(io.File(model.pickedImagePath!), fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.red.withValues(alpha: 0.8),
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 12, color: Colors.white),
                                onPressed: model.clearPickedImage,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ] else ...[
                      OutlinedButton.icon(
                        onPressed: model.pickProductImage,
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: const Text('Select Product Image'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AdminColors.primaryGreen,
                          side: BorderSide(color: AdminColors.primaryGreen),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: model.isBusy ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: model.isBusy
                      ? null
                      : () async {
                          final double? price = double.tryParse(priceController.text);
                          final double? buyPrice =
                              double.tryParse(purchasePriceController.text);
                          final double? taxVal =
                              double.tryParse(taxPercentageController.text);
                          final int? stockVal = int.tryParse(stockCountController.text);

                          if (nameController.text.isNotEmpty &&
                              price != null &&
                              buyPrice != null &&
                              taxVal != null &&
                              stockVal != null) {
                            await model.addMockProduct(
                              name: nameController.text,
                              price: price,
                              categoryId: selectedCatId,
                              partNumber: partController.text.isNotEmpty
                                  ? partController.text
                                  : 'VP-9988-X',
                              fitmentBadge: fitmentController.text.isNotEmpty
                                  ? fitmentController.text
                                  : 'Universal Fit',
                              purchasePrice: buyPrice,
                              taxPercentage: taxVal,
                              stockCount: stockVal,
                            );
                            if (!model.isBusy) {
                              Navigator.pop(context);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primaryGreen,
                      foregroundColor: Colors.white),
                  child: model.isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Add Part'),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  AdminProductsViewModel viewModelBuilder(BuildContext context) =>
      AdminProductsViewModel();
}
