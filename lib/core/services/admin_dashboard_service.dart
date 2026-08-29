import 'package:spare_shop_admin/app/app.locator.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class AdminDashboardService {
  final ApiClient _apiClient;

  AdminDashboardService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  Future<Map<String, dynamic>> getSummary() async {
    final response = await _apiClient.get('${ApiEndpoints.dashboard}/summary');
    return response.data['data'] ?? {};
  }

  Future<List<dynamic>> getRecentOrders() async {
    final response =
        await _apiClient.get('${ApiEndpoints.dashboard}/recent-orders');
    return response.data['data'] ?? [];
  }

  Future<List<dynamic>> getLowStock() async {
    final response =
        await _apiClient.get('${ApiEndpoints.dashboard}/low-stock');
    return response.data['data'] ?? [];
  }

  Future<List<dynamic>> getSalesChart(String range) async {
    final response = await _apiClient.get(
        '${ApiEndpoints.dashboard}/sales-chart',
        queryParameters: {'range': range});
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> getQuickStats() async {
    final response =
        await _apiClient.get('${ApiEndpoints.dashboard}/quick-stats');
    return response.data['data'] ?? {};
  }
}
