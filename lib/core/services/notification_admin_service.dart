import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/models/notification_model.dart';
import 'package:spare_shop_admin/core/services/api_client.dart';
import 'package:spare_shop_admin/core/services/api_endpoints.dart';

class NotificationAdminService {
  final ApiClient _apiClient;

  NotificationAdminService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  /// Search customers to target for single push notifications
  Future<List<CustomerNotificationTarget>> searchCustomers({
    String query = '',
    int limit = 25,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.notificationsCustomersList,
        queryParameters: {
          if (query.trim().isNotEmpty) 'search': query.trim(),
          'limit': limit.toString(),
        },
      );

      final dynamic raw = response.data;
      List<dynamic> list = [];
      if (raw is Map<String, dynamic> && raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        list = raw;
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => CustomerNotificationTarget.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('⚠️ [NotificationAdminService] searchCustomers error: $e');
      return [];
    }
  }

  /// Send targeted notification to a single customer
  Future<Map<String, dynamic>> sendSingleNotification({
    required String customerId,
    required String title,
    required String message,
    String? image,
    String type = 'manual_single',
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.notificationsSendSingle,
        data: {
          'customerId': customerId,
          'title': title.trim(),
          'message': message.trim(),
          'image': (image != null && image.trim().isNotEmpty) ? image.trim() : null,
          'type': type,
          if (data != null) 'data': data,
        },
      );

      return {
        'success': true,
        'message': response.data?['message'] ?? 'Notification sent successfully',
        'data': response.data?['data'],
      };
    } catch (e) {
      debugPrint('⚠️ [NotificationAdminService] sendSingleNotification error: $e');
      String errorMsg = 'Failed to send notification';
      if (e is DioException && e.response?.data is Map) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }
      return {
        'success': false,
        'message': errorMsg,
      };
    }
  }

  /// Send bulk broadcast notification to all customers
  Future<Map<String, dynamic>> sendBulkNotification({
    required String title,
    required String message,
    String? image,
    String targetAudience = 'all_customers',
    String type = 'manual_bulk',
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.notificationsSendBulk,
        data: {
          'title': title.trim(),
          'message': message.trim(),
          'image': (image != null && image.trim().isNotEmpty) ? image.trim() : null,
          'targetAudience': targetAudience,
          'type': type,
          if (data != null) 'data': data,
        },
      );

      return {
        'success': true,
        'message': response.data?['message'] ?? 'Broadcast notification sent successfully',
        'data': response.data?['data'],
      };
    } catch (e) {
      debugPrint('⚠️ [NotificationAdminService] sendBulkNotification error: $e');
      String errorMsg = 'Failed to send bulk broadcast';
      if (e is DioException && e.response?.data is Map) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }
      return {
        'success': false,
        'message': errorMsg,
      };
    }
  }

  /// Get admin notifications history with filtering and pagination
  Future<Map<String, dynamic>> getAdminHistory({
    int page = 1,
    int limit = 20,
    String? type,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (type != null && type.isNotEmpty && type != 'all') {
        queryParams['type'] = type;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _apiClient.get(
        ApiEndpoints.notificationsAdminHistory,
        queryParameters: queryParams,
      );

      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      final listRaw = data['notifications'] as List<dynamic>? ?? [];
      final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

      final items = listRaw
          .whereType<Map<String, dynamic>>()
          .map((json) => AdminNotificationItem.fromJson(json))
          .toList();

      return {
        'success': true,
        'items': items,
        'pagination': pagination,
      };
    } catch (e) {
      debugPrint('⚠️ [NotificationAdminService] getAdminHistory error: $e');
      return {
        'success': false,
        'items': <AdminNotificationItem>[],
        'pagination': {'total': 0, 'page': page, 'totalPages': 1},
      };
    }
  }

  /// Upload notification image attachment
  Future<String?> uploadImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: file.name.isNotEmpty ? file.name : 'notification_banner.jpg'),
        'folder': 'voltspare/notifications',
      });

      final response = await _apiClient.post('/uploads', data: formData);
      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        if (raw['data'] is Map && raw['data']['url'] != null) {
          return raw['data']['url'].toString();
        }
        if (raw['data'] is String) return raw['data'].toString();
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ [NotificationAdminService] uploadImage error: $e');
      return null;
    }
  }

  /// Mark specific notification as read
  Future<bool> markAsRead(String id) async {
    try {
      await _apiClient.patch('/notifications/$id/read');
      return true;
    } catch (e) {
      debugPrint('⚠️ [NotificationAdminService] markAsRead error: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      await _apiClient.patch(ApiEndpoints.notificationsReadAll);
      return true;
    } catch (e) {
      debugPrint('⚠️ [NotificationAdminService] markAllAsRead error: $e');
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String id) async {
    try {
      await _apiClient.delete('/notifications/$id');
      return true;
    } catch (e) {
      debugPrint('⚠️ [NotificationAdminService] deleteNotification error: $e');
      return false;
    }
  }
}
