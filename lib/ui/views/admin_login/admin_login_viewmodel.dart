import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/app/app.router.dart';
import 'package:spare_shop_admin/core/services/auth_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AdminLoginViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _authService = locator<AuthService>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController(text: 'owner@voltspare.com');
  final passwordController = TextEditingController(text: 'OwnerPassword123!');

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
          _navigationService.clearStackAndShow(Routes.adminDashboardView);
        }
      } catch (e) {
        _errorMessage = e.toString().replaceAll('ApiException: ', '');
        notifyListeners();
      } finally {
        setBusy(false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
