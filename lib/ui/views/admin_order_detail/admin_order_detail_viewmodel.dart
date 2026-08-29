import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/order_service.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

class AdminOrderDetailViewModel extends BaseViewModel with NavigationMixin {
  final _orderService = locator<OrderService>();
  late OrderModel _order;
  OrderModel get order => _order;

  void initialize(OrderModel order) {
    _order = order;
  }

  Future<void> updateOrderStatus(OrderStatus status) async {
    setBusy(true);
    try {
      String statusStr = 'pending';
      if (status == OrderStatus.shipped) {
        statusStr = 'shipped';
      } else if (status == OrderStatus.delivered) {
        statusStr = 'delivered';
      } else if (status == OrderStatus.cancelled) {
        statusStr = 'cancelled';
      }

      final updated =
          await _orderService.adminUpdateOrderStatus(_order.id, statusStr);
      _order = updated;
      rebuildUi();
    } catch (e) {
      print('Error updating order status: $e');
    } finally {
      setBusy(false);
    }
  }

  void markOutForDelivery() {
    updateOrderStatus(OrderStatus.shipped);
  }
}
