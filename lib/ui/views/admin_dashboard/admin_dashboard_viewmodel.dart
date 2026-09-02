import 'package:flutter/foundation.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/admin_dashboard_service.dart';
import 'package:spare_shop_admin/core/services/order_service.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

class AdminDashboardViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _dashboardService = locator<AdminDashboardService>();
  final _orderService = locator<OrderService>();

  Map<String, dynamic> _summary = {};
  List<OrderModel> _recentOrders = [];
  List<dynamic> _salesChartData = [];
  List<dynamic> _lowStockProducts = [];

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
  int get lowStockCount => _summary['lowStock'] ?? 0;
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

  @override
  Future<void> futureToRun() async {
    await loadData();
  }

  Future<void> loadData() async {
    try {
      final summaryData = await _dashboardService.getSummary();
      final statsData = await _dashboardService.getQuickStats();
      _summary = {
        ...summaryData,
        ...statsData,
      };

      final list = await _orderService.adminGetAllOrders();
      _recentOrders = list.take(5).toList();

      _salesChartData = await _dashboardService.getSalesChart('daily');
      _lowStockProducts = await _dashboardService.getLowStock();

      rebuildUi();
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    }
  }

  void openOrderDetail(OrderModel order) {
    goToAdminOrderDetail(order: order);
  }
}
