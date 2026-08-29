import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:stacked/stacked.dart';

class StaffMemberModel {
  final String id;
  final String name;
  final String role;
  final String phone;
  final String shift;
  final String status; // 'Active', 'On Leave', 'Inactive'

  StaffMemberModel({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    required this.shift,
    required this.status,
  });
}

class AdminStaffRolesViewModel extends BaseViewModel with NavigationMixin {
  String _selectedRoleFilter =
      'All'; // 'All', 'Owner', 'Inventory', 'Sales', 'Delivery'
  String get selectedRoleFilter => _selectedRoleFilter;

  final List<StaffMemberModel> _teamMembers = [
    StaffMemberModel(
      id: 'staff_1',
      name: 'Amit Patel',
      role: 'Owner / Admin',
      phone: '+91 99880 77665',
      shift: 'Flexible',
      status: 'Active',
    ),
    StaffMemberModel(
      id: 'staff_2',
      name: 'Rohan Deshmukh',
      role: 'Inventory Staff',
      phone: '+91 98887 66554',
      shift: '09:00 AM - 06:00 PM',
      status: 'Active',
    ),
    StaffMemberModel(
      id: 'staff_3',
      name: 'Priya Nair',
      role: 'Sales Staff',
      phone: '+91 97776 55443',
      shift: '10:00 AM - 07:00 PM',
      status: 'Active',
    ),
    StaffMemberModel(
      id: 'staff_4',
      name: 'Vikram Singh',
      role: 'Delivery Staff',
      phone: '+91 96665 44332',
      shift: '08:00 AM - 05:00 PM',
      status: 'On Leave',
    ),
  ];

  List<StaffMemberModel> get filteredTeamMembers {
    if (_selectedRoleFilter == 'All') return _teamMembers;
    return _teamMembers
        .where((member) => member.role
            .toLowerCase()
            .contains(_selectedRoleFilter.toLowerCase()))
        .toList();
  }

  void setSelectedRoleFilter(String filter) {
    _selectedRoleFilter = filter;
    notifyListeners();
  }

  void inviteStaff({
    required String name,
    required String role,
    required String shift,
    required String phone,
  }) {
    final newId = 'staff_${_teamMembers.length + 1}';
    _teamMembers.add(
      StaffMemberModel(
        id: newId,
        name: name,
        role: role,
        phone: phone.isNotEmpty ? phone : '+91 90000 88000',
        shift: shift,
        status: 'Active',
      ),
    );
    notifyListeners();
  }

  void updateStaff({
    required String id,
    required String name,
    required String role,
    required String shift,
    required String phone,
  }) {
    final idx = _teamMembers.indexWhere((m) => m.id == id);
    if (idx != -1) {
      _teamMembers[idx] = StaffMemberModel(
        id: id,
        name: name,
        role: role,
        phone: phone,
        shift: shift,
        status: _teamMembers[idx].status,
      );
      notifyListeners();
    }
  }

  void updateStaffStatus({required String id, required String status}) {
    final idx = _teamMembers.indexWhere((m) => m.id == id);
    if (idx != -1) {
      _teamMembers[idx] = StaffMemberModel(
        id: id,
        name: _teamMembers[idx].name,
        role: _teamMembers[idx].role,
        phone: _teamMembers[idx].phone,
        shift: _teamMembers[idx].shift,
        status: status,
      );
      notifyListeners();
    }
  }
}
