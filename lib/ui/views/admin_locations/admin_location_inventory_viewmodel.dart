import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/location_service.dart';
import 'package:spare_shop_admin/core/services/product_service.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:spare_shop_admin/ui/common/location_inventory_models.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

class AdminLocationInventoryViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _locationService = locator<LocationService>();
  final _productService = locator<ProductService>();

  final String? locationId;
  LocationModel? _location;
  LocationModel? get location => _location;

  AdminLocationInventoryViewModel({
    this.locationId,
    LocationModel? location,
  }) : _location = location;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _stockFilter = 'All'; // 'All', 'In Stock', 'Out of Stock'
  String get stockFilter => _stockFilter;

  List<LocationInventoryItem> _allInventoryItems = [];

  List<LocationInventoryItem> get inventoryItems {
    return _allInventoryItems.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.productName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.brand.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStock = _stockFilter == 'All' ||
          (_stockFilter == 'In Stock' && item.isInStock) ||
          (_stockFilter == 'Out of Stock' && !item.isInStock);

      return matchesSearch && matchesStock;
    }).toList();
  }

  int get totalTrackedSpares => _allInventoryItems.length;
  int get inStockCount => _allInventoryItems.where((i) => i.isInStock).length;
  int get outOfStockCount =>
      _allInventoryItems.where((i) => !i.isInStock).length;

  @override
  Future<void> futureToRun() async {
    if (locationId != null && locationId!.isNotEmpty) {
      await loadInventory();
    }
  }

  Future<void> loadInventory() async {
    final locId = locationId;
    if (locId == null || locId.isEmpty) return;
    try {
      setBusy(true);
      setError(null);
      final response = await _locationService.getLocationInventory(locId);
      if (response.location != null) {
        _location = response.location;
      }
      _allInventoryItems = response.items;
      rebuildUi();
    } catch (e) {
      print('Error loading location inventory: $e');
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStockFilter(String filter) {
    _stockFilter = filter;
    notifyListeners();
  }

  /// Search global product catalog
  Future<List<ProductModel>> searchGlobalProducts(String query) async {
    try {
      return await _productService.getProducts(search: query);
    } catch (e) {
      return [];
    }
  }

  /// Add or update stock quantity for a product in this location
  Future<bool> updateStock(String productId, int quantity) async {
    final locId = locationId;
    if (locId == null || locId.isEmpty) return false;
    setBusy(true);
    try {
      final updatedItem = await _locationService.updateInventoryStock(
        locId,
        productId,
        quantity,
      );

      final existingIndex =
          _allInventoryItems.indexWhere((item) => item.productId == productId);
      if (existingIndex >= 0) {
        _allInventoryItems[existingIndex] = updatedItem;
      } else {
        _allInventoryItems.insert(0, updatedItem);
      }
      notifyListeners();

      await loadInventory();
      return true;
    } catch (e) {
      setError(e);
      return false;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  /// Remove inventory record for a product in this location
  Future<bool> removeInventoryRecord(String productId) async {
    final locId = locationId;
    if (locId == null || locId.isEmpty) return false;
    setBusy(true);
    try {
      await _locationService.deleteInventoryRecord(locId, productId);
      _allInventoryItems.removeWhere((item) => item.productId == productId);
      notifyListeners();

      await loadInventory();
      return true;
    } catch (e) {
      setError(e);
      return false;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }
}
