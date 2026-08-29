import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/admin_purchase_service.dart';
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
  });
}

class AdminPurchasesViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _purchaseService = locator<AdminPurchaseService>();
  final _supplierService = locator<AdminSupplierService>();
  final _productService = locator<ProductService>();

  String _selectedStatus =
      'All'; // 'All', 'Draft', 'Sent', 'Received', 'Completed'
  String get selectedStatus => _selectedStatus;

  List<PurchaseOrderModel> _purchaseOrders = [];
  List<SupplierModel> _suppliers = [];
  List<ProductModel> _products = [];

  List<PurchaseOrderModel> get filteredPurchaseOrders {
    if (_selectedStatus == 'All') return _purchaseOrders;
    return _purchaseOrders
        .where((po) => po.status.toLowerCase() == _selectedStatus.toLowerCase())
        .toList();
  }

  List<SupplierModel> get suppliers => _suppliers;
  List<ProductModel> get products => _products;

  @override
  Future<void> futureToRun() async {
    await loadPurchases();
    await loadSuppliers();
    await loadProducts();
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
            ? (supplierMap['name'] ?? '')
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
