import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/admin_purchase_service.dart';
import 'package:spare_shop_admin/core/services/location_service.dart';
import 'package:spare_shop_admin/core/services/token_service.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:stacked/stacked.dart';

import 'package:spare_shop_admin/core/services/admin_supplier_service.dart';
import 'package:spare_shop_admin/core/services/product_service.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';

class PurchaseOrderModel {
  final String id;
  final String poNumber;
  final String supplier;
  final String supplierId;
  final String productId;
  final int quantity;
  final double unitPrice;
  final int itemCount;
  final double amount;
  final String status; // 'Draft', 'Sent', 'Received', 'Completed'
  final String expectedDate;
  final String notes;
  final String? locationId;
  final String? locationName;

  PurchaseOrderModel({
    required this.id,
    required this.poNumber,
    required this.supplier,
    required this.supplierId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.itemCount,
    required this.amount,
    required this.status,
    required this.expectedDate,
    required this.notes,
    this.locationId,
    this.locationName,
  });

  PurchaseOrderModel copyWith({
    String? id,
    String? poNumber,
    String? supplier,
    String? supplierId,
    String? productId,
    int? quantity,
    double? unitPrice,
    int? itemCount,
    double? amount,
    String? status,
    String? expectedDate,
    String? notes,
    String? locationId,
    String? locationName,
  }) {
    return PurchaseOrderModel(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      supplier: supplier ?? this.supplier,
      supplierId: supplierId ?? this.supplierId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      itemCount: itemCount ?? this.itemCount,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      expectedDate: expectedDate ?? this.expectedDate,
      notes: notes ?? this.notes,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
    );
  }
}

class AdminPurchasesViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _purchaseService = locator<AdminPurchaseService>();
  final _supplierService = locator<AdminSupplierService>();
  final _productService = locator<ProductService>();
  final _locationService = locator<LocationService>();
  final _tokenService = locator<TokenService>();

  String _selectedStatus =
      'All'; // 'All', 'Draft', 'Sent', 'Received', 'Completed'
  String get selectedStatus => _selectedStatus;

  String _selectedLocationFilter = 'all'; // 'all', 'unassigned', or locationId
  String get selectedLocationFilter => _selectedLocationFilter;

  List<LocationModel> _locations = [];
  List<LocationModel> get locations => _locations;

  bool _canChangeLocation = true;
  bool get canChangeLocation => _canChangeLocation;

  String? _userAssignedLocationId;
  String? get userAssignedLocationId => _userAssignedLocationId;

  String? _userAssignedLocationName;
  String? get userAssignedLocationName => _userAssignedLocationName;

  List<PurchaseOrderModel> _purchaseOrders = [];
  List<SupplierModel> _suppliers = [];
  List<ProductModel> _products = [];

  List<PurchaseOrderModel> get filteredPurchaseOrders {
    if (_selectedLocationFilter == '__none__') return [];

    return _purchaseOrders.where((po) {
      // 1. Status Filter
      if (_selectedStatus != 'All' &&
          po.status.toLowerCase() != _selectedStatus.toLowerCase()) {
        return false;
      }

      // 2. Location Filter
      if (_selectedLocationFilter == 'unassigned') {
        return po.locationId == null ||
            po.locationId!.isEmpty ||
            po.locationName == null ||
            po.locationName!.isEmpty;
      } else if (_selectedLocationFilter != 'all') {
        final loc = _locations.where((l) => l.id == _selectedLocationFilter);
        final locName = loc.isNotEmpty ? loc.first.name.toLowerCase() : '';
        final matchesId = po.locationId == _selectedLocationFilter;
        final matchesName = locName.isNotEmpty &&
            po.locationName != null &&
            po.locationName!.isNotEmpty &&
            po.locationName!.toLowerCase() == locName;
        return matchesId || matchesName;
      }

      return true;
    }).toList();
  }

  int get unassignedPOCount => _purchaseOrders
      .where((p) =>
          p.locationId == null ||
          p.locationId!.isEmpty ||
          p.locationName == null ||
          p.locationName!.isEmpty)
      .length;

  List<SupplierModel> get suppliers => _suppliers;
  List<ProductModel> get products => _products;

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

    await loadPurchases();
    await loadSuppliers();
    await loadProducts();
  }

  void _onLocationNotifierChanged() {
    final newLocId = TokenService.locationNotifier.locationId;
    _selectedLocationFilter = (newLocId != null && newLocId.isNotEmpty) ? newLocId : 'all';
    loadPurchases();
    notifyListeners();
  }

  @override
  void dispose() {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    super.dispose();
  }

  void setSelectedLocationFilter(String filter) {
    _selectedLocationFilter = filter;
    if (_canChangeLocation) {
      locator<TokenService>().saveUserLocation(
        locationId: filter == 'all' || filter == 'unassigned' ? null : filter,
        locationName: filter != 'all' && filter != 'unassigned' && _locations.any((l) => l.id == filter)
            ? _locations.firstWhere((l) => l.id == filter).name
            : 'All Locations (HQ)',
      );
    }
    loadPurchases();
    notifyListeners();
  }

  Future<void> loadSuppliers() async {
    try {
      _suppliers = await _supplierService.getSuppliers();
    } catch (e) {
      print('Error loading suppliers: $e');
    }
  }

  Future<void> loadProducts() async {
    try {
      _products = await _productService.getProducts();
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  Future<void> loadPurchases() async {
    try {
      final list = await _purchaseService.getPurchases();
      _purchaseOrders = list.map((item) {
        final supplierMap = item['supplier'];
        final supplierName = supplierMap is Map
            ? (supplierMap['name'] ?? supplierMap['companyName'] ?? '')
            : supplierMap?.toString() ?? 'Unknown Supplier';
        final supplierId = supplierMap is Map
            ? (supplierMap['_id'] ?? supplierMap['id'] ?? '')
            : supplierMap?.toString() ?? '';

        final itemsList = item['items'] as List<dynamic>? ?? [];
        final int itemCount = itemsList.fold<int>(
            0, (sum, i) => sum + ((i['quantity'] ?? 1) as int));

        final firstItem = itemsList.isNotEmpty ? itemsList.first : {};
        final productId = firstItem['product'] is Map
            ? (firstItem['product']['_id'] ?? firstItem['product']['id'] ?? '')
            : firstItem['product']?.toString() ?? '';
        final int quantity = (firstItem['quantity'] ?? 0) as int;
        final double unitPrice = ((firstItem['unitPrice'] ?? 0) as num) / 100.0;

        final double amount = (item['totalAmount'] ?? 0) / 100.0;

        final locMap = item['location'];
        String? locId;
        String? locName;
        if (locMap is Map) {
          locId = locMap['_id'] ?? locMap['id'];
          locName = locMap['name'];
        } else if (locMap is String) {
          locId = locMap;
        }

        if (locId == null || locId.isEmpty) {
          locId = item['locationId'];
          locName = item['locationName'];
        }

        return PurchaseOrderModel(
          id: item['_id'] ?? item['id'] ?? '',
          poNumber:
              item['poNumber'] ?? item['purchaseOrderNumber'] ?? 'PO-Unknown',
          supplier: supplierName,
          supplierId: supplierId,
          productId: productId,
          quantity: quantity,
          unitPrice: unitPrice,
          itemCount: itemCount,
          amount: amount,
          status: item['status'] ?? 'Draft',
          expectedDate: item['expectedDeliveryDate'] != null
              ? item['expectedDeliveryDate'].toString().split('T')[0]
              : '',
          notes: item['notes'] ?? '',
          locationId: locId,
          locationName: locName,
        );
      }).toList();
      rebuildUi();
    } catch (e) {
      print('Error loading purchases: $e');
    }
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  Future<void> createPurchaseOrder({
    required String supplierId,
    required String productId,
    required int quantity,
    required double unitPrice,
    String? locationId,
    String? locationName,
    String? notes,
    String? expectedDate,
  }) async {
    setBusy(true);
    try {
      final payload = {
        'supplier': supplierId,
        'items': [
          {
            'product': productId,
            'quantity': quantity,
            'unitPrice': (unitPrice * 100).toInt(),
            'taxPercentage': 18,
          }
        ],
        if (locationId != null && locationId.isNotEmpty) 'location': locationId,
        if (locationId != null && locationId.isNotEmpty) 'locationId': locationId,
        if (locationName != null && locationName.isNotEmpty)
          'locationName': locationName,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (expectedDate != null && expectedDate.isNotEmpty)
          'expectedDeliveryDate': expectedDate,
      };
      await _purchaseService.createPurchase(payload);
      await loadPurchases();
    } catch (e) {
      print('Error creating purchase order: $e');
      rethrow;
    } finally {
      setBusy(false);
    }
  }

  Future<void> editPurchaseOrder({
    required String poId,
    required String supplierId,
    required String productId,
    required int quantity,
    required double unitPrice,
    String? locationId,
    String? locationName,
    String? notes,
    String? expectedDate,
  }) async {
    setBusy(true);
    try {
      final payload = {
        'supplier': supplierId,
        'items': [
          {
            'product': productId,
            'quantity': quantity,
            'unitPrice': (unitPrice * 100).toInt(),
            'taxPercentage': 18,
          }
        ],
        'location': locationId,
        'locationId': locationId,
        'locationName': locationName,
        'notes': notes ?? '',
        if (expectedDate != null && expectedDate.isNotEmpty)
          'expectedDeliveryDate': expectedDate,
      };
      await _purchaseService.updatePurchase(poId, payload);
      await loadPurchases();
    } catch (e) {
      print('Error editing purchase order: $e');
      rethrow;
    } finally {
      setBusy(false);
    }
  }

  Future<void> assignPOLocation(
      PurchaseOrderModel po, LocationModel? location) async {
    final updatedList = _purchaseOrders.map((item) {
      if (item.id == po.id) {
        return item.copyWith(
          locationId: location?.id,
          locationName: location?.name,
        );
      }
      return item;
    }).toList();
    _purchaseOrders = updatedList;
    notifyListeners();

    try {
      await _purchaseService.updatePurchase(po.id, {
        'location': location?.id,
        'locationId': location?.id,
        'locationName': location?.name,
      });
    } catch (_) {}
  }

  Future<void> changePOStatus(String poId, String newStatus) async {
    setBusy(true);
    try {
      await _purchaseService.updatePurchaseStatus(poId, newStatus);
      await loadPurchases();
    } catch (e) {
      print('Error updating PO status: $e');
      rethrow;
    } finally {
      setBusy(false);
    }
  }
}
