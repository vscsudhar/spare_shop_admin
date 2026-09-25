import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:spare_shop_admin/ui/common/location_inventory_models.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_location_inventory_viewmodel.dart';

class AdminLocationInventoryView
    extends StackedView<AdminLocationInventoryViewModel> {
  final String? locationId;
  final LocationModel? location;

  const AdminLocationInventoryView({
    Key? key,
    this.locationId,
    this.location,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminLocationInventoryViewModel viewModel,
    Widget? child,
  ) {
    if (viewModel.locationId == null || viewModel.locationId!.isEmpty) {
      return AdminShell(
        title: 'Location Inventory',
        selectedItem: AdminNavigationItem.locations,
        child: AdminPanelCard(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_off_outlined,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No location selected.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please navigate to Location Inventory from the Locations list.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: viewModel.goToAdminLocations,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Locations'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= AdminBreakpoints.tablet;
    final locName = viewModel.location?.name ?? 'Location';

    return AdminShell(
      title: '$locName Inventory',
      selectedItem: AdminNavigationItem.locations,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Back Button
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: viewModel.goBack,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$locName — Stock & Inventory Management',
                  style: AdminTextStyles.sectionHeader,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Location Summary Banner Card
          if (viewModel.location != null) _buildLocationSummaryCard(viewModel),
          const SizedBox(height: 20),

          // Metrics Summary Cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _metricCard(
                'Tracked Spares',
                '${viewModel.totalTrackedSpares}',
                Icons.inventory_2_rounded,
                Colors.blue,
              ),
              _metricCard(
                'In Stock',
                '${viewModel.inStockCount}',
                Icons.check_circle_rounded,
                AdminColors.primaryGreen,
              ),
              _metricCard(
                'Out of Stock',
                '${viewModel.outOfStockCount}',
                Icons.warning_amber_rounded,
                Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search and Actions Header
          AdminPanelCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: viewModel.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Search product name, SKU, or category...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _openAddStockDialog(context, viewModel),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add / Update Stock'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Stock Filter: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      viewModel.stockFilter == 'All',
                      'All Spares',
                      () => viewModel.setStockFilter('All'),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      viewModel.stockFilter == 'In Stock',
                      'In Stock',
                      () => viewModel.setStockFilter('In Stock'),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      viewModel.stockFilter == 'Out of Stock',
                      'Out of Stock',
                      () => viewModel.setStockFilter('Out of Stock'),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh Inventory',
                      onPressed: viewModel.loadInventory,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Content state handling
          if (viewModel.isBusy && viewModel.inventoryItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (viewModel.hasError && viewModel.inventoryItems.isEmpty)
            AdminEmptyState(
              message:
                  'Failed to load location inventory.\n${viewModel.modelError ?? "An unexpected error occurred."}',
              icon: Icons.error_outline,
            )
          else if (viewModel.inventoryItems.isEmpty)
            AdminEmptyState(
              message: viewModel.searchQuery.isNotEmpty
                  ? 'No inventory items matching "${viewModel.searchQuery}".'
                  : 'No inventory stock records for $locName yet.\nClick "+ Add / Update Stock" to assign product quantities.',
              icon: Icons.inventory_outlined,
            )
          else if (isDesktop)
            _buildInventoryTable(context, viewModel)
          else
            _buildInventoryCardsList(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildLocationSummaryCard(AdminLocationInventoryViewModel viewModel) {
    final loc = viewModel.location!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AdminColors.primaryGreen.withValues(alpha: 0.12),
            child: Icon(Icons.location_on, color: AdminColors.primaryGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Wrap(
              spacing: 24,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Target Service Hub',
                      style: TextStyle(
                        fontSize: 12,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                _summaryPill('Radius', loc.radiusDisplay, Icons.radar),
                _summaryPill(
                  'Coordinates',
                  loc.coordinatesDisplay,
                  Icons.my_location,
                ),
              ],
            ),
          ),
          AdminStatusChip(
            label: loc.isActive ? 'Active Location' : 'Inactive Location',
            color: loc.isActive ? AdminColors.primaryGreen : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _summaryPill(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AdminColors.isDarkTheme
            ? Colors.white10
            : Colors.black12.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AdminColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12, color: AdminColors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String val, IconData icon, Color color) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    TextStyle(fontSize: 12, color: AdminColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                val,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(bool isSelected, String label, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : AdminColors.textPrimary,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AdminColors.primaryGreen,
      backgroundColor: AdminColors.isDarkTheme
          ? Colors.white10
          : Colors.black12.withValues(alpha: 0.04),
    );
  }

  Widget _buildInventoryTable(
    BuildContext context,
    AdminLocationInventoryViewModel viewModel,
  ) {
    return AdminPanelCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth:
                    constraints.maxWidth > 850 ? constraints.maxWidth : 850,
              ),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Product / Spare Part')),
                  DataColumn(label: Text('SKU / Category')),
                  DataColumn(label: Text('Available Stock')),
                  DataColumn(label: Text('Stock Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: viewModel.inventoryItems.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.build_circle_outlined,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                item.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.sku.isNotEmpty ? item.sku : '—',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (item.category.isNotEmpty)
                              Text(
                                item.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AdminColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: item.isInStock
                                    ? AdminColors.textPrimary
                                    : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'units',
                              style: TextStyle(
                                fontSize: 11,
                                color: AdminColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        AdminStatusChip(
                          label: item.statusDisplay,
                          color: item.isInStock
                              ? AdminColors.primaryGreen
                              : Colors.red,
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              tooltip: 'Update Stock',
                              onPressed: () => _openEditStockDialog(
                                context,
                                viewModel,
                                item,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.red,
                              ),
                              tooltip: 'Remove Record',
                              onPressed: () => _confirmDeleteRecord(
                                context,
                                viewModel,
                                item,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInventoryCardsList(
    BuildContext context,
    AdminLocationInventoryViewModel viewModel,
  ) {
    return Column(
      children: viewModel.inventoryItems.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: AdminPanelCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: item.isInStock
                    ? AdminColors.primaryGreen.withValues(alpha: 0.12)
                    : Colors.red.withValues(alpha: 0.12),
                child: Icon(
                  Icons.build_circle,
                  color: item.isInStock ? AdminColors.primaryGreen : Colors.red,
                ),
              ),
              title: Text(
                item.productName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('SKU: ${item.sku.isNotEmpty ? item.sku : '—'}'),
                  Text('Stock: ${item.quantity} units'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminStatusChip(
                    label: item.statusDisplay,
                    color:
                        item.isInStock ? AdminColors.primaryGreen : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () =>
                        _openEditStockDialog(context, viewModel, item),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.red,
                    ),
                    onPressed: () =>
                        _confirmDeleteRecord(context, viewModel, item),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _openAddStockDialog(
    BuildContext context,
    AdminLocationInventoryViewModel viewModel,
  ) async {
    await showDialog(
      context: context,
      builder: (ctx) => _AddUpdateStockDialog(
        viewModel: viewModel,
      ),
    );
    await viewModel.loadInventory();
  }

  Future<void> _openEditStockDialog(
    BuildContext context,
    AdminLocationInventoryViewModel viewModel,
    LocationInventoryItem item,
  ) async {
    await showDialog(
      context: context,
      builder: (ctx) => _AddUpdateStockDialog(
        viewModel: viewModel,
        existingItem: item,
      ),
    );
    await viewModel.loadInventory();
  }

  void _confirmDeleteRecord(
    BuildContext context,
    AdminLocationInventoryViewModel viewModel,
    LocationInventoryItem item,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Inventory Record'),
        content: Text(
          'Are you sure you want to remove the stock record for "${item.productName}" at ${viewModel.location?.name ?? 'this location'}?\n\nThis will treat the spare as Out of Stock for this location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success =
                  await viewModel.removeInventoryRecord(item.productId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Stock record removed'
                          : 'Failed to remove record',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  AdminLocationInventoryViewModel viewModelBuilder(BuildContext context) =>
      AdminLocationInventoryViewModel(
        locationId: locationId,
        location: location,
      );
}

class _AddUpdateStockDialog extends StatefulWidget {
  final AdminLocationInventoryViewModel viewModel;
  final LocationInventoryItem? existingItem;

  const _AddUpdateStockDialog({
    required this.viewModel,
    this.existingItem,
  });

  @override
  State<_AddUpdateStockDialog> createState() => _AddUpdateStockDialogState();
}

class _AddUpdateStockDialogState extends State<_AddUpdateStockDialog> {
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  ProductModel? _selectedProduct;
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.existingItem != null) {
      _quantityController.text = widget.existingItem!.quantity.toString();
    } else {
      _quantityController.text = '1';
      _loadInitialProducts();
    }
  }

  Future<void> _loadInitialProducts() async {
    setState(() => _isSearching = true);
    final results = await widget.viewModel.searchGlobalProducts('');
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  Future<void> _onSearchChanged(String query) async {
    setState(() => _isSearching = true);
    final results = await widget.viewModel.searchGlobalProducts(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _adjustQuantity(int delta) {
    final current = int.tryParse(_quantityController.text) ?? 0;
    final next = (current + delta).clamp(0, 99999);
    _quantityController.text = next.toString();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final productId = widget.existingItem?.productId ?? _selectedProduct?.id;
    if (productId == null || productId.isEmpty) {
      setState(() => _errorMessage = 'Please select a product');
      return;
    }

    final qty = int.parse(_quantityController.text.trim());

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final success = await widget.viewModel.updateStock(productId, qty);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingItem != null
                  ? 'Stock updated to $qty units!'
                  : 'Product added to location with $qty units!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = widget.viewModel.modelError?.toString() ??
              'Failed to update stock';
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locName = widget.viewModel.location?.name ?? 'Location';
    final isEdit = widget.existingItem != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit
                          ? 'Update Stock Quantity'
                          : 'Add Product to Inventory',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Text(
                  'Managing stock for $locName',
                  style:
                      TextStyle(color: AdminColors.textSecondary, fontSize: 13),
                ),
                const Divider(height: 24),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Product Selection section
                if (isEdit) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AdminColors.isDarkTheme
                          ? Colors.white10
                          : Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AdminColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.build_circle, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.existingItem!.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (widget.existingItem!.sku.isNotEmpty)
                                Text(
                                  'SKU: ${widget.existingItem!.sku}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AdminColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  const Text(
                    'Select Global Product *',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Type to search products by name or SKU...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Search dropdown results
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AdminColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _isSearching
                          ? const Center(child: CircularProgressIndicator())
                          : _searchResults.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No products found.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: _searchResults.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, idx) {
                                    final p = _searchResults[idx];
                                    final isSelected =
                                        _selectedProduct?.id == p.id;
                                    return ListTile(
                                      selected: isSelected,
                                      selectedTileColor: AdminColors
                                          .primaryGreen
                                          .withValues(alpha: 0.12),
                                      title: Text(
                                        p.name,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 13,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Price: ₹${p.price.toStringAsFixed(2)} | Type: ${p.vehicleType}',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      trailing: isSelected
                                          ? Icon(
                                              Icons.check_circle,
                                              color: AdminColors.primaryGreen,
                                              size: 20,
                                            )
                                          : null,
                                      onTap: () {
                                        setState(() {
                                          _selectedProduct = p;
                                          _errorMessage = null;
                                        });
                                      },
                                    );
                                  },
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Quantity Input with Stepper Controls
                const Text(
                  'Quantity to Stock *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton.outlined(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _adjustQuantity(-1),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Quantity is required';
                          }
                          final n = int.tryParse(val.trim());
                          if (n == null || n < 0) {
                            return 'Enter valid quantity >= 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      icon: const Icon(Icons.add),
                      onPressed: () => _adjustQuantity(1),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Dialog Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(isEdit ? 'Update Stock' : 'Save Stock'),
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
}
