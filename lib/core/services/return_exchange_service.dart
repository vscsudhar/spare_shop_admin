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
    String? locationId,
    String? channel,
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
    if (locationId != null && locationId.isNotEmpty && locationId != 'all') {
      queryParams['locationId'] = locationId;
    }
    if (channel != null && channel.isNotEmpty && channel != 'all') {
      queryParams['channel'] = channel;
    }

    final response = await _apiClient.get(
      '/returns',
      queryParameters: queryParams,
    );

    final raw = response.data;
    List<dynamic> list = [];
    if (raw is Map) {
      final d = raw['data'];
      if (d is List) {
        list = d;
      } else if (d is Map && d['cases'] is List) {
        list = d['cases'] as List;
      } else if (d is Map && d['items'] is List) {
        list = d['items'] as List;
      }
    } else if (raw is List) {
      list = raw;
    }

    return list
        .whereType<Map>()
        .map((item) =>
            ReturnExchangeCase.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  /// Get case by ID with full details
  Future<ReturnExchangeCase> getCaseById(String id) async {
    final response = await _apiClient.get('/returns/$id');
    final data = response.data['data'] is Map
        ? Map<String, dynamic>.from(response.data['data'])
        : <String, dynamic>{};
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
    final data = response.data['data'] is Map
        ? Map<String, dynamic>.from(response.data['data'])
        : <String, dynamic>{};
    return ReturnExchangeCase.fromJson(data);
  }

  /// Update case location
  Future<ReturnExchangeCase> updateCaseLocation(
    String id, {
    String? locationId,
    String? locationName,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/returns/$id/location',
        data: {
          'locationId': locationId,
          if (locationName != null) 'locationName': locationName,
        },
      );
      final data = response.data['data'] is Map
          ? Map<String, dynamic>.from(response.data['data'])
          : <String, dynamic>{};
      return ReturnExchangeCase.fromJson(data);
    } catch (_) {
      final kase = await getCaseById(id);
      return kase.copyWith(
        locationId: locationId,
        locationName: locationName,
      );
    }
  }

  /// Get list of damaged products across cases with metrics
  Future<DamagedItemsResponse> getDamagedItems({
    String? damageType,
    String? damageDiscoveredAt,
    String? damageResolution,
    String? search,
    String? locationId,
    String? channel,
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
    if (damageDiscoveredAt != null &&
        damageDiscoveredAt.isNotEmpty &&
        damageDiscoveredAt != 'all') {
      queryParams['damageDiscoveredAt'] = damageDiscoveredAt;
    }
    if (damageResolution != null &&
        damageResolution.isNotEmpty &&
        damageResolution != 'all') {
      queryParams['damageResolution'] = damageResolution;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (locationId != null && locationId.isNotEmpty && locationId != 'all') {
      queryParams['locationId'] = locationId;
    }
    if (channel != null && channel.isNotEmpty && channel != 'all') {
      queryParams['channel'] = channel;
    }

    final response = await _apiClient.get(
      '/returns/damaged-items',
      queryParameters: queryParams,
    );

    final raw = response.data;
    List<dynamic> list = [];
    Map<String, dynamic> metricsJson = {};
    int total = 0;

    if (raw is Map) {
      final d = raw['data'];
      if (d is List) {
        list = d;
      } else if (d is Map && d['items'] is List) {
        list = d['items'] as List;
        if (d['metrics'] is Map) {
          metricsJson = Map<String, dynamic>.from(d['metrics'] as Map);
        }
      }
      final meta = raw['meta'];
      if (meta is Map) {
        if (meta['metrics'] is Map && metricsJson.isEmpty) {
          metricsJson = Map<String, dynamic>.from(meta['metrics'] as Map);
        }
        total =
            meta['total'] is num ? (meta['total'] as num).toInt() : list.length;
      }
    } else if (raw is List) {
      list = raw;
      total = list.length;
    }

    final items = list
        .whereType<Map>()
        .map((i) => DamagedItemRecord.fromJson(Map<String, dynamic>.from(i)))
        .toList();

    return DamagedItemsResponse(
      metrics: DamagedItemsMetrics.fromJson(metricsJson),
      items: items,
      total: total > 0 ? total : items.length,
    );
  }
}
