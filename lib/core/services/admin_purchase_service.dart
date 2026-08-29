import 'package:spare_shop_admin/app/app.locator.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class AdminPurchaseService {
  final ApiClient _apiClient;

  AdminPurchaseService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  Future<List<dynamic>> getPurchases() async {
    final response = await _apiClient.get(ApiEndpoints.purchases);
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> getPurchaseById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.purchases}/$id');
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> createPurchase(
      Map<String, dynamic> poData) async {
    final response = await _apiClient.post(
      ApiEndpoints.purchases,
      data: poData,
    );
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> receiveReceipt(
      String id, List<Map<String, dynamic>> items) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.purchases}/$id/receive',
      data: {'items': items},
    );
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> updatePurchase(
      String id, Map<String, dynamic> poData) async {
    final response = await _apiClient.patch(
      '${ApiEndpoints.purchases}/$id',
      data: poData,
    );
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> updatePurchaseStatus(
      String id, String status) async {
    final response = await _apiClient.patch(
      '${ApiEndpoints.purchases}/$id/status',
      data: {'status': status.toLowerCase()},
    );
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> createPayment(
    String id, {
    required double amount,
    required String paymentMethod,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.purchases}/$id/payments',
      data: {
        'amount': (amount * 100).toInt(), // convert to paise
        'paymentMethod': paymentMethod,
        'notes': notes ?? '',
      },
    );
    return response.data['data'] ?? {};
  }
}
