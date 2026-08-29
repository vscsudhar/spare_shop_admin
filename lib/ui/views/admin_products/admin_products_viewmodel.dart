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

  String? _pickedImagePath;
  String? get pickedImagePath => _pickedImagePath;

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> pickProductImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        _pickedImagePath = image.path;
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
    _pickedImagePath = null;
    notifyListeners();
  }

  void resetImageState() {
    _pickedImagePath = null;
    _existingImageCleared = false;
    notifyListeners();
  }

  List<ProductModel> _allProducts = [];
  List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => _categories;

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
  }

  Future<void> loadProducts() async {
    try {
      _allProducts = await _productService.getProducts();
      rebuildUi();
    } catch (e) {
      print('Error loading admin products: $e');
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _productService.getCategories();
      rebuildUi();
    } catch (e) {
      print('Error loading admin categories: $e');
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
    required double purchasePrice,
    required double taxPercentage,
    required int stockCount,
    String? existingImageUrl,
  }) async {
    setBusy(true);
    try {
      String? imageUrl = _existingImageCleared ? null : existingImageUrl;
      if (_pickedImagePath != null) {
        imageUrl = await _productService.uploadImage(_pickedImagePath!);
      }

      final payload = {
        'name': name,
        'sellingPrice': (sellingPrice * 100).toInt(),
        'mrp': (sellingPrice * 1.2 * 100).toInt(),
        'purchasePrice': (purchasePrice * 100).toInt(),
        'taxPercentage': taxPercentage,
        'currentStock': stockCount,
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
      print('Error updating product details: $e');
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

  Future<void> addMockProduct({
    required String name,
    required double price,
    required String categoryId,
    required String partNumber,
    required String fitmentBadge,
    required double purchasePrice,
    required double taxPercentage,
    required int stockCount,
  }) async {
    setBusy(true);
    try {
      String? imageUrl;
      if (_pickedImagePath != null) {
        imageUrl = await _productService.uploadImage(_pickedImagePath!);
      }

      String realCategoryId = categoryId;
      if (!RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(categoryId)) {
        // Map mock category IDs to real seeded category ObjectIds
        String targetSlug = 'electrical-spares';
        if (categoryId == 'cat_01') targetSlug = 'electrical-spares';
        if (categoryId == 'cat_02') targetSlug = 'electrical-spares';
        if (categoryId == 'cat_03') targetSlug = 'engine-spares';
        if (categoryId == 'cat_04') targetSlug = 'brakes';

        final matchingCat = _categories.firstWhere(
          (c) => c.name.toLowerCase().replaceAll(' ', '-') == targetSlug,
          orElse: () => _categories.isNotEmpty
              ? _categories.first
              : const CategoryModel(
                  id: '662888f8d8f8d8f8d8f8d8f8',
                  name: 'Default',
                  icon: Icons.category,
                ),
        );
        realCategoryId = matchingCat.id;
      }

      final payload = {
        'sku': partNumber,
        'name': name,
        'brand': fitmentBadge.toUpperCase().contains('OLA')
            ? 'Ola'
            : (fitmentBadge.toUpperCase().contains('ATHER')
                ? 'Ather'
                : 'Honda'),
        'category': realCategoryId,
        'sellingPrice': (price * 100).toInt(),
        'mrp': (price * 1.2 * 100).toInt(),
        'purchasePrice': (purchasePrice * 100).toInt(),
        'taxPercentage': taxPercentage,
        'currentStock': stockCount,
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
      print('Error creating product: $e');
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
