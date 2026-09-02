import 'package:flutter/foundation.dart';
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

  bool _initialized = false;

  @override
  Future<void> futureToRun() async {
    if (_initialized) return;
    _initialized = true;
    await loadOrders();
  }

  Future<void> loadOrders() async {
    setBusy(true);
    try {
      _allOrders = await _orderService.adminGetAllOrders();
      rebuildUi();
    } catch (e) {
      debugPrint('Error loading admin orders: $e');
    } finally {
      setBusy(false);
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

  Future<void> openOrderDetail(OrderModel order) async {
    await goToAdminOrderDetail(order: order);
    await loadOrders();
  }
}
