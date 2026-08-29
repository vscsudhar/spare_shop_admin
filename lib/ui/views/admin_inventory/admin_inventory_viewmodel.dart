import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/product_service.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

class AdminInventoryViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _productService = locator<ProductService>();

  String _searchQuery = '';
  bool _filterLowStockOnly = false;

  String get searchQuery => _searchQuery;
  bool get filterLowStockOnly => _filterLowStockOnly;

  List<ProductModel> _allProducts = [];

  int getStockLevel(String productId) {
    final prod = _allProducts.firstWhere((p) => p.id == productId,
        orElse: () => mockProductsFallback(productId));
    return prod.stockCount;
  }

  ProductModel mockProductsFallback(String id) {
    return ProductModel(
      id: id,
      name: 'Fallback Item',
      price: 0,
      originalPrice: 0,
      rating: 4.5,
      description: '',
      categoryId: '',
      compatibleVehicleIds: [],
      fitmentBadge: 'Universal',
      stockCount: 0,
    );
  }

  String getStorageLocation(String productId) {
    final prod = _allProducts.firstWhere((p) => p.id == productId,
        orElse: () => mockProductsFallback(productId));
    return prod.locationBin ?? 'Not Assigned';
  }

  Future<void> updateStorageLocation(
      ProductModel product, String newLocation) async {
    setBusy(true);
    try {
      final payload = {
        'locationBin': newLocation,
      };
      await _productService.updateProduct(product.id, payload);
      await loadInventory();
    } catch (e) {
      print('Error updating storage location: $e');
    } finally {
      setBusy(false);
    }
  }

  List<ProductModel> get filteredInventory {
    return _allProducts.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.id.toLowerCase().contains(_searchQuery.toLowerCase());

      if (_filterLowStockOnly) {
        return matchesSearch && product.stockCount <= 5;
      }
      return matchesSearch;
    }).toList();
  }

  double get totalStockValue {
    return _allProducts.fold(0, (sum, p) => sum + (p.price * p.stockCount));
  }

  int get outOfStockCount {
    return _allProducts.where((p) => p.stockCount == 0).length;
  }

  @override
  Future<void> futureToRun() async {
    await loadInventory();
  }

  Future<void> loadInventory() async {
    try {
      _allProducts = await _productService.getProducts();
      rebuildUi();
    } catch (e) {
      print('Error loading inventory: $e');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleLowStockFilter() {
    _filterLowStockOnly = !_filterLowStockOnly;
    notifyListeners();
  }

  Future<void> restockProduct(ProductModel product, int quantity) async {
    setBusy(true);
    try {
      final payload = {
        'currentStock': product.stockCount + quantity,
      };
      await _productService.updateProduct(product.id, payload);
      await loadInventory();
    } catch (e) {
      print('Error restocking product: $e');
    } finally {
      setBusy(false);
    }
  }
}
