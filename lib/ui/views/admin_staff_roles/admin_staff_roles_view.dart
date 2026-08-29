import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_table_widgets.dart';
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
    final bool isOwner = activeAdminRole == 'Owner / Admin';

    return AdminShell(
      title: 'Console Staff & Roles',
      selectedItem: AdminNavigationItem.staffRoles,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Console Team Members roster',
                  style: AdminTextStyles.sectionHeader),
              ElevatedButton.icon(
                onPressed: () {
                  if (!isOwner) {
                    _showOwnerAlert(context);
                  } else {
                    _showInviteStaffDialog(context, viewModel);
                  }
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Invite Staff Member'),
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

          // Role Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'All',
                'Owner',
                'Inventory',
                'Sales',
                'Delivery',
              ].map((role) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: AdminFilterChip(
                    label: role == 'All' ? 'All Roles' : '$role Staff',
                    isSelected: viewModel.selectedRoleFilter == role,
                    onTap: () => viewModel.setSelectedRoleFilter(role),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Team Roster Table
          AdminDataTable(
            columns: const [
              'Staff Name',
              'Assigned Role',
              'Contact Phone',
              'Shift Hours',
              'Roster Status',
              'Actions'
            ],
            rows: viewModel.filteredTeamMembers.map((member) {
              return AdminTableRow(
                cells: [
                  Text(member.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(member.role,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(member.phone),
                  Text(member.shift),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: isOwner
                        ? DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: member.status,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              onChanged: (String? val) {
                                if (val != null) {
                                  viewModel.updateStaffStatus(
                                      id: member.id, status: val);
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
                            color: member.status == 'Active'
                                ? AdminColors.success
                                : member.status == 'On Leave'
                                    ? AdminColors.textLight
                                    : AdminColors.cancelled,
                          ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () {
                        if (!isOwner) {
                          _showOwnerAlert(context);
                        } else {
                          _showEditStaffDialog(context, viewModel, member);
                        }
                      },
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
            'Only the Owner / Admin is authorized to perform staff/role management operations.'),
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
      BuildContext context, AdminStaffRolesViewModel viewModel) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final shiftController = TextEditingController(text: '09:00 AM - 06:00 PM');
    String selectedRole = 'Inventory Staff';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invite New Team Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Staff Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                    labelText: 'Phone Number', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: const InputDecoration(
                    labelText: 'Role', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(
                      value: 'Owner / Admin', child: Text('Owner / Admin')),
                  DropdownMenuItem(
                      value: 'Inventory Staff', child: Text('Inventory Staff')),
                  DropdownMenuItem(
                      value: 'Sales Staff', child: Text('Sales Staff')),
                  DropdownMenuItem(
                      value: 'Delivery Staff', child: Text('Delivery Staff')),
                ],
                onChanged: (val) {
                  if (val != null) selectedRole = val;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: shiftController,
                decoration: const InputDecoration(
                    labelText: 'Shift Hours', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  viewModel.inviteStaff(
                    name: nameController.text,
                    role: selectedRole,
                    shift: shiftController.text,
                    phone: phoneController.text,
                  );
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryGreen,
                  foregroundColor: Colors.white),
              child: const Text('Send Invitation'),
            )
          ],
        );
      },
    );
  }

  void _showEditStaffDialog(BuildContext context,
      AdminStaffRolesViewModel viewModel, StaffMemberModel member) {
    final nameController = TextEditingController(text: member.name);
    final phoneController = TextEditingController(text: member.phone);
    final shiftController = TextEditingController(text: member.shift);
    String selectedRole = member.role;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Team Member: ${member.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Staff Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                    labelText: 'Phone Number', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: const InputDecoration(
                    labelText: 'Role', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(
                      value: 'Owner / Admin', child: Text('Owner / Admin')),
                  DropdownMenuItem(
                      value: 'Inventory Staff', child: Text('Inventory Staff')),
                  DropdownMenuItem(
                      value: 'Sales Staff', child: Text('Sales Staff')),
                  DropdownMenuItem(
                      value: 'Delivery Staff', child: Text('Delivery Staff')),
                ],
                onChanged: (val) {
                  if (val != null) selectedRole = val;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: shiftController,
                decoration: const InputDecoration(
                    labelText: 'Shift Hours', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  viewModel.updateStaff(
                    id: member.id,
                    name: nameController.text,
                    role: selectedRole,
                    shift: shiftController.text,
                    phone: phoneController.text,
                  );
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryGreen,
                  foregroundColor: Colors.white),
              child: const Text('Save Changes'),
            )
          ],
        );
      },
    );
  }

  @override
  AdminStaffRolesViewModel viewModelBuilder(BuildContext context) =>
      AdminStaffRolesViewModel();
}
