import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/api_client.dart';
import 'package:spare_shop_admin/core/theme/theme_service.dart';
import 'package:stacked/stacked.dart';

class AdminSettingsViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _themeService = locator<ThemeService>();
  final _apiClient = locator<ApiClient>();

  // Selected tab
  String _selectedSection = 'General';
  String get selectedSection => _selectedSection;

  // General Settings
  final storeNameController =
      TextEditingController(text: 'VoltSpare Headquarters');
  final phoneController = TextEditingController(text: '+91 99000 88000');
  final emailController = TextEditingController(text: 'billing@voltspare.com');
  final addressController =
      TextEditingController(text: '12, MG Road, Landmark Block');
  final gstNumberController = TextEditingController(text: '29AAAAA0000A1Z1');

  // Billing Settings
  final invoicePrefixController = TextEditingController(text: 'VS-POS-');
  final nextInvoiceController = TextEditingController(text: '2489');
  bool gstEnabled = true;

  // POS Settings / tax percentage edit
  final taxPercentageController = TextEditingController(text: '18.0');
  bool allowSplitPayment = true;
  bool allowCashOverpayment = true;
  bool requireUpiId = true;
  bool requireCardRef = true;

  // Inventory Settings
  final lowStockThresholdController = TextEditingController(text: '5');
  bool outOfStockNotify = true;
  bool negativeStockAllowed = false;

  // Appearance
  AppThemePreference get themePreference => _themeService.themePreference;

  @override
  Future<void> futureToRun() async {
    await loadSettings();
  }

  void setSection(String section) {
    _selectedSection = section;
    notifyListeners();
  }

  void setTheme(AppThemePreference pref) {
    if (pref == AppThemePreference.light) {
      _themeService.setLightTheme();
    } else if (pref == AppThemePreference.dark) {
      _themeService.setDarkTheme();
    } else {
      _themeService.setSystemTheme();
    }
    notifyListeners();
  }

  void setGstEnabled(bool val) {
    gstEnabled = val;
    notifyListeners();
  }

  Future<void> loadSettings() async {
    setBusy(true);
    try {
      final response = await _apiClient.get('/settings');
      final data = response.data['data'] ?? {};

      final general = data['general'] ?? {};
      storeNameController.text = general['appName'] ?? 'VoltSpare Headquarters';
      phoneController.text = general['supportPhone'] ?? '+91 99000 88000';
      emailController.text = general['supportEmail'] ?? 'billing@voltspare.com';

      final billing = data['billing'] ?? {};
      invoicePrefixController.text = billing['invoicePrefix'] ?? 'VS-POS-';
      taxPercentageController.text =
          (billing['taxPercentage'] ?? 18.0).toString();

      final pos = data['pos'] ?? {};
      allowSplitPayment = pos['allowSplitPayment'] ?? true;

      final inventory = data['inventory'] ?? {};
      lowStockThresholdController.text =
          (inventory['lowStockThreshold'] ?? 5).toString();

      notifyListeners();
    } catch (e) {
      print('Error loading settings: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> saveSettings(BuildContext context) async {
    setBusy(true);
    try {
      // 1. General settings
      await _apiClient.patch('/settings/general', data: {
        'appName': storeNameController.text.trim(),
        'supportEmail': emailController.text.trim(),
        'supportPhone': phoneController.text.trim(),
      });

      // 2. Billing settings
      final double tax =
          double.tryParse(taxPercentageController.text.trim()) ?? 18.0;
      await _apiClient.patch('/settings/billing', data: {
        'invoicePrefix': invoicePrefixController.text.trim(),
        'taxPercentage': tax,
      });

      // 3. POS settings
      await _apiClient.patch('/settings/pos', data: {
        'allowSplitPayment': allowSplitPayment,
      });

      // 4. Inventory settings
      final int threshold =
          int.tryParse(lowStockThresholdController.text.trim()) ?? 5;
      await _apiClient.patch('/settings/inventory', data: {
        'lowStockThreshold': threshold,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error saving settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setBusy(false);
    }
  }

  void resetSettings() {
    storeNameController.text = 'VoltSpare Headquarters';
    phoneController.text = '+91 99000 88000';
    emailController.text = 'billing@voltspare.com';
    addressController.text = '12, MG Road, Landmark Block';
    gstNumberController.text = '29AAAAA0000A1Z1';
    invoicePrefixController.text = 'VS-POS-';
    nextInvoiceController.text = '2489';
    gstEnabled = true;
    taxPercentageController.text = '18.0';
    allowSplitPayment = true;
    allowCashOverpayment = true;
    requireUpiId = true;
    requireCardRef = true;
    lowStockThresholdController.text = '5';
    outOfStockNotify = true;
    negativeStockAllowed = false;
    notifyListeners();
  }
}
