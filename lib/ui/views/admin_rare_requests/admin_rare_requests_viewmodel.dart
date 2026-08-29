import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/app/app.router.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/rare_request_service.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

class AdminRareRequestsViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _rareRequestService = locator<RareRequestService>();

  String _selectedStatus =
      'All'; // 'All', 'Submitted', 'Searching', 'Quotation Sent', 'Approved', 'Cancelled'
  String get selectedStatus => _selectedStatus;

  List<RareProductRequestModel> _allRequests = [];

  List<RareProductRequestModel> get filteredRequests {
    if (_selectedStatus == 'All') return _allRequests;

    return _allRequests.where((r) {
      if (_selectedStatus == 'Submitted') {
        return r.status == RareRequestStatus.submitted;
      }
      if (_selectedStatus == 'Searching') {
        return r.status == RareRequestStatus.searching;
      }
      if (_selectedStatus == 'Quotation Sent') {
        return r.status == RareRequestStatus.quotationSent;
      }
      if (_selectedStatus == 'Approved') {
        return r.status == RareRequestStatus.approved;
      }
      if (_selectedStatus == 'Cancelled') {
        return r.status == RareRequestStatus.cancelled;
      }
      return true;
    }).toList();
  }

  @override
  Future<void> futureToRun() async {
    await loadRequests();
  }

  Future<void> loadRequests() async {
    try {
      _allRequests = await _rareRequestService.adminGetAllRequests();
      rebuildUi();
    } catch (e) {
      print('Error loading admin rare requests: $e');
    }
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void openChat(RareProductRequestModel request) {
    navigationService.navigateTo(
      Routes.adminRareRequestChatView,
      arguments: AdminRareRequestChatViewArguments(requestId: request.id),
    );
  }
}
