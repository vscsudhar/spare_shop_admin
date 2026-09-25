import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/services/api_client.dart';
import 'package:spare_shop_admin/core/services/api_endpoints.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:spare_shop_admin/core/services/voltspare_models_extensions.dart';

class CategoryService {
  final ApiClient _apiClient;

  CategoryService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  /// Fetch list of categories with optional filters
  Future<List<CategoryModel>> getCategories({
    String? type,
    bool? active,
    String? search,
  }) async {
    final Map<String, dynamic> query = {};
    if (type != null && type.isNotEmpty && type != 'All') {
      query['type'] = type;
    }
    if (active != null) {
      query['active'] = active;
    }
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    final response = await _apiClient.get(
      ApiEndpoints.categories,
      queryParameters: query.isNotEmpty ? query : null,
    );

    final List<dynamic> list = response.data['data'] ?? [];
    return list.map((item) => CategoryModelExtension.fromJson(item)).toList();
  }

  /// Get single category by ID
  Future<CategoryModel> getCategoryById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.categories}/$id');
    final data = response.data['data'] ?? {};
    return CategoryModelExtension.fromJson(data);
  }

  /// Create a new category
  Future<CategoryModel> createCategory(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.categories,
      data: payload,
    );
    final data = response.data['data'] ?? {};
    return CategoryModelExtension.fromJson(data);
  }

  /// Update category details
  Future<CategoryModel> updateCategory(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.patch(
      '${ApiEndpoints.categories}/$id',
      data: payload,
    );
    final data = response.data['data'] ?? {};
    return CategoryModelExtension.fromJson(data);
  }

  /// Delete category
  Future<bool> deleteCategory(String id) async {
    final response = await _apiClient.delete('${ApiEndpoints.categories}/$id');
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
