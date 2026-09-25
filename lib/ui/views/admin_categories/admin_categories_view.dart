import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:spare_shop_admin/ui/views/admin_categories/admin_categories_viewmodel.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:stacked/stacked.dart';

class AdminCategoriesView extends StackedView<AdminCategoriesViewModel> {
  const AdminCategoriesView({super.key});

  @override
  Widget builder(
    BuildContext context,
    AdminCategoriesViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: 'Categories Management',
      selectedItem: AdminNavigationItem.categories,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          _buildHeader(context, viewModel),
          const SizedBox(height: AdminSpacing.l),

          // Metrics Summary Cards
          _buildMetricsOverview(viewModel),
          const SizedBox(height: AdminSpacing.l),

          // Search, Filters & Action Bar
          _buildFilterBar(context, viewModel),
          const SizedBox(height: AdminSpacing.m),

          // Categories Content (Table / List)
          _buildCategoriesContent(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AdminCategoriesViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spare Part Categories',
              style: AdminTextStyles.header.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              'Organize products, assign vehicle compatibility types, and manage catalog taxonomy.',
              style: AdminTextStyles.bodySecondary.copyWith(fontSize: 13),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddCategoryDialog(context, viewModel),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('Add Category'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminRadius.chip),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsOverview(AdminCategoriesViewModel viewModel) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 800;
        return GridView.count(
          crossAxisCount: isNarrow ? 2 : 4,
          crossAxisSpacing: AdminSpacing.m,
          mainAxisSpacing: AdminSpacing.m,
          childAspectRatio: isNarrow ? 1.9 : 2.2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              title: 'Total Categories',
              value: viewModel.totalCount.toString(),
              icon: Icons.category_rounded,
              color: AdminColors.primaryGreen,
              subtitle: '${viewModel.activeCount} Active',
            ),
            _buildStatCard(
              title: 'EV Categories',
              value: viewModel.evCount.toString(),
              icon: Icons.electric_bolt_rounded,
              color: const Color(0xFF00E5FF),
              subtitle: 'Electric Powertrain & Systems',
            ),
            _buildStatCard(
              title: 'Petrol Categories',
              value: viewModel.petrolCount.toString(),
              icon: Icons.local_gas_station_rounded,
              color: const Color(0xFFFF9100),
              subtitle: 'ICE Engine & Fuel Systems',
            ),
            _buildStatCard(
              title: 'Universal Categories',
              value: viewModel.universalCount.toString(),
              icon: Icons.all_inclusive_rounded,
              color: const Color(0xFF7C4DFF),
              subtitle: 'Cross-Vehicle Compatible',
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminSpacing.m,
        vertical: AdminSpacing.s + 2,
      ),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(AdminRadius.card),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AdminSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AdminTextStyles.header.copyWith(fontSize: 20),
                ),
                Text(
                  title,
                  style: AdminTextStyles.bodySecondary.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AdminColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(
      BuildContext context, AdminCategoriesViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(AdminSpacing.m),
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(AdminRadius.card),
        border: Border.all(color: AdminColors.border),
      ),
      child: Wrap(
        spacing: AdminSpacing.m,
        runSpacing: AdminSpacing.s,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          // Search Box
          SizedBox(
            width: 280,
            height: 42,
            child: TextField(
              onChanged: viewModel.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search, size: 18),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AdminRadius.chip),
                  borderSide: BorderSide(color: AdminColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AdminRadius.chip),
                  borderSide: BorderSide(color: AdminColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AdminRadius.chip),
                  borderSide: BorderSide(color: AdminColors.primaryGreen),
                ),
              ),
            ),
          ),

          // Type Filter Chips
          Wrap(
            spacing: 8,
            children: [
              _buildTypeChip('All', viewModel),
              _buildTypeChip('EV', viewModel),
              _buildTypeChip('Petrol', viewModel),
              _buildTypeChip('Universal', viewModel),
            ],
          ),

          // Status Filter Dropdown
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AdminColors.border),
              borderRadius: BorderRadius.circular(AdminRadius.chip),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: viewModel.statusFilter,
                style: AdminTextStyles.body.copyWith(fontSize: 13),
                dropdownColor: AdminColors.panelBackground,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All Status')),
                  DropdownMenuItem(value: 'Active', child: Text('Active Only')),
                  DropdownMenuItem(
                      value: 'Inactive', child: Text('Inactive Only')),
                ],
                onChanged: (val) {
                  if (val != null) viewModel.setStatusFilter(val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type, AdminCategoriesViewModel viewModel) {
    final isSelected = viewModel.typeFilter == type;
    Color activeColor = AdminColors.primaryGreen;
    if (type == 'EV') activeColor = const Color(0xFF00E5FF);
    if (type == 'Petrol') activeColor = const Color(0xFFFF9100);
    if (type == 'Universal') activeColor = const Color(0xFF7C4DFF);

    return ChoiceChip(
      label: Text(type == 'All' ? 'All Types' : type),
      selected: isSelected,
      onSelected: (_) => viewModel.setTypeFilter(type),
      selectedColor: activeColor.withValues(alpha: 0.2),
      side: BorderSide(
        color: isSelected ? activeColor : AdminColors.border,
      ),
      labelStyle: TextStyle(
        color: isSelected ? activeColor : AdminColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  Widget _buildCategoriesContent(
    BuildContext context,
    AdminCategoriesViewModel viewModel,
  ) {
    if (viewModel.isBusy && viewModel.allCategories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final categories = viewModel.filteredCategories;

    if (categories.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AdminColors.panelBackground,
          borderRadius: BorderRadius.circular(AdminRadius.card),
          border: Border.all(color: AdminColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined,
                size: 48, color: AdminColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No categories found',
              style: AdminTextStyles.header.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Try changing search filters or create a new category.',
              style: AdminTextStyles.bodySecondary,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddCategoryDialog(context, viewModel),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Category'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(AdminRadius.card),
        border: Border.all(color: AdminColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AdminRadius.card),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 900),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                AdminColors.isDarkTheme ? Colors.white10 : Colors.grey.shade100,
              ),
              dataRowMinHeight: 64,
              dataRowMaxHeight: 64,
              horizontalMargin: 20,
              columnSpacing: 24,
              columns: const [
                DataColumn(
                  label: Text('Category',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Slug',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Vehicle Type',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Parent Category',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Description',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Status',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Actions',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
              rows: categories.map((category) {
                return DataRow(
                  cells: [
                    // Category Icon & Name
                    DataCell(
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AdminColors.primaryGreen
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              category.icon,
                              color: AdminColors.primaryGreen,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                category.name,
                                style: AdminTextStyles.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (category.productCount > 0)
                                Text(
                                  '${category.productCount} products',
                                  style: TextStyle(
                                    color: AdminColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Slug
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category.slug.isNotEmpty ? category.slug : '-',
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: AdminColors.textPrimary,
                          ),
                        ),
                      ),
                    ),

                    // Vehicle Type Badge
                    DataCell(
                      _buildTypeBadge(category.type),
                    ),

                    // Parent Category
                    DataCell(
                      Text(
                        category.parentCategoryName != null &&
                                category.parentCategoryName!.isNotEmpty
                            ? category.parentCategoryName!
                            : '— Top Level',
                        style: TextStyle(
                          color: category.parentCategoryName != null
                              ? AdminColors.textPrimary
                              : AdminColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    // Description
                    DataCell(
                      SizedBox(
                        width: 180,
                        child: Text(
                          category.description.isNotEmpty
                              ? category.description
                              : 'No description provided',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: category.description.isNotEmpty
                                ? AdminColors.textPrimary
                                : AdminColors.textSecondary
                                    .withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                    // Status Switch
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: category.active,
                            activeTrackColor:
                                AdminColors.primaryGreen.withValues(alpha: 0.4),
                            activeThumbImage: null,
                            thumbColor: WidgetStateProperty.resolveWith(
                              (states) => states.contains(WidgetState.selected)
                                  ? AdminColors.primaryGreen
                                  : Colors.grey,
                            ),
                            onChanged: (_) =>
                                viewModel.toggleCategoryStatus(category),
                          ),
                          Text(
                            category.active ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: category.active
                                  ? AdminColors.primaryGreen
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            tooltip: 'Edit Category',
                            color: AdminColors.primaryGreen,
                            onPressed: () => _showEditCategoryDialog(
                              context,
                              viewModel,
                              category,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            tooltip: 'Delete Category',
                            color: Colors.redAccent,
                            onPressed: () => _showDeleteConfirmation(
                              context,
                              viewModel,
                              category,
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
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color bg = const Color(0xFF7C4DFF).withValues(alpha: 0.12);
    Color fg = const Color(0xFF7C4DFF);
    IconData icon = Icons.all_inclusive;

    if (type.toUpperCase() == 'EV') {
      bg = const Color(0xFF00E5FF).withValues(alpha: 0.15);
      fg = const Color(0xFF00B0FF);
      icon = Icons.electric_bolt;
    } else if (type.toUpperCase() == 'PETROL') {
      bg = const Color(0xFFFF9100).withValues(alpha: 0.15);
      fg = const Color(0xFFFF9100);
      icon = Icons.local_gas_station;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            type,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(
    BuildContext context,
    AdminCategoriesViewModel viewModel,
  ) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'Universal';
    String? selectedParentId;
    bool isActive = true;

    showDialog(
      context: context,
      barrierDismissible: !viewModel.isBusy,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminRadius.card),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AdminColors.primaryGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add_circle_outline,
                        color: AdminColors.primaryGreen, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Text('Add New Category'),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Category Name
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Category Name *',
                          hintText:
                              'e.g., Brake Systems, Battery Packs, Suspension',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Vehicle Type Selector
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vehicle Compatibility Type *',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildDialogTypeChip(
                                'Universal',
                                selectedType,
                                (t) => setDialogState(() => selectedType = t),
                              ),
                              const SizedBox(width: 8),
                              _buildDialogTypeChip(
                                'EV',
                                selectedType,
                                (t) => setDialogState(() => selectedType = t),
                              ),
                              const SizedBox(width: 8),
                              _buildDialogTypeChip(
                                'Petrol',
                                selectedType,
                                (t) => setDialogState(() => selectedType = t),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Parent Category Dropdown
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: selectedParentId,
                        decoration: const InputDecoration(
                          labelText: 'Parent Category (Optional)',
                          hintText: 'Select if this is a subcategory',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text(
                              'None (Top Level Category)',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          ...viewModel.allCategories.map((cat) {
                            return DropdownMenuItem(
                              value: cat.id,
                              child: Text(
                                '${cat.name} (${cat.type})',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setDialogState(() {
                            selectedParentId = val;
                          });
                        },
                      ),
                      const SizedBox(height: 14),

                      // Description
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText:
                              'Short summary of parts under this category...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Active status toggle
                      Row(
                        children: [
                          Checkbox(
                            value: isActive,
                            activeColor: AdminColors.primaryGreen,
                            onChanged: (val) {
                              setDialogState(() {
                                isActive = val ?? true;
                              });
                            },
                          ),
                          const Text(
                            'Active (Visible across admin catalog and store)',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: viewModel.isBusy
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: viewModel.isBusy
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter category name'),
                              ),
                            );
                            return;
                          }

                          final success = await viewModel.createCategory(
                            name: name,
                            type: selectedType,
                            description: descriptionController.text.trim(),
                            parentCategoryId: selectedParentId,
                            active: isActive,
                          );

                          if (success && context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Category "$name" created!'),
                                backgroundColor: AdminColors.primaryGreen,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: viewModel.isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Create Category'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditCategoryDialog(
    BuildContext context,
    AdminCategoriesViewModel viewModel,
    CategoryModel category,
  ) {
    final nameController = TextEditingController(text: category.name);
    final descriptionController =
        TextEditingController(text: category.description);
    String selectedType = category.type;
    String? selectedParentId = category.parentCategoryId;
    bool isActive = category.active;

    showDialog(
      context: context,
      barrierDismissible: !viewModel.isBusy,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final eligibleParents = viewModel.allCategories
                .where((c) => c.id != category.id)
                .toList();

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminRadius.card),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AdminColors.primaryGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.edit_note,
                        color: AdminColors.primaryGreen, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Text('Edit Category'),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Category Name *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Vehicle Type Selector
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vehicle Compatibility Type *',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildDialogTypeChip(
                                'Universal',
                                selectedType,
                                (t) => setDialogState(() => selectedType = t),
                              ),
                              const SizedBox(width: 8),
                              _buildDialogTypeChip(
                                'EV',
                                selectedType,
                                (t) => setDialogState(() => selectedType = t),
                              ),
                              const SizedBox(width: 8),
                              _buildDialogTypeChip(
                                'Petrol',
                                selectedType,
                                (t) => setDialogState(() => selectedType = t),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Parent Category Dropdown
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue:
                            eligibleParents.any((p) => p.id == selectedParentId)
                                ? selectedParentId
                                : null,
                        decoration: const InputDecoration(
                          labelText: 'Parent Category (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text(
                              'None (Top Level Category)',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          ...eligibleParents.map((cat) {
                            return DropdownMenuItem(
                              value: cat.id,
                              child: Text(
                                '${cat.name} (${cat.type})',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setDialogState(() {
                            selectedParentId = val;
                          });
                        },
                      ),
                      const SizedBox(height: 14),

                      // Description
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Active status toggle
                      Row(
                        children: [
                          Checkbox(
                            value: isActive,
                            activeColor: AdminColors.primaryGreen,
                            onChanged: (val) {
                              setDialogState(() {
                                isActive = val ?? true;
                              });
                            },
                          ),
                          const Text(
                            'Active (Visible across admin catalog and store)',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: viewModel.isBusy
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: viewModel.isBusy
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter category name'),
                              ),
                            );
                            return;
                          }

                          final success = await viewModel.updateCategory(
                            id: category.id,
                            name: name,
                            type: selectedType,
                            description: descriptionController.text.trim(),
                            parentCategoryId: selectedParentId,
                            active: isActive,
                          );

                          if (success && context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Category "$name" updated!'),
                                backgroundColor: AdminColors.primaryGreen,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: viewModel.isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogTypeChip(
    String type,
    String selectedType,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = selectedType == type;
    Color color = AdminColors.primaryGreen;
    if (type == 'EV') color = const Color(0xFF00E5FF);
    if (type == 'Petrol') color = const Color(0xFFFF9100);
    if (type == 'Universal') color = const Color(0xFF7C4DFF);

    return ChoiceChip(
      label: Text(type),
      selected: isSelected,
      onSelected: (_) => onSelected(type),
      selectedColor: color.withValues(alpha: 0.2),
      side: BorderSide(
        color: isSelected ? color : AdminColors.border,
      ),
      labelStyle: TextStyle(
        color: isSelected ? color : AdminColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AdminCategoriesViewModel viewModel,
    CategoryModel category,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminRadius.card),
          ),
          title: const Text('Delete Category?'),
          content: Text(
            'Are you sure you want to delete "${category.name}"? This action cannot be undone.\n\nNote: If products are currently linked to this category, you will need to reassign them first.',
            style: AdminTextStyles.bodySecondary,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await viewModel.deleteCategory(category.id);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Category "${category.name}" deleted.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  AdminCategoriesViewModel viewModelBuilder(BuildContext context) =>
      AdminCategoriesViewModel();
}
