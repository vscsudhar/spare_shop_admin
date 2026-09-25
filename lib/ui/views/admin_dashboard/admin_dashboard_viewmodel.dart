import 'package:flutter/foundation.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/admin_dashboard_service.dart';
import 'package:spare_shop_admin/core/services/location_service.dart';
import 'package:spare_shop_admin/core/services/order_service.dart';
import 'package:spare_shop_admin/core/services/token_service.dart';
import 'package:spare_shop_admin/core/utils/hub_matching_helper.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

class AdminDashboardViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _dashboardService = locator<AdminDashboardService>();
  final _locationService = locator<LocationService>();
  final _orderService = locator<OrderService>();

  Map<String, dynamic> _summary = {};
  List<OrderModel> _recentOrders = [];
  List<dynamic> _salesChartData = [];
  List<dynamic> _lowStockProducts = [];

  List<LocationModel> _locations = [];
  List<LocationModel> get locations => _locations;

  String? _selectedLocationId;
  String? get selectedLocationId => _selectedLocationId;

  LocationModel? get selectedLocation {
    if (_selectedLocationId == null || _selectedLocationId!.isEmpty)
      return null;
    try {
      return _locations.firstWhere((l) => l.id == _selectedLocationId);
    } catch (_) {
      return null;
    }
  }

  int? _locationTrackedSpares;
  int? _locationInStockCount;
  int? _locationOutOfStockCount;

  bool get isLocationSelected =>
      _selectedLocationId != null && _selectedLocationId!.isNotEmpty;

  int get trackedSparesCount =>
      _locationTrackedSpares ?? (_summary['products'] ?? 0);
  int get inStockCount => _locationInStockCount ?? (_summary['inStock'] ?? 0);
  int get outOfStockCount =>
      _locationOutOfStockCount ?? (_summary['outOfStock'] ?? 0);

  double get todaySales {
    final todayStr = DateTime.now().toString().substring(0, 10);
    final todayEntry = _salesChartData.firstWhere(
      (el) => el['period'] == todayStr,
      orElse: () => null,
    );
    if (todayEntry != null) {
      return (todayEntry['sales'] ?? 0) / 100.0;
    }
    return 0.0;
  }

  int get ordersCount => _summary['orders'] ?? 0;
  int get lowStockCount {
    if (isLocationSelected && _locationTrackedSpares != null) {
      return _lowStockProducts.length;
    }
    return _summary['lowStock'] ?? 0;
  }

  int get pendingRequestsCount => _summary['pendingRareRequests'] ?? 0;
  List<OrderModel> get recentOrders => _recentOrders;
  List<dynamic> get lowStockProducts => _lowStockProducts;

  List<double> get salesChartValues {
    if (_salesChartData.isEmpty) return [0, 0, 0, 0, 0, 0, 0];
    final last7 = _salesChartData.length > 7
        ? _salesChartData.sublist(_salesChartData.length - 7)
        : _salesChartData;
    return last7.map<double>((el) => (el['sales'] ?? 0) / 100.0).toList();
  }

  List<String> get salesChartLabels {
    if (_salesChartData.isEmpty) {
      return ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    }
    final last7 = _salesChartData.length > 7
        ? _salesChartData.sublist(_salesChartData.length - 7)
        : _salesChartData;
    return last7.map<String>((el) {
      final period = el['period'].toString();
      return period.length > 5 ? period.substring(period.length - 5) : period;
    }).toList();
  }

  bool _canChangeLocation = true;
  bool get canChangeLocation => _canChangeLocation;

  @override
  Future<void> futureToRun() async {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    TokenService.locationNotifier.addListener(_onLocationNotifierChanged);

    await loadLocations();
    try {
      final tokenService = locator<TokenService>();
      _canChangeLocation = await tokenService.canChangeLocation();
      final userLocId = await tokenService.getUserLocationId();
      if (!_canChangeLocation && (userLocId == null || userLocId.isEmpty)) {
        _selectedLocationId = '__none__';
      } else {
        _selectedLocationId =
            (userLocId != null && userLocId.isNotEmpty) ? userLocId : null;
      }
    } catch (_) {}
    await loadData();
  }

  void _onLocationNotifierChanged() {
    final newLocId = TokenService.locationNotifier.locationId;
    _selectedLocationId = newLocId;
    loadData();
  }

  @override
  void dispose() {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    super.dispose();
  }

  Future<void> loadLocations() async {
    try {
      _locations = await _locationService.getLocations();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading locations for dashboard: $e');
    }
  }

  Future<void> loadData() async {
    try {
      setBusy(true);
      final locId = _selectedLocationId;

      if (locId == '__none__') {
        _summary = {};
        _recentOrders = [];
        _salesChartData = [];
        _lowStockProducts = [];
        _locationTrackedSpares = 0;
        _locationInStockCount = 0;
        _locationOutOfStockCount = 0;
        rebuildUi();
        return;
      }

      final summaryData = await _dashboardService.getSummary(locationId: locId);
      final statsData =
          await _dashboardService.getQuickStats(locationId: locId);
      _summary = {
        ...summaryData,
        ...statsData,
      };

      final list = await _orderService.adminGetAllOrders(
        locationId: locId != null && locId.isNotEmpty ? locId : null,
      );
      final resolvedList = list.map((ord) {
        final res = HubMatchingHelper.resolveOrderLocation(ord, _locations);
        if (ord.locationId == null || ord.locationId!.isEmpty) {
          if (res.locationId != null && res.locationId!.isNotEmpty) {
            _orderService
                .adminUpdateOrderLocation(
                  res.id,
                  locationId: res.locationId,
                  locationName: res.locationName,
                )
                .catchError((_) => res);
          }
        }
        return res;
      }).toList();

      if (locId != null && locId.isNotEmpty) {
        _recentOrders =
            resolvedList.where((o) => o.locationId == locId).take(5).toList();
      } else {
        _recentOrders = resolvedList.take(5).toList();
      }

      _salesChartData =
          await _dashboardService.getSalesChart('daily', locationId: locId);
      _lowStockProducts =
          await _dashboardService.getLowStock(locationId: locId);

      if (locId != null && locId.isNotEmpty) {
        try {
          final locInv = await _locationService.getLocationInventory(locId);
          _locationTrackedSpares = locInv.totalProducts;
          _locationInStockCount = locInv.inStockCount;
          _locationOutOfStockCount = locInv.outOfStockCount;

          final locationLowStock = locInv.items
              .where((item) => item.quantity < 10)
              .map((item) => {
                    'name': item.productName,
                    'currentStock': item.quantity,
                    'sku': item.sku,
                    'price': item.price,
                  })
              .toList();

          if (locationLowStock.isNotEmpty || _lowStockProducts.isEmpty) {
            _lowStockProducts = locationLowStock;
          }
        } catch (e) {
          debugPrint('Error loading location inventory in dashboard: $e');
        }
      } else {
        _locationTrackedSpares = null;
        _locationInStockCount = null;
        _locationOutOfStockCount = null;
      }

      rebuildUi();
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      setBusy(false);
    }
  }

  void setLocation(String? locationId) {
    if (!_canChangeLocation) return;
    if (_selectedLocationId == locationId) return;
    _selectedLocationId = locationId;
    locator<TokenService>().saveUserLocation(
      locationId: locationId,
      locationName:
          locationId != null && _locations.any((l) => l.id == locationId)
              ? _locations.firstWhere((l) => l.id == locationId).name
              : 'All Locations (HQ)',
    );
    notifyListeners();
    loadData();
  }

  void goToSelectedLocationInventory() {
    final loc = selectedLocation;
    final locId = _selectedLocationId;
    if (locId != null && locId.isNotEmpty) {
      goToAdminLocationInventory(
        locationId: locId,
        location: loc,
      );
    }
  }

  void openOrderDetail(OrderModel order) {
    goToAdminOrderDetail(order: order);
  }
}
