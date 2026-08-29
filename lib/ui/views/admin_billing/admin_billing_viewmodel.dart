import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/api_client.dart';
import 'package:spare_shop_admin/core/services/product_service.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

enum PaymentMethod {
  cash,
  upi,
  creditCard,
  debitCard,
  bankTransfer,
  storeCredit,
  other,
}

class PaymentAllocation {
  final String id;
  final PaymentMethod method;
  final double amount;
  final String? referenceNumber;
  final String? note;

  const PaymentAllocation({
    required this.id,
    required this.method,
    required this.amount,
    this.referenceNumber,
    this.note,
  });
}

class AdminBillingViewModel extends BaseViewModel with NavigationMixin {
  final _apiClient = locator<ApiClient>();
  final _productService = locator<ProductService>();

  final List<CartItemModel> _invoiceItems = [];
  List<CartItemModel> get invoiceItems => _invoiceItems;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  double _discount = 0.0;
  double get discount => _discount;

  String _selectedCustomer = 'Walk-in Guest';
  String get selectedCustomer => _selectedCustomer;

  final List<PaymentAllocation> _payments = [];
  List<PaymentAllocation> get payments => _payments;

  PaymentMethod _selectedMethod = PaymentMethod.cash;
  PaymentMethod get selectedMethod => _selectedMethod;

  final amountController = TextEditingController();
  final referenceController = TextEditingController();
  final noteController = TextEditingController();

  List<ProductModel> _allProducts = [];

  List<ProductModel> get searchResults {
    if (_searchQuery.isEmpty) return [];
    return _allProducts
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // Server-side Preview Calculations Cache
  double _serverSubtotal = 0.0;
  double _serverTaxAmount = 0.0;
  double _serverGrandTotal = 0.0;
  double _serverAmountPaid = 0.0;
  double _serverRemainingAmount = 0.0;
  double _serverChangeReturned = 0.0;

  double _taxPercentage = 18.0;
  double get taxPercentage => _taxPercentage;

  void initialize() async {
    amountController.text = remainingAmount.toStringAsFixed(2);
    try {
      _allProducts = await _productService.getProducts();
      await loadPastInvoices();
      await loadTaxPercentage();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadTaxPercentage() async {
    try {
      final response = await _apiClient.get('/settings');
      final data = response.data['data'] ?? {};
      final billing = data['billing'] ?? {};
      _taxPercentage = (billing['taxPercentage'] ?? 18.0).toDouble();
      notifyListeners();
    } catch (e) {
      print('Error loading tax: $e');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedMethod(PaymentMethod method) {
    _selectedMethod = method;
    notifyListeners();
  }

  void addProductToInvoice(ProductModel product) {
    final index =
        _invoiceItems.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _invoiceItems[index] = CartItemModel(
        id: _invoiceItems[index].id,
        product: product,
        quantity: _invoiceItems[index].quantity + 1,
      );
    } else {
      _invoiceItems.add(CartItemModel(
        id: 'inv_${_invoiceItems.length + 1}',
        product: product,
        quantity: 1,
      ));
    }
    _searchQuery = '';
    recalculateFromServer();
  }

  void updateQuantity(CartItemModel item, int quantity) {
    final index = _invoiceItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      if (quantity <= 0) {
        _invoiceItems.removeAt(index);
      } else {
        _invoiceItems[index] = CartItemModel(
          id: item.id,
          product: item.product,
          quantity: quantity,
        );
      }
      recalculateFromServer();
    }
  }

  void removeItem(CartItemModel item) {
    _invoiceItems.removeWhere((i) => i.id == item.id);
    recalculateFromServer();
  }

  void setDiscount(double amt) {
    _discount = amt;
    recalculateFromServer();
  }

  void setSelectedCustomer(String name) {
    _selectedCustomer = name;
    notifyListeners();
  }

  // --- Split Payment Recalculation Bindings ---

  double get billTotal => grandTotal;
  double get totalPaid => _serverAmountPaid;

  double get remainingAmount => _serverRemainingAmount;
  double get changeAmount => _serverChangeReturned;

  bool get isFullyPaid => _serverAmountPaid >= grandTotal && grandTotal > 0;
  bool get hasOverPayment => _serverAmountPaid > grandTotal;

  bool get hasOverPaymentFailure {
    if (!hasOverPayment) return false;
    final nonCashPaid = _payments
        .where((p) => p.method != PaymentMethod.cash)
        .fold<double>(0, (sum, p) => sum + p.amount);
    if (nonCashPaid > grandTotal) return true;
    return false;
  }

  bool get isReferencesValid {
    for (final p in _payments) {
      if (p.method == PaymentMethod.upi &&
          (p.referenceNumber == null || p.referenceNumber!.trim().isEmpty)) {
        return false;
      }
      if ((p.method == PaymentMethod.creditCard ||
              p.method == PaymentMethod.debitCard) &&
          (p.referenceNumber == null || p.referenceNumber!.trim().isEmpty)) {
        return false;
      }
    }
    return true;
  }

  bool get canCompleteSale {
    if (_invoiceItems.isEmpty) return false;

    if (_payments.isNotEmpty) {
      return isFullyPaid && !hasOverPaymentFailure && isReferencesValid;
    }

    if (_selectedMethod == PaymentMethod.upi ||
        _selectedMethod == PaymentMethod.creditCard ||
        _selectedMethod == PaymentMethod.debitCard) {
      final ref = referenceController.text.trim();
      return ref.isNotEmpty;
    }

    return true;
  }

  Future<void> recalculateFromServer() async {
    if (_invoiceItems.isEmpty) {
      _serverSubtotal = 0;
      _serverTaxAmount = 0;
      _serverGrandTotal = 0;
      _serverAmountPaid = 0;
      _serverRemainingAmount = 0;
      _serverChangeReturned = 0;
      amountController.text = '0.00';
      notifyListeners();
      return;
    }

    try {
      final response = await _apiClient.post(
        '/pos/preview',
        data: {
          'items': _invoiceItems
              .map((i) => {
                    'productId': i.product.id,
                    'quantity': i.quantity,
                  })
              .toList(),
          'discountAmount': (_discount * 100).toInt(),
          'paymentAllocations': _payments
              .map((p) => {
                    'method': p.method.name,
                    'amount': (p.amount * 100).toInt(),
                  })
              .toList(),
        },
      );

      final data = response.data['data'];
      _serverSubtotal = (data['subTotal'] ?? 0) / 100.0;
      _serverTaxAmount = (data['taxAmount'] ?? 0) / 100.0;
      _serverGrandTotal = (data['grandTotal'] ?? 0) / 100.0;
      _serverAmountPaid = (data['amountPaid'] ?? 0) / 100.0;
      _serverRemainingAmount = (data['remainingAmount'] ?? 0) / 100.0;
      _serverChangeReturned = (data['changeReturned'] ?? 0) / 100.0;

      amountController.text = _serverRemainingAmount.toStringAsFixed(2);
      rebuildUi();
    } catch (_) {}
  }

  void addPaymentAllocation() {
    final amt = double.tryParse(amountController.text) ?? 0.0;
    if (amt <= 0) return;

    final ref = referenceController.text.trim();
    final note = noteController.text.trim();

    _payments.add(
      PaymentAllocation(
        id: 'pay_${_payments.length + 1}',
        method: _selectedMethod,
        amount: amt,
        referenceNumber: ref.isNotEmpty ? ref : null,
        note: note.isNotEmpty ? note : null,
      ),
    );

    referenceController.clear();
    noteController.clear();
    recalculateFromServer();
  }

  void removePaymentAllocation(PaymentAllocation p) {
    _payments.removeWhere((item) => item.id == p.id);
    recalculateFromServer();
  }

  void clearAllPayments() {
    _payments.clear();
    recalculateFromServer();
  }

  void quickFill(String action) {
    final rem = remainingAmount;
    if (action == 'full') {
      amountController.text = rem.toStringAsFixed(2);
    } else if (action == '50') {
      amountController.text = (rem * 0.5).toStringAsFixed(2);
    } else if (action == '25') {
      amountController.text = (rem * 0.25).toStringAsFixed(2);
    } else if (action == 'exact_cash') {
      _selectedMethod = PaymentMethod.cash;
      amountController.text = rem.toStringAsFixed(2);
    } else if (action == 'clear') {
      amountController.text = '0.00';
    }
    notifyListeners();
  }

  // --- Calculations Getters ---

  double get subtotal => _serverSubtotal;
  double get gstAmount => _serverTaxAmount;
  double get grandTotal => _serverGrandTotal;

  void clearInvoice() {
    _invoiceItems.clear();
    _discount = 0;
    _payments.clear();
    _serverSubtotal = 0;
    _serverTaxAmount = 0;
    _serverGrandTotal = 0;
    _serverAmountPaid = 0;
    _serverRemainingAmount = 0;
    _serverChangeReturned = 0;
    amountController.text = '0.00';
    notifyListeners();
  }

  Future<Map<String, dynamic>?> completeSale() async {
    if (!canCompleteSale) return null;

    if (_payments.isEmpty && grandTotal > 0) {
      final ref = referenceController.text.trim();
      final note = noteController.text.trim();
      _payments.add(
        PaymentAllocation(
          id: 'pay_1',
          method: _selectedMethod,
          amount: grandTotal,
          referenceNumber: ref.isNotEmpty ? ref : null,
          note: note.isNotEmpty ? note : null,
        ),
      );
    }

    setBusy(true);
    try {
      final itemsForReceipt = _invoiceItems
          .map((i) => {
                'name': i.product.name,
                'quantity': i.quantity,
                'unitPrice': i.product.price,
                'totalPrice': i.product.price * i.quantity,
              })
          .toList();

      final response = await _apiClient.post(
        '/pos/checkout',
        data: {
          'customerName': _selectedCustomer,
          'customerPhone': '+91 99000 88000',
          'items': _invoiceItems
              .map((i) => {
                    'productId': i.product.id,
                    'quantity': i.quantity,
                  })
              .toList(),
          'discountAmount': (_discount * 100).toInt(),
          'paymentAllocations': _payments
              .map((p) => {
                    'method': p.method.name,
                    'amount': (p.amount * 100).toInt(),
                  })
              .toList(),
          'notes': 'POS Counter Checkout',
        },
      );

      final data = response.data['data'] ?? {};
      final String invoiceNumber = data['invoiceNumber'] ?? 'INV-UNKNOWN';

      final result = {
        'invoiceNumber': invoiceNumber,
        'customerName': _selectedCustomer,
        'dateStr': DateTime.now().toString().substring(0, 16),
        'subtotal': _serverSubtotal,
        'gstAmount': _serverTaxAmount,
        'discount': _discount,
        'grandTotal': _serverGrandTotal,
        'amountPaid': _serverAmountPaid,
        'changeReturned': _serverChangeReturned,
        'items': itemsForReceipt,
        'payments': _payments
            .map((p) => {
                  'method': p.method.name.toUpperCase(),
                  'amount': p.amount,
                })
            .toList(),
      };

      clearInvoice();
      return result;
    } catch (e) {
      print('Error completing sale: $e');
      return null;
    } finally {
      setBusy(false);
    }
  }

  List<Map<String, dynamic>> _pastInvoices = [];
  List<Map<String, dynamic>> get pastInvoices => _pastInvoices;

  Future<void> loadPastInvoices() async {
    setBusy(true);
    try {
      final response = await _apiClient.get('/pos');
      final rawList = response.data['data'] as List<dynamic>? ?? [];

      _pastInvoices = rawList.map((item) {
        final double subtotal = (item['subTotal'] ?? 0) / 100.0;
        final double gstAmount = (item['taxAmount'] ?? 0) / 100.0;
        final double discount = (item['discountAmount'] ?? 0) / 100.0;
        final double grandTotal = (item['grandTotal'] ?? 0) / 100.0;
        final double amountPaid = (item['amountPaid'] ?? 0) / 100.0;
        final double changeReturned = (item['changeReturned'] ?? 0) / 100.0;

        final rawItems = item['items'] as List<dynamic>? ?? [];
        final items = rawItems.map((i) {
          final prodMap = i['product'];
          final name = prodMap is Map
              ? (prodMap['name'] ?? '')
              : (i['name'] ?? 'Spare Part');
          final unitPrice = (i['unitPrice'] ?? 0) / 100.0;
          final totalPrice = (i['totalPrice'] ?? 0) / 100.0;
          return {
            'name': name,
            'quantity': i['quantity'] ?? 1,
            'unitPrice': unitPrice,
            'totalPrice': totalPrice,
          };
        }).toList();

        final rawPayments = item['paymentAllocations'] as List<dynamic>? ?? [];
        final payments = rawPayments.map((p) {
          return {
            'method': (p['method'] ?? 'CASH').toString().toUpperCase(),
            'amount': (p['amount'] ?? 0) / 100.0,
          };
        }).toList();

        final dateStr = item['createdAt'] != null
            ? item['createdAt'].toString().substring(0, 16).replaceAll('T', ' ')
            : DateTime.now().toString().substring(0, 16);

        return {
          'invoiceNumber': item['invoiceNumber'] ?? 'INV-UNKNOWN',
          'customerName': item['customerName'] ?? 'Walk-in Guest',
          'dateStr': dateStr,
          'subtotal': subtotal,
          'gstAmount': gstAmount,
          'discount': discount,
          'grandTotal': grandTotal,
          'amountPaid': amountPaid,
          'changeReturned': changeReturned,
          'items': items,
          'payments': payments,
        };
      }).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading past invoices: $e');
    } finally {
      setBusy(false);
    }
  }
}
