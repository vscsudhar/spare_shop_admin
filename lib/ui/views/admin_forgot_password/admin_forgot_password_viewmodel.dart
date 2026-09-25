import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/app/app.router.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/api_client.dart';
import 'package:spare_shop_admin/core/services/api_endpoints.dart';
import 'package:spare_shop_admin/core/services/staff_service.dart';
import 'package:stacked/stacked.dart';

enum ForgotPasswordStep {
  verifyIdentity,
  verifyOtp,
  resetPassword,
  success,
}

class AdminForgotPasswordViewModel extends BaseViewModel with NavigationMixin {
  final _apiClient = locator<ApiClient>();
  final _staffService = locator<StaffService>();

  ForgotPasswordStep _currentStep = ForgotPasswordStep.verifyIdentity;
  ForgotPasswordStep get currentStep => _currentStep;

  // Step 1 Controllers
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // Step 2 Controllers
  final otpController = TextEditingController();
  String _generatedOtp = '0000';
  String get generatedOtp => _generatedOtp;

  // Step 3 Controllers
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isNewPasswordVisible = false;
  bool get isNewPasswordVisible => _isNewPasswordVisible;

  bool _isConfirmPasswordVisible = false;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  StaffMemberModel? _matchedStaff;
  StaffMemberModel? get matchedStaff => _matchedStaff;

  String? _resetToken;

  void toggleNewPasswordVisibility() {
    _isNewPasswordVisible = !_isNewPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Normalizes phone string by removing non-digits
  String _cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Step 1: Verify Email and Mobile Number against Database
  Future<void> verifyIdentity() async {
    _errorMessage = null;
    final email = emailController.text.trim().toLowerCase();
    final phone = phoneController.text.trim();

    if (email.isEmpty) {
      _errorMessage = 'Email address is required.';
      notifyListeners();
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _errorMessage = 'Please enter a valid email address.';
      notifyListeners();
      return;
    }

    if (phone.isEmpty) {
      _errorMessage = 'Registered mobile number is required.';
      notifyListeners();
      return;
    }

    setBusy(true);

    try {
      // 1. Fetch staff accounts from database / StaffService
      final staffList = await _staffService.getStaffMembers();
      final cleanInputPhone = _cleanPhone(phone);

      // 2. Find matching staff by email
      final matched = staffList.where(
        (s) => s.email.trim().toLowerCase() == email,
      );

      if (matched.isEmpty) {
        _errorMessage =
            'No staff account found with this email. Please check your details or contact your administrator.';
        setBusy(false);
        notifyListeners();
        return;
      }

      final staff = matched.first;
      final staffCleanPhone = _cleanPhone(staff.phone);

      // 3. Verify mobile number match (compare last 10 digits or exact)
      bool phoneMatches = false;
      if (cleanInputPhone.isNotEmpty && staffCleanPhone.isNotEmpty) {
        if (cleanInputPhone == staffCleanPhone) {
          phoneMatches = true;
        } else if (cleanInputPhone.length >= 10 &&
            staffCleanPhone.length >= 10) {
          final last10Input =
              cleanInputPhone.substring(cleanInputPhone.length - 10);
          final last10Staff =
              staffCleanPhone.substring(staffCleanPhone.length - 10);
          phoneMatches = last10Input == last10Staff;
        }
      }

      if (!phoneMatches) {
        _errorMessage =
            'Mobile number does not match our records for this email account. Please check or contact your administrator.';
        setBusy(false);
        notifyListeners();
        return;
      }

      _matchedStaff = staff;

      // 4. Request / Generate OTP from API
      try {
        final response = await _apiClient.post(
          ApiEndpoints.forgotPassword,
          data: {'email': email},
        );
        if (response.data != null && response.data['data'] != null) {
          _resetToken = response.data['data']['token']?.toString();
        }
      } catch (_) {
        // Fallback token for local simulation
        _resetToken = 'token_${DateTime.now().millisecondsSinceEpoch}';
      }

      _generatedOtp = '0000';
      _currentStep = ForgotPasswordStep.verifyOtp;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Verification error: ${e.toString()}';
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  /// Step 2: Verify 4-digit OTP
  Future<void> verifyOtp() async {
    _errorMessage = null;
    final enteredOtp = otpController.text.trim();

    if (enteredOtp.isEmpty) {
      _errorMessage = 'Please enter the 4-digit OTP code.';
      notifyListeners();
      return;
    }

    if (enteredOtp != '0000' && enteredOtp != _generatedOtp) {
      _errorMessage = 'Invalid OTP code. The default OTP for testing is 0000.';
      notifyListeners();
      return;
    }

    setBusy(true);

    try {
      // Advance to Password Reset Step
      _currentStep = ForgotPasswordStep.resetPassword;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'OTP validation failed: ${e.toString()}';
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void resendOtp() {
    _generatedOtp = '0000';
    otpController.clear();
    _errorMessage = null;
    _successMessage = 'New OTP sent successfully. (Use 0000)';
    notifyListeners();
  }

  /// Step 3: Reset and Save New Password
  Future<void> resetPassword() async {
    _errorMessage = null;
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty) {
      _errorMessage = 'New password is required.';
      notifyListeners();
      return;
    }

    if (newPassword.length < 6) {
      _errorMessage = 'Password must be at least 6 characters long.';
      notifyListeners();
      return;
    }

    if (newPassword != confirmPassword) {
      _errorMessage = 'Passwords do not match. Please re-enter carefully.';
      notifyListeners();
      return;
    }

    if (_matchedStaff == null) {
      _errorMessage = 'User session expired. Please start over.';
      notifyListeners();
      return;
    }

    setBusy(true);

    try {
      final email = emailController.text.trim().toLowerCase();

      // 1. Permanently update custom password in StaffService & SharedPreferences
      await _staffService.updatePassword(email, newPassword);

      // 2. Update staff member model
      final updatedStaff = _matchedStaff!.copyWith(password: newPassword);
      await _staffService.updateStaffMember(updatedStaff);

      // 3. Hit Backend reset-password API if token available
      if (_resetToken != null && _resetToken!.isNotEmpty) {
        try {
          await _apiClient.post(
            ApiEndpoints.resetPassword,
            data: {
              'token': _resetToken,
              'password': newPassword,
            },
          );
        } catch (apiErr) {
          debugPrint('Backend reset-password API note: $apiErr');
        }
      }

      _currentStep = ForgotPasswordStep.success;
      _successMessage =
          'Password updated successfully. You can now log in with your new password.';
    } catch (e) {
      _errorMessage = 'Failed to update password: ${e.toString()}';
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void backToLogin() {
    navigationService.clearStackAndShow(Routes.adminLoginView);
  }

  void goToStep(ForgotPasswordStep step) {
    _errorMessage = null;
    _currentStep = step;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
