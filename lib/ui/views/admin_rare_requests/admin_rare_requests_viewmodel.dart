import 'package:flutter/foundation.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/app/app.router.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/rare_request_service.dart';
import 'package:spare_shop_admin/core/services/socket_service.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

class AdminRareRequestsViewModel extends BaseViewModel with NavigationMixin {
  final _rareRequestService = locator<RareRequestService>();
  final _socketService = locator<SocketService>();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Function(dynamic)? _onUpdatedHandler;
  Function(dynamic)? _onNewHandler;

  String _selectedStatus = 'All';
  String get selectedStatus => _selectedStatus;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<RareProductRequestModel> _allRequests = [];
  List<RareProductRequestModel> get allRequests => _allRequests;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Status Counters
  int get allCount => _allRequests.length;
  int get submittedCount =>
      _allRequests.where((r) => r.status == RareRequestStatus.submitted).length;
  int get searchingCount =>
      _allRequests.where((r) => r.status == RareRequestStatus.searching).length;
  int get quotationSentCount => _allRequests
      .where((r) => r.status == RareRequestStatus.quotationSent)
      .length;
  int get approvedCount =>
      _allRequests.where((r) => r.status == RareRequestStatus.approved).length;
  int get cancelledCount =>
      _allRequests.where((r) => r.status == RareRequestStatus.cancelled).length;

  List<RareProductRequestModel> get filteredRequests {
    var list = _allRequests;

    if (_selectedStatus != 'All') {
      list = list.where((r) {
        switch (_selectedStatus) {
          case 'Submitted':
            return r.status == RareRequestStatus.submitted;
          case 'Searching':
            return r.status == RareRequestStatus.searching;
          case 'Quotation Sent':
            return r.status == RareRequestStatus.quotationSent;
          case 'Approved':
            return r.status == RareRequestStatus.approved;
          case 'Cancelled':
            return r.status == RareRequestStatus.cancelled;
          default:
            return true;
        }
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((r) {
        final idMatch = r.id.toLowerCase().contains(q);
        final titleMatch = (r.partName ?? '').toLowerCase().contains(q);
        final descMatch = r.description.toLowerCase().contains(q);
        final custMatch = r.customerName.toLowerCase().contains(q);
        final phoneMatch = r.phone.toLowerCase().contains(q);
        final vehicleMatch = r.vehicle.displayName.toLowerCase().contains(q);
        return idMatch ||
            titleMatch ||
            descMatch ||
            custMatch ||
            phoneMatch ||
            vehicleMatch;
      }).toList();
    }

    return list;
  }

  Future<void> initialise() async {
    if (_initialized) return;
    _initialized = true;

    _setupSocket();
    await loadRequests();
  }

  Future<void> loadRequests() async {
    setBusy(true);
    _errorMessage = null;
    notifyListeners();

    try {
      _allRequests = await _rareRequestService.adminGetAllRequests();
    } catch (e, st) {
      debugPrint('Error loading admin rare requests: $e\n$st');
      _errorMessage = 'Failed to load requests: $e';
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void onSearch(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void _setupSocket() {
    try {
      _socketService.connect();

      _onUpdatedHandler = (data) {
        if (!disposed) loadRequests();
      };
      _onNewHandler = (data) {
        if (!disposed) loadRequests();
      };

      _socketService.on('rare_request:updated', _onUpdatedHandler!);
      _socketService.on('rare_request:new', _onNewHandler!);
    } catch (e) {
      debugPrint('RareRequests Socket connection error: $e');
    }
  }

  Future<void> openChat(RareProductRequestModel request) async {
    await navigationService.navigateTo(
      Routes.adminRareRequestChatView,
      arguments: AdminRareRequestChatViewArguments(requestId: request.id),
    );
    if (!disposed) {
      await loadRequests();
    }
  }

  @override
  void dispose() {
    try {
      if (_onUpdatedHandler != null) {
        _socketService.off('rare_request:updated', _onUpdatedHandler);
      }
      if (_onNewHandler != null) {
        _socketService.off('rare_request:new', _onNewHandler);
      }
    } catch (_) {}
    super.dispose();
  }
}
