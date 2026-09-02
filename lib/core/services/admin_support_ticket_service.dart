import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/services/api_client.dart';
import 'package:spare_shop_admin/ui/common/admin_support_ticket_models.dart';

class AdminSupportTicketService {
  final ApiClient _apiClient;

  AdminSupportTicketService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  /// Admin: Get all tickets with optional status & category filter
  Future<List<AdminSupportTicket>> getAllTickets(
      {String? status, String? category}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null &&
          status.isNotEmpty &&
          status.toLowerCase() != 'all') {
        queryParams['status'] = status.toLowerCase();
      }
      if (category != null &&
          category.isNotEmpty &&
          category.toLowerCase() != 'all') {
        queryParams['category'] = category;
      }

      final response = await _apiClient.get(
        '/support-tickets/admin/all',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final raw = response.data;
      final List<dynamic> list;
      if (raw is Map<String, dynamic>) {
        if (raw['data'] is List) {
          list = raw['data'] as List<dynamic>;
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
          .map((json) => AdminSupportTicket.fromJson(json))
          .toList();
    } catch (e, st) {
      debugPrint('AdminSupportTicketService.getAllTickets error: $e\n$st');
      return [];
    }
  }

  /// Admin: Get ticket details and conversation messages
  Future<Map<String, dynamic>> getTicketDetails(String ticketId) async {
    final response = await _apiClient.get('/support-tickets/$ticketId');

    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final ticketJson = data['ticket'] as Map<String, dynamic>? ?? {};
    final messagesList = data['messages'] as List<dynamic>? ?? [];

    final ticket = AdminSupportTicket.fromJson(ticketJson);
    final messages = messagesList
        .map((m) => AdminTicketMessage.fromJson(m as Map<String, dynamic>))
        .toList();

    return {
      'ticket': ticket,
      'messages': messages,
    };
  }

  /// Admin: Send reply message in ticket chat
  Future<AdminTicketMessage> sendMessage(
    String ticketId,
    String message, {
    List<XFile> photos = const [],
  }) async {
    final formData = FormData.fromMap({
      'message': message,
    });

    if (photos.isNotEmpty) {
      for (final photo in photos) {
        final bytes = await photo.readAsBytes();
        final multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: photo.name.isNotEmpty ? photo.name : 'attachment.jpg',
        );
        formData.files.add(MapEntry('photos', multipartFile));
      }
    }

    final response = await _apiClient.post(
      '/support-tickets/$ticketId/messages',
      data: formData,
    );

    final msgData = response.data['data'] as Map<String, dynamic>;
    return AdminTicketMessage.fromJson(msgData);
  }

  /// Admin: Update ticket status ('open', 'pending', 'resolved', 'closed')
  Future<AdminSupportTicket> updateStatus(
      String ticketId, String status) async {
    final response = await _apiClient.patch(
      '/support-tickets/$ticketId/status',
      data: {'status': status},
    );

    final ticketData = response.data['data'] as Map<String, dynamic>;
    return AdminSupportTicket.fromJson(ticketData);
  }
}
