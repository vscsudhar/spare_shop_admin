import 'package:spare_shop_admin/app/app.locator.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'voltspare_models_extensions.dart';

class WishlistService {
  final ApiClient _apiClient;

  WishlistService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  Future<List<ProductModel>> getWishlist() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.wishlist);
      final List<dynamic> list = response.data['data']?['products'] ?? [];
      return list.map((item) => ProductModelExtension.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<ProductModel>> addToWishlist(String productId) async {
    final response =
        await _apiClient.post('${ApiEndpoints.wishlist}/$productId');
    final List<dynamic> list = response.data['data']?['products'] ?? [];
    return list.map((item) => ProductModelExtension.fromJson(item)).toList();
  }

  Future<List<ProductModel>> removeFromWishlist(String productId) async {
    final response =
        await _apiClient.delete('${ApiEndpoints.wishlist}/$productId');
    final List<dynamic> list = response.data['data']?['products'] ?? [];
    return list.map((item) => ProductModelExtension.fromJson(item)).toList();
  }
}
