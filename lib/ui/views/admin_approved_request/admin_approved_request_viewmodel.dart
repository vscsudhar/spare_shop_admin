import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/rare_request_service.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

class AdminApprovedRequestViewModel extends BaseViewModel with NavigationMixin {
  final _rareRequestService = locator<RareRequestService>();

  late String _requestId;
  String get requestId => _requestId;

  RareProductRequestModel? _request;
  RareProductRequestModel? get request => _request;

  bool _isInitialized = false;

  void initialize(String id) async {
    if (_isInitialized && _requestId == id) return;
    _requestId = id;
    _isInitialized = true;
    setBusy(true);
    try {
      _request = await _rareRequestService.adminGetRequestById(id);
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
      rebuildUi();
    } catch (_) {
    } finally {
      setBusy(false);
    }
  }
}
