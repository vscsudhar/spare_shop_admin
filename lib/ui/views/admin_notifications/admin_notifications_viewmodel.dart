import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/models/notification_model.dart';
import 'package:spare_shop_admin/core/services/notification_admin_service.dart';
import 'package:stacked/stacked.dart';

class AdminNotificationsViewModel extends BaseViewModel {
  final NotificationAdminService _notificationService =
      locator<NotificationAdminService>();

  // Tabs: 0 = Send, 1 = History
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  // Send Mode: 'single' or 'bulk'
  String _sendMode = 'single';
  String get sendMode => _sendMode;

  // Target audience for bulk
  String _targetAudience = 'all_customers';
  String get targetAudience => _targetAudience;

  // Notification type
  String _selectedType = 'promotional';
  String get selectedType => _selectedType;

  // Templates
  List<NotificationTemplate> get templates => NotificationTemplate.defaultTemplates;
  NotificationTemplate? _selectedTemplate;
  NotificationTemplate? get selectedTemplate => _selectedTemplate;

  // Right panel subtab: 0 = Templates, 1 = Live Preview
  int _rightPanelTabIndex = 0;
  int get rightPanelTabIndex => _rightPanelTabIndex;
  void setRightPanelTabIndex(int idx) {
    _rightPanelTabIndex = idx;
    notifyListeners();
  }

  // Form Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController customerSearchController =
      TextEditingController();
  final TextEditingController historySearchController =
      TextEditingController();

  // Selected customer for single send
  CustomerNotificationTarget? _selectedCustomer;
  CustomerNotificationTarget? get selectedCustomer => _selectedCustomer;

  // Customer search suggestions
  List<CustomerNotificationTarget> _customerSuggestions = [];
  List<CustomerNotificationTarget> get customerSuggestions =>
      _customerSuggestions;
  bool _isSearchingCustomers = false;
  bool get isSearchingCustomers => _isSearchingCustomers;

  // Image upload state
  bool _isUploadingImage = false;
  bool get isUploadingImage => _isUploadingImage;
  String? _uploadedImageUrl;
  String? get uploadedImageUrl => _uploadedImageUrl;

  // History state
  List<AdminNotificationItem> _historyItems = [];
  List<AdminNotificationItem> get historyItems => _historyItems;
  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;

  int _currentPage = 1;
  int get currentPage => _currentPage;
  int _totalPages = 1;
  int get totalPages => _totalPages;
  int _totalHistoryCount = 0;
  int get totalHistoryCount => _totalHistoryCount;

  String _historyTypeFilter = 'all';
  String get historyTypeFilter => _historyTypeFilter;

  // Live preview getters
  String get previewTitle => titleController.text.trim().isEmpty
      ? 'Special Announcement ⚡'
      : titleController.text.trim();

  String get previewMessage => messageController.text.trim().isEmpty
      ? 'Get up to 20% off genuine spare parts with VoltSpare. Limited time offer.'
      : messageController.text.trim();

  String? get previewImage {
    if (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty) {
      return _uploadedImageUrl;
    }
    if (imageUrlController.text.trim().isNotEmpty) {
      return imageUrlController.text.trim();
    }
    return null;
  }

  void init() {
    titleController.addListener(notifyListeners);
    messageController.addListener(notifyListeners);
    imageUrlController.addListener(notifyListeners);

    loadHistory();
    searchCustomers('');
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    if (_currentTabIndex == 1 && _historyItems.isEmpty) {
      loadHistory();
    }
    notifyListeners();
  }

  void setSendMode(String mode) {
    _sendMode = mode;
    notifyListeners();
  }

  void setTargetAudience(String audience) {
    _targetAudience = audience;
    notifyListeners();
  }

  void setSelectedType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void applyTemplate(NotificationTemplate template, [BuildContext? context]) {
    _selectedTemplate = template;
    _sendMode = 'bulk';
    _targetAudience = 'all_customers';
    titleController.text = template.title;
    messageController.text = template.message;
    _selectedType = template.type;
    _uploadedImageUrl = null;
    imageUrlController.text = template.image ?? '';
    notifyListeners();

    if (context != null && context.mounted) {
      _showToast(
        context,
        'Template applied to Broadcast! Ready to send or edit.',
        isError: false,
      );
    }
  }

  Future<void> sendTemplateDirectly(
    BuildContext context,
    NotificationTemplate template,
  ) async {
    applyTemplate(template);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            Icon(Icons.campaign_rounded, color: Color(0xFF10B981), size: 24),
            SizedBox(width: 10),
            Text('Confirm Quick Broadcast', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to broadcast this notification to all customers now?',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Broadcast Now', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await sendNotification(context);
    }
  }

  void selectCustomer(CustomerNotificationTarget customer) {
    _selectedCustomer = customer;
    _customerSuggestions = [];
    customerSearchController.clear();
    notifyListeners();
  }

  void clearSelectedCustomer() {
    _selectedCustomer = null;
    notifyListeners();
  }

  Future<void> searchCustomers(String query) async {
    _isSearchingCustomers = true;
    notifyListeners();

    _customerSuggestions =
        await _notificationService.searchCustomers(query: query, limit: 15);

    _isSearchingCustomers = false;
    notifyListeners();
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return;

    _isUploadingImage = true;
    notifyListeners();

    final url = await _notificationService.uploadImage(picked);
    if (url != null && url.isNotEmpty) {
      _uploadedImageUrl = url;
      imageUrlController.text = url;
    }

    _isUploadingImage = false;
    notifyListeners();
  }

  void clearImage() {
    _uploadedImageUrl = null;
    imageUrlController.clear();
    notifyListeners();
  }

  Future<bool> sendNotification(BuildContext context) async {
    final title = titleController.text.trim();
    final message = messageController.text.trim();
    final image = previewImage;

    if (title.isEmpty) {
      _showToast(context, 'Please enter a notification title.', isError: true);
      return false;
    }
    if (message.isEmpty) {
      _showToast(context, 'Please enter a notification message.', isError: true);
      return false;
    }

    setBusy(true);

    Map<String, dynamic> result;
    if (_sendMode == 'single') {
      if (_selectedCustomer == null) {
        setBusy(false);
        _showToast(context, 'Please select a customer recipient.', isError: true);
        return false;
      }

      result = await _notificationService.sendSingleNotification(
        customerId: _selectedCustomer!.id,
        title: title,
        message: message,
        image: image,
        type: _selectedType,
      );
    } else {
      result = await _notificationService.sendBulkNotification(
        title: title,
        message: message,
        image: image,
        targetAudience: _targetAudience,
        type: _selectedType,
      );
    }

    setBusy(false);

    if (!context.mounted) return false;
    if (result['success'] == true) {
      _showToast(
        context,
        _sendMode == 'single'
            ? 'Push notification sent to ${_selectedCustomer!.name} successfully!'
            : 'Broadcast notification dispatched to all customers successfully!',
        isError: false,
      );

      // Reset form fields
      titleController.clear();
      messageController.clear();
      clearImage();
      if (_sendMode == 'single') {
        clearSelectedCustomer();
      }

      // Reload history in background
      loadHistory();
      return true;
    } else {
      _showToast(
        context,
        result['message'] ?? 'Failed to send notification. Please try again.',
        isError: true,
      );
      return false;
    }
  }

  Future<void> loadHistory({int page = 1}) async {
    _isLoadingHistory = true;
    _currentPage = page;
    notifyListeners();

    final result = await _notificationService.getAdminHistory(
      page: _currentPage,
      limit: 20,
      type: _historyTypeFilter == 'all' ? null : _historyTypeFilter,
      search: historySearchController.text.trim(),
    );

    if (result['success'] == true) {
      _historyItems = result['items'] as List<AdminNotificationItem>;
      final pagination = result['pagination'] as Map<String, dynamic>? ?? {};
      _totalPages = (pagination['totalPages'] as num?)?.toInt() ?? 1;
      _totalHistoryCount = (pagination['total'] as num?)?.toInt() ?? 0;
    } else {
      _historyItems = [];
    }

    _isLoadingHistory = false;
    notifyListeners();
  }

  void setHistoryTypeFilter(String type) {
    _historyTypeFilter = type;
    loadHistory(page: 1);
  }

  Future<void> deleteHistoryItem(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text(
          'Are you sure you want to permanently delete this notification record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await _notificationService.deleteNotification(id);
    if (!context.mounted) return;
    if (success) {
      _historyItems.removeWhere((item) => item.id == id);
      _totalHistoryCount = (_totalHistoryCount - 1).clamp(0, 999999);
      _showToast(context, 'Notification removed from history.', isError: false);
      notifyListeners();
    } else {
      _showToast(context, 'Failed to delete notification.', isError: true);
    }
  }

  void _showToast(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    imageUrlController.dispose();
    customerSearchController.dispose();
    historySearchController.dispose();
    super.dispose();
  }
}
