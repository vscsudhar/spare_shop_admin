import 'package:stacked/stacked.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/app/app.router.dart';
import 'package:spare_shop_admin/core/services/token_service.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:stacked_services/stacked_services.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _tokenService = locator<TokenService>();

  Future runStartupLogic() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final token = await _tokenService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      final role = await _tokenService.getUserRole();
      if (role != null && role.isNotEmpty) {
        activeAdminRole = normalizeAdminRole(role);
      }
      _navigationService.clearStackAndShow(Routes.adminDashboardView);
    } else {
      _navigationService.clearStackAndShow(Routes.adminLoginView);
    }
  }
}
