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
  final radiusController = TextEditingController(text: '20');

  // Selected Coordinates from OpenStreetMap
  double? _selectedLatitude;
  double? get selectedLatitude => _selectedLatitude;

  double? _selectedLongitude;
  double? get selectedLongitude => _selectedLongitude;

  bool _hasUserSelectedLocation = false;
  bool get hasUserSelectedLocation => _hasUserSelectedLocation;

  double _radiusKm = 20.0;
  double get radiusKm => _radiusKm;

  bool _isActive = true;
  bool get isActive => _isActive;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Default coordinate center for Tamil Nadu / Coimbatore hub
  static const double defaultLat = 10.9027;
  static const double defaultLng = 76.9634;

  Future<void> init(String? id) async {
    _locationId = id;
    if (id != null && id.isNotEmpty) {
      setBusy(true);
      _errorMessage = null;
      try {
        final loc = await _locationService.getLocationById(id);
        nameController.text = loc.name;
        _radiusKm = loc.radiusKm > 0 ? loc.radiusKm : 20.0;
        radiusController.text = _radiusKm.toString();
        _selectedLatitude = loc.latitude;
        _selectedLongitude = loc.longitude;
        _hasUserSelectedLocation = (loc.latitude != 0.0 || loc.longitude != 0.0);
        _isActive = loc.isActive;
        rebuildUi();
      } catch (e) {
        _errorMessage = 'Failed to load location details: $e';
        rebuildUi();
      } finally {
        setBusy(false);
      }
    } else {
      // Add mode - default view coordinates
      _selectedLatitude = defaultLat;
      _selectedLongitude = defaultLng;
      _hasUserSelectedLocation = true;
      _radiusKm = 20.0;
      radiusController.text = '20';
      rebuildUi();
    }
  }

  void updateCoordinates(double lat, double lng, {String? placeName}) {
    _selectedLatitude = double.parse(lat.toStringAsFixed(6));
    _selectedLongitude = double.parse(lng.toStringAsFixed(6));
    _hasUserSelectedLocation = true;
    _errorMessage = null;

    if (placeName != null && placeName.isNotEmpty && nameController.text.trim().isEmpty) {
      nameController.text = placeName;
    }

    notifyListeners();
  }

  void updateRadius(String val) {
    final num = double.tryParse(val.trim());
    if (num != null && num > 0) {
      _radiusKm = num;
      notifyListeners();
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

    if (_selectedLatitude == null || _selectedLongitude == null) {
      _errorMessage = 'Please select a location on the OpenStreetMap';
      notifyListeners();
      return false;
    }

    setBusy(true);
    _errorMessage = null;

    final name = nameController.text.trim();
    final lat = _selectedLatitude!;
    final lng = _selectedLongitude!;
    final radius = double.tryParse(radiusController.text.trim()) ?? _radiusKm;

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
    radiusController.dispose();
    super.dispose();
  }
}
