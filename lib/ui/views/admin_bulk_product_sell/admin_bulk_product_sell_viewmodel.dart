import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/models/bulk_quotation_model.dart';
import 'package:spare_shop_admin/core/services/admin_customer_service.dart';
import 'package:spare_shop_admin/core/services/bulk_quotation_service.dart';
import 'package:spare_shop_admin/core/services/invoice_service.dart';
import 'package:spare_shop_admin/core/services/product_service.dart';
import 'package:spare_shop_admin/core/services/token_service.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AdminBulkProductSellViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _productService = locator<ProductService>();
  final _customerService = locator<AdminCustomerService>();
  final _quotationService = locator<BulkQuotationService>();
  final _invoiceService = locator<InvoiceService>();

  SnackbarService? get _snackbarService =>
      locator.isRegistered<SnackbarService>()
          ? locator<SnackbarService>()
          : null;

  void showFeedback(String message, {bool isError = false}) {
    try {
      _snackbarService?.showSnackbar(
        message: message,
        duration: const Duration(seconds: 3),
      );
    } catch (_) {}
  }

  // --------------------------------------------------------------------------
  // Tab Navigation
  // --------------------------------------------------------------------------
  int _selectedTabIndex =
      0; // 0: Price Setup, 1: Create Quotation / Invoice, 2: Quotations Directory
  int get selectedTabIndex => _selectedTabIndex;

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    if (index == 2) {
      loadQuotations();
    }
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // Core Data
  // --------------------------------------------------------------------------
  List<ProductModel> _allProducts = [];
  List<CategoryModel> _categories = [];
  List<AdminCustomerModel> _customers = [];
  List<BulkQuotationModel> _quotations = [];

  List<ProductModel> get allProducts => _allProducts;
  List<CategoryModel> get categories => _categories;
  List<AdminCustomerModel> get customers => _customers;
  List<BulkQuotationModel> get quotations => _quotations;

  // --------------------------------------------------------------------------
  // TAB 0: Price Management (Least Selling Price 1 & 2)
  // --------------------------------------------------------------------------
  String _searchQuery = '';
  String _categoryFilter = 'All';
  String _statusFilter = 'All';

  String get searchQuery => _searchQuery;
  String get categoryFilter => _categoryFilter;
  String get statusFilter => _statusFilter;

  final Map<String, TextEditingController> _price1Controllers = {};
  final Map<String, TextEditingController> _price2Controllers = {};
  final Set<String> _modifiedProductIds = {};

  Set<String> get modifiedProductIds => _modifiedProductIds;
  int get modifiedCount => _modifiedProductIds.length;

  TextEditingController getPrice1Controller(ProductModel product) {
    if (!_price1Controllers.containsKey(product.id)) {
      final initialVal = product.leastSellingPrice1 > 0
          ? product.leastSellingPrice1.toStringAsFixed(2)
          : '';
      _price1Controllers[product.id] = TextEditingController(text: initialVal);
    }
    return _price1Controllers[product.id]!;
  }

  TextEditingController getPrice2Controller(ProductModel product) {
    if (!_price2Controllers.containsKey(product.id)) {
      final initialVal = product.leastSellingPrice2 > 0
          ? product.leastSellingPrice2.toStringAsFixed(2)
          : '';
      _price2Controllers[product.id] = TextEditingController(text: initialVal);
    }
    return _price2Controllers[product.id]!;
  }

  bool isProductModified(String productId) =>
      _modifiedProductIds.contains(productId);

  void onPriceChanged(String productId) {
    final product = _allProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => const ProductModel(
        id: '',
        name: '',
        price: 0,
        rating: 0,
        description: '',
        categoryId: '',
      ),
    );
    if (product.id.isEmpty) return;

    final p1Text = _price1Controllers[productId]?.text.trim() ?? '';
    final p2Text = _price2Controllers[productId]?.text.trim() ?? '';

    final currentP1 = double.tryParse(p1Text) ?? 0.0;
    final currentP2 = double.tryParse(p2Text) ?? 0.0;

    final origP1 = product.leastSellingPrice1;
    final origP2 = product.leastSellingPrice2;

    final bool changed = (currentP1 - origP1).abs() > 0.001 ||
        (currentP2 - origP2).abs() > 0.001;

    if (changed) {
      _modifiedProductIds.add(productId);
    } else {
      _modifiedProductIds.remove(productId);
    }
    notifyListeners();
  }

  int get totalProducts => _allProducts.length;
  int get tier1ConfiguredCount =>
      _allProducts.where((p) => p.leastSellingPrice1 > 0).length;
  int get tier2ConfiguredCount =>
      _allProducts.where((p) => p.leastSellingPrice2 > 0).length;
  int get fullyConfiguredCount => _allProducts
      .where((p) => p.leastSellingPrice1 > 0 && p.leastSellingPrice2 > 0)
      .length;
  int get unconfiguredCount => _allProducts
      .where((p) => p.leastSellingPrice1 <= 0 || p.leastSellingPrice2 <= 0)
      .length;

  List<ProductModel> get filteredProducts {
    return _allProducts.where((product) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = product.name.toLowerCase().contains(q);
        final matchDesc = product.description.toLowerCase().contains(q);
        final matchBadge =
            product.fitmentBadge?.toLowerCase().contains(q) ?? false;
        final matchType = product.vehicleType.toLowerCase().contains(q);
        if (!matchName && !matchDesc && !matchBadge && !matchType) return false;
      }

      if (_categoryFilter != 'All') {
        if (product.categoryId != _categoryFilter) {
          return false;
        }
      }

      if (_statusFilter != 'All') {
        if (_statusFilter == 'Missing Tier 1' &&
            product.leastSellingPrice1 > 0) {
          return false;
        }
        if (_statusFilter == 'Missing Tier 2' &&
            product.leastSellingPrice2 > 0) {
          return false;
        }
        if (_statusFilter == 'Fully Configured' &&
            (product.leastSellingPrice1 <= 0 ||
                product.leastSellingPrice2 <= 0)) {
          return false;
        }
        if (_statusFilter == 'Modified' &&
            !_modifiedProductIds.contains(product.id)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String catId) {
    _categoryFilter = catId;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  void resetAllDrafts() {
    _modifiedProductIds.clear();
    for (final p in _allProducts) {
      _price1Controllers[p.id]?.text = p.leastSellingPrice1 > 0
          ? p.leastSellingPrice1.toStringAsFixed(2)
          : '';
      _price2Controllers[p.id]?.text = p.leastSellingPrice2 > 0
          ? p.leastSellingPrice2.toStringAsFixed(2)
          : '';
    }
    notifyListeners();
    showFeedback('All draft price edits discarded.');
  }

  Future<void> saveSingleProduct(ProductModel product) async {
    final p1 =
        double.tryParse(_price1Controllers[product.id]?.text.trim() ?? '') ??
            0.0;
    final p2 =
        double.tryParse(_price2Controllers[product.id]?.text.trim() ?? '') ??
            0.0;

    if (p1 > product.price && product.price > 0) {
      showFeedback(
          'Warning: Least Price 1 is higher than regular price (₹${product.price}).',
          isError: true);
    }

    setBusy(true);
    try {
      final updatedProduct = product.copyWith(
        leastSellingPrice1: p1,
        leastSellingPrice2: p2,
      );

      await _productService.updateProduct(product.id, {
        'leastSellingPrice1': p1,
        'leastSellingPrice2': p2,
      });

      final index = _allProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _allProducts[index] = updatedProduct;
      }
      _modifiedProductIds.remove(product.id);
      showFeedback('Bulk prices saved for ${product.name}');
    } catch (e) {
      showFeedback('Failed to save prices: $e', isError: true);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> saveAllModifiedProducts() async {
    if (_modifiedProductIds.isEmpty) return;

    final updates = <Map<String, dynamic>>[];
    final updatedMap = <String, ProductModel>{};

    for (final id in _modifiedProductIds) {
      final product = _allProducts.firstWhere((p) => p.id == id);
      final p1 =
          double.tryParse(_price1Controllers[id]?.text.trim() ?? '') ?? 0.0;
      final p2 =
          double.tryParse(_price2Controllers[id]?.text.trim() ?? '') ?? 0.0;

      updates.add({
        'productId': id,
        'leastSellingPrice1': p1,
        'leastSellingPrice2': p2,
      });

      updatedMap[id] = product.copyWith(
        leastSellingPrice1: p1,
        leastSellingPrice2: p2,
      );
    }

    setBusy(true);
    try {
      try {
        await _productService.bulkUpdatePrices(updates);
      } catch (e) {
        for (final item in updates) {
          final id = item['productId'] as String;
          await _productService.updateProduct(id, {
            'leastSellingPrice1': item['leastSellingPrice1'],
            'leastSellingPrice2': item['leastSellingPrice2'],
          });
        }
      }

      for (int i = 0; i < _allProducts.length; i++) {
        final id = _allProducts[i].id;
        if (updatedMap.containsKey(id)) {
          _allProducts[i] = updatedMap[id]!;
        }
      }

      final count = _modifiedProductIds.length;
      _modifiedProductIds.clear();
      showFeedback(
          'Successfully updated bulk selling prices for $count products.');
    } catch (e) {
      showFeedback('Error saving bulk updates: $e', isError: true);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void applyBulkRule({
    required double tier1DiscountPercent,
    required double tier2DiscountPercent,
    required String targetCategory,
    required bool overwriteExisting,
  }) {
    int updatedCount = 0;
    for (final product in _allProducts) {
      if (targetCategory != 'All' && product.categoryId != targetCategory) {
        continue;
      }

      final currentP1 =
          double.tryParse(_price1Controllers[product.id]?.text.trim() ?? '') ??
              product.leastSellingPrice1;
      final currentP2 =
          double.tryParse(_price2Controllers[product.id]?.text.trim() ?? '') ??
              product.leastSellingPrice2;

      final bool shouldUpdateP1 = overwriteExisting || currentP1 <= 0;
      final bool shouldUpdateP2 = overwriteExisting || currentP2 <= 0;

      if (!shouldUpdateP1 && !shouldUpdateP2) continue;

      final basePrice = product.price;
      if (basePrice <= 0) continue;

      if (shouldUpdateP1) {
        final newP1 = (basePrice * (1.0 - (tier1DiscountPercent / 100.0)))
            .clamp(0.0, basePrice);
        _price1Controllers[product.id] ??= TextEditingController();
        _price1Controllers[product.id]!.text = newP1.toStringAsFixed(2);
      }

      if (shouldUpdateP2) {
        final newP2 = (basePrice * (1.0 - (tier2DiscountPercent / 100.0)))
            .clamp(0.0, basePrice);
        _price2Controllers[product.id] ??= TextEditingController();
        _price2Controllers[product.id]!.text = newP2.toStringAsFixed(2);
      }

      _modifiedProductIds.add(product.id);
      updatedCount++;
    }

    notifyListeners();
    showFeedback(
        'Rule calculated and applied to $updatedCount products. Click "Save Changes" to persist.');
  }

  // --------------------------------------------------------------------------
  // TAB 1: Create B2B Quotation / Invoice
  // --------------------------------------------------------------------------
  AdminCustomerModel? _selectedCustomer;
  AdminCustomerModel? get selectedCustomer => _selectedCustomer;

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerPhoneController = TextEditingController();
  final TextEditingController customerEmailController = TextEditingController();
  final TextEditingController customerGstController = TextEditingController();
  final TextEditingController customerAddressController =
      TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController quotationNotesController = TextEditingController(
    text:
        'Prices valid for 15 days from quotation date. Subject to stock availability.',
  );

  final List<BulkQuotationItemModel> _quotationItems = [];
  List<BulkQuotationItemModel> get quotationItems => _quotationItems;

  String _productPickerSearch = '';
  String get productPickerSearch => _productPickerSearch;

  void setProductPickerSearch(String q) {
    _productPickerSearch = q;
    notifyListeners();
  }

  List<ProductModel> get pickerFilteredProducts {
    if (_productPickerSearch.isEmpty) return _allProducts;
    final q = _productPickerSearch.toLowerCase();
    return _allProducts.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          (p.fitmentBadge?.toLowerCase().contains(q) ?? false) ||
          p.vehicleType.toLowerCase().contains(q);
    }).toList();
  }

  void selectCustomer(AdminCustomerModel? customer) {
    _selectedCustomer = customer;
    if (customer != null) {
      customerNameController.text = customer.name;
      customerPhoneController.text = customer.phone;
      customerEmailController.text = customer.email;
      customerGstController.text = customer.gstNumber;
      customerAddressController.text = customer.address;
      businessNameController.text = customer.type.contains('Workshop') ||
              customer.type.contains('Wholesale')
          ? customer.name
          : '';
    }
    notifyListeners();
  }

  void clearCustomerSelection() {
    _selectedCustomer = null;
    customerNameController.clear();
    customerPhoneController.clear();
    customerEmailController.clear();
    customerGstController.clear();
    customerAddressController.clear();
    businessNameController.clear();
    notifyListeners();
  }

  void addItemToQuotation(
    ProductModel product, {
    int quantity = 1,
    PriceTierType tier = PriceTierType.retail,
    double? customPrice,
  }) {
    final existingIndex =
        _quotationItems.indexWhere((item) => item.productId == product.id);
    if (existingIndex != -1) {
      final existing = _quotationItems[existingIndex];
      _quotationItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      _quotationItems.add(
        BulkQuotationItemModel.fromProduct(
          product,
          quantity: quantity,
          tier: tier,
          customPrice: customPrice,
        ),
      );
    }
    notifyListeners();
  }

  void removeItemFromQuotation(int index) {
    if (index >= 0 && index < _quotationItems.length) {
      _quotationItems.removeAt(index);
      notifyListeners();
    }
  }

  void updateItemQuantity(int index, int newQty) {
    if (index >= 0 && index < _quotationItems.length) {
      if (newQty <= 0) {
        removeItemFromQuotation(index);
      } else {
        _quotationItems[index] =
            _quotationItems[index].copyWith(quantity: newQty);
        notifyListeners();
      }
    }
  }

  void updateItemPriceTier(int index, PriceTierType tier,
      {double? customPrice}) {
    if (index >= 0 && index < _quotationItems.length) {
      final item = _quotationItems[index];
      double newUnitPrice;
      switch (tier) {
        case PriceTierType.least1:
          newUnitPrice = item.leastSellingPrice1 > 0
              ? item.leastSellingPrice1
              : item.retailPrice;
          break;
        case PriceTierType.least2:
          newUnitPrice = item.leastSellingPrice2 > 0
              ? item.leastSellingPrice2
              : (item.leastSellingPrice1 > 0
                  ? item.leastSellingPrice1
                  : item.retailPrice);
          break;
        case PriceTierType.custom:
          newUnitPrice = customPrice ?? item.unitPrice;
          break;
        case PriceTierType.retail:
          newUnitPrice = item.retailPrice;
          break;
      }

      _quotationItems[index] = item.copyWith(
        priceTier: tier,
        unitPrice: newUnitPrice,
      );
      notifyListeners();
    }
  }

  void updateItemCustomPrice(int index, double customPrice) {
    if (index >= 0 && index < _quotationItems.length) {
      _quotationItems[index] = _quotationItems[index].copyWith(
        priceTier: PriceTierType.custom,
        unitPrice: customPrice,
      );
      notifyListeners();
    }
  }

  void clearQuotationForm() {
    clearCustomerSelection();
    _quotationItems.clear();
    quotationNotesController.text =
        'Prices valid for 15 days from quotation date. Subject to stock availability.';
    notifyListeners();
  }

  double get quotationSubtotal =>
      _quotationItems.fold(0.0, (sum, i) => sum + i.totalTaxable);
  double get quotationTotalTax =>
      _quotationItems.fold(0.0, (sum, i) => sum + i.taxAmount);
  double get quotationGrandTotal =>
      _quotationItems.fold(0.0, (sum, i) => sum + i.grandTotal);

  Future<BulkQuotationModel?> createQuotation() async {
    final name = customerNameController.text.trim();
    final phone = customerPhoneController.text.trim();

    if (name.isEmpty) {
      showFeedback('Please enter or select a customer name.', isError: true);
      return null;
    }
    if (phone.isEmpty) {
      showFeedback('Please enter customer phone number.', isError: true);
      return null;
    }
    if (_quotationItems.isEmpty) {
      showFeedback('Please add at least one product item to the quotation.',
          isError: true);
      return null;
    }

    setBusy(true);
    try {
      final quotationNum =
          await _quotationService.generateNextQuotationNumber();
      final quotation = BulkQuotationModel(
        id: 'quo_${DateTime.now().millisecondsSinceEpoch}',
        quotationNumber: quotationNum,
        customerId: _selectedCustomer?.id ??
            'cust_${DateTime.now().millisecondsSinceEpoch}',
        customerName: name,
        customerPhone: phone,
        customerEmail: customerEmailController.text.trim(),
        customerGst: customerGstController.text.trim().toUpperCase(),
        customerAddress: customerAddressController.text.trim(),
        businessName: businessNameController.text.trim(),
        items: List.from(_quotationItems),
        subtotal: quotationSubtotal,
        totalTax: quotationTotalTax,
        grandTotal: quotationGrandTotal,
        status: 'Quotation',
        notes: quotationNotesController.text.trim(),
        createdAt: DateTime.now(),
      );

      final saved = await _quotationService.saveQuotation(quotation);
      await loadQuotations();
      showFeedback('Quotation $quotationNum generated successfully!');
      return saved;
    } catch (e) {
      showFeedback('Failed to generate quotation: $e', isError: true);
      return null;
    } finally {
      setBusy(false);
    }
  }

  Future<InvoiceModel?> createDirectB2BInvoice() async {
    final quotation = await createQuotation();
    if (quotation == null) return null;

    setBusy(true);
    try {
      final converted = await _quotationService.convertToInvoice(quotation);
      await loadQuotations();
      final businessSettings = await _invoiceService.loadBusinessSettings();
      final invoice = converted.toInvoiceModel(businessInfo: businessSettings);
      showFeedback(
          'B2B Invoice ${invoice.invoiceNumber} created successfully!');
      return invoice;
    } catch (e) {
      showFeedback('Failed to create B2B invoice: $e', isError: true);
      return null;
    } finally {
      setBusy(false);
    }
  }

  // --------------------------------------------------------------------------
  // TAB 2: Quotations Directory & Convert to Invoice
  // --------------------------------------------------------------------------
  String _quotationSearch = '';
  String _quotationStatusFilter = 'All'; // 'All', 'Active', 'Converted'

  String get quotationSearch => _quotationSearch;
  String get quotationStatusFilter => _quotationStatusFilter;

  void setQuotationSearch(String q) {
    _quotationSearch = q;
    notifyListeners();
  }

  void setQuotationStatusFilter(String filter) {
    _quotationStatusFilter = filter;
    notifyListeners();
  }

  List<BulkQuotationModel> get filteredQuotations {
    return _quotations.where((q) {
      if (_quotationSearch.isNotEmpty) {
        final query = _quotationSearch.toLowerCase();
        final matchNo = q.quotationNumber.toLowerCase().contains(query);
        final matchCust = q.customerName.toLowerCase().contains(query);
        final matchPhone = q.customerPhone.toLowerCase().contains(query);
        final matchGst = q.customerGst.toLowerCase().contains(query);
        final matchInv =
            q.invoiceNumber?.toLowerCase().contains(query) ?? false;
        if (!matchNo && !matchCust && !matchPhone && !matchGst && !matchInv)
          return false;
      }

      if (_quotationStatusFilter != 'All') {
        if (_quotationStatusFilter == 'Active' && q.isConverted) return false;
        if (_quotationStatusFilter == 'Converted' && !q.isConverted)
          return false;
      }

      return true;
    }).toList();
  }

  Future<void> loadQuotations() async {
    try {
      _quotations = await _quotationService.getQuotations();
      notifyListeners();
    } catch (_) {}
  }

  Future<InvoiceModel?> convertQuotationToInvoice(
      BulkQuotationModel quotation) async {
    setBusy(true);
    try {
      final converted = await _quotationService.convertToInvoice(quotation);
      await loadQuotations();
      final businessSettings = await _invoiceService.loadBusinessSettings();
      final invoice = converted.toInvoiceModel(businessInfo: businessSettings);
      showFeedback(
          'Quotation ${quotation.quotationNumber} converted to Tax Invoice ${invoice.invoiceNumber}!');
      return invoice;
    } catch (e) {
      showFeedback('Failed to convert quotation: $e', isError: true);
      return null;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> deleteQuotation(String id) async {
    try {
      final success = await _quotationService.deleteQuotation(id);
      if (success) {
        _quotations.removeWhere((q) => q.id == id);
        notifyListeners();
        showFeedback('Quotation deleted successfully.');
      }
      return success;
    } catch (e) {
      showFeedback('Error deleting quotation: $e', isError: true);
      return false;
    }
  }

  // --------------------------------------------------------------------------
  // Lifecycle Initializer
  // --------------------------------------------------------------------------
  @override
  Future<void> futureToRun() async {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    TokenService.locationNotifier.addListener(_onLocationNotifierChanged);
    await _loadAllData();
  }

  void _onLocationNotifierChanged() {
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setBusy(true);
    try {
      final productsFuture = _productService.getProducts();
      final categoriesFuture = _productService.getCategories();
      final customersFuture = _customerService.getCustomers();
      final quotationsFuture = _quotationService.getQuotations();

      final results = await Future.wait([
        productsFuture,
        categoriesFuture,
        customersFuture,
        quotationsFuture,
      ]);

      _allProducts = results[0] as List<ProductModel>;
      _categories = results[1] as List<CategoryModel>;
      _customers = results[2] as List<AdminCustomerModel>;
      _quotations = results[3] as List<BulkQuotationModel>;

      _price1Controllers.clear();
      _price2Controllers.clear();
      _modifiedProductIds.clear();

      for (final p in _allProducts) {
        _price1Controllers[p.id] = TextEditingController(
          text: p.leastSellingPrice1 > 0
              ? p.leastSellingPrice1.toStringAsFixed(2)
              : '',
        );
        _price2Controllers[p.id] = TextEditingController(
          text: p.leastSellingPrice2 > 0
              ? p.leastSellingPrice2.toStringAsFixed(2)
              : '',
        );
      }
    } catch (e) {
      showFeedback('Error loading bulk sell module: $e', isError: true);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    for (final c in _price1Controllers.values) {
      c.dispose();
    }
    for (final c in _price2Controllers.values) {
      c.dispose();
    }
    customerNameController.dispose();
    customerPhoneController.dispose();
    customerEmailController.dispose();
    customerGstController.dispose();
    customerAddressController.dispose();
    businessNameController.dispose();
    quotationNotesController.dispose();
    super.dispose();
  }
}
