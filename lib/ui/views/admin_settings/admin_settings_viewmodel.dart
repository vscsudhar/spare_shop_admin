import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/api_client.dart';
import 'package:spare_shop_admin/core/services/invoice_service.dart';
import 'package:spare_shop_admin/core/theme/theme_service.dart';
import 'package:spare_shop_admin/ui/common/app_strings.dart';
import 'package:stacked/stacked.dart';

class AdminSettingsViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _themeService = locator<ThemeService>();
  final _apiClient = locator<ApiClient>();

  // Selected tab
  String _selectedSection = 'General';
  String get selectedSection => _selectedSection;

  // General Settings - Business & Tax Information
  final storeNameController =
      TextEditingController(text: VoltSpareBusinessConfig.storeName);
  final legalNameController =
      TextEditingController(text: VoltSpareBusinessConfig.legalEntityName);
  final phoneController =
      TextEditingController(text: VoltSpareBusinessConfig.supportPhone);
  final emailController =
      TextEditingController(text: VoltSpareBusinessConfig.billingEmail);
  final gstNumberController =
      TextEditingController(text: VoltSpareBusinessConfig.defaultGstin);
  final panController =
      TextEditingController(text: VoltSpareBusinessConfig.defaultPan);
  final websiteController =
      TextEditingController(text: VoltSpareBusinessConfig.website);

  // General Settings - Address & Map Coordinates
  final addressLine1Controller =
      TextEditingController(text: VoltSpareBusinessConfig.defaultAddressLine1);
  final addressLine2Controller =
      TextEditingController(text: VoltSpareBusinessConfig.defaultAddressLine2);
  final cityController =
      TextEditingController(text: VoltSpareBusinessConfig.defaultCity);
  final stateController =
      TextEditingController(text: VoltSpareBusinessConfig.defaultState);
  final stateCodeController =
      TextEditingController(text: VoltSpareBusinessConfig.defaultStateCode);
  final pincodeController =
      TextEditingController(text: VoltSpareBusinessConfig.defaultPincode);

  // OpenStreetMap Coordinates
  double latitude = VoltSpareBusinessConfig.defaultLatitude;
  double longitude = VoltSpareBusinessConfig.defaultLongitude;
  bool isMapMoved = false;

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

  void updateLocation(double lat, double lng) {
    latitude = lat;
    longitude = lng;
    isMapMoved = true;
    notifyListeners();
  }

  void onAreaSelected(String taluk, String district, String state,
      [String? postalCode]) {
    if (taluk.isNotEmpty && taluk != 'Area') {
      addressLine2Controller.text = taluk;
    }
    if (district.isNotEmpty && district != 'City') {
      cityController.text = district;
    }
    if (state.isNotEmpty && state != 'State') {
      stateController.text = state;
      stateCodeController.text = InvoiceService.getStateCode(state);
    }
    if (postalCode != null && postalCode.isNotEmpty) {
      pincodeController.text = postalCode;
    }
    notifyListeners();
  }

  Future<void> loadSettings() async {
    setBusy(true);
    try {
      final response = await _apiClient.get('/settings');
      final data = response.data['data'] ?? {};

      final general = data['general'] ?? {};
      storeNameController.text =
          (general['appName'] ?? VoltSpareBusinessConfig.storeName).toString();
      legalNameController.text = (general['legalName'] ??
              general['appName'] ??
              VoltSpareBusinessConfig.legalEntityName)
          .toString();
      phoneController.text =
          (general['supportPhone'] ?? VoltSpareBusinessConfig.supportPhone)
              .toString();
      emailController.text =
          (general['supportEmail'] ?? VoltSpareBusinessConfig.billingEmail)
              .toString();
      gstNumberController.text = (general['gstin'] ??
              general['gstNumber'] ??
              VoltSpareBusinessConfig.defaultGstin)
          .toString();
      panController.text =
          (general['pan'] ?? VoltSpareBusinessConfig.defaultPan).toString();
      websiteController.text =
          (general['website'] ?? VoltSpareBusinessConfig.website).toString();

      addressLine1Controller.text = (general['addressLine1'] ??
              general['address'] ??
              VoltSpareBusinessConfig.defaultAddressLine1)
          .toString();
      addressLine2Controller.text = (general['addressLine2'] ??
              VoltSpareBusinessConfig.defaultAddressLine2)
          .toString();
      cityController.text =
          (general['city'] ?? VoltSpareBusinessConfig.defaultCity).toString();
      stateController.text =
          (general['state'] ?? VoltSpareBusinessConfig.defaultState).toString();
      stateCodeController.text = (general['stateCode'] ??
              InvoiceService.getStateCode(stateController.text))
          .toString();
      pincodeController.text = (general['postalCode'] ??
              general['pincode'] ??
              VoltSpareBusinessConfig.defaultPincode)
          .toString();

      if (general['latitude'] != null) {
        final latNum = double.tryParse(general['latitude'].toString());
        if (latNum != null) latitude = latNum;
      }
      if (general['longitude'] != null) {
        final lngNum = double.tryParse(general['longitude'].toString());
        if (lngNum != null) longitude = lngNum;
      }

      // Cache business details for invoice generation
      InvoiceService.updateCachedBusinessInfo(
        InvoiceBusinessInfo(
          name: storeNameController.text,
          legalName: legalNameController.text,
          addressLine1: addressLine1Controller.text,
          addressLine2: addressLine2Controller.text,
          city: cityController.text,
          state: stateController.text,
          stateCode: stateCodeController.text,
          pincode: pincodeController.text,
          phone: phoneController.text,
          email: emailController.text,
          gstin: gstNumberController.text,
          pan: panController.text,
          website: websiteController.text,
        ),
      );

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
      debugPrint('Error loading settings: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> saveSettings(BuildContext context) async {
    setBusy(true);
    try {
      final stateCode = stateCodeController.text.trim().isNotEmpty
          ? stateCodeController.text.trim()
          : InvoiceService.getStateCode(stateController.text.trim());

      // 1. General settings with full address, coordinates, tax numbers
      await _apiClient.patch('/settings/general', data: {
        'appName': storeNameController.text.trim(),
        'legalName': legalNameController.text.trim(),
        'supportEmail': emailController.text.trim(),
        'supportPhone': phoneController.text.trim(),
        'gstin': gstNumberController.text.trim(),
        'gstNumber': gstNumberController.text.trim(),
        'pan': panController.text.trim(),
        'address': addressLine1Controller.text.trim(),
        'addressLine1': addressLine1Controller.text.trim(),
        'addressLine2': addressLine2Controller.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'stateCode': stateCode,
        'postalCode': pincodeController.text.trim(),
        'pincode': pincodeController.text.trim(),
        'latitude': latitude,
        'longitude': longitude,
        'website': websiteController.text.trim(),
      });

      // Synchronize in-memory InvoiceService business info
      InvoiceService.updateCachedBusinessInfo(
        InvoiceBusinessInfo(
          name: storeNameController.text.trim(),
          legalName: legalNameController.text.trim(),
          addressLine1: addressLine1Controller.text.trim(),
          addressLine2: addressLine2Controller.text.trim(),
          city: cityController.text.trim(),
          state: stateController.text.trim(),
          stateCode: stateCode,
          pincode: pincodeController.text.trim(),
          phone: phoneController.text.trim(),
          email: emailController.text.trim(),
          gstin: gstNumberController.text.trim(),
          pan: panController.text.trim(),
          website: websiteController.text.trim(),
        ),
      );

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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved & synced to Invoices successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setBusy(false);
    }
  }

  void resetSettings() {
    storeNameController.text = VoltSpareBusinessConfig.storeName;
    legalNameController.text = VoltSpareBusinessConfig.legalEntityName;
    phoneController.text = VoltSpareBusinessConfig.supportPhone;
    emailController.text = VoltSpareBusinessConfig.billingEmail;
    gstNumberController.text = VoltSpareBusinessConfig.defaultGstin;
    panController.text = VoltSpareBusinessConfig.defaultPan;
    websiteController.text = VoltSpareBusinessConfig.website;

    addressLine1Controller.text = VoltSpareBusinessConfig.defaultAddressLine1;
    addressLine2Controller.text = VoltSpareBusinessConfig.defaultAddressLine2;
    cityController.text = VoltSpareBusinessConfig.defaultCity;
    stateController.text = VoltSpareBusinessConfig.defaultState;
    stateCodeController.text = VoltSpareBusinessConfig.defaultStateCode;
    pincodeController.text = VoltSpareBusinessConfig.defaultPincode;
    latitude = VoltSpareBusinessConfig.defaultLatitude;
    longitude = VoltSpareBusinessConfig.defaultLongitude;
    isMapMoved = false;

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
