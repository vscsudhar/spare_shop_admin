import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/admin_customer_service.dart';
import 'package:spare_shop_admin/core/services/location_service.dart';
import 'package:spare_shop_admin/core/services/token_service.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:stacked/stacked.dart';

export 'package:spare_shop_admin/core/services/admin_customer_service.dart'
    show AdminCustomerModel, CustomerVehicleModel;

class AdminCustomersViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _customerService = locator<AdminCustomerService>();
  final _locationService = locator<LocationService>();
  final _tokenService = locator<TokenService>();

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedStatusFilter =
      'all'; // 'all', 'Active', 'Suspended', 'Disabled'
  String get selectedStatusFilter => _selectedStatusFilter;

  String _selectedTypeFilter =
      'all'; // 'all', 'Retail Customer', 'Workshop Owner', 'Fleet Owner'
  String get selectedTypeFilter => _selectedTypeFilter;

  String _selectedChannelFilter = 'all'; // 'all', 'mobile', 'store'
  String get selectedChannelFilter => _selectedChannelFilter;

  String _selectedLocationFilter = 'all'; // 'all', 'unassigned', or locationId
  String get selectedLocationFilter => _selectedLocationFilter;

  List<LocationModel> _locations = [];
  List<LocationModel> get locations => _locations;

  bool _canChangeLocation = true;
  bool get canChangeLocation => _canChangeLocation;

  String? _userAssignedLocationId;
  String? get userAssignedLocationId => _userAssignedLocationId;

  String? _userAssignedLocationName;
  String? get userAssignedLocationName => _userAssignedLocationName;

  List<AdminCustomerModel> _customers = [];
  List<AdminCustomerModel> get customers => _customers;

  bool _isLoadingData = false;
  bool get isLoadingData => _isLoadingData;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<AdminCustomerModel> get filteredCustomers {
    if (_selectedLocationFilter == '__none__') return [];

    return _customers.where((c) {
      // 1. Search Query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = c.name.toLowerCase().contains(query);
        final phoneMatch = c.phone.contains(_searchQuery);
        final emailMatch = c.email.toLowerCase().contains(query);
        final vehicleMatch = c.vehicles.any((v) =>
            v.brand.toLowerCase().contains(query) ||
            v.model.toLowerCase().contains(query));
        if (!nameMatch && !phoneMatch && !emailMatch && !vehicleMatch) {
          return false;
        }
      }

      // 2. Status Filter
      if (_selectedStatusFilter != 'all') {
        if (c.status.toLowerCase() != _selectedStatusFilter.toLowerCase()) {
          return false;
        }
      }

      // 3. Type Filter
      if (_selectedTypeFilter != 'all') {
        if (!c.type.toLowerCase().contains(_selectedTypeFilter.toLowerCase())) {
          return false;
        }
      }

      // 4. Channel / User Origin Filter (Mobile App vs In-Store)
      if (_selectedChannelFilter != 'all') {
        if (_selectedChannelFilter == 'mobile' && !c.isMobileUser) {
          return false;
        }
        if (_selectedChannelFilter == 'store' && !c.isStoreUser) {
          return false;
        }
      }

      // 5. Location Filter
      if (_selectedLocationFilter == 'unassigned') {
        return c.locationId == null ||
            c.locationId!.isEmpty ||
            c.locationName == null ||
            c.locationName!.isEmpty;
      } else if (_selectedLocationFilter != 'all') {
        final loc = _locations.where((l) => l.id == _selectedLocationFilter);
        final locName = loc.isNotEmpty ? loc.first.name.toLowerCase() : '';
        final matchesId = c.locationId == _selectedLocationFilter;
        final matchesName = locName.isNotEmpty &&
            c.locationName != null &&
            c.locationName!.isNotEmpty &&
            c.locationName!.toLowerCase() == locName;
        return matchesId || matchesName;
      }

      return true;
    }).toList();
  }

  int get totalCustomersCount => _customers.length;
  int get activeCustomersCount =>
      _customers.where((c) => c.status.toLowerCase() == 'active').length;
  int get suspendedCustomersCount =>
      _customers.where((c) => c.status.toLowerCase() == 'suspended').length;
  int get mobileUsersCount => _customers.where((c) => c.isMobileUser).length;
  int get storeUsersCount => _customers.where((c) => c.isStoreUser).length;
  int get workshopCustomersCount =>
      _customers.where((c) => c.type.toLowerCase().contains('workshop')).length;
  int get retailCustomersCount =>
      _customers.where((c) => c.type.toLowerCase().contains('retail')).length;

  int get unassignedCustomersCount => _customers
      .where((c) =>
          c.locationId == null ||
          c.locationId!.isEmpty ||
          c.locationName == null ||
          c.locationName!.isEmpty)
      .length;

  double get totalLifetimeSpend =>
      filteredCustomers.fold(0.0, (sum, c) => sum + c.totalSpend);

  double get totalOutstandingDue =>
      filteredCustomers.fold(0.0, (sum, c) => sum + c.outstandingDue);

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

    await loadCustomers();
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

  Future<void> loadCustomers() async {
    _isLoadingData = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _customers = await _customerService.getCustomers(
        locationId: _selectedLocationFilter == 'all' ||
                _selectedLocationFilter == 'unassigned' ||
                _selectedLocationFilter == '__none__'
            ? null
            : _selectedLocationFilter,
        status: _selectedStatusFilter == 'all' ? null : _selectedStatusFilter,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingData = false;
      notifyListeners();
    }
  }

  void setSelectedLocationFilter(String filter) {
    _selectedLocationFilter = filter;
    if (_canChangeLocation) {
      locator<TokenService>().saveUserLocation(
        locationId: filter == 'all' || filter == 'unassigned' ? null : filter,
        locationName: filter != 'all' &&
                filter != 'unassigned' &&
                _locations.any((l) => l.id == filter)
            ? _locations.firstWhere((l) => l.id == filter).name
            : 'All Locations (HQ)',
      );
    }
    notifyListeners();
  }

  void setSelectedStatusFilter(String status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  void setSelectedTypeFilter(String type) {
    _selectedTypeFilter = type;
    notifyListeners();
  }

  void setSelectedChannelFilter(String channel) {
    _selectedChannelFilter = channel;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> createCustomer({
    required String name,
    required String email,
    required String phone,
    required String type,
    required String status,
    required String source,
    required double outstandingDue,
    String? profileImage,
    String? locationId,
    String? locationName,
    String? address,
    String? gstNumber,
  }) async {
    setBusy(true);
    try {
      final newCustomer = await _customerService.createCustomer({
        'name': name,
        'email': email,
        'phone': phone,
        'type': type,
        'status': status,
        'source': source,
        'outstandingDue': outstandingDue,
        'profileImage': profileImage ?? '',
        'locationId': locationId,
        'locationName': locationName,
        'address': address ?? '',
        'gstNumber': gstNumber ?? '',
      });

      _customers.removeWhere((c) => c.id == newCustomer.id);
      _customers.insert(0, newCustomer);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create customer: $e';
      notifyListeners();
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> updateCustomer(
    String id, {
    required String name,
    required String email,
    required String phone,
    required String type,
    required String status,
    required String source,
    required double outstandingDue,
    String? profileImage,
    String? locationId,
    String? locationName,
    String? address,
    String? gstNumber,
  }) async {
    setBusy(true);
    try {
      final updated = await _customerService.updateCustomer(id, {
        'name': name,
        'email': email,
        'phone': phone,
        'type': type,
        'status': status,
        'source': source,
        'outstandingDue': outstandingDue,
        'profileImage': profileImage,
        'locationId': locationId,
        'locationName': locationName,
        'address': address,
        'gstNumber': gstNumber,
      });

      final index = _customers.indexWhere((c) => c.id == id);
      if (index != -1) {
        _customers[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update customer: $e';
      notifyListeners();
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> updateCustomerStatus(
      AdminCustomerModel customer, String newStatus) async {
    try {
      final updated =
          await _customerService.updateCustomerStatus(customer.id, newStatus);
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update status: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    setBusy(true);
    try {
      final success = await _customerService.deleteCustomer(id);
      if (success) {
        _customers.removeWhere((c) => c.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete customer: $e';
      notifyListeners();
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<void> assignCustomerLocation(
      AdminCustomerModel customer, LocationModel? location) async {
    try {
      final updated = await _customerService.updateCustomer(customer.id, {
        'locationId': location?.id,
        'locationName': location?.name,
      });
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update hub assignment: $e';
      notifyListeners();
    }
  }
}
