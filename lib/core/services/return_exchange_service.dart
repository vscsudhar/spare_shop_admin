import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/services/api_client.dart';
import 'package:spare_shop_admin/ui/common/return_exchange_models.dart';

class ReturnExchangeService {
  final ApiClient _apiClient;

  ReturnExchangeService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  /// Search bill or order by query string
  Future<BillLookupResult> searchBill(String query) async {
    final response = await _apiClient.get(
      '/returns/search-bill',
      queryParameters: {'q': query.trim()},
    );
    final data = response.data['data'] ?? {};
    return BillLookupResult.fromJson(data);
  }

  /// Create a new Return / Damage / Exchange case
  Future<ReturnExchangeCase> createCase(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      '/returns',
      data: payload,
    );
    final data = response.data['data'] ?? {};
    return ReturnExchangeCase.fromJson(data);
  }

  /// Get all cases with optional filtering
  Future<List<ReturnExchangeCase>> getCases({
    String? status,
    String? type,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }
    if (type != null && type.isNotEmpty && type != 'all') {
      queryParams['type'] = type;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _apiClient.get(
      '/returns',
      queryParameters: queryParams,
    );
    final List<dynamic> list = response.data['data'] ?? [];
    return list.map((item) => ReturnExchangeCase.fromJson(item)).toList();
  }

  /// Get case by ID with full details
  Future<ReturnExchangeCase> getCaseById(String id) async {
    final response = await _apiClient.get('/returns/$id');
    final data = response.data['data'] ?? {};
    return ReturnExchangeCase.fromJson(data);
  }

  /// Update case status
  Future<ReturnExchangeCase> updateCaseStatus(
    String id,
    String status, {
    String? notes,
  }) async {
    final response = await _apiClient.patch(
      '/returns/$id/status',
      data: {
        'status': status,
        'notes': notes ?? '',
      },
    );
    final data = response.data['data'] ?? {};
    return ReturnExchangeCase.fromJson(data);
  }

  /// Get list of damaged products across cases with metrics
  Future<DamagedItemsResponse> getDamagedItems({
    String? damageType,
    String? damageDiscoveredAt,
    String? damageResolution,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (damageType != null && damageType.isNotEmpty && damageType != 'all') {
      queryParams['damageType'] = damageType;
    }
    if (damageDiscoveredAt != null && damageDiscoveredAt.isNotEmpty && damageDiscoveredAt != 'all') {
      queryParams['damageDiscoveredAt'] = damageDiscoveredAt;
    }
    if (damageResolution != null && damageResolution.isNotEmpty && damageResolution != 'all') {
      queryParams['damageResolution'] = damageResolution;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _apiClient.get(
      '/returns/damaged-items',
      queryParameters: queryParams,
    );

    final List<dynamic> list = response.data['data'] ?? [];
    final items = list.map((i) => DamagedItemRecord.fromJson(i)).toList();
    final meta = response.data['meta'] ?? {};
    final metricsJson = meta['metrics'] ?? {};
    final metrics = DamagedItemsMetrics.fromJson(metricsJson);
    final total = meta['total'] ?? items.length;

    return DamagedItemsResponse(
      metrics: metrics,
      items: items,
      total: total,
    );
  }
}
