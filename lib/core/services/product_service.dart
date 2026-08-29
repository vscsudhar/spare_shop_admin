import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'voltspare_models_extensions.dart';

class ProductService {
  final ApiClient _apiClient;

  ProductService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  Future<String> uploadImage(String filePath) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });
    final response = await _apiClient.post(
      '/uploads',
      data: formData,
    );
    final data = response.data['data'] ?? {};
    return data['url'] ?? '';
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get(ApiEndpoints.categories);
    final List<dynamic> list = response.data['data'] ?? [];
    return list.map((item) => CategoryModelExtension.fromJson(item)).toList();
  }

  Future<List<ProductModel>> getProducts({
    String? type,
    String? categoryId,
    String? search,
    bool? featured,
  }) async {
    final Map<String, dynamic> query = {};
    if (type != null) query['type'] = type;
    if (categoryId != null && categoryId.isNotEmpty) {
      query['category'] = categoryId;
    }
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (featured != null) query['featured'] = featured.toString();

    final response =
        await _apiClient.get(ApiEndpoints.products, queryParameters: query);
    final List<dynamic> list = response.data['data'] ?? [];
    return list.map((item) => ProductModelExtension.fromJson(item)).toList();
  }

  Future<ProductModel> getProductById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.products}/$id');
    final data = response.data['data'] ?? {};
    return ProductModelExtension.fromJson(data);
  }

  Future<List<VehicleBrandModel>> getVehicleBrands() async {
    final response = await _apiClient.get(ApiEndpoints.vehicleBrands);
    final List<dynamic> list = response.data['data'] ?? [];
    return list
        .map((item) => VehicleBrandModelExtension.fromJson(item))
        .toList();
  }

  Future<List<VehicleModel>> getVehicleModels() async {
    final response = await _apiClient.get(ApiEndpoints.vehicleModels);
    final List<dynamic> list = response.data['data'] ?? [];
    return list.map((item) => VehicleModelExtension.fromJson(item)).toList();
  }

  Future<ProductModel> createProduct(Map<String, dynamic> payload) async {
    final response =
        await _apiClient.post(ApiEndpoints.products, data: payload);
    final data = response.data['data'] ?? {};
    return ProductModelExtension.fromJson(data);
  }

  Future<ProductModel> updateProduct(
      String id, Map<String, dynamic> payload) async {
    final response =
        await _apiClient.patch('${ApiEndpoints.products}/$id', data: payload);
    final data = response.data['data'] ?? {};
    return ProductModelExtension.fromJson(data);
  }
}
