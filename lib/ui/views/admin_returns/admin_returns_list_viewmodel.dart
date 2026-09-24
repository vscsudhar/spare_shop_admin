import 'package:flutter/foundation.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/location_service.dart';
import 'package:spare_shop_admin/core/services/return_exchange_service.dart';
import 'package:spare_shop_admin/core/services/token_service.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:spare_shop_admin/ui/common/return_exchange_models.dart';
import 'package:stacked/stacked.dart';

class AdminReturnsListViewModel extends FutureViewModel<void> with NavigationMixin {
  final _returnsService = locator<ReturnExchangeService>();
  final _locationService = locator<LocationService>();
  final _tokenService = locator<TokenService>();

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedType = 'all';
  String get selectedType => _selectedType;

  String _selectedStatus = 'all';
  String get selectedStatus => _selectedStatus;

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

  List<ReturnExchangeCase> _cases = [];
  List<ReturnExchangeCase> get cases => _cases;

  List<ReturnExchangeCase> get filteredCases {
    if (_selectedLocationFilter == '__none__') return [];

    return _cases.where((c) {
      final matchesSearch = _searchQuery.isEmpty ||
          c.caseNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.billNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c.locationName ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.customerPhone.contains(_searchQuery);

      final matchesType =
          _selectedType == 'all' || c.type.toLowerCase() == _selectedType.toLowerCase();

      final matchesStatus =
          _selectedStatus == 'all' || c.status.toLowerCase() == _selectedStatus.toLowerCase();

      bool matchesLocation = true;
      if (_selectedLocationFilter == 'unassigned') {
        matchesLocation = c.locationId == null || c.locationId!.isEmpty;
      } else if (_selectedLocationFilter != 'all') {
        matchesLocation = (c.locationId == _selectedLocationFilter) ||
            (c.locationName != null &&
                c.locationName!.isNotEmpty &&
                _locations.any((l) =>
                    l.id == _selectedLocationFilter &&
                    l.name.toLowerCase() == c.locationName!.toLowerCase()));
      }

      bool matchesChannel = true;
      if (_selectedChannel != 'all') {
        matchesChannel = c.channel.toLowerCase() == _selectedChannel.toLowerCase();
      }

      return matchesSearch && matchesType && matchesStatus && matchesLocation && matchesChannel;
    }).toList();
  }

  int get unassignedCasesCount =>
      _cases.where((c) => c.locationId == null || c.locationId!.isEmpty).length;

  int get onlineClaimsCount =>
      _cases.where((c) => c.channel == 'online').length;

  int get storeVisitsCount =>
      _cases.where((c) => c.channel == 'in_store').length;

  bool _initialized = false;

  @override
  Future<void> futureToRun() async {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    TokenService.locationNotifier.addListener(_onLocationNotifierChanged);

    if (_initialized) return;
    _initialized = true;
    await loadCases();
  }

  void _onLocationNotifierChanged() {
    final newLocId = TokenService.locationNotifier.locationId;
    _selectedLocationFilter = (newLocId != null && newLocId.isNotEmpty) ? newLocId : 'all';
    loadCases();
  }

  @override
  void dispose() {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    super.dispose();
  }

  Future<void> loadCases() async {
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
        _cases = [];
        notifyListeners();
        return;
      }

      _cases = await _returnsService.getCases(
        locationId: _selectedLocationFilter != 'all' && _selectedLocationFilter != 'unassigned'
            ? _selectedLocationFilter
            : null,
        channel: _selectedChannel != 'all' ? _selectedChannel : null,
      );

      // Auto-sync location names with registered locations
      for (int i = 0; i < _cases.length; i++) {
        final c = _cases[i];
        if (c.locationId != null && (c.locationName == null || c.locationName!.isEmpty)) {
          final match = _locations.where((l) => l.id == c.locationId);
          if (match.isNotEmpty) {
            _cases[i] = c.copyWith(locationName: match.first.name);
          }
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading return cases: $e');
    } finally {
      setBusy(false);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void setFilterStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
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
    loadCases();
  }

  void setSelectedChannel(String channel) {
    _selectedChannel = channel;
    notifyListeners();
  }

  Future<void> assignCaseLocation(ReturnExchangeCase kase, LocationModel? location) async {
    try {
      final updated = await _returnsService.updateCaseLocation(
        kase.id,
        locationId: location?.id,
        locationName: location?.name,
      );

      final index = _cases.indexWhere((c) => c.id == kase.id);
      if (index != -1) {
        _cases[index] = updated.copyWith(
          locationId: location?.id,
          locationName: location?.name,
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating case location: $e');
      final index = _cases.indexWhere((c) => c.id == kase.id);
      if (index != -1) {
        _cases[index] = kase.copyWith(
          locationId: location?.id,
          locationName: location?.name,
        );
        notifyListeners();
      }
    }
  }

  Future<void> openCaseDetail(ReturnExchangeCase kase) async {
    await goToReturnDetail(caseId: kase.id);
    await loadCases();
  }

  Future<void> openNewReturn() async {
    await goToNewReturn();
    await loadCases();
  }
}
