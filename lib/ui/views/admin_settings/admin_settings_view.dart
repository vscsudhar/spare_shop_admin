import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:spare_shop_admin/core/theme/theme_service.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:spare_shop_admin/ui/common/legal_content.dart';
import 'package:stacked/stacked.dart';

import 'admin_settings_viewmodel.dart';

class AdminSettingsView extends StackedView<AdminSettingsViewModel> {
  const AdminSettingsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminSettingsViewModel viewModel,
    Widget? child,
  ) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= AdminBreakpoints.tablet;

    final sections = [
      'General',
      'Billing',
      'POS Settings',
      'Inventory',
      'Appearance',
      'Security',
      'Legal & Policies',
    ];

    return AdminShell(
      title: 'Console Control Settings',
      selectedItem: AdminNavigationItem.settings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Section Selector (Desktop navigation rail/tabs)
              if (isWide)
                Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: AdminColors.panelBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AdminColors.border),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sections.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final sec = sections[index];
                      final isSelected = viewModel.selectedSection == sec;
                      return ListTile(
                        title: Text(
                          sec,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AdminColors.primaryGreen
                                : AdminColors.textPrimary,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor:
                            AdminColors.primaryGreen.withValues(alpha: 0.12),
                        onTap: () => viewModel.setSection(sec),
                      );
                    },
                  ),
                ),

              // Right Section Content (Form Panels)
              Expanded(
                child: Column(
                  children: [
                    // Mobile Dropdown Selector
                    if (!isWide) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AdminColors.border),
                          borderRadius: BorderRadius.circular(8),
                          color: AdminColors.panelBackground,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: viewModel.selectedSection,
                            isExpanded: true,
                            dropdownColor: AdminColors.panelBackground,
                            items: sections
                                .map((sec) => DropdownMenuItem(
                                    value: sec,
                                    child: Text(sec,
                                        style: TextStyle(
                                            color: AdminColors.textPrimary))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) viewModel.setSection(val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    AdminPanelCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${viewModel.selectedSection} Parameters',
                                style: AdminTextStyles.sectionHeader
                                    .copyWith(fontSize: 16),
                              ),
                              if (viewModel.selectedSection == 'General')
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AdminColors.primaryGreen
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AdminColors.primaryGreen
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.receipt_long_rounded,
                                          color: AdminColors.primaryGreen,
                                          size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Used on all Invoices & Delivery',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AdminColors.primaryGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const Divider(height: 32),
                          _buildActiveSectionContent(
                              context, viewModel, isWide),
                          const Divider(height: 48),

                          // Save Action row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: viewModel.resetSettings,
                                style: OutlinedButton.styleFrom(
                                    side:
                                        BorderSide(color: AdminColors.border)),
                                child: Text('Reset to Defaults',
                                    style: TextStyle(
                                        color: AdminColors.textPrimary)),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    viewModel.saveSettings(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AdminColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: viewModel.isBusy
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Save System Changes'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSectionContent(
      BuildContext context, AdminSettingsViewModel viewModel, bool isWide) {
    switch (viewModel.selectedSection) {
      case 'General':
        return _buildGeneralSettingsSection(context, viewModel, isWide);
      case 'Billing':
        return Column(
          children: [
            _textInput(
                viewModel.invoicePrefixController, 'Invoice Prefix Schema'),
            _textInput(viewModel.nextInvoiceController,
                'Next Ticket Autoincrement No'),
            SwitchListTile(
              title: const Text('GST Calculations Enabled',
                  style: TextStyle(fontSize: 13)),
              value: viewModel.gstEnabled,
              onChanged: viewModel.setGstEnabled,
              activeThumbColor: AdminColors.primaryGreen,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        );
      case 'POS Settings':
        return Column(
          children: [
            _textInput(viewModel.taxPercentageController,
                'POS Tax / GST Percentage (%)'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AdminColors.primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AdminColors.primaryGreen.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_shipping_rounded,
                      color: AdminColors.primaryGreen, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Delivery Charges & Tiers',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage order amount ranges (e.g. Under ₹399 -> ₹60, ₹400-999 -> ₹100, Free delivery)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => viewModel.goToAdminDeliveryCharges(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Manage Rates',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Support Split POS Payment Method',
                  style: TextStyle(fontSize: 13)),
              value: viewModel.allowSplitPayment,
              onChanged: (val) {
                viewModel.allowSplitPayment = val;
                viewModel.notifyListeners();
              },
              activeThumbColor: AdminColors.primaryGreen,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Allow Cash Overpayment (Give Change)',
                  style: TextStyle(fontSize: 13)),
              value: viewModel.allowCashOverpayment,
              onChanged: (val) {
                viewModel.allowCashOverpayment = val;
                viewModel.notifyListeners();
              },
              activeThumbColor: AdminColors.primaryGreen,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Require Reference/Txn ID for UPI POS',
                  style: TextStyle(fontSize: 13)),
              value: viewModel.requireUpiId,
              onChanged: (val) {
                viewModel.requireUpiId = val;
                viewModel.notifyListeners();
              },
              activeThumbColor: AdminColors.primaryGreen,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Require Card Reference authorization',
                  style: TextStyle(fontSize: 13)),
              value: viewModel.requireCardRef,
              onChanged: (val) {
                viewModel.requireCardRef = val;
                viewModel.notifyListeners();
              },
              activeThumbColor: AdminColors.primaryGreen,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        );
      case 'Inventory':
        return Column(
          children: [
            _textInput(viewModel.lowStockThresholdController,
                'Low Stock Level Limit (Units)'),
            SwitchListTile(
              title: const Text('Out of Stock Warnings Enabled',
                  style: TextStyle(fontSize: 13)),
              value: viewModel.outOfStockNotify,
              onChanged: (val) {
                viewModel.outOfStockNotify = val;
                viewModel.notifyListeners();
              },
              activeThumbColor: AdminColors.primaryGreen,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Allow Negative Inventory Sell Out',
                  style: TextStyle(fontSize: 13)),
              value: viewModel.negativeStockAllowed,
              onChanged: (val) {
                viewModel.negativeStockAllowed = val;
                viewModel.notifyListeners();
              },
              activeThumbColor: AdminColors.primaryGreen,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        );
      case 'Appearance':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Visual Theme Preference',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            _themeRadioTile(
                viewModel, AppThemePreference.light, 'Clear Light Mode'),
            _themeRadioTile(
                viewModel, AppThemePreference.dark, 'Deep Graphite Dark Mode'),
            _themeRadioTile(viewModel, AppThemePreference.system,
                'Follow Platform OS settings'),
          ],
        );
      case 'Security':
        return Column(
          children: [
            _textInput(TextEditingController(), 'Old Console Password',
                obscure: true),
            _textInput(TextEditingController(), 'New Target Password',
                obscure: true),
            _textInput(TextEditingController(), 'Confirm New Password',
                obscure: true),
          ],
        );
      case 'Legal & Policies':
        return _buildLegalPoliciesSection(context, viewModel, isWide);
      default:
        return const SizedBox();
    }
  }

  Widget _buildGeneralSettingsSection(
      BuildContext context, AdminSettingsViewModel viewModel, bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Business & Tax Identity Info
        Row(
          children: [
            Icon(Icons.business_rounded,
                color: AdminColors.primaryGreen, size: 20),
            const SizedBox(width: 8),
            Text(
              'Company & Tax Identity',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AdminColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (isWide) ...[
          Row(
            children: [
              Expanded(
                child: _textInput(
                  viewModel.storeNameController,
                  'HQ Brand / Display Name',
                  hint: 'VoltSpare Automotive',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _textInput(
                  viewModel.legalNameController,
                  'Legal Entity Name (Invoice Header)',
                  hint: 'VoltSpare Automotive Technologies Pvt. Ltd.',
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _textInput(
                  viewModel.gstNumberController,
                  'GSTIN Registration Number',
                  hint: '29AAAAA0000A1Z1',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _textInput(
                  viewModel.panController,
                  'Business PAN Number',
                  hint: 'AAAAA0000A',
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _textInput(
                  viewModel.phoneController,
                  'Official Support Phone',
                  hint: '+91 99000 88000',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _textInput(
                  viewModel.emailController,
                  'Official Billing Email',
                  hint: 'billing@voltspare.com',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _textInput(
                  viewModel.websiteController,
                  'Website URL',
                  hint: 'www.voltspare.com',
                ),
              ),
            ],
          ),
        ] else ...[
          _textInput(
            viewModel.storeNameController,
            'HQ Brand / Display Name',
            hint: 'VoltSpare Automotive',
          ),
          _textInput(
            viewModel.legalNameController,
            'Legal Entity Name (Invoice Header)',
            hint: 'VoltSpare Automotive Technologies Pvt. Ltd.',
          ),
          _textInput(
            viewModel.gstNumberController,
            'GSTIN Registration Number',
            hint: '29AAAAA0000A1Z1',
          ),
          _textInput(
            viewModel.panController,
            'Business PAN Number',
            hint: 'AAAAA0000A',
          ),
          _textInput(
            viewModel.phoneController,
            'Official Support Phone',
            hint: '+91 99000 88000',
          ),
          _textInput(
            viewModel.emailController,
            'Official Billing Email',
            hint: 'billing@voltspare.com',
          ),
          _textInput(
            viewModel.websiteController,
            'Website URL',
            hint: 'www.voltspare.com',
          ),
        ],

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // 2. Address & OpenStreetMap Pin Picker
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_rounded,
                    color: AdminColors.primaryGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Logistics & Invoice Address (OpenStreetMap Pin Location)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AdminColors.textPrimary,
                  ),
                ),
              ],
            ),
            if (viewModel.isMapMoved)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AdminColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AdminColors.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.gps_fixed_rounded,
                        color: AdminColors.primaryGreen, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Pin Updated (${viewModel.latitude.toStringAsFixed(4)}, ${viewModel.longitude.toStringAsFixed(4)})',
                      style: TextStyle(
                        color: AdminColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Address Form & Map layout
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address Fields Column
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _textInput(
                      viewModel.addressLine1Controller,
                      'Address Line 1 (Door No, Building, Street)',
                      hint: '12, MG Road, Landmark Block',
                    ),
                    _textInput(
                      viewModel.addressLine2Controller,
                      'Address Line 2 (Area / Landmark / Taluk)',
                      hint: 'Indiranagar Commercial Zone',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _textInput(
                            viewModel.cityController,
                            'City / District',
                            hint: 'Bangalore',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _textInput(
                            viewModel.stateController,
                            'State',
                            hint: 'Karnataka',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _textInput(
                            viewModel.stateCodeController,
                            'GST State Code (2-digit)',
                            hint: '29',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _textInput(
                            viewModel.pincodeController,
                            'Postal / PIN Code',
                            hint: '560001',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Map Column
              Expanded(
                flex: 5,
                child: Container(
                  height: 380,
                  decoration: BoxDecoration(
                    color: AdminColors.panelBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AdminColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InteractiveAdminMapPicker(
                    initialLat: viewModel.latitude,
                    initialLng: viewModel.longitude,
                    onLocationChanged: (lat, lng) {
                      viewModel.updateLocation(lat, lng);
                    },
                    onAreaSelected: (taluk, district, state, [postalCode]) {
                      viewModel.onAreaSelected(
                          taluk, district, state, postalCode);
                    },
                  ),
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _textInput(
                viewModel.addressLine1Controller,
                'Address Line 1 (Door No, Building, Street)',
                hint: '12, MG Road, Landmark Block',
              ),
              _textInput(
                viewModel.addressLine2Controller,
                'Address Line 2 (Area / Landmark / Taluk)',
                hint: 'Indiranagar Commercial Zone',
              ),
              Row(
                children: [
                  Expanded(
                    child: _textInput(
                      viewModel.cityController,
                      'City / District',
                      hint: 'Bangalore',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _textInput(
                      viewModel.stateController,
                      'State',
                      hint: 'Karnataka',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _textInput(
                      viewModel.stateCodeController,
                      'GST State Code',
                      hint: '29',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _textInput(
                      viewModel.pincodeController,
                      'Postal / PIN Code',
                      hint: '560001',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 320,
                decoration: BoxDecoration(
                  color: AdminColors.panelBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AdminColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: InteractiveAdminMapPicker(
                  initialLat: viewModel.latitude,
                  initialLng: viewModel.longitude,
                  onLocationChanged: (lat, lng) {
                    viewModel.updateLocation(lat, lng);
                  },
                  onAreaSelected: (taluk, district, state, [postalCode]) {
                    viewModel.onAreaSelected(
                        taluk, district, state, postalCode);
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _textInput(
    TextEditingController ctrl,
    String label, {
    String hint = '',
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        style: TextStyle(fontSize: 13, color: AdminColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint.isNotEmpty ? hint : null,
          labelStyle: TextStyle(fontSize: 12, color: AdminColors.textSecondary),
          hintStyle: TextStyle(fontSize: 12, color: AdminColors.textLight),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AdminColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AdminColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AdminColors.primaryGreen, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _themeRadioTile(
      AdminSettingsViewModel vm, AppThemePreference pref, String label) {
    return RadioListTile<AppThemePreference>(
      value: pref,
      groupValue: vm.themePreference,
      title: Text(label, style: const TextStyle(fontSize: 13)),
      activeColor: AdminColors.primaryGreen,
      onChanged: (val) {
        if (val != null) vm.setTheme(val);
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildLegalPoliciesSection(
      BuildContext context, AdminSettingsViewModel viewModel, bool isWide) {
    return _LegalPoliciesViewer(isWide: isWide);
  }

  @override
  AdminSettingsViewModel viewModelBuilder(BuildContext context) =>
      AdminSettingsViewModel();
}

class SearchLocation {
  final String name;
  final double latitude;
  final double longitude;
  final String taluk;
  final String district;
  final String state;
  final String postalCode;

  const SearchLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.taluk,
    required this.district,
    required this.state,
    this.postalCode = '',
  });
}

class InteractiveAdminMapPicker extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final Function(double lat, double lng) onLocationChanged;
  final Function(String taluk, String district, String state,
      [String? postalCode])? onAreaSelected;

  const InteractiveAdminMapPicker({
    Key? key,
    required this.initialLat,
    required this.initialLng,
    required this.onLocationChanged,
    this.onAreaSelected,
  }) : super(key: key);

  @override
  State<InteractiveAdminMapPicker> createState() =>
      _InteractiveAdminMapPickerState();
}

class _InteractiveAdminMapPickerState extends State<InteractiveAdminMapPicker>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late double _currentLat;
  late double _currentLng;
  bool _isDragging = false;
  bool _isSearching = false;

  final _searchController = TextEditingController();
  List<SearchLocation> _searchResults = [];

  Timer? _searchDebounceTimer;
  Timer? _panDebounceTimer;
  CancelToken? _searchCancelToken;
  CancelToken? _reverseGeoCancelToken;
  final Dio _dio = Dio();

  late AnimationController _pinAnimationController;
  late Animation<double> _pinTranslationY;
  late Animation<double> _shadowScale;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentLat = widget.initialLat;
    _currentLng = widget.initialLng;

    _pinAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _pinTranslationY = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _pinAnimationController, curve: Curves.easeOut),
    );

    _shadowScale = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _pinAnimationController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant InteractiveAdminMapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLat != oldWidget.initialLat ||
        widget.initialLng != oldWidget.initialLng) {
      _currentLat = widget.initialLat;
      _currentLng = widget.initialLng;
      _mapController.move(
          LatLng(_currentLat, _currentLng), _mapController.camera.zoom);
    }
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _panDebounceTimer?.cancel();
    _searchCancelToken?.cancel();
    _reverseGeoCancelToken?.cancel();
    _pinAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    if (hasGesture) {
      if (!_isDragging) {
        _isDragging = true;
        _pinAnimationController.forward();
      }

      setState(() {
        _currentLat = camera.center.latitude;
        _currentLng = camera.center.longitude;
      });

      _panDebounceTimer?.cancel();
      _panDebounceTimer = Timer(const Duration(milliseconds: 500), () {
        _finalizePinMove(camera.center.latitude, camera.center.longitude);
      });
    }
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd) {
      _panDebounceTimer?.cancel();
      _panDebounceTimer = Timer(const Duration(milliseconds: 150), () {
        final center = _mapController.camera.center;
        _finalizePinMove(center.latitude, center.longitude);
      });
    }
  }

  void _finalizePinMove(double lat, double lng) {
    if (!mounted) return;
    if (_isDragging) {
      setState(() {
        _isDragging = false;
        _currentLat = lat;
        _currentLng = lng;
      });
      _pinAnimationController.reverse();
    }

    widget.onLocationChanged(_currentLat, _currentLng);
    _performReverseGeocode(_currentLat, _currentLng);
  }

  Future<void> _performReverseGeocode(double lat, double lng) async {
    _reverseGeoCancelToken?.cancel();
    _reverseGeoCancelToken = CancelToken();

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lng,
          'format': 'json',
          'addressdetails': '1',
        },
        options: Options(
          headers: {'User-Agent': 'VoltSpare_Admin/1.0'},
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
        cancelToken: _reverseGeoCancelToken,
      );

      if (response.statusCode == 200 && response.data is Map && mounted) {
        final data = response.data as Map;
        final addr = (data['address'] as Map?) ?? {};

        final String taluk = (addr['suburb'] ??
                addr['neighbourhood'] ??
                addr['village'] ??
                addr['town'] ??
                addr['city_district'] ??
                addr['county'] ??
                '')
            .toString();

        final String district = (addr['city'] ??
                addr['town'] ??
                addr['district'] ??
                addr['county'] ??
                '')
            .toString();

        final String state = (addr['state'] ?? '').toString();
        final String postalCode = (addr['postcode'] ?? '').toString();

        if (widget.onAreaSelected != null) {
          widget.onAreaSelected!(
            taluk.isNotEmpty ? taluk : 'Area',
            district.isNotEmpty ? district : 'City',
            state.isNotEmpty ? state : 'State',
            postalCode,
          );
        }
      }
    } catch (_) {}
  }

  void _onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();

    if (query.trim().length < 3) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    _searchDebounceTimer = Timer(const Duration(milliseconds: 550), () async {
      _searchCancelToken?.cancel();
      _searchCancelToken = CancelToken();

      if (mounted) {
        setState(() {
          _isSearching = true;
        });
      }

      try {
        final response = await _dio.get(
          'https://nominatim.openstreetmap.org/search',
          queryParameters: {
            'q': query.trim(),
            'format': 'json',
            'addressdetails': '1',
            'limit': '5',
            'countrycodes': 'in',
          },
          options: Options(
            headers: {'User-Agent': 'VoltSpare_Admin/1.0'},
            receiveTimeout: const Duration(seconds: 6),
            sendTimeout: const Duration(seconds: 6),
          ),
          cancelToken: _searchCancelToken,
        );

        if (response.statusCode == 200 && response.data is List && mounted) {
          final list = response.data as List;
          setState(() {
            _searchResults = list.map((item) {
              final addr = (item['address'] as Map?) ?? {};

              final String taluk = (addr['suburb'] ??
                      addr['neighbourhood'] ??
                      addr['village'] ??
                      addr['town'] ??
                      addr['city_district'] ??
                      addr['county'] ??
                      '')
                  .toString();

              final String district = (addr['city'] ??
                      addr['town'] ??
                      addr['district'] ??
                      addr['county'] ??
                      '')
                  .toString();

              final String state = (addr['state'] ?? '').toString();
              final String postalCode = (addr['postcode'] ?? '').toString();

              return SearchLocation(
                name: item['display_name'] ?? '',
                latitude: double.tryParse(item['lat']?.toString() ?? '') ??
                    widget.initialLat,
                longitude: double.tryParse(item['lon']?.toString() ?? '') ??
                    widget.initialLng,
                taluk: taluk.isNotEmpty ? taluk : 'Area',
                district: district.isNotEmpty ? district : 'City',
                state: state.isNotEmpty ? state : 'State',
                postalCode: postalCode,
              );
            }).toList();
          });
        }
      } catch (_) {
      } finally {
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
        }
      }
    });
  }

  void _selectSearchResult(SearchLocation loc) {
    setState(() {
      _currentLat = loc.latitude;
      _currentLng = loc.longitude;
      _searchResults = [];
      _searchController.text = loc.name;
      FocusScope.of(context).unfocus();
    });

    _mapController.move(LatLng(loc.latitude, loc.longitude), 16.0);
    widget.onLocationChanged(loc.latitude, loc.longitude);
    if (widget.onAreaSelected != null) {
      widget.onAreaSelected!(
          loc.taluk, loc.district, loc.state, loc.postalCode);
    }
  }

  void _recenterMap() {
    setState(() {
      _currentLat = widget.initialLat;
      _currentLng = widget.initialLng;
      _searchController.clear();
      _searchResults = [];
    });
    _mapController.move(LatLng(widget.initialLat, widget.initialLng), 15.0);
    widget.onLocationChanged(_currentLat, _currentLng);
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom < 18.5) {
      _mapController.move(_mapController.camera.center, currentZoom + 1.0);
    }
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom > 4.5) {
      _mapController.move(_mapController.camera.center, currentZoom - 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // OpenStreetMap Layer
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(widget.initialLat, widget.initialLng),
            initialZoom: 15.0,
            minZoom: 4.0,
            maxZoom: 19.0,
            onPositionChanged: _onPositionChanged,
            onMapEvent: _onMapEvent,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.voltspare.spare_shop_admin',
              maxZoom: 19,
            ),
          ],
        ),

        // Center Animated Pin Teardrop with shadow
        Align(
          alignment: Alignment.center,
          child: AnimatedBuilder(
            animation: _pinAnimationController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Ground Pin Shadow
                  Transform.translate(
                    offset: const Offset(0, 16),
                    child: Transform.scale(
                      scale: _shadowScale.value,
                      child: Container(
                        width: 14,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Animated Center Pin
                  Transform.translate(
                    offset: Offset(0, -18 + _pinTranslationY.value),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 42,
                          color: AdminColors.primaryGreen,
                        ),
                        Transform.translate(
                          offset: const Offset(0, -3),
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // Search Bar in Top Corner
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Search city, street or pincode...',
                    hintStyle:
                        TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    prefixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.green,
                              ),
                            ),
                          )
                        : const Icon(Icons.search_rounded,
                            color: Colors.grey, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                size: 18, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchResults = []);
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),

              // Search Suggestions Dropdown
              if (_searchResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _searchResults.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.location_on_outlined,
                            size: 18, color: Colors.green),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _selectSearchResult(item),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),

        // Zoom & Recenter Controls in Bottom-Right
        Positioned(
          bottom: 12,
          right: 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'admin_zoom_in',
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 4,
                onPressed: _zoomIn,
                child: const Icon(Icons.add_rounded, size: 20),
              ),
              const SizedBox(height: 6),
              FloatingActionButton.small(
                heroTag: 'admin_zoom_out',
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 4,
                onPressed: _zoomOut,
                child: const Icon(Icons.remove_rounded, size: 20),
              ),
              FloatingActionButton.small(
                heroTag: 'admin_recenter',
                backgroundColor: AdminColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 4,
                onPressed: _recenterMap,
                child: const Icon(Icons.my_location_rounded, size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegalPoliciesViewer extends StatefulWidget {
  final bool isWide;
  const _LegalPoliciesViewer({required this.isWide});

  @override
  State<_LegalPoliciesViewer> createState() => _LegalPoliciesViewerState();
}

class _LegalPoliciesViewerState extends State<_LegalPoliciesViewer> {
  int _activeTab = 0; // 0: Terms, 1: Privacy
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final termsList = VoltSpareTermsAndConditions.sections.where((s) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return s.title.toLowerCase().contains(q) ||
          s.summary.toLowerCase().contains(q) ||
          s.bulletPoints.any((b) => b.toLowerCase().contains(q));
    }).toList();

    final privacyList = VoltSparePrivacyPolicy.sections.where((s) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return s.title.toLowerCase().contains(q) ||
          s.summary.toLowerCase().contains(q) ||
          s.bulletPoints.any((b) => b.toLowerCase().contains(q));
    }).toList();

    final activeSections = _activeTab == 0 ? termsList : privacyList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Compliance Overview Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0F172A),
                Color(0xFF1E293B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AdminColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AdminColors.primaryGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.verified_user_rounded,
                        color: AdminColors.primaryGreen, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VoltSpare Statutory Legal Framework',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Compliant with Consumer Protection (E-Commerce) Rules 2020 & Digital Personal Data Protection Act 2023 (DPDPA)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _statutoryChip(
                      'Consumer Protection Act 2019', Icons.gavel_rounded),
                  _statutoryChip(
                      'E-Commerce Rules 2020', Icons.shopping_bag_outlined),
                  _statutoryChip(
                      'DPDPA 2023 Notice & Consent', Icons.shield_outlined),
                  _statutoryChip(
                      'Hub Radius Serviceability', Icons.location_on_outlined),
                  _statutoryChip('Effective: ${LegalConfig.effectiveDate}',
                      Icons.event_available_outlined),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.support_agent_rounded,
                        color: Colors.white70, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Grievance Redressal: ${LegalConfig.grievanceOfficerName} • ${LegalConfig.grievanceEmail} • ${LegalConfig.supportPhone}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Policy Switcher Tabs + Search Box
        Row(
          children: [
            ChoiceChip(
              label: Text(
                  'Terms & Conditions (${VoltSpareTermsAndConditions.sections.length})'),
              selected: _activeTab == 0,
              onSelected: (selected) {
                if (selected) setState(() => _activeTab = 0);
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(
                  'Privacy Policy (${VoltSparePrivacyPolicy.sections.length})'),
              selected: _activeTab == 1,
              onSelected: (selected) {
                if (selected) setState(() => _activeTab = 1);
              },
            ),
            const Spacer(),
            SizedBox(
              width: widget.isWide ? 280 : 180,
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                style: TextStyle(color: AdminColors.textPrimary, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Search legal clauses...',
                  hintStyle:
                      TextStyle(color: AdminColors.textSecondary, fontSize: 12),
                  prefixIcon: const Icon(Icons.search, size: 16),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Preamble Text Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AdminColors.isDarkTheme
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AdminColors.border),
          ),
          child: Text(
            _activeTab == 0
                ? VoltSpareTermsAndConditions.preamble
                : VoltSparePrivacyPolicy.preamble,
            style: TextStyle(
              fontSize: 12,
              color: AdminColors.textSecondary,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Section Cards
        if (activeSections.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Center(
              child: Text(
                'No legal sections matched "$_searchQuery"',
                style:
                    TextStyle(color: AdminColors.textSecondary, fontSize: 13),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeSections.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final sec = activeSections[index];
              return _buildLegalSectionCard(sec);
            },
          ),
      ],
    );
  }

  Widget _statutoryChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AdminColors.accentLime, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSectionCard(LegalSection sec) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.panelBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminColors.border),
      ),
      child: ExpansionTile(
        key: PageStorageKey(sec.id),
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
        title: Text(
          sec.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AdminColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(
            sec.summary,
            style: TextStyle(
              fontSize: 11,
              color: AdminColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        children: [
          const Divider(height: 12),
          ...sec.bulletPoints.map((bp) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, right: 8.0),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AdminColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        bp,
                        style: TextStyle(
                          fontSize: 12,
                          color: AdminColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          if (sec.detailedText != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AdminColors.primaryGreen.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: AdminColors.primaryGreen.withValues(alpha: 0.2)),
              ),
              child: Text(
                sec.detailedText!,
                style: TextStyle(
                  fontSize: 11,
                  color: AdminColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
