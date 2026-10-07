import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/ui/common/enquiry_models.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class EnquiryService {
  final ApiClient _apiClient;

  EnquiryService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  Future<List<EnquiryModel>> getEnquiries({
    String? status,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status != 'all' && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _apiClient.get(
      ApiEndpoints.adminEnquiries,
      queryParameters: queryParams,
    );
    final List<dynamic> list = response.data['data'] ?? [];
    return list.map((item) => EnquiryModel.fromJson(item)).toList();
  }

  Future<EnquiryModel> getEnquiryById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.adminEnquiries}/$id');
    final data = response.data['data'] ?? {};
    return EnquiryModel.fromJson(data);
  }

  Future<EnquiryModel> updateStatus(
    String id,
    String status, {
    String? adminNotes,
  }) async {
    final response = await _apiClient.patch(
      '${ApiEndpoints.adminEnquiries}/$id/status',
      data: {
        'status': status,
        if (adminNotes != null) 'adminNotes': adminNotes,
      },
    );
    final data = response.data['data'] ?? {};
    return EnquiryModel.fromJson(data);
  }

  Future<void> deleteEnquiry(String id) async {
    await _apiClient.delete('${ApiEndpoints.adminEnquiries}/$id');
  }
}
