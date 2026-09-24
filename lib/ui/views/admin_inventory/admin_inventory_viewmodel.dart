import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/location_service.dart';
import 'package:spare_shop_admin/core/services/product_service.dart';
import 'package:spare_shop_admin/core/services/token_service.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:spare_shop_admin/ui/common/location_inventory_models.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

class AdminInventoryViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _productService = locator<ProductService>();
  final _locationService = locator<LocationService>();
  final _tokenService = locator<TokenService>();

  String _searchQuery = '';
  bool _filterLowStockOnly = false;

  String get searchQuery => _searchQuery;
  bool get filterLowStockOnly => _filterLowStockOnly;

  String _selectedLocationFilter = 'all'; // 'all' or locationId
  String get selectedLocationFilter => _selectedLocationFilter;

  List<LocationModel> _locations = [];
  List<LocationModel> get locations => _locations;

  bool _canChangeLocation = true;
  bool get canChangeLocation => _canChangeLocation;

  String? _userAssignedLocationId;
  String? get userAssignedLocationId => _userAssignedLocationId;

  String? _userAssignedLocationName;
  String? get userAssignedLocationName => _userAssignedLocationName;

  List<ProductModel> _allProducts = [];
  LocationInventoryResponse? _locationInventory;

  int getStockLevel(String productId) {
    if (_selectedLocationFilter != 'all' && _locationInventory != null) {
      final item = _locationInventory!.items.where((i) => i.productId == productId || i.sku == productId);
      if (item.isNotEmpty) {
        return item.first.quantity;
      }
    }
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
    } catch (_) {
    } finally {
      setBusy(false);
    }
  }

  List<ProductModel> get filteredInventory {
    if (_selectedLocationFilter == '__none__') return [];

    List<ProductModel> baseList;
    if (_selectedLocationFilter != 'all') {
      if (_locationInventory == null || _locationInventory!.items.isEmpty) {
        return [];
      }
      final locItemIds = _locationInventory!.items.map((i) => i.productId).toSet();
      final locItemSkus = _locationInventory!.items.map((i) => i.sku).toSet();

      baseList = _allProducts
          .where((p) => locItemIds.contains(p.id) || locItemSkus.contains(p.id) || locItemSkus.contains(p.name))
          .toList();

      for (final item in _locationInventory!.items) {
        if (!baseList.any((p) => p.id == item.productId || p.id == item.sku)) {
          baseList.add(ProductModel(
            id: item.productId.isNotEmpty ? item.productId : item.sku,
            name: item.productName,
            price: item.price,
            originalPrice: item.price,
            rating: 4.8,
            description: '',
            categoryId: '',
            compatibleVehicleIds: [],
            fitmentBadge: 'Location Specific',
            stockCount: item.quantity,
          ));
        }
      }
    } else {
      baseList = _allProducts;
    }

    return baseList.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.id.toLowerCase().contains(_searchQuery.toLowerCase());

      final stock = getStockLevel(product.id);
      if (_filterLowStockOnly) {
        return matchesSearch && stock <= 5;
      }
      return matchesSearch;
    }).toList();
  }

  double get totalStockValue {
    if (_selectedLocationFilter == '__none__') return 0.0;
    if (_selectedLocationFilter != 'all' && _locationInventory != null) {
      return _locationInventory!.items.fold(0.0, (sum, i) => sum + (i.price * i.quantity));
    }
    return _allProducts.fold(0, (sum, p) => sum + (p.price * p.stockCount));
  }

  int get outOfStockCount {
    if (_selectedLocationFilter == '__none__') return 0;
    if (_selectedLocationFilter != 'all' && _locationInventory != null) {
      return _locationInventory!.outOfStockCount;
    }
    return _allProducts.where((p) => getStockLevel(p.id) == 0).length;
  }

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

    await loadInventory();
  }

  void _onLocationNotifierChanged() {
    final newLocId = TokenService.locationNotifier.locationId;
    _selectedLocationFilter = (newLocId != null && newLocId.isNotEmpty) ? newLocId : 'all';
    loadInventory();
  }

  @override
  void dispose() {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    super.dispose();
  }

  Future<void> loadInventory() async {
    try {
      if (_selectedLocationFilter == '__none__') {
        _allProducts = [];
        _locationInventory = null;
        rebuildUi();
        return;
      }

      _allProducts = await _productService.getProducts();

      if (_selectedLocationFilter != 'all') {
        try {
          _locationInventory = await _locationService.getLocationInventory(_selectedLocationFilter);
        } catch (_) {
          _locationInventory = null;
        }
      } else {
        _locationInventory = null;
      }

      rebuildUi();
    } catch (_) {}
  }

  void setSelectedLocationFilter(String locationId) {
    if (_selectedLocationFilter == locationId) return;
    _selectedLocationFilter = locationId;
    if (_canChangeLocation) {
      locator<TokenService>().saveUserLocation(
        locationId: locationId == 'all' ? null : locationId,
        locationName: locationId != 'all' && _locations.any((l) => l.id == locationId)
            ? _locations.firstWhere((l) => l.id == locationId).name
            : 'All Locations (HQ)',
      );
    }
    loadInventory();
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
      if (_selectedLocationFilter != 'all') {
        final currentStock = getStockLevel(product.id);
        await _locationService.updateInventoryStock(
          _selectedLocationFilter,
          product.id,
          currentStock + quantity,
        );
      } else {
        final payload = {
          'currentStock': product.stockCount + quantity,
        };
        await _productService.updateProduct(product.id, payload);
      }
      await loadInventory();
    } catch (_) {
    } finally {
      setBusy(false);
    }
  }
}
