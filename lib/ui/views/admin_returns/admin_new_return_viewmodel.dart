import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/product_service.dart';
import 'package:spare_shop_admin/core/services/return_exchange_service.dart';
import 'package:spare_shop_admin/ui/common/return_exchange_models.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

class ItemFormState {
  final BillItemProcessedSummary item;
  AfterSalesAction action = AfterSalesAction.none;
  int quantity = 1;

  // Return fields
  String returnReason = 'Wrong Product';
  String condition = 'unused';
  String inventoryDisposition = 'sellable';
  bool refundRequired = false;
  String refundMethod = 'cash';

  // Damage fields
  String damageType = 'physical';
  String damageDiscoveredAt = 'customer';
  String damageResolution = 'no_refund';
  String damageReason = 'Physical damage discovered';

  // Exchange fields
  String exchangeReason = 'Incorrect Fitment';
  ProductModel? replacementProduct;
  int replacementQuantity = 1;

  String notes = '';

  ItemFormState({required this.item}) {
    quantity = item.availableQty > 0 ? 1 : 0;
  }

  double get originalValue => item.unitPrice * quantity;

  double get replacementValue {
    if (replacementProduct == null) return 0;
    return replacementProduct!.price * replacementQuantity;
  }

  double get exchangeDifference => replacementValue - originalValue;
}

class AdminNewReturnViewModel extends BaseViewModel with NavigationMixin {
  final _returnsService = locator<ReturnExchangeService>();
  final _productService = locator<ProductService>();

  final searchController = TextEditingController();
  final adminNotesController = TextEditingController();

  BillLookupResult? _bill;
  BillLookupResult? get bill => _bill;

  List<ItemFormState> _itemForms = [];
  List<ItemFormState> get itemForms => _itemForms;

  List<ProductModel> _allProducts = [];
  List<ProductModel> get allProducts => _allProducts;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _initialized = false;

  void handleBack() {
    try {
      navigationService.back();
    } catch (_) {
      goToReturnsExchanges();
    }
  }

  void initialize(String? prefillBill) async {
    if (_initialized) return;
    _initialized = true;

    try {
      _allProducts = await _productService.getProducts();
      notifyListeners();
    } catch (_) {}

    if (prefillBill != null && prefillBill.isNotEmpty) {
      searchController.text = prefillBill;
      await searchBill();
    }
  }

  Future<void> searchBill() async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;

    setBusy(true);
    _errorMessage = null;
    try {
      _bill = await _returnsService.searchBill(query);
      _itemForms = _bill!.items.map((i) => ItemFormState(item: i)).toList();
      notifyListeners();
    } catch (e) {
      _bill = null;
      _itemForms = [];
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  void setItemAction(ItemFormState form, AfterSalesAction action) {
    form.action = action;
    if (action == AfterSalesAction.returnAction) {
      form.refundRequired = true;
    }
    notifyListeners();
  }

  void setItemQuantity(ItemFormState form, int qty) {
    if (qty >= 1 && qty <= form.item.availableQty) {
      form.quantity = qty;
      notifyListeners();
    }
  }

  void setItemReturnReason(ItemFormState form, String reason) {
    form.returnReason = reason;
    notifyListeners();
  }

  void setItemCondition(ItemFormState form, String condition) {
    form.condition = condition;
    notifyListeners();
  }

  void setItemDisposition(ItemFormState form, String disposition) {
    form.inventoryDisposition = disposition;
    notifyListeners();
  }

  void setItemRefundRequired(ItemFormState form, bool required) {
    form.refundRequired = required;
    notifyListeners();
  }

  void setItemRefundMethod(ItemFormState form, String method) {
    form.refundMethod = method;
    notifyListeners();
  }

  void setItemDamageType(ItemFormState form, String type) {
    form.damageType = type;
    notifyListeners();
  }

  void setItemDamageDiscoveredAt(ItemFormState form, String place) {
    form.damageDiscoveredAt = place;
    notifyListeners();
  }

  void setItemDamageResolution(ItemFormState form, String res) {
    form.damageResolution = res;
    notifyListeners();
  }

  void setItemReplacementProduct(ItemFormState form, ProductModel? product) {
    form.replacementProduct = product;
    notifyListeners();
  }

  void setItemReplacementQuantity(ItemFormState form, int qty) {
    if (qty >= 1) {
      form.replacementQuantity = qty;
      notifyListeners();
    }
  }

  int get configuredItemsCount {
    return _itemForms.where((f) => f.action != AfterSalesAction.none).length;
  }

  double get calculatedTotalRefund {
    double sum = 0.0;
    for (final f in _itemForms) {
      if (f.action == AfterSalesAction.returnAction && f.refundRequired) {
        sum += f.originalValue;
      } else if (f.action == AfterSalesAction.damage && f.damageResolution == 'refund') {
        sum += f.originalValue;
      } else if (f.action == AfterSalesAction.exchange && f.exchangeDifference < 0) {
        sum += f.exchangeDifference.abs();
      }
    }
    return sum;
  }

  double get calculatedTotalPayable {
    double sum = 0.0;
    for (final f in _itemForms) {
      if (f.action == AfterSalesAction.exchange && f.exchangeDifference > 0) {
        sum += f.exchangeDifference;
      }
    }
    return sum;
  }

  bool get canSubmit {
    if (_bill == null || isBusy) return false;
    final activeForms = _itemForms.where((f) => f.action != AfterSalesAction.none).toList();
    if (activeForms.isEmpty) return false;

    for (final f in activeForms) {
      if (f.quantity <= 0 || f.quantity > f.item.availableQty) return false;
      if (f.action == AfterSalesAction.exchange && f.replacementProduct == null) {
        return false;
      }
    }
    return true;
  }

  Future<void> submitCase(BuildContext context) async {
    if (!canSubmit) return;

    setBusy(true);
    _errorMessage = null;

    try {
      final activeForms = _itemForms.where((f) => f.action != AfterSalesAction.none).toList();

      final itemsPayload = activeForms.map((f) {
        final Map<String, dynamic> itemMap = {
          'orderItemId': f.item.orderItemId,
          'action': f.action.apiValue,
          'quantity': f.quantity,
          'condition': f.condition,
          'inventoryDisposition': f.inventoryDisposition,
          'notes': f.notes,
        };

        if (f.action == AfterSalesAction.returnAction) {
          itemMap['reasonText'] = f.returnReason;
          itemMap['refundRequired'] = f.refundRequired;
          itemMap['refundMethod'] = f.refundMethod;
        } else if (f.action == AfterSalesAction.damage) {
          itemMap['reasonText'] = f.damageReason;
          itemMap['damageType'] = f.damageType;
          itemMap['damageDiscoveredAt'] = f.damageDiscoveredAt;
          itemMap['damageResolution'] = f.damageResolution;
          itemMap['inventoryDisposition'] = 'damaged';
        } else if (f.action == AfterSalesAction.exchange) {
          itemMap['reasonText'] = f.exchangeReason;
          itemMap['replacementProductId'] = f.replacementProduct?.id;
          itemMap['replacementQuantity'] = f.replacementQuantity;
        }

        return itemMap;
      }).toList();

      final payload = {
        'orderId': _bill!.orderId,
        'items': itemsPayload,
        'adminNotes': adminNotesController.text.trim(),
      };

      final createdCase = await _returnsService.createCase(payload);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Case ${createdCase.caseNumber} created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Navigate to detail
      await goToReturnDetail(caseId: createdCase.id);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Failed to create case'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    adminNotesController.dispose();
    super.dispose();
  }
}
