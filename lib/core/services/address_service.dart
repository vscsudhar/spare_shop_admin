import 'package:spare_shop_admin/app/app.locator.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'voltspare_models_extensions.dart';

class AddressService {
  final ApiClient _apiClient;

  AddressService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  Future<List<AddressModel>> getAddresses() async {
    final response = await _apiClient.get(ApiEndpoints.addresses);
    final List<dynamic> list = response.data['data'] ?? [];
    return list.map((item) => AddressModelExtension.fromJson(item)).toList();
  }

  Future<AddressModel> addAddress(AddressModel address) async {
    final response = await _apiClient.post(
      ApiEndpoints.addresses,
      data: address.toJson(),
    );
    final data = response.data['data'] ?? {};
    return AddressModelExtension.fromJson(data);
  }

  Future<AddressModel> updateAddress(String id, AddressModel address) async {
    final response = await _apiClient.patch(
      '${ApiEndpoints.addresses}/$id',
      data: address.toJson(),
    );
    final data = response.data['data'] ?? {};
    return AddressModelExtension.fromJson(data);
  }

  Future<void> deleteAddress(String id) async {
    await _apiClient.delete('${ApiEndpoints.addresses}/$id');
  }

  Future<AddressModel> setDefaultAddress(String id) async {
    final response =
        await _apiClient.patch('${ApiEndpoints.addresses}/$id/default');
    final data = response.data['data'] ?? {};
    return AddressModelExtension.fromJson(data);
  }
}
