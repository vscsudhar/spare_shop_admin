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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer Ledger Accounts',
                      style: AdminTextStyles.sectionHeader),
                  const SizedBox(height: 4),
                  Text(
                    'Manage customers, workshop accounts, and associated branch hubs',
                    style: AdminTextStyles.bodySecondary.copyWith(fontSize: 12),
                  ),
                ],
              ),
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
          const SizedBox(height: 16),

          // Location Filter Section & Hub Quick Selector
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminColors.panelBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AdminColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16, color: AdminColors.primaryGreen),
                    const SizedBox(width: 6),
                    Text(
                      'Customer Hub Location Filter:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    if (!viewModel.canChangeLocation &&
                        viewModel.userAssignedLocationName != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock, size: 12, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              'Scoped to ${viewModel.userAssignedLocationName}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      AdminFilterChip(
                        label: 'All Customers (HQ)',
                        isSelected: viewModel.selectedLocationFilter == 'all',
                        onTap: () => viewModel.setSelectedLocationFilter('all'),
                      ),
                      ...viewModel.locations.map((loc) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: AdminFilterChip(
                            label: '${loc.name} Hub',
                            isSelected:
                                viewModel.selectedLocationFilter == loc.id,
                            onTap: () =>
                                viewModel.setSelectedLocationFilter(loc.id),
                          ),
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: AdminFilterChip(
                          label: viewModel.unassignedCustomersCount > 0
                              ? '⚠️ Unassigned (${viewModel.unassignedCustomersCount})'
                              : 'Unassigned',
                          isSelected:
                              viewModel.selectedLocationFilter == 'unassigned',
                          onTap: () =>
                              viewModel.setSelectedLocationFilter('unassigned'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Ledger Table
          AdminDataTable(
            columns: const [
              'Client Name',
              'Hub Location',
              'Account Type',
              'Contact Phone',
              'Orders Count',
              'Total Spent',
              'Outstanding Due',
              'Action'
            ],
            rows: viewModel.filteredCustomers.map((customer) {
              final hasDue = customer.outstandingDue > 0;
              final hasLocation = customer.locationName != null &&
                  customer.locationName!.isNotEmpty;

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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: hasLocation
                        ? InkWell(
                            onTap: () => _showAssignLocationDialog(
                                context, viewModel, customer),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AdminColors.primaryGreen
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: AdminColors.primaryGreen
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on,
                                      size: 13,
                                      color: AdminColors.primaryGreen),
                                  const SizedBox(width: 4),
                                  Text(
                                    customer.locationName!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AdminColors.primaryGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_drop_down,
                                      size: 14, color: Colors.white54),
                                ],
                              ),
                            ),
                          )
                        : OutlinedButton.icon(
                            onPressed: () => _showAssignLocationDialog(
                                context, viewModel, customer),
                            icon: const Icon(Icons.add_location_alt,
                                size: 12, color: Colors.amber),
                            label: const Text(
                              '+ Add Hub',
                              style:
                                  TextStyle(fontSize: 11, color: Colors.amber),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Colors.amber.withValues(alpha: 0.5)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
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
    String? selectedLocationId = customer?.locationId;
    if (selectedLocationId == null && customer?.locationName != null) {
      final match = viewModel.locations
          .where((l) => l.name.toLowerCase() == customer!.locationName!.toLowerCase());
      if (match.isNotEmpty) selectedLocationId = match.first.id;
    }

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AdminColors.panelBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          if (val != null) setState(() => selectedType = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedLocationId,
                        dropdownColor: AdminColors.panelBackground,
                        decoration: const InputDecoration(
                          labelText: 'Assigned Branch / Hub',
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(color: AdminColors.textPrimary),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Unassigned (HQ)'),
                          ),
                          ...viewModel.locations.map((loc) {
                            return DropdownMenuItem<String>(
                              value: loc.id,
                              child: Text('${loc.name} Hub'),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setState(() => selectedLocationId = val);
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
                      String? locName;
                      if (selectedLocationId != null) {
                        final match = viewModel.locations
                            .where((l) => l.id == selectedLocationId);
                        if (match.isNotEmpty) locName = match.first.name;
                      }

                      if (customer == null) {
                        viewModel.addCustomer(
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          phone: phoneController.text.trim(),
                          type: selectedType,
                          outstandingDue: due,
                          locationId: selectedLocationId,
                          locationName: locName,
                        );
                      } else {
                        viewModel.updateCustomer(
                          customer,
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          phone: phoneController.text.trim(),
                          type: selectedType,
                          outstandingDue: due,
                          locationId: selectedLocationId,
                          locationName: locName,
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
      },
    );
  }

  void _showAssignLocationDialog(
    BuildContext context,
    AdminCustomersViewModel viewModel,
    AdminCustomerModel customer,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AdminColors.panelBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(Icons.location_on, color: AdminColors.primaryGreen, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Assign Hub for ${customer.name}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer: ${customer.name} (${customer.phone})',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      if (customer.locationName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Current Hub: ${customer.locationName}',
                          style: TextStyle(
                              fontSize: 11,
                              color: AdminColors.primaryGreen,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Serving Branch Hub:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (viewModel.locations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'No locations registered in system. Please create locations in Locations Management.',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: viewModel.locations.length,
                      separatorBuilder: (_, __) => const Divider(height: 8),
                      itemBuilder: (context, index) {
                        final loc = viewModel.locations[index];
                        final isCurrent = customer.locationId == loc.id ||
                            customer.locationName?.toLowerCase() ==
                                loc.name.toLowerCase();
                        return ListTile(
                          dense: true,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          tileColor: isCurrent
                              ? AdminColors.primaryGreen.withValues(alpha: 0.15)
                              : Colors.transparent,
                          leading: Icon(
                            Icons.storefront_outlined,
                            size: 18,
                            color: isCurrent
                                ? AdminColors.primaryGreen
                                : Colors.white70,
                          ),
                          title: Text(
                            '${loc.name} Hub',
                            style: TextStyle(
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isCurrent
                                  ? AdminColors.primaryGreen
                                  : Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            'Coverage: ${loc.radiusDisplay}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white54),
                          ),
                          trailing: isCurrent
                              ? Icon(Icons.check_circle,
                                  color: AdminColors.primaryGreen, size: 18)
                              : null,
                          onTap: () {
                            Navigator.of(ctx).pop();
                            viewModel.assignCustomerLocation(customer, loc);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Customer ${customer.name} assigned to ${loc.name} Hub'),
                                backgroundColor: AdminColors.primaryGreen,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            if (customer.locationId != null || customer.locationName != null)
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  viewModel.assignCustomerLocation(customer, null);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Customer ${customer.name} location cleared (Unassigned)'),
                      backgroundColor: Colors.grey[800],
                    ),
                  );
                },
                child: const Text('Clear Hub',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
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
