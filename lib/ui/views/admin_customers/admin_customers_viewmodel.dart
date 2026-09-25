import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/location_service.dart';
import 'package:spare_shop_admin/core/services/token_service.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:stacked/stacked.dart';

class AdminCustomerModel {
  final String name;
  final String email;
  final String phone;
  final String type; // 'Retailer' or 'Workshop'
  final int ordersCount;
  final double totalSpend;
  final double outstandingDue;
  final String? locationId;
  final String? locationName;

  AdminCustomerModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.type,
    required this.ordersCount,
    required this.totalSpend,
    required this.outstandingDue,
    this.locationId,
    this.locationName,
  });

  AdminCustomerModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? type,
    int? ordersCount,
    double? totalSpend,
    double? outstandingDue,
    String? locationId,
    String? locationName,
  }) {
    return AdminCustomerModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      ordersCount: ordersCount ?? this.ordersCount,
      totalSpend: totalSpend ?? this.totalSpend,
      outstandingDue: outstandingDue ?? this.outstandingDue,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
    );
  }
}

class AdminCustomersViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _locationService = locator<LocationService>();
  final _tokenService = locator<TokenService>();

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

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

  final List<AdminCustomerModel> _customers = [
    AdminCustomerModel(
      name: 'Ravi Kumar',
      email: 'ravi.kumar@gmail.com',
      phone: '+91 98765 43210',
      type: 'Workshop Owner',
      ordersCount: 24,
      totalSpend: 48900.00,
      outstandingDue: 4500.00,
      locationName: 'Madukkarai',
    ),
    AdminCustomerModel(
      name: 'Anjali Sharma',
      email: 'anjali@live.com',
      phone: '+91 98123 45678',
      type: 'Retail Customer',
      ordersCount: 4,
      totalSpend: 8400.00,
      outstandingDue: 0.00,
      locationName: 'Gandhipuram',
    ),
    AdminCustomerModel(
      name: 'Suresh EV Services',
      email: 'contact@sureshev.com',
      phone: '+91 94440 12345',
      type: 'Workshop Owner',
      ordersCount: 89,
      totalSpend: 245000.00,
      outstandingDue: 18500.00,
      locationName: 'Madukkarai',
    ),
  ];

  List<AdminCustomerModel> get filteredCustomers {
    if (_selectedLocationFilter == '__none__') return [];

    return _customers.where((c) {
      final matchesSearch = _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.phone.contains(_searchQuery);
      if (!matchesSearch) return false;

      // Location filter
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

  int get unassignedCustomersCount => _customers
      .where((c) =>
          c.locationId == null ||
          c.locationId!.isEmpty ||
          c.locationName == null ||
          c.locationName!.isEmpty)
      .length;

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

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  double get totalOutstandingDue {
    return filteredCustomers.fold(0, (sum, c) => sum + c.outstandingDue);
  }

  void addCustomer({
    required String name,
    required String email,
    required String phone,
    required String type,
    required double outstandingDue,
    String? locationId,
    String? locationName,
  }) {
    _customers.add(
      AdminCustomerModel(
        name: name,
        email: email,
        phone: phone,
        type: type,
        ordersCount: 0,
        totalSpend: 0.0,
        outstandingDue: outstandingDue,
        locationId: locationId,
        locationName: locationName,
      ),
    );
    notifyListeners();
  }

  void updateCustomer(
    AdminCustomerModel oldCustomer, {
    required String name,
    required String email,
    required String phone,
    required String type,
    required double outstandingDue,
    String? locationId,
    String? locationName,
  }) {
    final index = _customers.indexOf(oldCustomer);
    if (index != -1) {
      _customers[index] = oldCustomer.copyWith(
        name: name,
        email: email,
        phone: phone,
        type: type,
        outstandingDue: outstandingDue,
        locationId: locationId,
        locationName: locationName,
      );
      notifyListeners();
    }
  }

  void assignCustomerLocation(
      AdminCustomerModel customer, LocationModel? location) {
    final index = _customers.indexOf(customer);
    if (index != -1) {
      _customers[index] = customer.copyWith(
        locationId: location?.id,
        locationName: location?.name,
      );
      notifyListeners();
    }
  }
}
