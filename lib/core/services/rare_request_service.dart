import 'package:spare_shop_admin/app/app.locator.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'voltspare_models_extensions.dart';

class RareRequestService {
  final ApiClient _apiClient;

  RareRequestService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  // --- Customer Sourcing ---

  Future<RareProductRequestModel> createRequest({
    required String title,
    required String description,
    required int quantity,
    required String urgency,
    double? budget,
    required String brand,
    required String modelName,
    required String year,
    required String vehicleType,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.rareRequests,
      data: {
        'title': title,
        'description': description,
        'quantity': quantity,
        'urgency': urgency.toLowerCase(),
        'budget':
            budget != null ? (budget * 100).toInt() : null, // Convert to paise
        'vehicle': {
          'brand': brand,
          'name': modelName,
          'year': year,
          'type': vehicleType.toLowerCase(),
        }
      },
    );
    final data = response.data['data'] ?? {};
    return RareProductRequestModelExtension.fromJson(data);
  }

  Future<List<RareProductRequestModel>> getMyRequests() async {
    final response = await _apiClient.get('${ApiEndpoints.rareRequests}/my');
    final List<dynamic> list = response.data['data'] ?? [];
    return list
        .map((item) => RareProductRequestModelExtension.fromJson(item))
        .toList();
  }

  Future<RareProductRequestModel> getRequestById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.rareRequests}/$id');
    final data = response.data['data'] ?? {};
    return RareProductRequestModelExtension.fromJson(data);
  }

  Future<List<RareChatMessageModel>> getChatMessages(String id) async {
    final response =
        await _apiClient.get('${ApiEndpoints.rareRequests}/$id/messages');
    final List<dynamic> list = response.data['data'] ?? [];
    return list
        .map((item) => RareChatMessageModelExtension.fromJson(item))
        .toList();
  }

  Future<RareChatMessageModel> sendChatMessage(String id, String text) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.rareRequests}/$id/messages',
      data: {'message': text},
    );
    final data = response.data['data'] ?? {};
    return RareChatMessageModelExtension.fromJson(data);
  }

  Future<void> customerApproveQuotation(
      String id, String quotationId, String addressId) async {
    await _apiClient.patch(
      '${ApiEndpoints.rareRequests}/$id/quotations/$quotationId/approve',
      data: {'addressId': addressId},
    );
  }

  Future<void> customerDeclineQuotation(
      String id, String quotationId, String reason) async {
    await _apiClient.patch(
      '${ApiEndpoints.rareRequests}/$id/quotations/$quotationId/decline',
      data: {'reason': reason},
    );
  }

  // --- Admin Sourcing ---

  Future<List<RareProductRequestModel>> adminGetAllRequests({
    String? status,
    String? search,
  }) async {
    final Map<String, dynamic> query = {};
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      query['status'] = status.toLowerCase();
    }
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }

    final response = await _apiClient.get(
      ApiEndpoints.adminRareRequests,
      queryParameters: query.isNotEmpty ? query : null,
    );

    final raw = response.data;
    final List<dynamic> list;
    if (raw is Map<String, dynamic>) {
      if (raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      } else if (raw['data'] is Map && raw['data']['items'] is List) {
        list = raw['data']['items'] as List<dynamic>;
      } else {
        list = [];
      }
    } else if (raw is List) {
      list = raw;
    } else {
      list = [];
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map((item) => RareProductRequestModelExtension.fromJson(item))
        .toList();
  }

  Future<RareProductRequestModel> adminGetRequestById(String id) async {
    final response =
        await _apiClient.get('${ApiEndpoints.adminRareRequests}/$id');
    final data = response.data['data'] ?? {};
    return RareProductRequestModelExtension.fromJson(data);
  }

  Future<RareQuotationModel> adminCreateQuotationDraft(
    String id, {
    required String partName,
    required double price,
    required double shippingCharge,
    required double gst,
    required double discount,
    required String deliveryTimeline,
    required DateTime expiryDate,
    String? adminNotes,
  }) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.adminRareRequests}/$id/quotations',
      data: {
        'expiresAt': expiryDate.toUtc().toIso8601String(),
        'deliveryFee': (shippingCharge * 100).toInt(),
        'shippingCharge': (shippingCharge * 100).toInt(),
        'discount': (discount * 100).toInt(),
        'deliveryTimeline': deliveryTimeline,
        'adminNotes': adminNotes ?? '',
        'items': [
          {
            'name': partName,
            'partName': partName,
            'partNumber': '',
            'quantity': 1,
            'unitPrice': (price * 100).toInt(),
            'price': (price * 100).toInt(),
            'taxPercentage': 18,
          }
        ]
      },
    );
    final data = response.data['data'] ?? {};
    return RareQuotationModelExtension.fromJson(data);
  }

  Future<RareQuotationModel> adminReviseQuotationDraft(
    String id,
    String quotationId, {
    required String partName,
    required double price,
    required double shippingCharge,
    required double gst,
    required double discount,
    required String deliveryTimeline,
    required DateTime expiryDate,
    String? adminNotes,
  }) async {
    final response = await _apiClient.patch(
      '${ApiEndpoints.adminRareRequests}/$id/quotations/$quotationId',
      data: {
        'expiresAt': expiryDate.toUtc().toIso8601String(),
        'deliveryFee': (shippingCharge * 100).toInt(),
        'shippingCharge': (shippingCharge * 100).toInt(),
        'discount': (discount * 100).toInt(),
        'deliveryTimeline': deliveryTimeline,
        'adminNotes': adminNotes ?? '',
        'items': [
          {
            'name': partName,
            'partName': partName,
            'partNumber': '',
            'quantity': 1,
            'unitPrice': (price * 100).toInt(),
            'price': (price * 100).toInt(),
            'taxPercentage': 18,
          }
        ]
      },
    );
    final data = response.data['data'] ?? {};
    return RareQuotationModelExtension.fromJson(data);
  }

  Future<void> adminSendQuotation(String id, String quotationId) async {
    await _apiClient.post(
        '${ApiEndpoints.adminRareRequests}/$id/quotations/$quotationId/send');
  }

  Future<void> adminConvertToOrder(String id) async {
    await _apiClient.post(
      '${ApiEndpoints.adminRareRequests}/$id/convert-to-order',
    );
  }

  Future<void> adminCancelRequest(String id, String reason) async {
    await _apiClient.patch(
      '${ApiEndpoints.adminRareRequests}/$id/cancel',
      data: {'reason': reason},
    );
  }

  Future<RareProductRequestModel> adminUpdateStatus(
      String id, String status) async {
    final response = await _apiClient.patch(
      '${ApiEndpoints.adminRareRequests}/$id/status',
      data: {'status': status},
    );
    final data = response.data['data'] ?? {};
    return RareProductRequestModelExtension.fromJson(data);
  }

  Future<RareChatMessageModel> adminSendChatMessage(
      String id, String text) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.adminRareRequests}/$id/messages',
      data: {'message': text},
    );
    final data = response.data['data'] ?? {};
    return RareChatMessageModelExtension.fromJson(data);
  }

  Future<void> reopenRequest(String id) async {
    await _apiClient.post('${ApiEndpoints.rareRequests}/$id/reopen');
  }
}
