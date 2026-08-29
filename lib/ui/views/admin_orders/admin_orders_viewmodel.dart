import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/order_service.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

class AdminOrdersViewModel extends FutureViewModel<void> with NavigationMixin {
  final _orderService = locator<OrderService>();

  String _searchQuery = '';
  OrderStatus? _selectedStatus;

  String get searchQuery => _searchQuery;
  OrderStatus? get selectedStatus => _selectedStatus;

  List<OrderModel> _allOrders = [];

  List<OrderModel> get filteredOrders {
    return _allOrders.where((order) {
      final matchesSearch = order.orderNumber
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          order.address.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus =
          _selectedStatus == null || order.status == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Future<void> futureToRun() async {
    await loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      _allOrders = await _orderService.adminGetAllOrders();
      rebuildUi();
    } catch (e) {
      print('Error loading admin orders: $e');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(OrderStatus? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void openOrderDetail(OrderModel order) {
    goToAdminOrderDetail(order: order);
  }
}
