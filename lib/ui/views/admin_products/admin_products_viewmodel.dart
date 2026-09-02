import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/product_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AdminProductsViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _productService = locator<ProductService>();
  final _dialogService = locator<DialogService>();

  String _searchQuery = '';
  String _categoryFilter = 'All'; // 'All', 'EV', 'Petrol'

  String get searchQuery => _searchQuery;
  String get categoryFilter => _categoryFilter;

  XFile? _pickedImageFile;
  XFile? get pickedImageFile => _pickedImageFile;

  Uint8List? _pickedImageBytes;
  Uint8List? get pickedImageBytes => _pickedImageBytes;

  String? get pickedImagePath => _pickedImageFile?.path;

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> pickProductImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        _pickedImageFile = image;
        _pickedImageBytes = await image.readAsBytes();
        notifyListeners();
      }
    } catch (e) {
      print('Error picking product image: $e');
    }
  }

  bool _existingImageCleared = false;
  bool get existingImageCleared => _existingImageCleared;

  void clearExistingImage() {
    _existingImageCleared = true;
    notifyListeners();
  }

  void clearPickedImage() {
    _pickedImageFile = null;
    _pickedImageBytes = null;
    notifyListeners();
  }

  void resetImageState() {
    _pickedImageFile = null;
    _pickedImageBytes = null;
    _existingImageCleared = false;
    notifyListeners();
  }

  List<ProductModel> _allProducts = [];
  List<CategoryModel> _categories = [];
  List<VehicleBrandModel> _brands = [];
  final Map<String, List<VehicleModel>> _modelsByBrand = {};

  List<CategoryModel> get categories => _categories;
  List<VehicleBrandModel> get brands => _brands;
  Map<String, List<VehicleModel>> get modelsByBrand => _modelsByBrand;

  bool _loadingBrands = false;
  bool get loadingBrands => _loadingBrands;
  String? _brandLoadError;
  String? get brandLoadError => _brandLoadError;

  final Map<String, bool> _loadingModelsByBrand = {};
  bool isLoadingModelsForBrand(String brandId) =>
      _loadingModelsByBrand[brandId] ?? false;

  final Map<String, String?> _modelLoadErrors = {};
  String? getModelLoadError(String brandId) => _modelLoadErrors[brandId];

  List<ProductModel> get filteredProducts {
    return _allProducts.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.id.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesCategory = true;
      if (_categoryFilter != 'All') {
        final type = product.vehicleType.toUpperCase();
        matchesCategory =
            type == _categoryFilter.toUpperCase() || type == 'UNIVERSAL';
      }

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Future<void> futureToRun() async {
    await loadProducts();
    await loadCategories();
    await loadBrands();
  }

  Future<void> loadProducts() async {
    try {
      _allProducts = await _productService.getProducts();
      rebuildUi();
    } catch (e) {
      debugPrint('Error loading admin products: $e');
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _productService.getCategories();
      rebuildUi();
    } catch (e) {
      debugPrint('Error loading admin categories: $e');
    }
  }

  Future<void> loadBrands() async {
    if (_brands.isNotEmpty) return;
    _loadingBrands = true;
    _brandLoadError = null;
    notifyListeners();
    try {
      _brands = await _productService.getVehicleBrands();
      _brandLoadError = null;
    } catch (e) {
      _brandLoadError = 'Failed to load brands. Tap to retry.';
      debugPrint('Error loading vehicle brands: $e');
    } finally {
      _loadingBrands = false;
      notifyListeners();
    }
  }

  Future<List<VehicleModel>> loadModelsForBrand(String brandId) async {
    if (brandId.isEmpty) return [];
    if (_modelsByBrand.containsKey(brandId) &&
        _modelsByBrand[brandId]!.isNotEmpty) {
      return _modelsByBrand[brandId]!;
    }

    _loadingModelsByBrand[brandId] = true;
    _modelLoadErrors[brandId] = null;
    notifyListeners();

    try {
      final list = await _productService.getVehicleModels(brandId: brandId);
      _modelsByBrand[brandId] = list;
      _modelLoadErrors[brandId] = null;
      return list;
    } catch (e) {
      _modelLoadErrors[brandId] = 'Failed to load models. Tap to retry.';
      debugPrint('Error loading models for brand $brandId: $e');
      return [];
    } finally {
      _loadingModelsByBrand[brandId] = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _categoryFilter = category;
    notifyListeners();
  }

  Future<void> updateProductDetails({
    required String productId,
    required String name,
    required double sellingPrice,
    required double mrp,
    required double purchasePrice,
    required double taxPercentage,
    required int stockCount,
    required String fitType,
    required bool stockManaged,
    required List<Map<String, String>> compatibleVehicles,
    String? existingImageUrl,
  }) async {
    setBusy(true);
    try {
      String? imageUrl = _existingImageCleared ? null : existingImageUrl;
      if (_pickedImageFile != null) {
        imageUrl = await _productService.uploadImage(_pickedImageFile!);
      }

      final payload = {
        'name': name,
        'sellingPrice': (sellingPrice * 100).toInt(),
        'mrp': (mrp * 100).toInt(),
        'purchasePrice': (purchasePrice * 100).toInt(),
        'taxPercentage': taxPercentage,
        'currentStock': stockCount,
        'stockManaged': stockManaged,
        'fitType': fitType,
        'compatibleVehicles': fitType == 'universal' ? [] : compatibleVehicles,
      };

      if (imageUrl != null && imageUrl.isNotEmpty) {
        payload['images'] = [
          {'url': imageUrl, 'isDefault': true}
        ];
      }

      await _productService.updateProduct(productId, payload);
      clearPickedImage();
      await loadProducts();
    } catch (e) {
      debugPrint('Error updating product details: $e');
      String errMsg = 'Failed to update product details.';
      try {
        if (e is DioException && e.response?.data != null) {
          final data = e.response!.data;
          if (data is Map && data.containsKey('message')) {
            errMsg = data['message'].toString();
          }
        }
      } catch (_) {}
      _dialogService.showDialog(
        title: 'Error Updating Product',
        description: errMsg,
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> addProduct({
    required String name,
    required double price,
    required double mrp,
    required String categoryId,
    required String partNumber,
    required double purchasePrice,
    required double taxPercentage,
    required int stockCount,
    required String fitType,
    required bool stockManaged,
    required List<Map<String, String>> compatibleVehicles,
  }) async {
    setBusy(true);
    try {
      String? imageUrl;
      if (_pickedImageFile != null) {
        imageUrl = await _productService.uploadImage(_pickedImageFile!);
      }

      String realCategoryId = categoryId;
      if (!RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(categoryId)) {
        final matchingCat = _categories.isNotEmpty
            ? _categories.first
            : const CategoryModel(
                id: '662888f8d8f8d8f8d8f8d8f8',
                name: 'Default',
                icon: Icons.category,
              );
        realCategoryId = matchingCat.id;
      }

      final payload = {
        'sku': partNumber,
        'name': name,
        'category': realCategoryId,
        'sellingPrice': (price * 100).toInt(),
        'mrp': (mrp * 100).toInt(),
        'purchasePrice': (purchasePrice * 100).toInt(),
        'taxPercentage': taxPercentage,
        'currentStock': stockCount,
        'stockManaged': stockManaged,
        'fitType': fitType,
        'compatibleVehicles': fitType == 'universal' ? [] : compatibleVehicles,
        'description': 'Genuine replacement spare part - $name.',
      };

      if (imageUrl != null && imageUrl.isNotEmpty) {
        payload['images'] = [
          {'url': imageUrl, 'isDefault': true}
        ];
      }

      await _productService.createProduct(payload);
      clearPickedImage();
      await loadProducts();
    } catch (e) {
      debugPrint('Error creating product: $e');
      String errMsg = 'Failed to create product.';
      try {
        if (e is DioException && e.response?.data != null) {
          final data = e.response!.data;
          if (data is Map && data.containsKey('message')) {
            errMsg = data['message'].toString();
          }
        }
      } catch (_) {}
      _dialogService.showDialog(
        title: 'Error Creating Product',
        description: errMsg,
      );
    } finally {
      setBusy(false);
    }
  }
}
