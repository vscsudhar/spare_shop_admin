import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_suppliers_viewmodel.dart';

class AdminSuppliersView extends StackedView<AdminSuppliersViewModel> {
  const AdminSuppliersView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminSuppliersViewModel viewModel,
    Widget? child,
  ) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= AdminBreakpoints.tablet;

    return AdminShell(
      title: 'Suppliers Registry',
      selectedItem: AdminNavigationItem.suppliers,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics Cards Row
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _metricCard('Total Suppliers', '${viewModel.totalSuppliers}',
                  Icons.warehouse_rounded, Colors.blue),
              _metricCard('Active Suppliers', '${viewModel.activeSuppliers}',
                  Icons.check_circle_outline, Colors.green),
              _metricCard(
                  'Outstanding Payable',
                  '₹${viewModel.outstandingPayable.toStringAsFixed(2)}',
                  Icons.payment_rounded,
                  Colors.orange),
            ],
          ),
          const SizedBox(height: 24),

          // Filters and Search Header
          AdminPanelCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: viewModel.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Search by Company Name or Contact...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: viewModel.goToAdminSupplierForm,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Supplier'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Spares Type: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    _filterChip(
                        viewModel.categoryFilter == 'All',
                        'All Categories',
                        () => viewModel.setCategoryFilter('All')),
                    const SizedBox(width: 8),
                    _filterChip(viewModel.categoryFilter == 'EV', 'EV Parts',
                        () => viewModel.setCategoryFilter('EV')),
                    const SizedBox(width: 8),
                    _filterChip(
                        viewModel.categoryFilter == 'Petrol',
                        'Petrol Parts',
                        () => viewModel.setCategoryFilter('Petrol')),
                    const Spacer(),
                    const Text('Status: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    _filterDropdown(
                      value: viewModel.statusFilter,
                      items: const ['All', 'Active', 'Inactive'],
                      onChanged: (val) {
                        if (val != null) viewModel.setStatusFilter(val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Responsive List/Table
          if (viewModel.suppliers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60.0),
              child: Center(
                  child: Text(
                      'No suppliers matching the selected filter criteria.',
                      style: TextStyle(color: Colors.grey))),
            )
          else if (isDesktop)
            _buildSuppliersTable(context, viewModel)
          else
            _buildSuppliersCardsList(context, viewModel),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String val, IconData icon, Color color) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
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
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 12, color: AdminColors.textSecondary)),
              const SizedBox(height: 4),
              Text(val,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textPrimary)),
            ],
          )
        ],
      ),
    );
  }

  Widget _filterChip(bool isSelected, String label, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label,
          style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : AdminColors.textPrimary)),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AdminColors.primaryGreen,
      backgroundColor: AdminColors.isDarkTheme
          ? Colors.white10
          : Colors.black12.withValues(alpha: 0.04),
    );
  }

  Widget _filterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AdminColors.border),
        borderRadius: BorderRadius.circular(8),
        color: AdminColors.panelBackground,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AdminColors.panelBackground,
          items: items
              .map((i) => DropdownMenuItem(
                  value: i,
                  child: Text(i,
                      style: TextStyle(
                          fontSize: 12, color: AdminColors.textPrimary))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSuppliersTable(
      BuildContext context, AdminSuppliersViewModel viewModel) {
    return AdminPanelCard(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Company Name')),
            DataColumn(label: Text('Contact Person')),
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('City/State')),
            DataColumn(label: Text('Outstanding')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: viewModel.suppliers.map((s) {
            return DataRow(
              cells: [
                DataCell(
                  Text(s.companyName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () =>
                      viewModel.goToAdminSupplierDetail(supplierId: s.id),
                ),
                DataCell(Text(s.contactPerson)),
                DataCell(Text(s.phone)),
                DataCell(Text('${s.city}, ${s.state}')),
                DataCell(Text(
                    '₹${(s.outstandingAmountInPaise / 100.0).toStringAsFixed(2)}',
                    style: TextStyle(
                        color: s.outstandingAmountInPaise > 0
                            ? Colors.red
                            : Colors.grey,
                        fontWeight: FontWeight.bold))),
                DataCell(
                  AdminStatusChip(
                    label: s.isActive ? 'Active' : 'Inactive',
                    color: s.isActive ? Colors.green : Colors.grey,
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        onPressed: () =>
                            viewModel.goToAdminSupplierDetail(supplierId: s.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () =>
                            viewModel.goToEditAdminSupplier(supplierId: s.id),
                      ),
                      IconButton(
                        icon: Icon(
                            s.isActive
                                ? Icons.block
                                : Icons.check_circle_outline,
                            size: 18,
                            color: s.isActive ? Colors.red : Colors.green),
                        onPressed: () => viewModel.toggleStatus(s),
                      ),
                    ],
                  ),
                )
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSuppliersCardsList(
      BuildContext context, AdminSuppliersViewModel viewModel) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.suppliers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final s = viewModel.suppliers[index];
        return Card(
          color: AdminColors.panelBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AdminColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(s.companyName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    AdminStatusChip(
                      label: s.isActive ? 'Active' : 'Inactive',
                      color: s.isActive ? Colors.green : Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Contact: ${s.contactPerson} • ${s.phone}'),
                Text('Location: ${s.city}, ${s.state}'),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Outstanding Payable',
                            style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text(
                            '₹${(s.outstandingAmountInPaise / 100.0).toStringAsFixed(2)}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: s.outstandingAmountInPaise > 0
                                    ? Colors.red
                                    : Colors.grey)),
                      ],
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => viewModel.goToAdminSupplierDetail(
                              supplierId: s.id),
                          child: const Text('View'),
                        ),
                        TextButton(
                          onPressed: () =>
                              viewModel.goToEditAdminSupplier(supplierId: s.id),
                          child: const Text('Edit'),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  AdminSuppliersViewModel viewModelBuilder(BuildContext context) =>
      AdminSuppliersViewModel();
}
