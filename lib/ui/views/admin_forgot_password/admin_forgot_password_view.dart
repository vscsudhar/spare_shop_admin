import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/views/admin_forgot_password/admin_forgot_password_viewmodel.dart';
import 'package:stacked/stacked.dart';

class AdminForgotPasswordView
    extends StackedView<AdminForgotPasswordViewModel> {
  const AdminForgotPasswordView({Key? key}) : super(key: key);

  @override
  AdminForgotPasswordViewModel viewModelBuilder(BuildContext context) =>
      AdminForgotPasswordViewModel();

  @override
  Widget builder(
    BuildContext context,
    AdminForgotPasswordViewModel viewModel,
    Widget? child,
  ) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 800;

    return Scaffold(
      backgroundColor: AdminColors.sidebarBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
            width: isDesktop ? 520 : double.infinity,
            decoration: BoxDecoration(
              color: AdminColors.panelBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AdminColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, viewModel),
                  const SizedBox(height: 24),
                  if (viewModel.currentStep != ForgotPasswordStep.success) ...[
                    _buildStepper(viewModel),
                    const SizedBox(height: 28),
                  ],
                  if (viewModel.errorMessage != null) ...[
                    _buildErrorMessage(viewModel.errorMessage!),
                    const SizedBox(height: 20),
                  ],
                  if (viewModel.successMessage != null &&
                      viewModel.currentStep != ForgotPasswordStep.success) ...[
                    _buildSuccessBanner(viewModel.successMessage!),
                    const SizedBox(height: 20),
                  ],
                  _buildStepContent(context, viewModel),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AdminForgotPasswordViewModel viewModel) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AdminColors.primaryGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                color: AdminColors.primaryGreen,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'VoltSpare Console',
              style: TextStyle(
                color: AdminColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          viewModel.currentStep == ForgotPasswordStep.verifyIdentity
              ? 'Reset Staff Password'
              : viewModel.currentStep == ForgotPasswordStep.verifyOtp
                  ? 'Verify OTP Code'
                  : viewModel.currentStep == ForgotPasswordStep.resetPassword
                      ? 'Create New Password'
                      : 'Password Reset Successful',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AdminColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          viewModel.currentStep == ForgotPasswordStep.verifyIdentity
              ? 'Enter your registered email and mobile number to verify your identity.'
              : viewModel.currentStep == ForgotPasswordStep.verifyOtp
                  ? 'Enter the 4-digit code (0000) sent to your registered account.'
                  : viewModel.currentStep == ForgotPasswordStep.resetPassword
                      ? 'Your new password must be at least 6 characters long.'
                      : 'Your staff account password has been updated in the database.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AdminColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepper(AdminForgotPasswordViewModel viewModel) {
    final stepIndex = viewModel.currentStep.index;

    return Row(
      children: [
        _buildStepBadge(1, 'Identity', stepIndex >= 0, stepIndex == 0),
        Expanded(
          child: Container(
            height: 2,
            color: stepIndex >= 1
                ? AdminColors.primaryGreen
                : Colors.grey.shade300,
          ),
        ),
        _buildStepBadge(2, 'OTP (0000)', stepIndex >= 1, stepIndex == 1),
        Expanded(
          child: Container(
            height: 2,
            color: stepIndex >= 2
                ? AdminColors.primaryGreen
                : Colors.grey.shade300,
          ),
        ),
        _buildStepBadge(3, 'Password', stepIndex >= 2, stepIndex == 2),
      ],
    );
  }

  Widget _buildStepBadge(
      int stepNum, String label, bool isCompleted, bool isCurrent) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isCompleted ? AdminColors.primaryGreen : Colors.grey.shade200,
            border: Border.all(
              color: isCurrent
                  ? AdminColors.accentLime
                  : (isCompleted
                      ? AdminColors.primaryGreen
                      : Colors.grey.shade400),
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: isCompleted && !isCurrent
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : Text(
                  '$stepNum',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.white : Colors.grey.shade600,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
            color:
                isCurrent ? AdminColors.textPrimary : AdminColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AdminColors.cancelled.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminColors.cancelled.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded,
              color: AdminColors.cancelled, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: AdminColors.cancelled,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AdminColors.primaryGreen.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminColors.primaryGreen.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded,
              color: AdminColors.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                color: AdminColors.primaryGreen,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(
      BuildContext context, AdminForgotPasswordViewModel viewModel) {
    switch (viewModel.currentStep) {
      case ForgotPasswordStep.verifyIdentity:
        return _buildStep1Identity(context, viewModel);
      case ForgotPasswordStep.verifyOtp:
        return _buildStep2Otp(context, viewModel);
      case ForgotPasswordStep.resetPassword:
        return _buildStep3NewPassword(context, viewModel);
      case ForgotPasswordStep.success:
        return _buildStep4Success(context, viewModel);
    }
  }

  /// STEP 1: Email & Mobile Number Input
  Widget _buildStep1Identity(
      BuildContext context, AdminForgotPasswordViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email Input
        Text(
          'Registered Staff Email Address',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: AdminColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: viewModel.emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'e.g. rohan.d@voltspare.com',
            prefixIcon: const Icon(Icons.mail_outline_rounded, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 18),

        // Mobile Number Input
        Text(
          'Registered Mobile Number',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: AdminColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: viewModel.phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => viewModel.verifyIdentity(),
          decoration: InputDecoration(
            hintText: 'e.g. +91 98887 66554 or 9888766554',
            prefixIcon: const Icon(Icons.phone_android_rounded, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 12),

        // Security Notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Both Email and Mobile number must match your active staff record in the system.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Verify Button
        ElevatedButton(
          onPressed: viewModel.isBusy ? null : viewModel.verifyIdentity,
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
          child: viewModel.isBusy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Verify Details & Get OTP',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(height: 16),

        // Back to Login Button
        TextButton(
          onPressed: viewModel.backToLogin,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_back, size: 16),
              const SizedBox(width: 6),
              Text(
                'Back to Login',
                style: TextStyle(
                  color: AdminColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// STEP 2: OTP Verification
  Widget _buildStep2Otp(
      BuildContext context, AdminForgotPasswordViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Verified Account Pill
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AdminColors.primaryGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: AdminColors.primaryGreen.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.verified_user_outlined,
                  size: 20, color: AdminColors.primaryGreen),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.matchedStaff?.name ?? 'Staff Member',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${viewModel.emailController.text} • ${viewModel.matchedStaff?.phone ?? viewModel.phoneController.text}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Testing OTP Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.key_rounded, size: 20, color: Colors.orange),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'API OTP CODE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Use OTP: ${viewModel.generatedOtp}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  viewModel.otpController.text = viewModel.generatedOtp;
                  viewModel.notifyListeners();
                },
                child: const Text('Auto-Fill',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // OTP Input
        Text(
          'Enter 4-Digit OTP Code',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: AdminColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: viewModel.otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 4,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 12,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: '••••',
            hintStyle: const TextStyle(letterSpacing: 12, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onSubmitted: (_) => viewModel.verifyOtp(),
        ),
        const SizedBox(height: 24),

        // Verify OTP Button
        ElevatedButton(
          onPressed: viewModel.isBusy ? null : viewModel.verifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
          child: viewModel.isBusy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Verify OTP Code',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () =>
                  viewModel.goToStep(ForgotPasswordStep.verifyIdentity),
              icon: const Icon(Icons.edit, size: 14),
              label:
                  const Text('Change Details', style: TextStyle(fontSize: 12)),
            ),
            TextButton.icon(
              onPressed: viewModel.resendOtp,
              icon: const Icon(Icons.refresh, size: 14),
              label: const Text('Resend OTP',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  /// STEP 3: New Password Input
  Widget _buildStep3NewPassword(
      BuildContext context, AdminForgotPasswordViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // New Password
        Text(
          'New Password (Minimum 6 characters)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: AdminColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: viewModel.newPasswordController,
          obscureText: !viewModel.isNewPasswordVisible,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'Enter new password',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
            suffixIcon: IconButton(
              icon: Icon(
                viewModel.isNewPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
              ),
              onPressed: viewModel.toggleNewPasswordVisibility,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 18),

        // Confirm Password
        Text(
          'Confirm New Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: AdminColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: viewModel.confirmPasswordController,
          obscureText: !viewModel.isConfirmPasswordVisible,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => viewModel.resetPassword(),
          decoration: InputDecoration(
            hintText: 'Re-enter new password',
            prefixIcon: const Icon(Icons.lock_reset_rounded, size: 18),
            suffixIcon: IconButton(
              icon: Icon(
                viewModel.isConfirmPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
              ),
              onPressed: viewModel.toggleConfirmPasswordVisibility,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),

        // Password Rules Indicator
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PASSWORD REQUIREMENTS:',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              _buildRuleRow(
                'Must be at least 6 characters in length',
                viewModel.newPasswordController.text.length >= 6,
              ),
              const SizedBox(height: 4),
              _buildRuleRow(
                'New password and Confirm password must match',
                viewModel.newPasswordController.text.isNotEmpty &&
                    viewModel.newPasswordController.text ==
                        viewModel.confirmPasswordController.text,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Submit Button
        ElevatedButton(
          onPressed: viewModel.isBusy ? null : viewModel.resetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
          child: viewModel.isBusy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Update Password in Database',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Widget _buildRuleRow(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          size: 14,
          color: isMet ? AdminColors.primaryGreen : Colors.grey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? AdminColors.primaryGreen : Colors.grey.shade700,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  /// STEP 4: Success Screen
  Widget _buildStep4Success(
      BuildContext context, AdminForgotPasswordViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AdminColors.primaryGreen.withOpacity(0.15),
              border: Border.all(color: AdminColors.primaryGreen, width: 3),
            ),
            child: Icon(
              Icons.check_rounded,
              size: 42,
              color: AdminColors.primaryGreen,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AdminColors.primaryGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AdminColors.primaryGreen.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(
                'ACCOUNT UPDATED',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.primaryGreen,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                viewModel.matchedStaff?.name ?? 'Staff Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                viewModel.emailController.text,
                style: TextStyle(
                  fontSize: 13,
                  color: AdminColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: viewModel.backToLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
          child: const Text(
            'Proceed to Login with New Password',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
