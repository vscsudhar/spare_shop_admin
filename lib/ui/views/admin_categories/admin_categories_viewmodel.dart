import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/category_service.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AdminCategoriesViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _categoryService = locator<CategoryService>();
  final _dialogService = locator<DialogService>();

  List<CategoryModel> _allCategories = [];
  List<CategoryModel> get allCategories => _allCategories;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _typeFilter = 'All'; // 'All', 'EV', 'Petrol', 'Universal'
  String get typeFilter => _typeFilter;

  String _statusFilter = 'All'; // 'All', 'Active', 'Inactive'
  String get statusFilter => _statusFilter;

  int get totalCount => _allCategories.length;
  int get evCount => _allCategories.where((c) => c.type == 'EV').length;
  int get petrolCount => _allCategories.where((c) => c.type == 'Petrol').length;
  int get universalCount =>
      _allCategories.where((c) => c.type == 'Universal').length;
  int get activeCount => _allCategories.where((c) => c.active).length;
  int get inactiveCount => _allCategories.where((c) => !c.active).length;

  List<CategoryModel> get filteredCategories {
    return _allCategories.where((cat) {
      // 1. Search Query
      final query = _searchQuery.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          cat.name.toLowerCase().contains(query) ||
          cat.slug.toLowerCase().contains(query) ||
          cat.description.toLowerCase().contains(query);

      // 2. Type Filter
      bool matchesType = true;
      if (_typeFilter != 'All') {
        matchesType = cat.type.toUpperCase() == _typeFilter.toUpperCase();
      }

      // 3. Status Filter
      bool matchesStatus = true;
      if (_statusFilter == 'Active') {
        matchesStatus = cat.active;
      } else if (_statusFilter == 'Inactive') {
        matchesStatus = !cat.active;
      }

      return matchesSearch && matchesType && matchesStatus;
    }).toList();
  }

  @override
  Future<void> futureToRun() async {
    await loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      _allCategories = await _categoryService.getCategories();
      rebuildUi();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setTypeFilter(String type) {
    _typeFilter = type;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  Future<bool> createCategory({
    required String name,
    required String type,
    String? description,
    String? parentCategoryId,
    bool active = true,
  }) async {
    setBusy(true);
    try {
      final payload = {
        'name': name.trim(),
        'type': type,
        'active': active,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        if (parentCategoryId != null && parentCategoryId.isNotEmpty)
          'parentCategory': parentCategoryId,
      };

      await _categoryService.createCategory(payload);
      await loadCategories();
      return true;
    } catch (e) {
      debugPrint('Error creating category: $e');
      String errMsg = 'Failed to create category.';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          errMsg = data['message'].toString();
        }
      }
      _dialogService.showDialog(
        title: 'Error Creating Category',
        description: errMsg,
      );
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> updateCategory({
    required String id,
    required String name,
    required String type,
    String? description,
    String? parentCategoryId,
    bool? active,
  }) async {
    setBusy(true);
    try {
      final payload = {
        'name': name.trim(),
        'type': type,
        if (active != null) 'active': active,
        if (description != null) 'description': description.trim(),
        'parentCategory':
            (parentCategoryId != null && parentCategoryId.isNotEmpty)
                ? parentCategoryId
                : null,
      };

      await _categoryService.updateCategory(id, payload);
      await loadCategories();
      return true;
    } catch (e) {
      debugPrint('Error updating category: $e');
      String errMsg = 'Failed to update category.';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          errMsg = data['message'].toString();
        }
      }
      _dialogService.showDialog(
        title: 'Error Updating Category',
        description: errMsg,
      );
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<void> toggleCategoryStatus(CategoryModel category) async {
    try {
      await _categoryService.updateCategory(
        category.id,
        {'active': !category.active},
      );
      await loadCategories();
    } catch (e) {
      debugPrint('Error toggling category status: $e');
      _dialogService.showDialog(
        title: 'Status Update Failed',
        description: 'Unable to toggle category active status.',
      );
    }
  }

  Future<bool> deleteCategory(String id) async {
    setBusy(true);
    try {
      await _categoryService.deleteCategory(id);
      await loadCategories();
      return true;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      String errMsg = 'Failed to delete category.';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          errMsg = data['message'].toString();
        }
      }
      _dialogService.showDialog(
        title: 'Cannot Delete Category',
        description: errMsg,
      );
      return false;
    } finally {
      setBusy(false);
    }
  }
}
