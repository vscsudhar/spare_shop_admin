import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_locations_viewmodel.dart';

class AdminLocationsView extends StackedView<AdminLocationsViewModel> {
  const AdminLocationsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminLocationsViewModel viewModel,
    Widget? child,
  ) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= AdminBreakpoints.tablet;

    return AdminShell(
      title: 'Location Management',
      selectedItem: AdminNavigationItem.locations,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics Cards Row
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _metricCard(
                'Total Locations',
                '${viewModel.totalLocations}',
                Icons.location_on_rounded,
                Colors.blue,
              ),
              _metricCard(
                'Active Locations',
                '${viewModel.activeLocations}',
                Icons.check_circle_outline,
                AdminColors.primaryGreen,
              ),
              _metricCard(
                'Inactive Locations',
                '${viewModel.inactiveLocations}',
                Icons.pause_circle_outline,
                Colors.orange,
              ),
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
                          hintText: 'Search by Location Name...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (viewModel.canChangeLocation)
                      ElevatedButton.icon(
                        onPressed: () async {
                          await viewModel.goToAdminLocationForm();
                          viewModel.loadLocations();
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Location'),
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
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                            SizedBox(width: 6),
                            Text(
                              'Fixed Location Mode',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      viewModel.statusFilter == 'All',
                      'All',
                      () => viewModel.setStatusFilter('All'),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      viewModel.statusFilter == 'Active',
                      'Active',
                      () => viewModel.setStatusFilter('Active'),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      viewModel.statusFilter == 'Inactive',
                      'Inactive',
                      () => viewModel.setStatusFilter('Inactive'),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh Locations',
                      onPressed: viewModel.loadLocations,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Content state handling
          if (viewModel.isBusy && viewModel.locations.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (viewModel.locations.isEmpty)
            const AdminEmptyState(
              message: 'No locations found. Click "+ Add Location" to create one.',
              icon: Icons.location_off_outlined,
            )
          else if (isDesktop)
            _buildLocationsTable(context, viewModel)
          else
            _buildLocationsCardsList(context, viewModel),
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
              Text(
                title,
                style: TextStyle(fontSize: 12, color: AdminColors.textSecondary),
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

  Widget _buildLocationsTable(
    BuildContext context,
    AdminLocationsViewModel viewModel,
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
                  DataColumn(label: Text('Location Name')),
                  DataColumn(label: Text('Coordinates (Lat, Lng)')),
                  DataColumn(label: Text('Coverage Radius')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: viewModel.locations.map((loc) {
                  return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: loc.isActive
                            ? AdminColors.primaryGreen
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        loc.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    loc.coordinatesDisplay,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      loc.radiusDisplay,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  AdminStatusChip(
                    label: loc.isActive ? 'Active' : 'Inactive',
                    color: loc.isActive ? AdminColors.primaryGreen : Colors.grey,
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.inventory_2_outlined, size: 16),
                        label: const Text('Inventory', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          side: BorderSide(color: AdminColors.border),
                        ),
                        onPressed: () => viewModel.goToAdminLocationInventory(
                          locationId: loc.id,
                          location: loc,
                        ),
                      ),
                      if (viewModel.canChangeLocation) ...[
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          tooltip: 'Edit Location',
                          onPressed: () async {
                            await viewModel.goToEditAdminLocation(
                              locationId: loc.id,
                            );
                            viewModel.loadLocations();
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                          tooltip: 'Delete Location',
                          onPressed: () =>
                              _confirmDelete(context, viewModel, loc),
                        ),
                      ],
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

  Widget _buildLocationsCardsList(
    BuildContext context,
    AdminLocationsViewModel viewModel,
  ) {
    return Column(
      children: viewModel.locations.map((loc) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: AdminPanelCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: loc.isActive
                    ? AdminColors.primaryGreen.withValues(alpha: 0.12)
                    : Colors.grey.withValues(alpha: 0.12),
                child: Icon(
                  Icons.location_on,
                  color: loc.isActive ? AdminColors.primaryGreen : Colors.grey,
                ),
              ),
              title: Text(
                loc.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Coordinates: ${loc.coordinatesDisplay}'),
                  Text('Radius: ${loc.radiusDisplay}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminStatusChip(
                    label: loc.isActive ? 'Active' : 'Inactive',
                    color: loc.isActive ? AdminColors.primaryGreen : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.inventory_2_outlined,
                      size: 18,
                      color: Colors.blue,
                    ),
                    tooltip: 'Manage Inventory',
                    onPressed: () => viewModel.goToAdminLocationInventory(
                      locationId: loc.id,
                      location: loc,
                    ),
                  ),
                  if (viewModel.canChangeLocation) ...[
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () async {
                        await viewModel.goToEditAdminLocation(locationId: loc.id);
                        viewModel.loadLocations();
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red,
                      ),
                      onPressed: () => _confirmDelete(context, viewModel, loc),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _confirmDelete(
    BuildContext context,
    AdminLocationsViewModel viewModel,
    LocationModel loc,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Location'),
        content: Text(
          'Are you sure you want to delete "${loc.name}"? This action cannot be undone.',
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
              final success = await viewModel.deleteLocation(loc.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Location "${loc.name}" deleted successfully'
                          : 'Failed to delete location',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  AdminLocationsViewModel viewModelBuilder(BuildContext context) =>
      AdminLocationsViewModel();
}
