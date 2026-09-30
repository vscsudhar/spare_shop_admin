import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/app/app.router.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/auth_service.dart';
import 'package:stacked/stacked.dart';

class AdminLoginViewModel extends BaseViewModel with NavigationMixin {
  final _authService = locator<AuthService>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  bool _rememberMe = false;
  bool get rememberMe => _rememberMe;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  Future<void> login() async {
    _errorMessage = null;
    notifyListeners();

    if (formKey.currentState?.validate() ?? false) {
      setBusy(true);

      try {
        final success = await _authService.loginAdmin(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
        if (success) {
          navigationService.clearStackAndShow(Routes.adminDashboardView);
        }
      } catch (e) {
        final errStr = e
            .toString()
            .replaceAll('ApiException: ', '')
            .replaceAll('Exception: ', '');
        if (errStr.contains('401') ||
            errStr.toLowerCase().contains('unauthorized') ||
            errStr.toLowerCase().contains('invalid')) {
          _errorMessage =
              'Invalid email or password. Please check your credentials.';
        } else if (errStr.contains('404') ||
            errStr.toLowerCase().contains('not found')) {
          _errorMessage =
              'Staff account not found. Please verify the email or contact admin.';
        } else {
          _errorMessage = errStr;
        }
        notifyListeners();
      } finally {
        setBusy(false);
      }
    }
  }

  void goToForgotPassword() {
    goToAdminForgotPassword();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
