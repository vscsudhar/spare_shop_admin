import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_supplier_form_viewmodel.dart';

class AdminSupplierFormView extends StackedView<AdminSupplierFormViewModel> {
  final String? supplierId;

  const AdminSupplierFormView({
    Key? key,
    this.supplierId,
  }) : super(key: key);

  @override
  void onViewModelReady(AdminSupplierFormViewModel viewModel) {
    viewModel.init(supplierId);
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    AdminSupplierFormViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: viewModel.isEditMode
          ? 'Modify Supplier Profile'
          : 'Onboard New Supplier',
      selectedItem: AdminNavigationItem.suppliers,
      child: Form(
        key: viewModel.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: viewModel.goBack,
                ),
                Text(
                  viewModel.isEditMode
                      ? 'Modify Partner Information'
                      : 'Onboard Partner Company',
                  style: AdminTextStyles.sectionHeader,
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Main form fields
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Basic Profile Card
                      AdminPanelCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Corporate Profile Details',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.grey)),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: viewModel.companyNameController,
                              decoration: const InputDecoration(
                                  labelText: 'Company/Entity Name *',
                                  border: OutlineInputBorder()),
                              validator: (val) =>
                                  val == null || val.trim().isEmpty
                                      ? 'Company name is required'
                                      : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller:
                                        viewModel.contactPersonController,
                                    decoration: const InputDecoration(
                                        labelText: 'Contact Person Name *',
                                        border: OutlineInputBorder()),
                                    validator: (val) =>
                                        val == null || val.trim().isEmpty
                                            ? 'Contact person is required'
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: viewModel.gstNumberController,
                                    decoration: const InputDecoration(
                                        labelText: 'GSTIN Number *',
                                        border: OutlineInputBorder()),
                                    validator: (val) =>
                                        val == null || val.trim().isEmpty
                                            ? 'GSTIN is required'
                                            : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: viewModel.phoneController,
                                    decoration: const InputDecoration(
                                        labelText: 'Primary Phone *',
                                        border: OutlineInputBorder()),
                                    validator: (val) =>
                                        val == null || val.trim().isEmpty
                                            ? 'Phone is required'
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: viewModel.emailController,
                                    decoration: const InputDecoration(
                                        labelText: 'Corporate Email *',
                                        border: OutlineInputBorder()),
                                    validator: (val) =>
                                        val == null || val.trim().isEmpty
                                            ? 'Email is required'
                                            : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Location details
                      AdminPanelCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Office & Location Address',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.grey)),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: viewModel.addressController,
                              decoration: const InputDecoration(
                                  labelText: 'Street Address Line *',
                                  border: OutlineInputBorder()),
                              validator: (val) =>
                                  val == null || val.trim().isEmpty
                                      ? 'Address is required'
                                      : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: viewModel.cityController,
                                    decoration: const InputDecoration(
                                        labelText: 'City *',
                                        border: OutlineInputBorder()),
                                    validator: (val) =>
                                        val == null || val.trim().isEmpty
                                            ? 'City is required'
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: viewModel.stateController,
                                    decoration: const InputDecoration(
                                        labelText: 'State *',
                                        border: OutlineInputBorder()),
                                    validator: (val) =>
                                        val == null || val.trim().isEmpty
                                            ? 'State is required'
                                            : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),

                // Right Column: Supplies categories, checkboxes
                Expanded(
                  child: Column(
                    children: [
                      // Status card
                      AdminPanelCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Partnership Logistics Scope',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.grey)),
                            const SizedBox(height: 12),
                            CheckboxListTile(
                              title: const Text('Supplies EV Parts',
                                  style: TextStyle(fontSize: 13)),
                              value: viewModel.suppliesEv,
                              onChanged: viewModel.toggleEv,
                              activeColor: AdminColors.primaryGreen,
                              contentPadding: EdgeInsets.zero,
                            ),
                            CheckboxListTile(
                              title: const Text('Supplies Petrol Parts',
                                  style: TextStyle(fontSize: 13)),
                              value: viewModel.suppliesPetrol,
                              onChanged: viewModel.togglePetrol,
                              activeColor: AdminColors.primaryGreen,
                              contentPadding: EdgeInsets.zero,
                            ),
                            CheckboxListTile(
                              title: const Text('Is Active Partner',
                                  style: TextStyle(fontSize: 13)),
                              value: viewModel.isActive,
                              onChanged: viewModel.toggleActive,
                              activeColor: AdminColors.primaryGreen,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Multi select categories
                      AdminPanelCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Select Categories Supplied',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.grey)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                'Batteries',
                                'Power Hubs',
                                'EV Motors',
                                'Piston Kits',
                                'Carburetors',
                                'Clutch Plates',
                                'Wiring Harness',
                                'Brake Shoes',
                                'Filters',
                                'Sensors'
                              ].map((cat) {
                                final isSelected =
                                    viewModel.selectedCategories.contains(cat);
                                return FilterChip(
                                  label: Text(cat,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: isSelected
                                              ? Colors.white
                                              : AdminColors.textPrimary)),
                                  selected: isSelected,
                                  selectedColor: AdminColors.primaryGreen,
                                  onSelected: (_) =>
                                      viewModel.toggleCategory(cat),
                                  backgroundColor: AdminColors.isDarkTheme
                                      ? Colors.white10
                                      : Colors.black12.withValues(alpha: 0.04),
                                );
                              }).toList(),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Submit Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: viewModel.goBack,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AdminColors.border),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                  child: Text('Cancel',
                      style: TextStyle(color: AdminColors.textPrimary)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: viewModel.saveSupplier,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(viewModel.isEditMode
                      ? 'Save Profile Changes'
                      : 'Onboard Partner'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  AdminSupplierFormViewModel viewModelBuilder(BuildContext context) =>
      AdminSupplierFormViewModel();
}
