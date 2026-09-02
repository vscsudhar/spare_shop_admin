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
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
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
    final mrpController = TextEditingController(
        text: ((product.originalPrice != null && product.originalPrice! > 0)
                ? product.originalPrice!
                : product.price)
            .toString());
    final purchasePriceController =
        TextEditingController(text: product.purchasePrice.toString());
    final taxPercentageController =
        TextEditingController(text: product.taxPercentage.toString());
    final stockCountController =
        TextEditingController(text: product.stockCount.toString());

    String selectedFitType = product.fitType;
    bool isStockManaged = product.stockManaged;
    final List<Map<String, String?>> compatibilityRows = [];

    if (product.compatibleVehicles.isNotEmpty) {
      for (final comp in product.compatibleVehicles) {
        compatibilityRows.add({
          'brandId': comp.brandId.isNotEmpty ? comp.brandId : null,
          'modelId': comp.modelId.isNotEmpty ? comp.modelId : null,
        });
        if (comp.brandId.isNotEmpty) {
          viewModel.loadModelsForBrand(comp.brandId);
        }
      }
    } else {
      compatibilityRows.add({'brandId': null, 'modelId': null});
    }

    if (viewModel.brands.isEmpty) {
      viewModel.loadBrands();
    }

    showDialog(
      context: context,
      barrierDismissible: !viewModel.isBusy,
      builder: (context) {
        return ViewModelBuilder<AdminProductsViewModel>.reactive(
          viewModelBuilder: () => viewModel,
          disposeViewModel: false,
          builder: (context, model, child) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return AlertDialog(
                  title: const Text('Update Spare Part Details'),
                  content: SizedBox(
                    width: 580,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Product Name *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: sellingPriceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Selling Price (₹) *',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: mrpController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'MRP (₹) *',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: purchasePriceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Purchase Price (₹) *',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
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

                          // Stock & Delivery Section
                          Card(
                            elevation: 0,
                            color: Colors.grey.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: isStockManaged,
                                        onChanged: (val) {
                                          setModalState(() {
                                            isStockManaged = val ?? true;
                                          });
                                        },
                                      ),
                                      const Text('Track Stock Quantity',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  if (isStockManaged) ...[
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: stockCountController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Current Stock Count',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                      ),
                                      onChanged: (_) => setModalState(() {}),
                                    ),
                                    const SizedBox(height: 8),
                                    Builder(builder: (c) {
                                      final int count = int.tryParse(
                                              stockCountController.text) ??
                                          0;
                                      final now = DateTime.now();
                                      final String badgeText = count > 0
                                          ? (now.hour < 15
                                              ? '⚡ Same Day Delivery (Ordered before 3 PM)'
                                              : '📦 Next Day Delivery (Ordered after 3 PM)')
                                          : '⚠️ Out of Stock';
                                      final Color badgeColor = count > 0
                                          ? AdminColors.primaryGreen
                                          : Colors.red;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: badgeColor.withValues(
                                              alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                              color: badgeColor.withValues(
                                                  alpha: 0.3)),
                                        ),
                                        child: Text(
                                          badgeText,
                                          style: TextStyle(
                                              color: badgeColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      );
                                    }),
                                  ] else ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.orange.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Colors.orange
                                                .withValues(alpha: 0.3)),
                                      ),
                                      child: const Text(
                                        '🚚 Available on Order (Delivery in 2 Days)',
                                        style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Vehicle Compatibility Section
                          _buildCompatibilitySelector(
                            context: context,
                            model: model,
                            fitType: selectedFitType,
                            compatibilityRows: compatibilityRows,
                            onFitTypeChanged: (newType) {
                              setModalState(() {
                                selectedFitType = newType;
                              });
                            },
                            onRowsChanged: () {
                              setModalState(() {});
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
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: model.pickedImageBytes != null
                                        ? Image.memory(
                                            model.pickedImageBytes!,
                                            fit: BoxFit.cover)
                                        : (kIsWeb
                                            ? Image.network(
                                                model.pickedImagePath!,
                                                fit: BoxFit.cover)
                                            : Image.file(
                                                io.File(model.pickedImagePath!),
                                                fit: BoxFit.cover)),
                                  ),
                                ),
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundColor:
                                        Colors.red.withValues(alpha: 0.8),
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          size: 12, color: Colors.white),
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
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product.imageAsset!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) =>
                                          const Icon(Icons.broken_image,
                                              size: 30),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundColor:
                                        Colors.red.withValues(alpha: 0.8),
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          size: 12, color: Colors.white),
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
                                side:
                                    BorderSide(color: AdminColors.primaryGreen),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          model.isBusy ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: model.isBusy
                          ? null
                          : () async {
                              final double? sellPrice =
                                  double.tryParse(sellingPriceController.text);
                              final double? mrpVal =
                                  double.tryParse(mrpController.text);
                              final double? buyPrice =
                                  double.tryParse(purchasePriceController.text);
                              final double? taxVal =
                                  double.tryParse(taxPercentageController.text);
                              final int stockVal = int.tryParse(
                                      stockCountController.text) ??
                                  0;

                              if (nameController.text.trim().isEmpty ||
                                  sellPrice == null ||
                                  mrpVal == null ||
                                  buyPrice == null ||
                                  taxVal == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please fill all required fields.')),
                                );
                                return;
                              }

                              final List<Map<String, String>> finalCompatibles =
                                  [];
                              if (selectedFitType == 'vehicle_specific') {
                                for (final r in compatibilityRows) {
                                  final bId = r['brandId'];
                                  final mId = r['modelId'];
                                  if (bId != null &&
                                      bId.isNotEmpty &&
                                      mId != null &&
                                      mId.isNotEmpty) {
                                    finalCompatibles.add({
                                      'brand': bId,
                                      'model': mId,
                                    });
                                  }
                                }

                                if (finalCompatibles.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Please select both Brand and Model for at least one compatible vehicle.'),
                                    ),
                                  );
                                  return;
                                }
                              }

                              await model.updateProductDetails(
                                productId: product.id,
                                name: nameController.text.trim(),
                                sellingPrice: sellPrice,
                                mrp: mrpVal,
                                purchasePrice: buyPrice,
                                taxPercentage: taxVal,
                                stockCount: stockVal,
                                fitType: selectedFitType,
                                stockManaged: isStockManaged,
                                compatibleVehicles: finalCompatibles,
                                existingImageUrl: product.imageAsset,
                              );
                              if (!model.isBusy && context.mounted) {
                                Navigator.pop(context);
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
      },
    );
  }

  void _showAddProductDialog(
      BuildContext context, AdminProductsViewModel viewModel) {
    viewModel.resetImageState();
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final mrpController = TextEditingController();
    final purchasePriceController = TextEditingController();
    final taxPercentageController = TextEditingController(text: '18');
    final stockCountController = TextEditingController(text: '10');
    final partController = TextEditingController();

    String selectedFitType = 'vehicle_specific';
    bool isStockManaged = true;
    String? selectedCatId =
        viewModel.categories.isNotEmpty ? viewModel.categories.first.id : null;
    final List<Map<String, String?>> compatibilityRows = [
      {'brandId': null, 'modelId': null}
    ];

    if (viewModel.brands.isEmpty) {
      viewModel.loadBrands();
    }

    showDialog(
      context: context,
      barrierDismissible: !viewModel.isBusy,
      builder: (context) {
        return ViewModelBuilder<AdminProductsViewModel>.reactive(
          viewModelBuilder: () => viewModel,
          disposeViewModel: false,
          builder: (context, model, child) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return AlertDialog(
                  title: const Text('Add New Product to Catalog'),
                  content: SizedBox(
                    width: 580,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Product Name *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: partController,
                                  decoration: const InputDecoration(
                                    labelText: 'Part Number (SKU) *',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedCatId,
                                  decoration: const InputDecoration(
                                    labelText: 'Category *',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: model.categories.map((c) {
                                    return DropdownMenuItem(
                                        value: c.id, child: Text(c.name));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setModalState(() {
                                        selectedCatId = val;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Selling Price (₹) *',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (val) {
                                    if (mrpController.text.isEmpty && val.isNotEmpty) {
                                      final p = double.tryParse(val);
                                      if (p != null) {
                                        mrpController.text = (p * 1.2).toStringAsFixed(0);
                                      }
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: mrpController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'MRP (₹) *',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: purchasePriceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Purchase Price (₹) *',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
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

                          // Stock & Delivery Section
                          Card(
                            elevation: 0,
                            color: Colors.grey.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: isStockManaged,
                                        onChanged: (val) {
                                          setModalState(() {
                                            isStockManaged = val ?? true;
                                          });
                                        },
                                      ),
                                      const Text('Track Stock Quantity',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  if (isStockManaged) ...[
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: stockCountController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Initial Stock Count',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                      ),
                                      onChanged: (_) => setModalState(() {}),
                                    ),
                                    const SizedBox(height: 8),
                                    Builder(builder: (c) {
                                      final int count = int.tryParse(
                                              stockCountController.text) ??
                                          0;
                                      final now = DateTime.now();
                                      final String badgeText = count > 0
                                          ? (now.hour < 15
                                              ? '⚡ Same Day Delivery (Ordered before 3 PM)'
                                              : '📦 Next Day Delivery (Ordered after 3 PM)')
                                          : '⚠️ Out of Stock';
                                      final Color badgeColor = count > 0
                                          ? AdminColors.primaryGreen
                                          : Colors.red;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: badgeColor.withValues(
                                              alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                              color: badgeColor.withValues(
                                                  alpha: 0.3)),
                                        ),
                                        child: Text(
                                          badgeText,
                                          style: TextStyle(
                                              color: badgeColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      );
                                    }),
                                  ] else ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.orange.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Colors.orange
                                                .withValues(alpha: 0.3)),
                                      ),
                                      child: const Text(
                                        '🚚 Available on Order (Delivery in 2 Days)',
                                        style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Vehicle Compatibility Section
                          _buildCompatibilitySelector(
                            context: context,
                            model: model,
                            fitType: selectedFitType,
                            compatibilityRows: compatibilityRows,
                            onFitTypeChanged: (newType) {
                              setModalState(() {
                                selectedFitType = newType;
                              });
                            },
                            onRowsChanged: () {
                              setModalState(() {});
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
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: model.pickedImageBytes != null
                                        ? Image.memory(
                                            model.pickedImageBytes!,
                                            fit: BoxFit.cover)
                                        : (kIsWeb
                                            ? Image.network(
                                                model.pickedImagePath!,
                                                fit: BoxFit.cover)
                                            : Image.file(
                                                io.File(model.pickedImagePath!),
                                                fit: BoxFit.cover)),
                                  ),
                                ),
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundColor:
                                        Colors.red.withValues(alpha: 0.8),
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          size: 12, color: Colors.white),
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
                                side:
                                    BorderSide(color: AdminColors.primaryGreen),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          model.isBusy ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: model.isBusy
                          ? null
                          : () async {
                              final double? price =
                                  double.tryParse(priceController.text);
                              final double? mrpVal =
                                  double.tryParse(mrpController.text);
                              final double? buyPrice =
                                  double.tryParse(purchasePriceController.text);
                              final double? taxVal =
                                  double.tryParse(taxPercentageController.text);
                              final int stockVal = int.tryParse(
                                      stockCountController.text) ??
                                  0;
                              final String sku = partController.text.trim();
                              final String categoryId = selectedCatId ??
                                  (model.categories.isNotEmpty
                                      ? model.categories.first.id
                                      : '');

                              if (nameController.text.trim().isEmpty ||
                                  sku.isEmpty ||
                                  categoryId.isEmpty ||
                                  price == null ||
                                  mrpVal == null ||
                                  buyPrice == null ||
                                  taxVal == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please fill all required fields.')),
                                );
                                return;
                              }

                              final List<Map<String, String>> finalCompatibles =
                                  [];
                              if (selectedFitType == 'vehicle_specific') {
                                for (final r in compatibilityRows) {
                                  final bId = r['brandId'];
                                  final mId = r['modelId'];
                                  if (bId != null &&
                                      bId.isNotEmpty &&
                                      mId != null &&
                                      mId.isNotEmpty) {
                                    finalCompatibles.add({
                                      'brand': bId,
                                      'model': mId,
                                    });
                                  }
                                }

                                if (finalCompatibles.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Please select both Brand and Model for at least one compatible vehicle.'),
                                    ),
                                  );
                                  return;
                                }
                              }

                              await model.addProduct(
                                name: nameController.text.trim(),
                                price: price,
                                mrp: mrpVal,
                                categoryId: categoryId,
                                partNumber: sku,
                                purchasePrice: buyPrice,
                                taxPercentage: taxVal,
                                stockCount: stockVal,
                                fitType: selectedFitType,
                                stockManaged: isStockManaged,
                                compatibleVehicles: finalCompatibles,
                              );
                              if (!model.isBusy && context.mounted) {
                                Navigator.pop(context);
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
      },
    );
  }

  Widget _buildCompatibilitySelector({
    required BuildContext context,
    required AdminProductsViewModel model,
    required String fitType,
    required List<Map<String, String?>> compatibilityRows,
    required ValueChanged<String> onFitTypeChanged,
    required VoidCallback onRowsChanged,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'VEHICLE COMPATIBILITY',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),

            // Fitment Type Selector
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Vehicle Specific'),
                  selected: fitType == 'vehicle_specific',
                  onSelected: (selected) {
                    if (selected) onFitTypeChanged('vehicle_specific');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Universal Fit'),
                  selected: fitType == 'universal',
                  onSelected: (selected) {
                    if (selected) onFitTypeChanged('universal');
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (fitType == 'universal') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.all_inclusive, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Universal Fit — Compatible with all vehicle types. No Brand or Model selection required.',
                        style: TextStyle(fontSize: 13, color: Colors.blueGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              if (model.brandLoadError != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        model.brandLoadError!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: model.loadBrands,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Dynamic Compatibility Rows
              for (int i = 0; i < compatibilityRows.length; i++) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Compatible Vehicle #${i + 1}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                          if (compatibilityRows.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.red, size: 18),
                              tooltip: 'Remove',
                              onPressed: () {
                                compatibilityRows.removeAt(i);
                                onRowsChanged();
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Brand Dropdown (From DB)
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: model.brands.any(
                                      (b) => b.id == compatibilityRows[i]['brandId'])
                                  ? compatibilityRows[i]['brandId']
                                  : null,
                              decoration: InputDecoration(
                                labelText: 'Brand *',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                suffixIcon: model.loadingBrands
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: Padding(
                                          padding: EdgeInsets.all(12),
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      )
                                    : null,
                              ),
                              hint: Text(model.loadingBrands
                                  ? 'Loading Brands...'
                                  : (model.brands.isEmpty
                                      ? 'No Brands Found'
                                      : 'Select Brand')),
                              items: model.brands.map((b) {
                                return DropdownMenuItem(
                                  value: b.id,
                                  child: Text(b.name),
                                );
                              }).toList(),
                              onChanged: (brandId) {
                                if (brandId != null) {
                                  compatibilityRows[i]['brandId'] = brandId;
                                  compatibilityRows[i]['modelId'] =
                                      null; // Clear model on brand change!
                                  model.loadModelsForBrand(brandId);
                                  onRowsChanged();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Model Dropdown (From DB, filtered by Brand)
                          Expanded(
                            child: Builder(builder: (context) {
                              final currentBrandId =
                                  compatibilityRows[i]['brandId'];
                              final bool hasBrand = currentBrandId != null &&
                                  currentBrandId.isNotEmpty;
                              final bool isLoadingModels = hasBrand &&
                                  model.isLoadingModelsForBrand(currentBrandId);
                              final List<VehicleModel> brandModels = hasBrand
                                  ? (model.modelsByBrand[currentBrandId] ?? [])
                                  : [];
                              final String? currentModelId =
                                  compatibilityRows[i]['modelId'];

                              return DropdownButtonFormField<String>(
                                initialValue: brandModels
                                        .any((m) => m.id == currentModelId)
                                    ? currentModelId
                                    : null,
                                decoration: InputDecoration(
                                  labelText: 'Model *',
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  suffixIcon: isLoadingModels
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: Padding(
                                            padding: EdgeInsets.all(12),
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          ),
                                        )
                                      : null,
                                ),
                                hint: Text(
                                  !hasBrand
                                      ? 'Select Brand First'
                                      : (isLoadingModels
                                          ? 'Loading Models...'
                                          : (brandModels.isEmpty
                                              ? 'No Models Available'
                                              : 'Select Model')),
                                ),
                                items: hasBrand &&
                                        !isLoadingModels &&
                                        brandModels.isNotEmpty
                                    ? brandModels.map((m) {
                                        return DropdownMenuItem(
                                          value: m.id,
                                          child: Text(m.displayName),
                                        );
                                      }).toList()
                                    : null,
                                onChanged: hasBrand &&
                                        !isLoadingModels &&
                                        brandModels.isNotEmpty
                                    ? (modelId) {
                                        compatibilityRows[i]['modelId'] =
                                            modelId;
                                        onRowsChanged();
                                      }
                                    : null,
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              OutlinedButton.icon(
                onPressed: () {
                  compatibilityRows
                      .add({'brandId': null, 'modelId': null});
                  onRowsChanged();
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Compatible Vehicle'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  AdminProductsViewModel viewModelBuilder(BuildContext context) =>
      AdminProductsViewModel();
}
