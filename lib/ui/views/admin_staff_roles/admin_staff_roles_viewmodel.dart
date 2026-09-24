import 'package:flutter/foundation.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/location_service.dart';
import 'package:spare_shop_admin/core/services/staff_service.dart';
import 'package:spare_shop_admin/core/services/token_service.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:stacked/stacked.dart';

export 'package:spare_shop_admin/core/services/staff_service.dart' show StaffMemberModel, StaffRoleDefinition;

class AdminStaffRolesViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _locationService = locator<LocationService>();
  final _staffService = locator<StaffService>();

  List<LocationModel> _locations = [];
  List<LocationModel> get locations => _locations;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedLocationFilter = 'All'; // 'All' or locationId
  String get selectedLocationFilter => _selectedLocationFilter;

  String _selectedRoleFilter = 'All';
  String get selectedRoleFilter => _selectedRoleFilter;

  int _selectedTab = 0; // 0: Team Roster, 1: Roles & Permissions
  int get selectedTab => _selectedTab;

  final List<StaffRoleDefinition> _roles = [
    const StaffRoleDefinition(
      id: 'role_owner',
      roleName: 'Owner / Admin',
      description: 'Unrestricted global access to all branches, billing, and settings.',
      isLocationScoped: false,
      permissions: ['ALL_PERMISSIONS', 'settings.manage', 'locations.manage'],
    ),
    const StaffRoleDefinition(
      id: 'role_manager',
      roleName: 'Store / Hub Manager',
      description: 'Manages day-to-day operations, staff, orders, and stock for assigned location.',
      isLocationScoped: true,
      permissions: ['inventory.manage', 'orders.manage', 'billing.create', 'staff.view'],
    ),
    const StaffRoleDefinition(
      id: 'role_inventory',
      roleName: 'Inventory Specialist',
      description: 'Tracks, receives, and adjusts stock quantities at the designated location hub.',
      isLocationScoped: true,
      permissions: ['inventory.read', 'inventory.update', 'products.view'],
    ),
    const StaffRoleDefinition(
      id: 'role_sales',
      roleName: 'Sales & POS Staff',
      description: 'Handles in-store customer billing, counter inquiries, and invoice generation.',
      isLocationScoped: true,
      permissions: ['billing.create', 'orders.read', 'inventory.read'],
    ),
    const StaffRoleDefinition(
      id: 'role_delivery',
      roleName: 'Delivery Driver',
      description: 'Assigned to pickup & deliver orders within the location coverage radius.',
      isLocationScoped: true,
      permissions: ['orders.read', 'delivery.update'],
    ),
  ];
  List<StaffRoleDefinition> get roles => _roles;

  List<StaffMemberModel> _teamMembers = [];
  List<StaffMemberModel> get teamMembers => _teamMembers;

  List<StaffMemberModel> get filteredTeamMembers {
    if (_selectedLocationFilter == '__none__') return [];

    return _teamMembers.where((member) {
      final matchesSearch = _searchQuery.isEmpty ||
          member.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          member.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          member.phone.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          member.role.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          member.locationName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesRole = _selectedRoleFilter == 'All' ||
          member.role.toLowerCase().contains(_selectedRoleFilter.toLowerCase());

      bool matchesLocation = true;
      if (_selectedLocationFilter == 'all_hq') {
        matchesLocation = member.locationId == null || member.locationId!.isEmpty;
      } else if (_selectedLocationFilter != 'All' && _selectedLocationFilter != 'all') {
        matchesLocation = member.locationId == _selectedLocationFilter ||
            (member.locationName.isNotEmpty &&
                _locations.any((l) =>
                    l.id == _selectedLocationFilter &&
                    l.name.toLowerCase() == member.locationName.toLowerCase()));
      }

      return matchesSearch && matchesRole && matchesLocation;
    }).toList();
  }

  int get totalStaffCount => _teamMembers.length;
  int get activeStaffCount =>
      _teamMembers.where((m) => m.status == 'Active').length;
  int get onLeaveStaffCount =>
      _teamMembers.where((m) => m.status == 'On Leave').length;
  int get totalLocationsCovered {
    final Set<String> distinctLocs = {};
    for (final m in _teamMembers) {
      if (m.locationId != null && m.locationId!.isNotEmpty) {
        distinctLocs.add(m.locationId!);
      }
    }
    return distinctLocs.length;
  }

  bool get isOwner => true; // All authenticated admin dashboard users can manage staff and roles

  bool _canChangeLocation = true;
  bool get canChangeLocation => _canChangeLocation;

  String? _userAssignedLocationId;
  String? get userAssignedLocationId => _userAssignedLocationId;

  @override
  Future<void> futureToRun() async {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    TokenService.locationNotifier.addListener(_onLocationNotifierChanged);
    await loadData();
  }

  void _onLocationNotifierChanged() {
    final newLocId = TokenService.locationNotifier.locationId;
    _selectedLocationFilter = (newLocId != null && newLocId.isNotEmpty) ? newLocId : 'All';
    loadData();
  }

  @override
  void dispose() {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      setBusy(true);
      final tokenService = locator<TokenService>();
      _canChangeLocation = await tokenService.canChangeLocation();
      _userAssignedLocationId = await tokenService.getUserLocationId();

      _locations = await _locationService.getLocations();
      final loadedStaff = await _staffService.getStaffMembers();
      _teamMembers = List.from(loadedStaff);

      if (!_canChangeLocation &&
          (_userAssignedLocationId == null || _userAssignedLocationId!.isEmpty)) {
        _selectedLocationFilter = '__none__';
      } else if (_userAssignedLocationId != null &&
          _userAssignedLocationId!.isNotEmpty &&
          _userAssignedLocationId != 'all') {
        _selectedLocationFilter = _userAssignedLocationId!;
      }

      // Sync existing staff with real location names if location IDs match
      for (int i = 0; i < _teamMembers.length; i++) {
        final locId = _teamMembers[i].locationId;
        if (locId != null && locId.isNotEmpty) {
          final matchedLoc = _locations.where((l) => l.id == locId);
          if (matchedLoc.isNotEmpty) {
            _teamMembers[i] = _teamMembers[i].copyWith(
              locationName: matchedLoc.first.name,
            );
          }
        }
      }
      rebuildUi();
    } catch (e) {
      debugPrint('Error loading staff/locations: $e');
    } finally {
      setBusy(false);
    }
  }

  void setSelectedTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedLocationFilter(String locationId) {
    if (!_canChangeLocation) return;
    _selectedLocationFilter = locationId;
    locator<TokenService>().saveUserLocation(
      locationId: locationId == 'All' || locationId == 'all' || locationId == 'all_hq' ? null : locationId,
      locationName: locationId != 'All' && locationId != 'all' && locationId != 'all_hq' && _locations.any((l) => l.id == locationId)
          ? _locations.firstWhere((l) => l.id == locationId).name
          : 'All Locations (HQ)',
    );
    notifyListeners();
  }

  void setSelectedRoleFilter(String filter) {
    _selectedRoleFilter = filter;
    notifyListeners();
  }

  Future<void> inviteStaff({
    required String name,
    required String email,
    required String password,
    required String role,
    required String shift,
    required String phone,
    String? locationId,
    String? locationName,
  }) async {
    String resolvedLocationName = 'All Locations (HQ)';
    if (locationId != null && locationId.isNotEmpty && locationId != 'all') {
      final loc = _locations.where((l) => l.id == locationId);
      resolvedLocationName =
          loc.isNotEmpty ? loc.first.name : (locationName ?? 'Location Hub');
    }

    final newStaff = StaffMemberModel(
      id: 'staff_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email.trim(),
      password: password.isNotEmpty ? password.trim() : 'Staff12345!',
      role: role,
      phone: phone.isNotEmpty ? phone : '+91 90000 88000',
      shift: shift,
      status: 'Active',
      locationId: (locationId == 'all' || locationId == null) ? null : locationId,
      locationName: resolvedLocationName,
    );

    _teamMembers.add(newStaff);
    await _staffService.saveStaffMember(newStaff);
    notifyListeners();
  }

  Future<void> updateStaff({
    required String id,
    required String name,
    required String email,
    String? password,
    required String role,
    required String shift,
    required String phone,
    String? locationId,
    String? locationName,
  }) async {
    final idx = _teamMembers.indexWhere((m) => m.id == id);
    if (idx != -1) {
      String resolvedLocationName = 'All Locations (HQ)';
      if (locationId != null && locationId.isNotEmpty && locationId != 'all') {
        final loc = _locations.where((l) => l.id == locationId);
        resolvedLocationName =
            loc.isNotEmpty ? loc.first.name : (locationName ?? 'Location Hub');
      }

      final existingPassword = _teamMembers[idx].password;
      final updatedStaff = StaffMemberModel(
        id: id,
        name: name,
        email: email.trim(),
        password: (password != null && password.trim().isNotEmpty)
            ? password.trim()
            : existingPassword,
        role: role,
        phone: phone,
        shift: shift,
        status: _teamMembers[idx].status,
        locationId: (locationId == 'all' || locationId == null) ? null : locationId,
        locationName: resolvedLocationName,
      );

      _teamMembers[idx] = updatedStaff;
      await _staffService.updateStaffMember(updatedStaff);
      notifyListeners();
    }
  }

  Future<void> deleteStaff(String id) async {
    _teamMembers.removeWhere((m) => m.id == id);
    await _staffService.deleteStaffMember(id);
    notifyListeners();
  }

  Future<void> updateStaffStatus({required String id, required String status}) async {
    final idx = _teamMembers.indexWhere((m) => m.id == id);
    if (idx != -1) {
      final updated = _teamMembers[idx].copyWith(status: status);
      _teamMembers[idx] = updated;
      await _staffService.updateStaffMember(updated);
      notifyListeners();
    }
  }

  void createRole({
    required String roleName,
    required String description,
    required bool isLocationScoped,
    required List<String> permissions,
  }) {
    final newId = 'role_${DateTime.now().millisecondsSinceEpoch}';
    _roles.add(
      StaffRoleDefinition(
        id: newId,
        roleName: roleName,
        description: description,
        isLocationScoped: isLocationScoped,
        permissions: permissions,
      ),
    );
    notifyListeners();
  }
}


