import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_location_map_picker.dart';
import 'package:stacked/stacked.dart';

import 'admin_location_form_viewmodel.dart';

class AdminLocationFormView extends StackedView<AdminLocationFormViewModel> {
  final String? locationId;

  const AdminLocationFormView({
    Key? key,
    this.locationId,
  }) : super(key: key);

  @override
  void onViewModelReady(AdminLocationFormViewModel viewModel) {
    viewModel.init(locationId);
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    AdminLocationFormViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: viewModel.isEditMode ? 'Edit Location' : 'Add Location',
      selectedItem: AdminNavigationItem.locations,
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
                const SizedBox(width: 8),
                Text(
                  viewModel.isEditMode
                      ? 'Edit Service Location'
                      : 'Create New Service Location',
                  style: AdminTextStyles.sectionHeader,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (viewModel.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: AdminPanelCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location & Service Boundary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select the location pin directly on the interactive OpenStreetMap. Coordinates and service coverage area are automatically synchronized.',
                        style: TextStyle(
                          color: AdminColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Location Name Field
                      TextFormField(
                        controller: viewModel.nameController,
                        decoration: const InputDecoration(
                          labelText: 'Location Name *',
                          hintText: 'e.g. Madukkarai, Eachanari, Kuniyamuthur',
                          prefixIcon: Icon(Icons.location_city_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: viewModel.validateName,
                      ),
                      const SizedBox(height: 24),

                      // Section Header for Map Selection
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.map_rounded,
                                  size: 18, color: AdminColors.primaryGreen),
                              const SizedBox(width: 8),
                              const Text(
                                'Pinpoint Location on OpenStreetMap *',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AdminColors.primaryGreen
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Interactive Map',
                              style: TextStyle(
                                color: AdminColors.primaryGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Interactive OpenStreetMap Location Picker
                      if (viewModel.isBusy)
                        Container(
                          height: 420,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.grey.shade50,
                          ),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        )
                      else
                        AdminLocationMapPicker(
                          initialLatitude: viewModel.selectedLatitude ??
                              AdminLocationFormViewModel.defaultLat,
                          initialLongitude: viewModel.selectedLongitude ??
                              AdminLocationFormViewModel.defaultLng,
                          radiusKm: viewModel.radiusKm,
                          onLocationChanged: (lat, lng, {placeName}) =>
                              viewModel.updateCoordinates(lat, lng,
                                  placeName: placeName),
                        ),
                      const SizedBox(height: 16),

                      // Read-Only Auto-Synced Coordinates Display Cards
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: AdminColors.isDarkTheme
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AdminColors.isDarkTheme
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.my_location_rounded,
                                      size: 20, color: AdminColors.primaryGreen),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Latitude (Read-Only)',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AdminColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          viewModel.selectedLatitude != null
                                              ? viewModel.selectedLatitude!
                                                  .toStringAsFixed(6)
                                              : 'Not selected',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.lock_outline_rounded,
                                      size: 16, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: AdminColors.isDarkTheme
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AdminColors.isDarkTheme
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.explore_outlined,
                                      size: 20, color: AdminColors.primaryGreen),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Longitude (Read-Only)',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AdminColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          viewModel.selectedLongitude != null
                                              ? viewModel.selectedLongitude!
                                                  .toStringAsFixed(6)
                                              : 'Not selected',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.lock_outline_rounded,
                                      size: 16, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Coverage Radius Field
                      TextFormField(
                        controller: viewModel.radiusController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Coverage Radius (KM) *',
                          hintText: '20',
                          suffixText: 'KM',
                          helperText:
                              'Service delivery radius around the selected coordinate point (green circle on map)',
                          prefixIcon: Icon(Icons.radar_rounded),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: viewModel.updateRadius,
                        validator: viewModel.validateRadius,
                      ),
                      const SizedBox(height: 20),

                      // Active Status Switch Card
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AdminColors.isDarkTheme
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AdminColors.border),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Location Status',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            viewModel.isActive
                                ? 'Active — Service area is operational and discoverable'
                                : 'Inactive — Temporarily disabled for operations',
                            style: TextStyle(
                              fontSize: 12,
                              color: AdminColors.textSecondary,
                            ),
                          ),
                          value: viewModel.isActive,
                          activeThumbColor: AdminColors.primaryGreen,
                          onChanged: viewModel.toggleActive,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: viewModel.goBack,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: viewModel.isBusy
                                ? null
                                : () async {
                                    final success =
                                        await viewModel.saveLocation();
                                    if (success && context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            viewModel.isEditMode
                                                ? 'Location updated successfully!'
                                                : 'Location created successfully!',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  },
                            icon: viewModel.isBusy
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.check, size: 18),
                            label: Text(
                              viewModel.isEditMode
                                  ? 'Update Location'
                                  : 'Save Location',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdminColors.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  AdminLocationFormViewModel viewModelBuilder(BuildContext context) =>
      AdminLocationFormViewModel();
}
