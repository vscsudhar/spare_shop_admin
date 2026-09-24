import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/location_service.dart';
import 'package:stacked/stacked.dart';

class AdminLocationFormViewModel extends BaseViewModel with NavigationMixin {
  final _locationService = locator<LocationService>();
  final formKey = GlobalKey<FormState>();

  String? _locationId;
  bool get isEditMode => _locationId != null && _locationId!.isNotEmpty;

  final nameController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final radiusController = TextEditingController(text: '20');

  bool _isActive = true;
  bool get isActive => _isActive;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> init(String? id) async {
    _locationId = id;
    if (id != null && id.isNotEmpty) {
      setBusy(true);
      _errorMessage = null;
      try {
        final loc = await _locationService.getLocationById(id);
        nameController.text = loc.name;
        latitudeController.text = loc.latitude.toString();
        longitudeController.text = loc.longitude.toString();
        radiusController.text = loc.radiusKm.toString();
        _isActive = loc.isActive;
        rebuildUi();
      } catch (e) {
        _errorMessage = 'Failed to load location details: $e';
        rebuildUi();
      } finally {
        setBusy(false);
      }
    }
  }

  void toggleActive(bool? value) {
    _isActive = value ?? true;
    notifyListeners();
  }

  String? validateName(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Location name is required';
    }
    return null;
  }

  String? validateLatitude(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Latitude is required';
    }
    final num = double.tryParse(val.trim());
    if (num == null) {
      return 'Please enter a valid decimal number';
    }
    if (num < -90 || num > 90) {
      return 'Latitude must be between -90 and 90';
    }
    return null;
  }

  String? validateLongitude(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Longitude is required';
    }
    final num = double.tryParse(val.trim());
    if (num == null) {
      return 'Please enter a valid decimal number';
    }
    if (num < -180 || num > 180) {
      return 'Longitude must be between -180 and 180';
    }
    return null;
  }

  String? validateRadius(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Radius is required';
    }
    final num = double.tryParse(val.trim());
    if (num == null || num <= 0) {
      return 'Radius must be a number greater than 0';
    }
    return null;
  }

  Future<bool> saveLocation() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    setBusy(true);
    _errorMessage = null;

    final name = nameController.text.trim();
    final lat = double.parse(latitudeController.text.trim());
    final lng = double.parse(longitudeController.text.trim());
    final radius = double.parse(radiusController.text.trim());

    final data = {
      'name': name,
      'latitude': lat,
      'longitude': lng,
      'radiusKm': radius,
      'isActive': _isActive,
    };

    try {
      if (isEditMode) {
        await _locationService.updateLocation(_locationId!, data);
      } else {
        await _locationService.createLocation(data);
      }
      setBusy(false);
      goBack();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      setBusy(false);
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    radiusController.dispose();
    super.dispose();
  }
}
