import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/admin_supplier_service.dart';
import 'package:spare_shop_admin/core/services/location_service.dart';
import 'package:spare_shop_admin/core/services/token_service.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

class AdminSuppliersViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _supplierService = locator<AdminSupplierService>();
  final _locationService = locator<LocationService>();
  final _tokenService = locator<TokenService>();

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _categoryFilter = 'All'; // 'All', 'EV', 'Petrol'
  String get categoryFilter => _categoryFilter;

  String _statusFilter = 'All'; // 'All', 'Active', 'Inactive'
  String get statusFilter => _statusFilter;

  String _selectedLocationFilter = 'all'; // 'all' or locationId
  String get selectedLocationFilter => _selectedLocationFilter;

  List<LocationModel> _locations = [];
  List<LocationModel> get locations => _locations;

  bool _canChangeLocation = true;
  bool get canChangeLocation => _canChangeLocation;

  String? _userAssignedLocationId;
  String? get userAssignedLocationId => _userAssignedLocationId;

  String? _userAssignedLocationName;
  String? get userAssignedLocationName => _userAssignedLocationName;

  List<SupplierModel> _allSuppliers = [];

  List<SupplierModel> get suppliers {
    return _allSuppliers.where((s) {
      final matchesSearch = s.companyName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          s.contactPerson.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.phone.contains(_searchQuery);

      final matchesCategory = _categoryFilter == 'All' ||
          (_categoryFilter == 'EV' && s.suppliesEvParts) ||
          (_categoryFilter == 'Petrol' && s.suppliesPetrolParts);

      final matchesStatus = _statusFilter == 'All' ||
          (_statusFilter == 'Active' && s.isActive) ||
          (_statusFilter == 'Inactive' && !s.isActive);

      if (!matchesSearch || !matchesCategory || !matchesStatus) return false;

      if (_selectedLocationFilter == '__none__') return false;

      // Location Filter
      if (_selectedLocationFilter != 'all') {
        final match = _locations.where((l) => l.id == _selectedLocationFilter);
        if (match.isNotEmpty) {
          final locName = match.first.name
              .toLowerCase()
              .replaceAll(RegExp(r'\s*hub', caseSensitive: false), '')
              .trim();
          return s.city.toLowerCase().contains(locName) ||
              s.state.toLowerCase().contains(locName) ||
              s.address.toLowerCase().contains(locName) ||
              (locName.isNotEmpty &&
                  s.companyName.toLowerCase().contains(locName));
        }
        return false;
      }

      return true;
    }).toList();
  }

  int get totalSuppliers => _allSuppliers.length;
  int get activeSuppliers => _allSuppliers.where((s) => s.isActive).length;

  double get outstandingPayable {
    final totalPaise =
        suppliers.fold(0, (sum, s) => sum + s.outstandingAmountInPaise);
    return totalPaise / 100.0;
  }

  @override
  Future<void> futureToRun() async {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    TokenService.locationNotifier.addListener(_onLocationNotifierChanged);

    _canChangeLocation = await _tokenService.canChangeLocation();
    _userAssignedLocationId = await _tokenService.getUserLocationId();
    _userAssignedLocationName = await _tokenService.getUserLocationName();

    try {
      _locations = await _locationService.getLocations();
    } catch (_) {
      _locations = [];
    }

    if (!_canChangeLocation &&
        (_userAssignedLocationId == null || _userAssignedLocationId!.isEmpty)) {
      _selectedLocationFilter = '__none__';
    } else if (_userAssignedLocationId != null &&
        _userAssignedLocationId!.isNotEmpty &&
        _userAssignedLocationId != 'all') {
      _selectedLocationFilter = _userAssignedLocationId!;
    } else {
      _selectedLocationFilter = 'all';
    }

    await loadSuppliers();
  }

  void _onLocationNotifierChanged() {
    final newLocId = TokenService.locationNotifier.locationId;
    _selectedLocationFilter =
        (newLocId != null && newLocId.isNotEmpty) ? newLocId : 'all';
    notifyListeners();
  }

  @override
  void dispose() {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    super.dispose();
  }

  void setSelectedLocationFilter(String filter) {
    _selectedLocationFilter = filter;
    if (_canChangeLocation) {
      locator<TokenService>().saveUserLocation(
        locationId: filter == 'all' ? null : filter,
        locationName: filter != 'all' && _locations.any((l) => l.id == filter)
            ? _locations.firstWhere((l) => l.id == filter).name
            : 'All Locations (HQ)',
      );
    }
    notifyListeners();
  }

  Future<void> loadSuppliers() async {
    try {
      _allSuppliers = await _supplierService.getSuppliers();
      rebuildUi();
    } catch (e) {
      print('Error loading admin suppliers: $e');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String val) {
    _categoryFilter = val;
    notifyListeners();
  }

  void setStatusFilter(String val) {
    _statusFilter = val;
    notifyListeners();
  }

  Future<void> toggleStatus(SupplierModel s) async {
    setBusy(true);
    try {
      await _supplierService.updateSupplier(s.id, {
        'status': s.isActive ? 'inactive' : 'active',
      });
      await loadSuppliers();
    } catch (e) {
      print('Error toggling supplier status: $e');
    } finally {
      setBusy(false);
    }
  }
}
