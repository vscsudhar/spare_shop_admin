import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_table_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_customers_viewmodel.dart';

class AdminCustomersView extends StackedView<AdminCustomersViewModel> {
  const AdminCustomersView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminCustomersViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: 'Customer Directory',
      selectedItem: AdminNavigationItem.customers,
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
                    title: 'Total Active Clients',
                    value: '${viewModel.filteredCustomers.length}',
                    icon: Icons.people_alt_outlined,
                    iconColor: Colors.blue,
                  ),
                  AdminMetricCard(
                    title: 'Workshop accounts',
                    value:
                        '${viewModel.filteredCustomers.where((c) => c.type.contains('Workshop')).length}',
                    icon: Icons.store_outlined,
                    iconColor: Colors.purple,
                  ),
                  AdminMetricCard(
                    title: 'Credit Dues Outstanding',
                    value:
                        '₹${viewModel.totalOutstandingDue.toStringAsFixed(0)}',
                    icon: Icons.credit_card_off_outlined,
                    iconColor: Colors.red,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Customer Ledger Accounts',
                  style: AdminTextStyles.sectionHeader),
              ElevatedButton.icon(
                onPressed: () => _showCustomerForm(context, viewModel),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Customer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Ledger Table
          AdminDataTable(
            columns: const [
              'Client Name',
              'Account Type',
              'Contact Phone',
              'Orders Count',
              'Total Spent',
              'Outstanding Due',
              'Action'
            ],
            rows: viewModel.filteredCustomers.map((customer) {
              final hasDue = customer.outstandingDue > 0;

              return AdminTableRow(
                cells: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(customer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(customer.email,
                          style: TextStyle(
                              fontSize: 10, color: AdminColors.textLight)),
                    ],
                  ),
                  Text(customer.type),
                  Text(customer.phone),
                  Text('${customer.ordersCount} orders'),
                  Text('₹${customer.totalSpend.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '₹${customer.outstandingDue.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: hasDue
                          ? AdminColors.cancelled
                          : AdminColors.textPrimary,
                      fontWeight: hasDue ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.edit_outlined,
                          color: AdminColors.primaryGreen, size: 18),
                      onPressed: () =>
                          _showCustomerForm(context, viewModel, customer),
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

  void _showCustomerForm(
      BuildContext context, AdminCustomersViewModel viewModel,
      [AdminCustomerModel? customer]) {
    final nameController = TextEditingController(text: customer?.name ?? '');
    final emailController = TextEditingController(text: customer?.email ?? '');
    final phoneController = TextEditingController(text: customer?.phone ?? '');
    final dueController = TextEditingController(
        text: customer != null
            ? customer.outstandingDue.toStringAsFixed(2)
            : '0.00');

    String selectedType = customer?.type ?? 'Retail Customer';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AdminColors.panelBackground,
          title: Text(
            customer == null ? 'Add New Customer' : 'Edit Customer',
            style: TextStyle(color: AdminColors.textPrimary),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    style: TextStyle(color: AdminColors.textPrimary),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    style: TextStyle(color: AdminColors.textPrimary),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(val.trim())) {
                        return 'Invalid email format';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    style: TextStyle(color: AdminColors.textPrimary),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Phone is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    dropdownColor: AdminColors.panelBackground,
                    decoration:
                        const InputDecoration(labelText: 'Account Type'),
                    style: TextStyle(color: AdminColors.textPrimary),
                    items: const [
                      DropdownMenuItem(
                          value: 'Retail Customer',
                          child: Text('Retail Customer')),
                      DropdownMenuItem(
                          value: 'Workshop Owner',
                          child: Text('Workshop Owner')),
                      DropdownMenuItem(
                          value: 'Wholesaler', child: Text('Wholesaler')),
                    ],
                    onChanged: (val) {
                      if (val != null) selectedType = val;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: dueController,
                    decoration:
                        const InputDecoration(labelText: 'Outstanding Due (₹)'),
                    style: TextStyle(color: AdminColors.textPrimary),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Due amount is required';
                      }
                      if (double.tryParse(val) == null) {
                        return 'Must be a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final due = double.parse(dueController.text);
                  if (customer == null) {
                    viewModel.addCustomer(
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      phone: phoneController.text.trim(),
                      type: selectedType,
                      outstandingDue: due,
                    );
                  } else {
                    viewModel.updateCustomer(
                      customer,
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      phone: phoneController.text.trim(),
                      type: selectedType,
                      outstandingDue: due,
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryGreen),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  AdminCustomersViewModel viewModelBuilder(BuildContext context) =>
      AdminCustomersViewModel();
}
