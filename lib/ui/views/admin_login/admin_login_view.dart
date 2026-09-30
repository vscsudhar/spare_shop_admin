import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:stacked/stacked.dart';

import 'admin_login_viewmodel.dart';

class AdminLoginView extends StackedView<AdminLoginViewModel> {
  const AdminLoginView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminLoginViewModel viewModel,
    Widget? child,
  ) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= AdminBreakpoints.tablet;

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Row(
        children: [
          // Left Hero Branding (Desktop Only)
          if (isWide)
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AdminColors.sidebarBackground,
                      const Color(0xFF0F1626)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/logo_icon.png',
                            height: 64,
                            width: 64,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'VoltSpare',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                'SPARE PARTS | EV & PETROL',
                                style: TextStyle(
                                  color: AdminColors.accentLime,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      const Text(
                        'Central Administrative Console',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Manage customer orders, warehouse inventory logistics, customer tickets chat support, billing invoices, and staff permissions securely from a unified dashboard.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Right Card Container (All Sizes)
          Expanded(
            flex: isWide ? 4 : 1,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: AdminColors.panelBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AdminColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: viewModel.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isWide) ...[
                          Center(
                            child: Image.asset(
                              'assets/images/logo_full.png',
                              height: 48,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        Text(
                          'Welcome back',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please log in with your staff console credentials.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AdminColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Error message
                        if (viewModel.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color:
                                  AdminColors.cancelled.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AdminColors.cancelled
                                      .withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: AdminColors.cancelled, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    viewModel.errorMessage!,
                                    style: TextStyle(
                                      color: AdminColors.cancelled,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Email
                        Text(
                          'Email Address',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: viewModel.emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(
                            color: AdminColors.textPrimary,
                            fontSize: 14,
                          ),
                          cursorColor: AdminColors.primaryGreen,
                          decoration: InputDecoration(
                            hintText: 'e.g. name@voltspare.com',
                            hintStyle: TextStyle(
                              color: AdminColors.textLight,
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.mail_outline_rounded,
                              size: 18,
                              color: AdminColors.textSecondary,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Password',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AdminColors.textPrimary,
                              ),
                            ),
                            TextButton(
                              onPressed: viewModel.goToForgotPassword,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: AdminColors.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: viewModel.passwordController,
                          obscureText: !viewModel.isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => viewModel.login(),
                          style: TextStyle(
                            color: AdminColors.textPrimary,
                            fontSize: 14,
                          ),
                          cursorColor: AdminColors.primaryGreen,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: TextStyle(
                              color: AdminColors.textLight,
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              size: 18,
                              color: AdminColors.textSecondary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                viewModel.isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: AdminColors.textSecondary,
                              ),
                              onPressed: viewModel.togglePasswordVisibility,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Password is required';
                            }
                            if (value.trim().length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Remember me checkbox
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: viewModel.rememberMe,
                                onChanged: viewModel.toggleRememberMe,
                                activeColor: AdminColors.primaryGreen,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remember me on this browser',
                              style: TextStyle(
                                fontSize: 13,
                                color: AdminColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Login button
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed:
                                viewModel.isBusy ? null : viewModel.login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdminColors.primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: viewModel.isBusy
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Log In to Dashboard',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            'VoltSpare Administrative Console • Terms & Conditions and Privacy Policy apply.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: AdminColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  AdminLoginViewModel viewModelBuilder(BuildContext context) =>
      AdminLoginViewModel();
}
