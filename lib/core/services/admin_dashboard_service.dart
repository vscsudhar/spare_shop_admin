import 'package:spare_shop_admin/app/app.locator.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class AdminDashboardService {
  final ApiClient _apiClient;

  AdminDashboardService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  Future<Map<String, dynamic>> getSummary({String? locationId}) async {
    final queryParameters = <String, dynamic>{};
    if (locationId != null && locationId.isNotEmpty && locationId != 'all') {
      queryParameters['locationId'] = locationId;
    }
    final response = await _apiClient.get(
      '${ApiEndpoints.dashboard}/summary',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );
    return response.data['data'] ?? {};
  }

  Future<List<dynamic>> getRecentOrders({String? locationId}) async {
    final queryParameters = <String, dynamic>{};
    if (locationId != null && locationId.isNotEmpty && locationId != 'all') {
      queryParameters['locationId'] = locationId;
    }
    final response = await _apiClient.get(
      '${ApiEndpoints.dashboard}/recent-orders',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );
    return response.data['data'] ?? [];
  }

  Future<List<dynamic>> getLowStock({String? locationId}) async {
    final queryParameters = <String, dynamic>{};
    if (locationId != null && locationId.isNotEmpty && locationId != 'all') {
      queryParameters['locationId'] = locationId;
    }
    final response = await _apiClient.get(
      '${ApiEndpoints.dashboard}/low-stock',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );
    return response.data['data'] ?? [];
  }

  Future<List<dynamic>> getSalesChart(String range, {String? locationId}) async {
    final queryParameters = <String, dynamic>{'range': range};
    if (locationId != null && locationId.isNotEmpty && locationId != 'all') {
      queryParameters['locationId'] = locationId;
    }
    final response = await _apiClient.get(
      '${ApiEndpoints.dashboard}/sales-chart',
      queryParameters: queryParameters,
    );
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> getQuickStats({String? locationId}) async {
    final queryParameters = <String, dynamic>{};
    if (locationId != null && locationId.isNotEmpty && locationId != 'all') {
      queryParameters['locationId'] = locationId;
    }
    final response = await _apiClient.get(
      '${ApiEndpoints.dashboard}/quick-stats',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );
    return response.data['data'] ?? {};
  }
}
