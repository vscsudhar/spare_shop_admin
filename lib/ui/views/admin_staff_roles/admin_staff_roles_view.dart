import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_staff_roles_viewmodel.dart';

class AdminStaffRolesView extends StackedView<AdminStaffRolesViewModel> {
  const AdminStaffRolesView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminStaffRolesViewModel viewModel,
    Widget? child,
  ) {
    final bool isOwner = viewModel.isOwner;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= AdminBreakpoints.tablet;

    return AdminShell(
      title: 'Console Staff & Location Roles',
      selectedItem: AdminNavigationItem.staffRoles,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Staff & Role Management',
                      style:
                          AdminTextStyles.sectionHeader.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage staff members, location assignments, and role-based permissions.',
                      style: AdminTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      if (!isOwner) {
                        _showOwnerAlert(context);
                      } else {
                        _showCreateRoleDialog(context, viewModel);
                      }
                    },
                    icon: const Icon(Icons.admin_panel_settings_outlined,
                        size: 16),
                    label: const Text('Create Role'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AdminColors.border),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (!isOwner) {
                        _showOwnerAlert(context);
                      } else {
                        _showInviteStaffDialog(context, viewModel);
                      }
                    },
                    icon: const Icon(Icons.person_add_alt_1, size: 16),
                    label: const Text('Invite Staff Member'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Summary Metrics Cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _metricCard(
                'Total Staff Members',
                '${viewModel.totalStaffCount}',
                Icons.people_alt_outlined,
                Colors.blue,
              ),
              _metricCard(
                'Active On Duty',
                '${viewModel.activeStaffCount}',
                Icons.check_circle_outline,
                AdminColors.primaryGreen,
              ),
              _metricCard(
                'Locations Covered',
                '${viewModel.totalLocationsCovered} Hubs',
                Icons.location_on_outlined,
                Colors.indigo,
              ),
              _metricCard(
                'On Leave / Inactive',
                '${viewModel.onLeaveStaffCount}',
                Icons.pause_circle_outline,
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Navigation Tabs (Team Roster vs Roles Matrix)
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AdminColors.border)),
            ),
            child: Row(
              children: [
                _tabButton(
                  title: 'Team Directory & Roster',
                  badgeCount: viewModel.filteredTeamMembers.length,
                  isSelected: viewModel.selectedTab == 0,
                  onTap: () => viewModel.setSelectedTab(0),
                ),
                const SizedBox(width: 8),
                _tabButton(
                  title: 'Location Roles & Permissions',
                  badgeCount: viewModel.roles.length,
                  isSelected: viewModel.selectedTab == 1,
                  onTap: () => viewModel.setSelectedTab(1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tab 0: Team Directory Content
          if (viewModel.selectedTab == 0) ...[
            // Filter and Search Header
            AdminPanelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Search field
                      Expanded(
                        child: TextField(
                          onChanged: viewModel.setSearchQuery,
                          decoration: InputDecoration(
                            hintText:
                                'Search staff by name, email, phone, role, or location...',
                            prefixIcon: const Icon(Icons.search),
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Location Filter Dropdown
                      if (viewModel.canChangeLocation)
                        Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AdminColors.panelBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AdminColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: viewModel.selectedLocationFilter,
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  size: 18),
                              style: TextStyle(
                                fontSize: 13,
                                color: AdminColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: 'All',
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.public,
                                          size: 16, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text('All Locations'),
                                    ],
                                  ),
                                ),
                                const DropdownMenuItem(
                                  value: 'all_hq',
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.business,
                                          size: 16, color: Colors.grey),
                                      SizedBox(width: 8),
                                      Text('Headquarters (HQ) Only'),
                                    ],
                                  ),
                                ),
                                ...viewModel.locations.map((loc) {
                                  return DropdownMenuItem(
                                    value: loc.id,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: loc.isActive
                                              ? AdminColors.primaryGreen
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(loc.name),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  viewModel.setSelectedLocationFilter(val);
                                }
                              },
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AdminColors.panelBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AdminColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on,
                                  size: 16, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                viewModel.locations
                                        .where((l) =>
                                            l.id ==
                                            viewModel.selectedLocationFilter)
                                        .map((l) => l.name)
                                        .firstOrNull ??
                                    'Assigned Hub',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AdminColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.lock_outline,
                                  size: 14, color: Colors.grey),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Role Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text(
                          'Role Filter: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        ...[
                          'All',
                          'Owner',
                          'Manager',
                          'Inventory',
                          'Sales',
                          'Delivery',
                        ].map((role) {
                          final isSelected =
                              viewModel.selectedRoleFilter == role;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(
                                role == 'All' ? 'All Roles' : '$role Staff',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : AdminColors.textPrimary,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) =>
                                  viewModel.setSelectedRoleFilter(role),
                              selectedColor: AdminColors.primaryGreen,
                              backgroundColor: AdminColors.isDarkTheme
                                  ? Colors.white10
                                  : Colors.black12.withValues(alpha: 0.04),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Team Roster Table
            if (viewModel.filteredTeamMembers.isEmpty)
              AdminEmptyState(
                message: viewModel.searchQuery.isNotEmpty ||
                        viewModel.selectedLocationFilter != 'All'
                    ? 'No staff members match the selected filters.'
                    : 'No staff members registered yet.\nClick "+ Invite Staff Member" to add one.',
                icon: Icons.person_off_outlined,
              )
            else if (isDesktop)
              _buildStaffTable(context, viewModel, isOwner)
            else
              _buildStaffCardsList(context, viewModel, isOwner),
          ] else ...[
            // Tab 1: Roles Matrix Content
            _buildRolesMatrix(context, viewModel, isOwner),
          ],
        ],
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required int badgeCount,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AdminColors.primaryGreen : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AdminColors.primaryGreen
                    : AdminColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AdminColors.primaryGreen.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$badgeCount',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? AdminColors.primaryGreen
                      : AdminColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(String title, String val, IconData icon, Color color) {
    return Container(
      width: 250,
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

  Widget _buildStaffTable(
    BuildContext context,
    AdminStaffRolesViewModel viewModel,
    bool isOwner,
  ) {
    return AdminPanelCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth:
                    constraints.maxWidth > 950 ? constraints.maxWidth : 950,
              ),
              child: DataTable(
                columnSpacing: 24,
                horizontalMargin: 12,
                columns: const [
                  DataColumn(label: Text('Staff Member')),
                  DataColumn(label: Text('Assigned Role')),
                  DataColumn(label: Text('Branch / Location Hub')),
                  DataColumn(label: Text('Contact Phone')),
                  DataColumn(label: Text('Shift Hours')),
                  DataColumn(label: Text('Roster Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: viewModel.filteredTeamMembers.map((member) {
                  return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            AdminColors.primaryGreen.withValues(alpha: 0.15),
                        child: Text(
                          member.name.isNotEmpty
                              ? member.name[0].toUpperCase()
                              : 'S',
                          style: TextStyle(
                            color: AdminColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          if (member.email.isNotEmpty)
                            Text(
                              member.email,
                              style: TextStyle(
                                fontSize: 11,
                                color: AdminColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border:
                          Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      member.role,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        member.isLocationBound
                            ? Icons.location_on
                            : Icons.public,
                        size: 14,
                        color: member.isLocationBound
                            ? AdminColors.primaryGreen
                            : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        member.locationName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: member.isLocationBound
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: member.isLocationBound
                              ? AdminColors.textPrimary
                              : AdminColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    member.phone,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    member.shift,
                    style: TextStyle(
                        fontSize: 12, color: AdminColors.textSecondary),
                  ),
                ),
                DataCell(
                  Align(
                    alignment: Alignment.centerLeft,
                    child: isOwner
                        ? DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: member.status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(member.status),
                              ),
                              onChanged: (String? val) {
                                if (val != null) {
                                  viewModel.updateStaffStatus(
                                    id: member.id,
                                    status: val,
                                  );
                                }
                              },
                              items: const [
                                DropdownMenuItem(
                                    value: 'Active', child: Text('Active')),
                                DropdownMenuItem(
                                    value: 'On Leave', child: Text('On Leave')),
                                DropdownMenuItem(
                                    value: 'Inactive', child: Text('Inactive')),
                              ],
                            ),
                          )
                        : AdminStatusChip(
                            label: member.status,
                            color: _getStatusColor(member.status),
                          ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.key_outlined,
                            size: 18, color: AdminColors.primaryGreen),
                        tooltip: 'View Login Credentials',
                        onPressed: () => _showStaffCredentialsDialog(
                            context, viewModel, member),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        tooltip: 'Edit Staff',
                        onPressed: () {
                          if (!isOwner) {
                            _showOwnerAlert(context);
                          } else {
                            _showEditStaffDialog(context, viewModel, member);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: Colors.red),
                        tooltip: 'Remove Staff',
                        onPressed: () {
                          if (!isOwner) {
                            _showOwnerAlert(context);
                          } else {
                            _confirmDeleteStaff(context, viewModel, member);
                          }
                        },
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

  Widget _buildStaffCardsList(
    BuildContext context,
    AdminStaffRolesViewModel viewModel,
    bool isOwner,
  ) {
    return Column(
      children: viewModel.filteredTeamMembers.map((member) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: AdminPanelCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor:
                    AdminColors.primaryGreen.withValues(alpha: 0.15),
                child: Text(
                  member.name.isNotEmpty ? member.name[0].toUpperCase() : 'S',
                  style: TextStyle(
                    color: AdminColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(member.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Role: ${member.role}'),
                  Row(
                    children: [
                      Icon(
                        member.isLocationBound
                            ? Icons.location_on
                            : Icons.public,
                        size: 13,
                        color: member.isLocationBound
                            ? AdminColors.primaryGreen
                            : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text('Hub: ${member.locationName}'),
                    ],
                  ),
                  Text('Phone: ${member.phone} | Shift: ${member.shift}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminStatusChip(
                    label: member.status,
                    color: _getStatusColor(member.status),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.key_outlined,
                        size: 18, color: AdminColors.primaryGreen),
                    tooltip: 'Login Credentials',
                    onPressed: () =>
                        _showStaffCredentialsDialog(context, viewModel, member),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () {
                      if (!isOwner) {
                        _showOwnerAlert(context);
                      } else {
                        _showEditStaffDialog(context, viewModel, member);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: Colors.red),
                    onPressed: () {
                      if (!isOwner) {
                        _showOwnerAlert(context);
                      } else {
                        _confirmDeleteStaff(context, viewModel, member);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRolesMatrix(
    BuildContext context,
    AdminStaffRolesViewModel viewModel,
    bool isOwner,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Defined Role Permissions & Location Scope',
              style: AdminTextStyles.sectionHeader.copyWith(fontSize: 16),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (!isOwner) {
                  _showOwnerAlert(context);
                } else {
                  _showCreateRoleDialog(context, viewModel);
                }
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Role'),
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
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.roles.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWide ? 2 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isWide ? 1.6 : 1.3,
              ),
              itemBuilder: (context, index) {
                final role = viewModel.roles[index];
                final assignedStaffCount = viewModel.teamMembers
                    .where((m) =>
                        m.role.toLowerCase() == role.roleName.toLowerCase())
                    .length;

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AdminColors.panelBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AdminColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              role.roleName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: role.isLocationScoped
                                  ? Colors.indigo.withValues(alpha: 0.1)
                                  : AdminColors.primaryGreen
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  role.isLocationScoped
                                      ? Icons.location_on
                                      : Icons.public,
                                  size: 12,
                                  color: role.isLocationScoped
                                      ? Colors.indigo
                                      : AdminColors.primaryGreen,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  role.isLocationScoped
                                      ? 'Location-Bound'
                                      : 'Global Access',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: role.isLocationScoped
                                        ? Colors.indigo
                                        : AdminColors.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        role.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AdminColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$assignedStaffCount Staff Assigned',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Wrap(
                            spacing: 4,
                            children: role.permissions.take(2).map((perm) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  perm,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return AdminColors.success;
      case 'On Leave':
        return Colors.orange;
      case 'Inactive':
      default:
        return AdminColors.cancelled;
    }
  }

  void _showOwnerAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Access Denied'),
          ],
        ),
        content: const Text(
          'Only the Owner / Admin is authorized to perform staff/role management operations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showInviteStaffDialog(
    BuildContext context,
    AdminStaffRolesViewModel viewModel,
  ) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController(text: 'Staff12345!');
    final phoneController = TextEditingController();
    final shiftController = TextEditingController(text: '09:00 AM - 06:00 PM');
    String selectedRole = viewModel.roles.length > 1
        ? viewModel.roles[1].roleName
        : 'Inventory Specialist';
    String? selectedLocationId =
        !viewModel.canChangeLocation && viewModel.userAssignedLocationId != null
            ? viewModel.userAssignedLocationId
            : (viewModel.locations.isNotEmpty
                ? viewModel.locations.first.id
                : null);
    bool obscurePassword = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.person_add_alt_1,
                      color: AdminColors.primaryGreen, size: 22),
                  const SizedBox(width: 8),
                  const Text('Invite / Add Staff Member'),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              AdminColors.primaryGreen.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AdminColors.primaryGreen
                                  .withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.vpn_key_outlined,
                                color: AdminColors.primaryGreen, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Email and password are used as login credentials for this staff member. Their console access will be scoped to the assigned Location Hub.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AdminColors.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Staff Full Name *',
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Login Email Address *',
                          prefixIcon: Icon(Icons.email_outlined, size: 20),
                          helperText:
                              'Used as username to log into the console',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Login Password *',
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          helperText: 'Initial password for first login',
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Contact Phone Number',
                          prefixIcon: Icon(Icons.phone_outlined, size: 20),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Assigned Role *',
                          prefixIcon: Icon(Icons.badge_outlined, size: 20),
                          border: OutlineInputBorder(),
                        ),
                        items: viewModel.roles.map((r) {
                          return DropdownMenuItem(
                            value: r.roleName,
                            child: Row(
                              children: [
                                Text(r.roleName),
                                const SizedBox(width: 6),
                                if (r.isLocationScoped)
                                  const Text(
                                    '(Location Scoped)',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedRole = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      if (viewModel.canChangeLocation)
                        DropdownButtonFormField<String?>(
                          initialValue: selectedLocationId,
                          decoration: const InputDecoration(
                            labelText: 'Assigned Branch / Location Hub *',
                            prefixIcon:
                                Icon(Icons.location_on_outlined, size: 20),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 'all',
                              child: Row(
                                children: [
                                  Icon(Icons.public,
                                      size: 16, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('All Locations (Global HQ)'),
                                ],
                              ),
                            ),
                            ...viewModel.locations.map((loc) {
                              return DropdownMenuItem(
                                value: loc.id,
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        size: 16,
                                        color: AdminColors.primaryGreen),
                                    const SizedBox(width: 8),
                                    Text('${loc.name} (${loc.radiusDisplay})'),
                                  ],
                                ),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setDialogState(() => selectedLocationId = val);
                          },
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: AdminColors.panelBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AdminColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 20, color: Colors.blue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Assigned Branch / Location Hub (Locked)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AdminColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      viewModel.locations
                                              .where((l) =>
                                                  l.id == selectedLocationId)
                                              .map((l) => l.name)
                                              .firstOrNull ??
                                          'Assigned Branch Hub',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AdminColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.lock_outline,
                                  size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: shiftController,
                        decoration: const InputDecoration(
                          labelText: 'Shift Hours',
                          prefixIcon: Icon(Icons.access_time, size: 20),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    final pass = passwordController.text.trim();
                    if (name.isNotEmpty && email.isNotEmpty) {
                      await viewModel.inviteStaff(
                        name: name,
                        email: email,
                        password: pass,
                        role: selectedRole,
                        shift: shiftController.text.trim(),
                        phone: phoneController.text.trim(),
                        locationId: selectedLocationId,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Staff member "$name" added with login credentials.'),
                            backgroundColor: AdminColors.primaryGreen,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Staff Member'),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showEditStaffDialog(
    BuildContext context,
    AdminStaffRolesViewModel viewModel,
    StaffMemberModel member,
  ) {
    final nameController = TextEditingController(text: member.name);
    final emailController = TextEditingController(text: member.email);
    final passwordController = TextEditingController(text: member.password);
    final phoneController = TextEditingController(text: member.phone);
    final shiftController = TextEditingController(text: member.shift);
    String selectedRole = member.role;
    String? selectedLocationId = member.locationId ?? 'all';
    bool obscurePassword = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.edit_outlined,
                      color: AdminColors.primaryGreen, size: 22),
                  const SizedBox(width: 8),
                  Text('Edit Staff & Credentials: ${member.name}'),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              AdminColors.primaryGreen.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AdminColors.primaryGreen
                                  .withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.security,
                                color: AdminColors.primaryGreen, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Update login credentials or branch location assignment. The new email and password can be used to log in immediately.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AdminColors.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Staff Name *',
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Login Email Address *',
                          prefixIcon: Icon(Icons.email_outlined, size: 20),
                          helperText: 'Username used to sign into the console',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Login Password *',
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          helperText:
                              'Update login password (visible for direct verification)',
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone_outlined, size: 20),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: viewModel.roles
                                .any((r) => r.roleName == selectedRole)
                            ? selectedRole
                            : viewModel.roles.first.roleName,
                        decoration: const InputDecoration(
                          labelText: 'Assigned Role',
                          prefixIcon: Icon(Icons.badge_outlined, size: 20),
                          border: OutlineInputBorder(),
                        ),
                        items: viewModel.roles.map((r) {
                          return DropdownMenuItem(
                            value: r.roleName,
                            child: Text(r.roleName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedRole = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      if (viewModel.canChangeLocation)
                        DropdownButtonFormField<String?>(
                          initialValue: selectedLocationId,
                          decoration: const InputDecoration(
                            labelText: 'Assigned Branch / Location Hub',
                            prefixIcon:
                                Icon(Icons.location_on_outlined, size: 20),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 'all',
                              child: Row(
                                children: [
                                  Icon(Icons.public,
                                      size: 16, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('All Locations (Global HQ)'),
                                ],
                              ),
                            ),
                            ...viewModel.locations.map((loc) {
                              return DropdownMenuItem(
                                value: loc.id,
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        size: 16,
                                        color: AdminColors.primaryGreen),
                                    const SizedBox(width: 8),
                                    Text('${loc.name} (${loc.radiusDisplay})'),
                                  ],
                                ),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setDialogState(() => selectedLocationId = val);
                          },
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: AdminColors.panelBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AdminColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 20, color: Colors.blue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Assigned Branch / Location Hub (Locked)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AdminColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      member.locationName.isNotEmpty
                                          ? member.locationName
                                          : (viewModel.locations
                                                  .where((l) =>
                                                      l.id ==
                                                      selectedLocationId)
                                                  .map((l) => l.name)
                                                  .firstOrNull ??
                                              'Assigned Branch Hub'),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AdminColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.lock_outline,
                                  size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: shiftController,
                        decoration: const InputDecoration(
                          labelText: 'Shift Hours',
                          prefixIcon: Icon(Icons.access_time, size: 20),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();
                    if (name.isNotEmpty && email.isNotEmpty) {
                      await viewModel.updateStaff(
                        id: member.id,
                        name: name,
                        email: email,
                        password: password.isNotEmpty ? password : null,
                        role: selectedRole,
                        shift: shiftController.text.trim(),
                        phone: phoneController.text.trim(),
                        locationId: selectedLocationId,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Staff member "$name" credentials updated successfully.'),
                            backgroundColor: AdminColors.primaryGreen,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Changes'),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showStaffCredentialsDialog(
    BuildContext context,
    AdminStaffRolesViewModel viewModel,
    StaffMemberModel member,
  ) {
    final currentMember = viewModel.teamMembers.firstWhere(
      (m) => m.id == member.id,
      orElse: () => member,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.key, color: AdminColors.primaryGreen, size: 22),
              const SizedBox(width: 8),
              Text('Login Credentials: ${currentMember.name}'),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AdminColors.panelBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AdminColors.border),
                  ),
                  child: Column(
                    children: [
                      _credentialRow(
                          'Login Email:',
                          currentMember.email.isNotEmpty
                              ? currentMember.email
                              : 'No email set',
                          Icons.email_outlined),
                      const Divider(height: 16),
                      _credentialRow('Password:', currentMember.password,
                          Icons.lock_outline),
                      const Divider(height: 16),
                      _credentialRow(
                          'Role:', currentMember.role, Icons.badge_outlined),
                      const Divider(height: 16),
                      _credentialRow(
                          'Assigned Location:',
                          currentMember.locationName,
                          Icons.location_on_outlined),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AdminColors.primaryGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: AdminColors.primaryGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Use the email and password above to sign into the admin console. Access will be scoped to ${currentMember.locationName}.',
                          style: TextStyle(
                              fontSize: 12,
                              color: AdminColors.textPrimary,
                              height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (viewModel.isOwner)
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showEditStaffDialog(context, viewModel, currentMember);
                },
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: const Text('Edit Credentials'),
              ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _credentialRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AdminColors.primaryGreen),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
        const Spacer(),
        SelectableText(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  void _showCreateRoleDialog(
    BuildContext context,
    AdminStaffRolesViewModel viewModel,
  ) {
    final roleNameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isLocationScoped = true;
    final selectedPermissions = <String>{'inventory.read', 'orders.read'};

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create New Staff Role'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: roleNameController,
                        decoration: const InputDecoration(
                          labelText: 'Role Title *',
                          hintText: 'e.g. Hub Dispatch Lead',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText:
                              'Describe responsibilities for this role...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Location-Scoped Role',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: const Text(
                          'When enabled, staff with this role are restricted to operations at their assigned branch hub.',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: isLocationScoped,
                        activeThumbColor: AdminColors.primaryGreen,
                        onChanged: (val) {
                          setDialogState(() => isLocationScoped = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Permissions:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'inventory.manage',
                          'inventory.read',
                          'orders.manage',
                          'orders.read',
                          'billing.create',
                          'delivery.update',
                          'staff.view',
                        ].map((perm) {
                          final isChecked = selectedPermissions.contains(perm);
                          return FilterChip(
                            label: Text(perm,
                                style: const TextStyle(
                                    fontSize: 11, fontFamily: 'monospace')),
                            selected: isChecked,
                            selectedColor:
                                AdminColors.primaryGreen.withValues(alpha: 0.2),
                            onSelected: (selected) {
                              setDialogState(() {
                                if (selected) {
                                  selectedPermissions.add(perm);
                                } else {
                                  selectedPermissions.remove(perm);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (roleNameController.text.trim().isNotEmpty) {
                      viewModel.createRole(
                        roleName: roleNameController.text.trim(),
                        description: descriptionController.text.trim(),
                        isLocationScoped: isLocationScoped,
                        permissions: selectedPermissions.toList(),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create Role'),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteStaff(
    BuildContext context,
    AdminStaffRolesViewModel viewModel,
    StaffMemberModel member,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Staff Member'),
        content: Text(
            'Are you sure you want to remove ${member.name} (${member.role}) from the roster?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await viewModel.deleteStaff(member.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Staff member "${member.name}" removed.'),
                    backgroundColor: Colors.red.shade700,
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
  AdminStaffRolesViewModel viewModelBuilder(BuildContext context) =>
      AdminStaffRolesViewModel();
}
