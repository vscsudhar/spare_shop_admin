import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/app/app.router.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/rare_request_service.dart';
import 'package:spare_shop_admin/core/services/socket_service.dart';
import 'package:spare_shop_admin/core/services/voltspare_models_extensions.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

class AdminRareRequestChatViewModel extends BaseViewModel with NavigationMixin {
  final _rareRequestService = locator<RareRequestService>();
  final _socketService = locator<SocketService>();

  late String _requestId;
  String get requestId => _requestId;

  final textController = TextEditingController();

  RareProductRequestModel? _request;
  RareProductRequestModel? get request => _request;

  List<RareChatMessageModel> _chatMessages = [];
  List<RareChatMessageModel> get chatMessages => _chatMessages;

  bool _isInitialized = false;

  void initialize(String id) async {
    if (_isInitialized && _requestId == id) return;
    _requestId = id;
    _isInitialized = true;
    setBusy(true);

    try {
      _request = await _rareRequestService.adminGetRequestById(id);
      _chatMessages = await _rareRequestService.getChatMessages(id);
      rebuildUi();
    } catch (e, st) {
      debugPrint('Error loading admin chat init: $e\n$st');
    } finally {
      setBusy(false);
    }

    // Connect real-time socket listeners
    _socketService.connect();
    _socketService.joinRequestRoom(id);

    _socketService.off('rare_chat:message');
    _socketService.off('rare_chat:read');
    _socketService.off('rare_request:updated');

    // Emit read receipt for existing messages
    _socketService.emit('rare_chat:read', {'requestId': id});

    _socketService.on('rare_chat:message', (data) {
      if (disposed) return;
      if (data != null) {
        try {
          final newMsg = RareChatMessageModelExtension.fromJson(
              Map<String, dynamic>.from(data));
          if (!_chatMessages.any((m) => m.id == newMsg.id)) {
            _chatMessages.add(newMsg);

            // Immediately mark it as read since the chat view is active
            _socketService.emit('rare_chat:read', {'requestId': _requestId});

            rebuildUi();
          }
        } catch (_) {}
      }
    });

    _socketService.on('rare_chat:read', (data) {
      if (disposed) return;
      if (data != null) {
        try {
          final map = Map<String, dynamic>.from(data);
          final readerId = map['userId']?.toString();
          if (readerId != null) {
            bool changed = false;
            for (var msg in _chatMessages) {
              if (!msg.readBy.contains(readerId)) {
                msg.readBy.add(readerId);
                changed = true;
              }
            }
            if (changed) rebuildUi();
          }
        } catch (_) {}
      }
    });

    _socketService.on('rare_chat:received', (data) {
      if (disposed) return;
      if (data != null) {
        try {
          final map = Map<String, dynamic>.from(data);
          final msgId = map['messageId']?.toString();
          final receiverId = map['userId']?.toString();
          if (msgId != null && receiverId != null) {
            final index = _chatMessages.indexWhere((m) => m.id == msgId);
            if (index != -1) {
              final msg = _chatMessages[index];
              if (!msg.receivedBy.contains(receiverId)) {
                msg.receivedBy.add(receiverId);
                rebuildUi();
              }
            }
          }
        } catch (_) {}
      }
    });

    _socketService.on('rare_request:updated', (data) {
      if (disposed) return;
      if (data != null) {
        try {
          _request = RareProductRequestModelExtension.fromJson(
              Map<String, dynamic>.from(data));
          rebuildUi();
        } catch (_) {}
      }
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMsg = RareChatMessageModel(
      id: tempId,
      message: text.trim(),
      sender: RareChatSender.admin,
      timestamp: DateTime.now(),
      messageType: RareChatMessageType.text,
      readBy: [],
      receivedBy: [],
    );

    _chatMessages.add(tempMsg);
    rebuildUi();

    textController.clear();
    try {
      final newMsg = await _rareRequestService.adminSendChatMessage(
          _requestId, text.trim());

      final index = _chatMessages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        _chatMessages[index] = newMsg;
      } else if (!_chatMessages.any((m) => m.id == newMsg.id)) {
        _chatMessages.add(newMsg);
      }
      rebuildUi();
    } catch (_) {
      _chatMessages.removeWhere((m) => m.id == tempId);
      rebuildUi();
    }
  }

  Future<void> markSearching() async {
    setBusy(true);
    try {
      _request =
          await _rareRequestService.adminUpdateStatus(_requestId, 'searching');
      rebuildUi();
    } catch (_) {
    } finally {
      setBusy(false);
    }
  }

  Future<void> markProductFound() async {
    setBusy(true);
    try {
      _request =
          await _rareRequestService.adminUpdateStatus(_requestId, 'found');
      rebuildUi();
    } catch (_) {
    } finally {
      setBusy(false);
    }
  }

  Future<void> convertApprovedRequestToOrder() async {
    setBusy(true);
    try {
      await _rareRequestService.adminConvertToOrder(_requestId);
      _request = await _rareRequestService.adminGetRequestById(_requestId);
      _chatMessages = await _rareRequestService.getChatMessages(_requestId);
      rebuildUi();
    } catch (e, st) {
      debugPrint('Error converting request to order: $e\n$st');
    } finally {
      setBusy(false);
    }
  }

  Future<void> openQuotationBuilder() async {
    await navigationService.navigateTo(
      Routes.adminCreateQuotationView,
      arguments: AdminCreateQuotationViewArguments(requestId: _requestId),
    );
    try {
      _request = await _rareRequestService.adminGetRequestById(_requestId);
      _chatMessages = await _rareRequestService.getChatMessages(_requestId);
      rebuildUi();
    } catch (_) {}
  }

  Future<void> markProductNotFound() async {
    // Redirect to cancellation view to pick reasons
    navigationService.navigateTo(
      Routes.adminCancelledRequestView,
      arguments: AdminCancelledRequestViewArguments(requestId: _requestId),
    );
  }

  void closeRequest() {
    goBack();
  }

  bool _showSummaryDetails = false;
  bool get showSummaryDetails => _showSummaryDetails;

  void toggleSummaryDetails() {
    _showSummaryDetails = !_showSummaryDetails;
    notifyListeners();
  }

  @override
  void dispose() {
    _socketService.leaveRequestRoom(_requestId);
    _socketService.off('rare_chat:message');
    _socketService.off('rare_chat:read');
    _socketService.off('rare_chat:received');
    _socketService.off('rare_request:updated');
    textController.dispose();
    super.dispose();
  }
}
