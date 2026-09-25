import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/ui/common/suggestion_models.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class SuggestionService {
  final ApiClient _apiClient;

  SuggestionService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  Future<List<SuggestionModel>> getSuggestions({
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
      ApiEndpoints.adminSuggestions,
      queryParameters: queryParams,
    );
    final List<dynamic> list = response.data['data'] ?? [];
    return list.map((item) => SuggestionModel.fromJson(item)).toList();
  }

  Future<SuggestionModel> updateStatus(
    String id,
    String status, {
    String? adminNotes,
  }) async {
    final response = await _apiClient.patch(
      '${ApiEndpoints.adminSuggestions}/$id/status',
      data: {
        'status': status,
        if (adminNotes != null) 'adminNotes': adminNotes,
      },
    );
    final data = response.data['data'] ?? {};
    return SuggestionModel.fromJson(data);
  }

  Future<void> deleteSuggestion(String id) async {
    await _apiClient.delete('${ApiEndpoints.adminSuggestions}/$id');
  }
}
