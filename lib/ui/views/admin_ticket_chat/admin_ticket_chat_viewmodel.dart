import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/admin_support_ticket_service.dart';
import 'package:spare_shop_admin/core/services/api_endpoints.dart';
import 'package:spare_shop_admin/core/services/socket_service.dart';
import 'package:spare_shop_admin/ui/common/admin_support_ticket_models.dart';
import 'package:stacked/stacked.dart';

class AdminTicketChatViewModel extends BaseViewModel with NavigationMixin {
  final _ticketService = locator<AdminSupportTicketService>();
  final _socketService = locator<SocketService>();
  final _picker = ImagePicker();

  String _ticketId = '';
  String get ticketId => _ticketId;

  AdminSupportTicket? _ticket;
  AdminSupportTicket? get ticket => _ticket;

  List<AdminTicketMessage> _messages = [];
  List<AdminTicketMessage> get messages => _messages;

  final messageController = TextEditingController();
  final scrollController = ScrollController();

  final List<XFile> _selectedPhotos = [];
  List<XFile> get selectedPhotos => _selectedPhotos;

  bool _isSending = false;
  bool get isSending => _isSending;

  bool _isInitialized = false;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> initialize(String id) async {
    if (_isInitialized && _ticketId == id) {
      return;
    }
    _ticketId = id;
    _isInitialized = true;
    _errorMessage = null;
    setBusy(true);
    await loadTicket();
    _setupSocket();
    setBusy(false);
  }

  Future<void> loadTicket() async {
    try {
      final details = await _ticketService.getTicketDetails(_ticketId);
      if (details['ticket'] is AdminSupportTicket) {
        _ticket = details['ticket'] as AdminSupportTicket;
      }
      if (details['messages'] is List<AdminTicketMessage>) {
        _messages = details['messages'] as List<AdminTicketMessage>;
      }
      _errorMessage = null;
      _scrollToBottom();
    } catch (e) {
      _errorMessage = 'Failed to load support ticket.';
      debugPrint('Error loading admin ticket details: $e');
    }
  }

  void _setupSocket() {
    try {
      _socketService.connect();
      _socketService.joinRoom('support-ticket:$_ticketId');

      _socketService.off('support_ticket:message');
      _socketService.off('support_ticket:status_changed');

      _socketService.on('support_ticket:message', (data) {
        if (data is Map<String, dynamic>) {
          final newMsg = AdminTicketMessage.fromJson(data);
          if (!_messages.any((m) => m.id == newMsg.id)) {
            _messages.add(newMsg);
            rebuildUi();
            _scrollToBottom();
          }
        }
      });

      _socketService.on('support_ticket:status_changed', (data) {
        if (data is Map<String, dynamic> &&
            data['status'] != null &&
            _ticket != null) {
          _ticket = _ticket!.copyWith(
            status: AdminTicketStatus.fromString(data['status'].toString()),
          );
          rebuildUi();
        }
      });
    } catch (_) {}
  }

  static String formatImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final clean = url.startsWith('/') ? url : '/$url';
    return '${ApiEndpoints.socketUrl}$clean';
  }

  Future<void> pickPhoto() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (photo != null) {
        _selectedPhotos.add(photo);
        rebuildUi();
      }
    } catch (e) {
      debugPrint('Error picking photo: $e');
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < _selectedPhotos.length) {
      _selectedPhotos.removeAt(index);
      rebuildUi();
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty && _selectedPhotos.isEmpty) return;

    _isSending = true;
    rebuildUi();

    final photosToSend = List<XFile>.from(_selectedPhotos);
    messageController.clear();
    _selectedPhotos.clear();

    try {
      final msg = await _ticketService.sendMessage(
        _ticketId,
        text.isNotEmpty ? text : 'Attached photo',
        photos: photosToSend,
      );

      if (!_messages.any((m) => m.id == msg.id)) {
        _messages.add(msg);
      }
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error sending admin reply: $e');
    } finally {
      _isSending = false;
      rebuildUi();
    }
  }

  Future<void> updateStatus(String status) async {
    setBusy(true);
    try {
      final updated = await _ticketService.updateStatus(_ticketId, status);
      _ticket = updated;
    } catch (_) {}
    setBusy(false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    try {
      _socketService.leaveRoom('support-ticket:$_ticketId');
    } catch (_) {}
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
