import 'package:spare_shop_admin/app/app.locator.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'voltspare_models_extensions.dart';

class CartService {
  final ApiClient _apiClient;

  CartService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  Future<List<CartItemModel>> getCart() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.cart);
      final data = response.data['data'] ?? {};
      final List<dynamic> itemsList = data['items'] ?? [];
      return itemsList
          .map((item) => CartItemModelExtension.fromJson(item))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<CartItemModel>> addToCart(String productId, int quantity) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.cart}/items',
      data: {'productId': productId, 'quantity': quantity},
    );
    final data = response.data['data'] ?? {};
    final List<dynamic> itemsList = data['items'] ?? [];
    return itemsList
        .map((item) => CartItemModelExtension.fromJson(item))
        .toList();
  }

  Future<List<CartItemModel>> updateCartItem(
      String itemId, int quantity) async {
    final response = await _apiClient.patch(
      '${ApiEndpoints.cart}/items/$itemId',
      data: {'quantity': quantity},
    );
    final data = response.data['data'] ?? {};
    final List<dynamic> itemsList = data['items'] ?? [];
    return itemsList
        .map((item) => CartItemModelExtension.fromJson(item))
        .toList();
  }

  Future<List<CartItemModel>> deleteCartItem(String itemId) async {
    final response =
        await _apiClient.delete('${ApiEndpoints.cart}/items/$itemId');
    final data = response.data['data'] ?? {};
    final List<dynamic> itemsList = data['items'] ?? [];
    return itemsList
        .map((item) => CartItemModelExtension.fromJson(item))
        .toList();
  }

  Future<void> clearCart() async {
    await _apiClient.delete(ApiEndpoints.cart);
  }

  Future<Map<String, dynamic>> applyCoupon(String code) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.cart}/apply-coupon',
      data: {'code': code},
    );
    return response.data['data'] ?? {};
  }

  Future<void> removeCoupon() async {
    await _apiClient.delete('${ApiEndpoints.cart}/coupon');
  }
}
