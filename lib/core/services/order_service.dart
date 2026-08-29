import 'package:spare_shop_admin/app/app.locator.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'voltspare_models_extensions.dart';

class OrderService {
  final ApiClient _apiClient;

  OrderService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  // --- Customer Methods ---

  Future<OrderModel> placeOrder({
    required String addressId,
    required String paymentMethod,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.orders,
      data: {
        'addressId': addressId,
        'paymentMethod': paymentMethod,
        'notes': notes ?? '',
      },
    );
    final data = response.data['data'] ?? {};
    return OrderModelExtension.fromJson(data);
  }

  Future<List<OrderModel>> getMyOrders() async {
    final response = await _apiClient.get('${ApiEndpoints.orders}/my');
    final List<dynamic> list = response.data['data'] ?? [];
    return list.map((item) => OrderModelExtension.fromJson(item)).toList();
  }

  Future<OrderModel> getMyOrderById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.orders}/my/$id');
    final data = response.data['data'] ?? {};
    return OrderModelExtension.fromJson(data);
  }

  Future<void> cancelOrder(String id) async {
    await _apiClient.post('${ApiEndpoints.orders}/$id/cancel');
  }

  Future<Map<String, dynamic>> validateCheckout({
    required String addressId,
    required String paymentMethod,
  }) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.checkout}/validate',
      data: {
        'addressId': addressId,
        'paymentMethod': paymentMethod,
      },
    );
    return response.data['data'] ?? {};
  }

  // --- Admin Methods ---

  Future<List<OrderModel>> adminGetAllOrders() async {
    final response = await _apiClient.get(ApiEndpoints.adminOrders);
    final List<dynamic> list = response.data['data'] ?? [];
    return list.map((item) => OrderModelExtension.fromJson(item)).toList();
  }

  Future<OrderModel> adminGetOrderById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.adminOrders}/$id');
    final data = response.data['data'] ?? {};
    return OrderModelExtension.fromJson(data);
  }

  Future<OrderModel> adminUpdateOrderStatus(String id, String status) async {
    final response = await _apiClient.patch(
      '${ApiEndpoints.adminOrders}/$id/status',
      data: {'status': status},
    );
    final data = response.data['data'] ?? {};
    return OrderModelExtension.fromJson(data);
  }

  Future<void> adminAssignDelivery(String id, String driverId,
      {String notes = ''}) async {
    await _apiClient.post(
      '${ApiEndpoints.adminOrders}/$id/assign-delivery',
      data: {
        'driverId': driverId,
        'notes': notes,
      },
    );
  }
}
