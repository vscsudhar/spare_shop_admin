import 'package:spare_shop_admin/app/app.locator.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'voltspare_models_extensions.dart';

class AdminSupplierService {
  final ApiClient _apiClient;

  AdminSupplierService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  Future<List<SupplierModel>> getSuppliers() async {
    final response = await _apiClient.get(ApiEndpoints.suppliers);
    final List<dynamic> list = response.data['data'] ?? [];
    return list.map((item) => SupplierModelExtension.fromJson(item)).toList();
  }

  Future<SupplierModel> getSupplierById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.suppliers}/$id');
    final data = response.data['data'] ?? {};
    return SupplierModelExtension.fromJson(data);
  }

  Future<SupplierModel> createSupplier(
      Map<String, dynamic> supplierData) async {
    final response = await _apiClient.post(
      ApiEndpoints.suppliers,
      data: supplierData,
    );
    final data = response.data['data'] ?? {};
    return SupplierModelExtension.fromJson(data);
  }

  Future<SupplierModel> updateSupplier(
      String id, Map<String, dynamic> supplierData) async {
    final response = await _apiClient.patch(
      '${ApiEndpoints.suppliers}/$id',
      data: supplierData,
    );
    final data = response.data['data'] ?? {};
    return SupplierModelExtension.fromJson(data);
  }

  Future<void> updateSupplierStatus(String id, bool active) async {
    await _apiClient.patch(
      '${ApiEndpoints.suppliers}/$id/status',
      data: {'status': active ? 'active' : 'inactive'},
    );
  }
}
