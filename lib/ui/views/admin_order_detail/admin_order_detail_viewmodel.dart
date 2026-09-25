import 'package:flutter/foundation.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/location_service.dart';
import 'package:spare_shop_admin/core/services/order_service.dart';
import 'package:spare_shop_admin/core/services/return_exchange_service.dart';
import 'package:spare_shop_admin/core/utils/hub_matching_helper.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:spare_shop_admin/ui/common/return_exchange_models.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

class AdminOrderDetailViewModel extends BaseViewModel with NavigationMixin {
  final _orderService = locator<OrderService>();
  final _returnsService = locator<ReturnExchangeService>();
  final _locationService = locator<LocationService>();

  late OrderModel _order;
  OrderModel get order => _order;

  List<ReturnExchangeCase> _linkedCases = [];
  List<ReturnExchangeCase> get linkedCases => _linkedCases;

  List<LocationModel> _locations = [];
  List<LocationModel> get locations => _locations;

  void initialize(OrderModel order) {
    _order = order;
    refreshOrder();
    loadLinkedCases();
    loadLocations();
  }

  Future<void> loadLocations() async {
    try {
      _locations = await _locationService.getLocations();
      final resolved =
          HubMatchingHelper.resolveOrderLocation(_order, _locations);
      if (resolved.locationId != _order.locationId ||
          resolved.locationName != _order.locationName) {
        _order = resolved;
        if (resolved.locationId != null && resolved.locationId!.isNotEmpty) {
          _orderService
              .adminUpdateOrderLocation(
                _order.id,
                locationId: resolved.locationId,
                locationName: resolved.locationName,
              )
              .catchError((_) => resolved);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading locations in order detail: $e');
    }
  }

  Future<void> updateOrderLocation(LocationModel? location) async {
    setBusy(true);
    try {
      final updated = await _orderService.adminUpdateOrderLocation(
        _order.id,
        locationId: location?.id,
        locationName: location?.name,
      );
      _order = updated.copyWith(
        locationId: location?.id,
        locationName: location?.name,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating order location: $e');
      _order = _order.copyWith(
        locationId: location?.id,
        locationName: location?.name,
      );
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<void> loadLinkedCases() async {
    try {
      _linkedCases = await _returnsService.getCases(search: _order.orderNumber);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading linked RMA cases: $e');
    }
  }

  Future<void> refreshOrder() async {
    try {
      final fresh = await _orderService.adminGetOrderById(_order.id);
      _order = fresh;
      loadLinkedCases();
      rebuildUi();
    } catch (e) {
      debugPrint('Error refreshing order: $e');
    }
  }

  Future<void> initiateReturn() async {
    await goToNewReturn(prefillBill: _order.orderNumber);
    await loadLinkedCases();
  }

  Future<void> openCaseDetail(ReturnExchangeCase kase) async {
    await goToReturnDetail(caseId: kase.id);
    await loadLinkedCases();
  }

  Future<void> updateOrderStatus(OrderStatus status) async {
    if (isBusy) return;
    setBusy(true);
    try {
      String statusStr = 'processing';
      if (status == OrderStatus.shipped) {
        statusStr = 'shipped';
      } else if (status == OrderStatus.delivered) {
        statusStr = 'delivered';
      } else if (status == OrderStatus.cancelled) {
        statusStr = 'cancelled';
      } else {
        statusStr = 'processing';
      }

      final updated =
          await _orderService.adminUpdateOrderStatus(_order.id, statusStr);
      _order = updated;
      rebuildUi();
    } catch (e) {
      debugPrint('Error updating order status: $e');
    } finally {
      setBusy(false);
    }
  }

  void markOutForDelivery() {
    updateOrderStatus(OrderStatus.shipped);
  }
}
