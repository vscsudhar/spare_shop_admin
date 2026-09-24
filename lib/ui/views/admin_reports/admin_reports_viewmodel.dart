import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/admin_dashboard_service.dart';
import 'package:spare_shop_admin/core/services/location_service.dart';
import 'package:spare_shop_admin/core/services/token_service.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:stacked/stacked.dart';

class AdminReportsViewModel extends FutureViewModel<void> with NavigationMixin {
  final _dashboardService = locator<AdminDashboardService>();
  final _locationService = locator<LocationService>();
  final _tokenService = locator<TokenService>();

  String _selectedPeriod = 'Weekly'; // 'Today', 'Weekly', 'Monthly', 'Yearly'
  String get selectedPeriod => _selectedPeriod;

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

  List<dynamic> _dailySales = [];

  double _netSales = 0.0;
  int _ordersCount = 0;

  double get netSales => _netSales;
  double get grossProfit => _netSales * 0.35;
  double get averageOrderValue =>
      _ordersCount > 0 ? _netSales / _ordersCount : 0.0;
  double get gstPayable => _netSales * 0.18;

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

    await loadData();
  }

  void _onLocationNotifierChanged() {
    final newLocId = TokenService.locationNotifier.locationId;
    _selectedLocationFilter = (newLocId != null && newLocId.isNotEmpty) ? newLocId : 'all';
    loadData();
  }

  @override
  void dispose() {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    super.dispose();
  }

  void setSelectedLocationFilter(String locationId) {
    if (_selectedLocationFilter == locationId) return;
    _selectedLocationFilter = locationId;
    if (_canChangeLocation) {
      locator<TokenService>().saveUserLocation(
        locationId: locationId == 'all' ? null : locationId,
        locationName: locationId != 'all' && _locations.any((l) => l.id == locationId)
            ? _locations.firstWhere((l) => l.id == locationId).name
            : 'All Locations (HQ)',
      );
    }
    loadData();
  }

  Future<void> loadData() async {
    try {
      if (_selectedLocationFilter == '__none__') {
        _dailySales = [];
        _calculateStats();
        rebuildUi();
        return;
      }

      final locId = _selectedLocationFilter == 'all' ? null : _selectedLocationFilter;
      _dailySales = await _dashboardService.getSalesChart('daily', locationId: locId);
      _calculateStats();
      rebuildUi();
    } catch (e) {
      print('Error loading reports data: $e');
    }
  }

  void setSelectedPeriod(String period) {
    _selectedPeriod = period;
    _calculateStats();
    notifyListeners();
  }

  void _calculateStats() {
    double totalSalesPaise = 0.0;
    int orders = 0;

    final todayStr = DateTime.now().toString().substring(0, 10); // YYYY-MM-DD

    if (_selectedPeriod == 'Today') {
      final todayEntry = _dailySales.firstWhere(
        (el) => el['period'] == todayStr,
        orElse: () => null,
      );
      if (todayEntry != null) {
        totalSalesPaise = (todayEntry['sales'] ?? 0).toDouble();
        orders = todayEntry['orders'] ?? 0;
      }
    } else if (_selectedPeriod == 'Weekly') {
      final len = _dailySales.length;
      final start = len > 7 ? len - 7 : 0;
      for (var i = start; i < len; i++) {
        totalSalesPaise += (_dailySales[i]['sales'] ?? 0).toDouble();
        orders += (_dailySales[i]['orders'] ?? 0) as int;
      }
    } else if (_selectedPeriod == 'Monthly') {
      final len = _dailySales.length;
      final start = len > 30 ? len - 30 : 0;
      for (var i = start; i < len; i++) {
        totalSalesPaise += (_dailySales[i]['sales'] ?? 0).toDouble();
        orders += (_dailySales[i]['orders'] ?? 0) as int;
      }
    } else if (_selectedPeriod == 'Yearly') {
      for (var el in _dailySales) {
        totalSalesPaise += (el['sales'] ?? 0).toDouble();
        orders += (el['orders'] ?? 0) as int;
      }
    }

    _netSales = totalSalesPaise / 100.0;
    _ordersCount = orders;
  }
}
