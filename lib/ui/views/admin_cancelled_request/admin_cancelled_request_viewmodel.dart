import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/rare_request_service.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

class AdminCancelledRequestViewModel extends BaseViewModel
    with NavigationMixin {
  final _rareRequestService = locator<RareRequestService>();

  late String _requestId;
  String get requestId => _requestId;

  RareProductRequestModel? _request;
  RareProductRequestModel? get request => _request;

  void initialize(String id) async {
    _requestId = id;
    setBusy(true);
    try {
      _request = await _rareRequestService.adminGetRequestById(id);
      rebuildUi();
    } catch (_) {
    } finally {
      setBusy(false);
    }
  }

  Future<void> reopenRequest() async {
    setBusy(true);
    try {
      await _rareRequestService.reopenRequest(_requestId);
      setBusy(false);
      goBack();
    } catch (_) {
      setBusy(false);
    }
  }
}
