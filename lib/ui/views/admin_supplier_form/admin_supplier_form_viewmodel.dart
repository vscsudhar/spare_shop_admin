import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/admin_supplier_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AdminSupplierFormViewModel extends BaseViewModel with NavigationMixin {
  final _supplierService = locator<AdminSupplierService>();
  final _dialogService = locator<DialogService>();
  final formKey = GlobalKey<FormState>();

  String? _supplierId;
  bool get isEditMode => _supplierId != null;

  final companyNameController = TextEditingController();
  final contactPersonController = TextEditingController();
  final phoneController = TextEditingController();
  final altPhoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final gstNumberController = TextEditingController();

  final bankAccountController = TextEditingController();
  final bankIfscController = TextEditingController();
  final bankUpiController = TextEditingController();
  final paymentTermsController = TextEditingController();
  final creditLimitController = TextEditingController();
  final noteController = TextEditingController();

  bool _suppliesEv = true;
  bool get suppliesEv => _suppliesEv;

  bool _suppliesPetrol = false;
  bool get suppliesPetrol => _suppliesPetrol;

  bool _isActive = true;
  bool get isActive => _isActive;

  final List<String> _selectedCategories = [];
  List<String> get selectedCategories => _selectedCategories;

  Future<void> init(String? id) async {
    _supplierId = id;
    if (id != null) {
      setBusy(true);
      try {
        final s = await _supplierService.getSupplierById(id);
        companyNameController.text = s.companyName;
        contactPersonController.text = s.contactPerson;
        phoneController.text = s.phone;
        emailController.text = s.email;
        addressController.text = s.address;
        cityController.text = s.city;
        stateController.text = s.state;
        gstNumberController.text = s.gstNumber;
        _suppliesEv = s.suppliesEvParts;
        _suppliesPetrol = s.suppliesPetrolParts;
        _isActive = s.isActive;
        _selectedCategories.clear();
        _selectedCategories.addAll(s.categories);
        rebuildUi();
      } catch (e) {
        print('Error loading supplier data: $e');
      } finally {
        setBusy(false);
      }
    }
  }

  void toggleEv(bool? val) {
    _suppliesEv = val ?? false;
    notifyListeners();
  }

  void togglePetrol(bool? val) {
    _suppliesPetrol = val ?? false;
    notifyListeners();
  }

  void toggleActive(bool? val) {
    _isActive = val ?? false;
    notifyListeners();
  }

  void toggleCategory(String cat) {
    if (_selectedCategories.contains(cat)) {
      _selectedCategories.remove(cat);
    } else {
      _selectedCategories.add(cat);
    }
    notifyListeners();
  }

  Future<void> saveSupplier() async {
    if (!formKey.currentState!.validate()) return;

    setBusy(true);
    try {
      final companyName = companyNameController.text.trim();

      String codeClean =
          companyName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
      if (codeClean.length > 5) {
        codeClean = codeClean.substring(0, 5);
      }
      final generatedCode = 'SUP-$codeClean-${DateTime.now().millisecond}';

      final List<String> categories = [];
      if (_suppliesEv) categories.add('EV');
      if (_suppliesPetrol) categories.add('Petrol');
      if (categories.isEmpty) categories.add('Universal');

      final payload = {
        'name': companyName,
        'code': generatedCode,
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'gstNumber': gstNumberController.text.trim(),
        'address': addressController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'vehicleCategories': categories,
        'contacts': [
          {
            'name': contactPersonController.text.trim(),
            'email': emailController.text.trim(),
            'phone': phoneController.text.trim(),
            'designation': 'Primary Contact',
          }
        ],
      };

      if (isEditMode) {
        final updatePayload = {
          'name': companyName,
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'gstNumber': gstNumberController.text.trim(),
          'address': addressController.text.trim(),
          'city': cityController.text.trim(),
          'state': stateController.text.trim(),
          'vehicleCategories': categories,
          'contacts': [
            {
              'name': contactPersonController.text.trim(),
              'email': emailController.text.trim(),
              'phone': phoneController.text.trim(),
              'designation': 'Primary Contact',
            }
          ],
        };
        await _supplierService.updateSupplier(_supplierId!, updatePayload);
        await _supplierService.updateSupplierStatus(_supplierId!, _isActive);
      } else {
        await _supplierService.createSupplier(payload);
      }
      setBusy(false);
      goBack();
    } catch (e) {
      print('Error saving supplier: $e');
      String errMsg = 'Failed to save supplier profile.';
      try {
        if (e is DioException && e.response?.data != null) {
          final data = e.response!.data;
          if (data is Map && data.containsKey('message')) {
            errMsg = data['message'].toString();
          }
        }
      } catch (_) {}
      _dialogService.showDialog(
        title: 'Error Saving Supplier',
        description: errMsg,
      );
      setBusy(false);
    }
  }
}
