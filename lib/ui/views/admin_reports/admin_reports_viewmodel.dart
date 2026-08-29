import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/admin_dashboard_service.dart';
import 'package:stacked/stacked.dart';

class AdminReportsViewModel extends FutureViewModel<void> with NavigationMixin {
  final _dashboardService = locator<AdminDashboardService>();

  String _selectedPeriod = 'Weekly'; // 'Today', 'Weekly', 'Monthly', 'Yearly'
  String get selectedPeriod => _selectedPeriod;

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
    await loadData();
  }

  Future<void> loadData() async {
    try {
      _dailySales = await _dashboardService.getSalesChart('daily');
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
