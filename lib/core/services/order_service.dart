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

  Future<List<OrderModel>> adminGetAllOrders({String? locationId}) async {
    final queryParams = <String, dynamic>{};
    if (locationId != null && locationId.isNotEmpty && locationId != 'all') {
      queryParams['locationId'] = locationId;
    }

    final response = await _apiClient.get(
      ApiEndpoints.adminOrders,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final raw = response.data;
    List<dynamic> list = [];
    if (raw is Map) {
      final d = raw['data'];
      if (d is List) {
        list = d;
      } else if (d is Map && d['orders'] is List) {
        list = d['orders'] as List;
      } else if (d is Map && d['items'] is List) {
        list = d['items'] as List;
      }
    } else if (raw is List) {
      list = raw;
    }

    return list
        .whereType<Map>()
        .map((item) => OrderModelExtension.fromJson(Map<String, dynamic>.from(item)))
        .toList();
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

  Future<OrderModel> adminUpdateOrderLocation(
    String id, {
    String? locationId,
    String? locationName,
  }) async {
    try {
      final response = await _apiClient.patch(
        '${ApiEndpoints.adminOrders}/$id/location',
        data: {
          'locationId': locationId,
          if (locationName != null) 'locationName': locationName,
        },
      );
      final data = response.data['data'] ?? {};
      return OrderModelExtension.fromJson(data);
    } catch (_) {
      // Fallback: If backend route is not available or offline, return local modified model
      final order = await adminGetOrderById(id);
      return order.copyWith(
        locationId: locationId,
        locationName: locationName,
      );
    }
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
