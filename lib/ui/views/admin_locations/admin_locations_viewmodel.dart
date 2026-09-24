import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/location_service.dart';
import 'package:spare_shop_admin/core/services/token_service.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:stacked/stacked.dart';

class AdminLocationsViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _locationService = locator<LocationService>();

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _statusFilter = 'All'; // 'All', 'Active', 'Inactive'
  String get statusFilter => _statusFilter;

  bool _canChangeLocation = true;
  bool get canChangeLocation => _canChangeLocation;

  List<LocationModel> _allLocations = [];

  List<LocationModel> get locations {
    return _allLocations.where((loc) {
      final matchesSearch = _searchQuery.isEmpty ||
          loc.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          loc.radiusDisplay.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _statusFilter == 'All' ||
          (_statusFilter == 'Active' && loc.isActive) ||
          (_statusFilter == 'Inactive' && !loc.isActive);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  int get totalLocations => _allLocations.length;
  int get activeLocations => _allLocations.where((l) => l.isActive).length;
  int get inactiveLocations => _allLocations.where((l) => !l.isActive).length;

  @override
  Future<void> futureToRun() async {
    await loadLocations();
  }

  Future<void> loadLocations() async {
    try {
      setBusy(true);
      final tokenService = locator<TokenService>();
      _canChangeLocation = await tokenService.canChangeLocation();
      _allLocations = await _locationService.getLocations();
      rebuildUi();
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  Future<void> toggleStatus(LocationModel loc) async {
    setBusy(true);
    try {
      await _locationService.updateLocation(loc.id, {
        'isActive': !loc.isActive,
      });
      await loadLocations();
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  Future<bool> deleteLocation(String id) async {
    setBusy(true);
    try {
      await _locationService.deleteLocation(id);
      await loadLocations();
      return true;
    } catch (e) {
      setError(e);
      return false;
    } finally {
      setBusy(false);
    }
  }
}
