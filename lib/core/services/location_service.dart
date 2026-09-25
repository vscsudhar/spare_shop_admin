import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:spare_shop_admin/ui/common/location_inventory_models.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class LocationService {
  final ApiClient _apiClient;

  LocationService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  /// Fetch all locations with optional search and status filters
  Future<List<LocationModel>> getLocations({
    String? search,
    String? status,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }
    if (status != null && status != 'All') {
      queryParameters['status'] = status.toLowerCase();
    }

    final response = await _apiClient.get(
      ApiEndpoints.locations,
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    final List<dynamic> list = response.data['data'] ?? [];
    return list.map((item) => LocationModel.fromJson(item)).toList();
  }

  /// Get a single location by ID
  Future<LocationModel> getLocationById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.locations}/$id');
    final data = response.data['data'] ?? {};
    return LocationModel.fromJson(data);
  }

  /// Create a new location
  Future<LocationModel> createLocation(
      Map<String, dynamic> locationData) async {
    final response = await _apiClient.post(
      ApiEndpoints.locations,
      data: locationData,
    );
    final data = response.data['data'] ?? {};
    return LocationModel.fromJson(data);
  }

  /// Update an existing location
  Future<LocationModel> updateLocation(
    String id,
    Map<String, dynamic> locationData,
  ) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.locations}/$id',
      data: locationData,
    );
    final data = response.data['data'] ?? {};
    return LocationModel.fromJson(data);
  }

  /// Delete a location by ID
  Future<void> deleteLocation(String id) async {
    await _apiClient.delete('${ApiEndpoints.locations}/$id');
  }

  // -------------------------------------------------------------
  // Location-wise Inventory APIs
  // -------------------------------------------------------------

  /// Get location inventory items with optional search
  Future<LocationInventoryResponse> getLocationInventory(
    String locationId, {
    String? search,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    final response = await _apiClient.get(
      '${ApiEndpoints.locations}/$locationId/inventory',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    final data = response.data['data'] ?? {};
    return LocationInventoryResponse.fromJson(data);
  }

  /// Add or update stock for a product in a location
  Future<LocationInventoryItem> updateInventoryStock(
    String locationId,
    String productId,
    int quantity,
  ) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.locations}/$locationId/inventory/$productId',
      data: {'quantity': quantity},
    );

    final data = response.data['data'] ?? {};
    return LocationInventoryItem.fromJson(data);
  }

  /// Delete inventory record for a product in a location
  Future<void> deleteInventoryRecord(
    String locationId,
    String productId,
  ) async {
    await _apiClient.delete(
      '${ApiEndpoints.locations}/$locationId/inventory/$productId',
    );
  }
}
