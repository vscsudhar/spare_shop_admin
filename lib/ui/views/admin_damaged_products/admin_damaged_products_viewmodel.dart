import 'package:flutter/foundation.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/location_service.dart';
import 'package:spare_shop_admin/core/services/return_exchange_service.dart';
import 'package:spare_shop_admin/core/services/token_service.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:spare_shop_admin/ui/common/return_exchange_models.dart';
import 'package:stacked/stacked.dart';

class AdminDamagedProductsViewModel extends FutureViewModel<void> with NavigationMixin {
  final _returnsService = locator<ReturnExchangeService>();
  final _locationService = locator<LocationService>();
  final _tokenService = locator<TokenService>();

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedDamageType = 'all';
  String get selectedDamageType => _selectedDamageType;

  String _selectedResolution = 'all';
  String get selectedResolution => _selectedResolution;

  String _selectedLocationFilter = 'all'; // 'all', locationId, or 'unassigned'
  String get selectedLocationFilter => _selectedLocationFilter;

  String _selectedChannel = 'all'; // 'all', 'online', 'in_store'
  String get selectedChannel => _selectedChannel;

  List<LocationModel> _locations = [];
  List<LocationModel> get locations => _locations;

  bool _canChangeLocation = true;
  bool get canChangeLocation => _canChangeLocation;

  String? _userAssignedLocationId;
  String? get userAssignedLocationId => _userAssignedLocationId;

  String? _userAssignedLocationName;
  String? get userAssignedLocationName => _userAssignedLocationName;

  List<DamagedItemRecord> _damagedItems = [];
  List<DamagedItemRecord> get damagedItems => _damagedItems;

  List<DamagedItemRecord> get filteredDamagedItems {
    if (_selectedLocationFilter == '__none__') return [];

    return _damagedItems.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.productName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.caseNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item.locationName ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesType =
          _selectedDamageType == 'all' || item.damageType.toLowerCase() == _selectedDamageType.toLowerCase();

      final matchesResolution =
          _selectedResolution == 'all' || item.damageResolution.toLowerCase() == _selectedResolution.toLowerCase();

      bool matchesLocation = true;
      if (_selectedLocationFilter == 'unassigned') {
        matchesLocation = item.locationId == null || item.locationId!.isEmpty;
      } else if (_selectedLocationFilter != 'all') {
        matchesLocation = (item.locationId == _selectedLocationFilter) ||
            (item.locationName != null &&
                item.locationName!.isNotEmpty &&
                _locations.any((l) =>
                    l.id == _selectedLocationFilter &&
                    l.name.toLowerCase() == item.locationName!.toLowerCase()));
      }

      bool matchesChannel = true;
      if (_selectedChannel != 'all') {
        matchesChannel = item.channel.toLowerCase() == _selectedChannel.toLowerCase();
      }

      return matchesSearch && matchesType && matchesResolution && matchesLocation && matchesChannel;
    }).toList();
  }

  DamagedItemsMetrics? _metrics;
  DamagedItemsMetrics? get metrics => _metrics;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  bool _initialized = false;

  @override
  Future<void> futureToRun() async {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    TokenService.locationNotifier.addListener(_onLocationNotifierChanged);

    if (_initialized) return;
    _initialized = true;
    await loadDamagedProducts();
  }

  void _onLocationNotifierChanged() {
    final newLocId = TokenService.locationNotifier.locationId;
    _selectedLocationFilter = (newLocId != null && newLocId.isNotEmpty) ? newLocId : 'all';
    loadDamagedProducts();
  }

  @override
  void dispose() {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    super.dispose();
  }

  Future<void> loadDamagedProducts() async {
    setBusy(true);
    try {
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
      }

      if (_selectedLocationFilter == '__none__') {
        _damagedItems = [];
        _totalCount = 0;
        _metrics = null;
        notifyListeners();
        return;
      }

      final res = await _returnsService.getDamagedItems(
        damageType: _selectedDamageType,
        damageResolution: _selectedResolution,
        search: _searchQuery,
        locationId: _selectedLocationFilter != 'all' && _selectedLocationFilter != 'unassigned'
            ? _selectedLocationFilter
            : null,
        channel: _selectedChannel != 'all' ? _selectedChannel : null,
      );
      _damagedItems = res.items;
      _metrics = res.metrics;
      _totalCount = res.total;

      // Auto sync location names
      for (int i = 0; i < _damagedItems.length; i++) {
        final d = _damagedItems[i];
        if (d.locationId != null && (d.locationName == null || d.locationName!.isEmpty)) {
          final match = _locations.where((l) => l.id == d.locationId);
          if (match.isNotEmpty) {
            _damagedItems[i] = d.copyWith(locationName: match.first.name);
          }
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading damaged products: $e');
    } finally {
      setBusy(false);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadDamagedProducts();
  }

  void setFilterDamageType(String type) {
    _selectedDamageType = type;
    loadDamagedProducts();
  }

  void setFilterResolution(String resolution) {
    _selectedResolution = resolution;
    loadDamagedProducts();
  }

  void setSelectedLocationFilter(String locationId) {
    _selectedLocationFilter = locationId;
    if (_canChangeLocation) {
      locator<TokenService>().saveUserLocation(
        locationId: locationId == 'all' || locationId == 'unassigned' ? null : locationId,
        locationName: locationId != 'all' && locationId != 'unassigned' && _locations.any((l) => l.id == locationId)
            ? _locations.firstWhere((l) => l.id == locationId).name
            : 'All Locations (HQ)',
      );
    }
    loadDamagedProducts();
  }

  void setSelectedChannel(String channel) {
    _selectedChannel = channel;
    loadDamagedProducts();
  }

  Future<void> openCaseDetail(String caseId) async {
    await goToReturnDetail(caseId: caseId);
    await loadDamagedProducts();
  }
}
