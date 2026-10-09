import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/location_service.dart';
import 'package:spare_shop_admin/core/services/order_service.dart';
import 'package:spare_shop_admin/core/services/token_service.dart';
import 'package:spare_shop_admin/core/services/invoice_service.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_invoice_dialog.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/core/utils/hub_matching_helper.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:spare_shop_admin/ui/common/voltspare_mock_data.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

class AdminOrdersViewModel extends FutureViewModel<void> with NavigationMixin {
  final _orderService = locator<OrderService>();
  final _locationService = locator<LocationService>();
  final _tokenService = locator<TokenService>();
  final _invoiceService = locator<InvoiceService>();

  String _searchQuery = '';
  OrderStatus? _selectedStatus;
  String _selectedLocationFilter = 'all'; // 'all', locationId, or 'unassigned'
  String _selectedChannelFilter = 'all'; // 'all', 'app', 'pos'

  String get searchQuery => _searchQuery;
  OrderStatus? get selectedStatus => _selectedStatus;
  String get selectedLocationFilter => _selectedLocationFilter;
  String get selectedChannelFilter => _selectedChannelFilter;

  List<LocationModel> _locations = [];
  List<LocationModel> get locations => _locations;

  bool _canChangeLocation = true;
  bool get canChangeLocation => _canChangeLocation;

  String? _userAssignedLocationId;
  String? get userAssignedLocationId => _userAssignedLocationId;

  String? _userAssignedLocationName;
  String? get userAssignedLocationName => _userAssignedLocationName;

  List<OrderModel> _allOrders = [];

  List<OrderModel> get filteredOrders {
    if (_selectedLocationFilter == '__none__') return [];
    return _allOrders.where((order) {
      final matchesSearch = order.orderNumber
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          order.address.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (order.locationName ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      final matchesStatus =
          _selectedStatus == null || order.status == _selectedStatus;

      bool matchesLocation = true;
      if (_selectedLocationFilter == 'unassigned') {
        matchesLocation = order.locationId == null || order.locationId!.isEmpty;
      } else if (_selectedLocationFilter != 'all') {
        matchesLocation = (order.locationId == _selectedLocationFilter) ||
            (order.locationName != null &&
                order.locationName!.isNotEmpty &&
                _locations.any((l) =>
                    l.id == _selectedLocationFilter &&
                    l.name.toLowerCase() == order.locationName!.toLowerCase()));
      }

      bool matchesChannel = true;
      if (_selectedChannelFilter == 'app') {
        matchesChannel = order.isAppOrder;
      } else if (_selectedChannelFilter == 'pos') {
        matchesChannel = order.isPosOrder;
      }

      return matchesSearch &&
          matchesStatus &&
          matchesLocation &&
          matchesChannel;
    }).toList();
  }

  bool _matchesLocation(OrderModel order) {
    if (_selectedLocationFilter == 'unassigned') {
      return order.locationId == null || order.locationId!.isEmpty;
    } else if (_selectedLocationFilter != 'all') {
      return (order.locationId == _selectedLocationFilter) ||
          (order.locationName != null &&
              order.locationName!.isNotEmpty &&
              _locations.any((l) =>
                  l.id == _selectedLocationFilter &&
                  l.name.toLowerCase() == order.locationName!.toLowerCase()));
    }
    return true;
  }

  // Status & channel count getters with notification counts
  int countByStatus(OrderStatus? status) {
    if (_selectedLocationFilter == '__none__') return 0;
    return _allOrders.where((order) {
      if (status != null && order.status != status) return false;
      if (!_matchesLocation(order)) return false;

      if (_selectedChannelFilter == 'app') {
        if (!order.isAppOrder) return false;
      } else if (_selectedChannelFilter == 'pos') {
        if (!order.isPosOrder) return false;
      }

      return true;
    }).length;
  }

  int get allOrdersCount => countByStatus(null);
  int get processingOrdersCount => countByStatus(OrderStatus.processing);
  int get shippedOrdersCount => countByStatus(OrderStatus.shipped);
  int get deliveredOrdersCount => countByStatus(OrderStatus.delivered);
  int get cancelledOrdersCount => countByStatus(OrderStatus.cancelled);

  int get appOrdersCount {
    if (_selectedLocationFilter == '__none__') return 0;
    return _allOrders.where((o) => o.isAppOrder && _matchesLocation(o)).length;
  }

  int get posOrdersCount {
    if (_selectedLocationFilter == '__none__') return 0;
    return _allOrders.where((o) => o.isPosOrder && _matchesLocation(o)).length;
  }

  // Count unassigned orders
  int get unassignedOrdersCount => _allOrders
      .where((o) => o.locationId == null || o.locationId!.isEmpty)
      .length;

  bool _initialized = false;

  @override
  Future<void> futureToRun() async {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    TokenService.locationNotifier.addListener(_onLocationNotifierChanged);

    OrderService.newOrderNotifier.removeListener(_onNewOrderReceived);
    OrderService.newOrderNotifier.addListener(_onNewOrderReceived);

    OrderService.orderRefreshNotifier.removeListener(_onOrderRefresh);
    OrderService.orderRefreshNotifier.addListener(_onOrderRefresh);

    if (_initialized) return;
    _initialized = true;
    await loadOrders();
  }

  void _onLocationNotifierChanged() {
    final newLocId = TokenService.locationNotifier.locationId;
    _selectedLocationFilter =
        (newLocId != null && newLocId.isNotEmpty) ? newLocId : 'all';
    loadOrders();
  }

  void _onOrderRefresh() {
    loadOrders();
  }

  void _onNewOrderReceived() {
    final newOrder = OrderService.newOrderNotifier.value;
    if (newOrder != null) {
      final existingIndex = _allOrders.indexWhere((o) => o.id == newOrder.id);
      if (existingIndex == -1) {
        final resolved =
            HubMatchingHelper.resolveOrderLocation(newOrder, _locations);
        _allOrders.insert(0, resolved);
        rebuildUi();
      } else {
        loadOrders();
      }
    }
  }

  @override
  void dispose() {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    OrderService.newOrderNotifier.removeListener(_onNewOrderReceived);
    OrderService.orderRefreshNotifier.removeListener(_onOrderRefresh);
    super.dispose();
  }

  Future<void> loadOrders() async {
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
          (_userAssignedLocationId == null ||
              _userAssignedLocationId!.isEmpty)) {
        _selectedLocationFilter = '__none__';
      } else if (_userAssignedLocationId != null &&
          _userAssignedLocationId!.isNotEmpty &&
          _userAssignedLocationId != 'all') {
        _selectedLocationFilter = _userAssignedLocationId!;
      } else if (_selectedLocationFilter != 'unassigned') {
        _selectedLocationFilter = 'all';
      }

      if (_selectedLocationFilter == '__none__') {
        _allOrders = [];
        rebuildUi();
        return;
      }

      final fetchedOrders = await _orderService.adminGetAllOrders(
        locationId: _selectedLocationFilter != 'all' &&
                _selectedLocationFilter != 'unassigned'
            ? _selectedLocationFilter
            : null,
      );

      _allOrders = fetchedOrders;

      // Auto-resolve missing or unassigned locations based on address and known hubs
      for (int i = 0; i < _allOrders.length; i++) {
        final ord = _allOrders[i];
        final resolved =
            HubMatchingHelper.resolveOrderLocation(ord, _locations);
        if (resolved.locationId != ord.locationId ||
            resolved.locationName != ord.locationName) {
          _allOrders[i] = resolved;
          // Asynchronously persist auto-matched hub to backend if it was previously unassigned
          if (ord.locationId == null || ord.locationId!.isEmpty) {
            _orderService
                .adminUpdateOrderLocation(
                  resolved.id,
                  locationId: resolved.locationId,
                  locationName: resolved.locationName,
                )
                .catchError((_) => resolved);
          }
        }
      }

      OrderService.processingCountNotifier.value =
          _allOrders.where((o) => o.status == OrderStatus.processing).length;
      rebuildUi();
    } catch (e) {
      debugPrint('Error loading admin orders: $e');
      if (_allOrders.isEmpty) {
        _allOrders = List.from(mockOrderList);
        for (int i = 0; i < _allOrders.length; i++) {
          _allOrders[i] =
              HubMatchingHelper.resolveOrderLocation(_allOrders[i], _locations);
        }
        OrderService.processingCountNotifier.value =
            _allOrders.where((o) => o.status == OrderStatus.processing).length;
      }
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

  void setSelectedChannelFilter(String channel) {
    _selectedChannelFilter = channel;
    notifyListeners();
  }

  void setSelectedLocationFilter(String locationId) {
    _selectedLocationFilter = locationId;
    if (_canChangeLocation) {
      locator<TokenService>().saveUserLocation(
        locationId: locationId == 'all' || locationId == 'unassigned'
            ? null
            : locationId,
        locationName: locationId != 'all' &&
                locationId != 'unassigned' &&
                _locations.any((l) => l.id == locationId)
            ? _locations.firstWhere((l) => l.id == locationId).name
            : 'All Locations (HQ)',
      );
    }
    loadOrders();
  }

  Future<void> assignOrderLocation(
      OrderModel order, LocationModel? location) async {
    try {
      final updatedOrder = await _orderService.adminUpdateOrderLocation(
        order.id,
        locationId: location?.id,
        locationName: location?.name,
      );

      final index = _allOrders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _allOrders[index] = updatedOrder.copyWith(
          locationId: location?.id,
          locationName: location?.name,
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error assigning order location: $e');
      // Local in-memory update fallback
      final index = _allOrders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _allOrders[index] = order.copyWith(
          locationId: location?.id,
          locationName: location?.name,
        );
        notifyListeners();
      }
    }
  }

  Future<void> openOrderDetail(OrderModel order) async {
    await goToAdminOrderDetail(order: order);
    await loadOrders();
  }

  Future<void> viewInvoice(BuildContext context, OrderModel order) async {
    try {
      await _invoiceService.loadBusinessSettings();
      InvoiceModel? invoice;
      try {
        invoice = await _invoiceService.fetchInvoiceFromBackend(order.id);
      } catch (_) {}
      invoice ??= _invoiceService.createInvoiceFromOrder(order);
      if (context.mounted) {
        AdminInvoiceDialog.show(context, invoice);
      }
    } catch (e) {
      debugPrint('Error viewing invoice: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to generate invoice: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> downloadInvoice(BuildContext context, OrderModel order) async {
    try {
      await _invoiceService.loadBusinessSettings();
      InvoiceModel? invoice;
      try {
        invoice = await _invoiceService.fetchInvoiceFromBackend(order.id);
      } catch (_) {}
      invoice ??= _invoiceService.createInvoiceFromOrder(order);
      await _invoiceService.printOrDownloadInvoice(invoice);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generating PDF for ${invoice.invoiceNumber}...'),
            backgroundColor: AdminColors.primaryGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error downloading invoice: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
