import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/delivery_charge_service.dart';
import 'package:spare_shop_admin/core/services/location_service.dart';
import 'package:spare_shop_admin/core/services/token_service.dart';
import 'package:spare_shop_admin/ui/common/delivery_charge_models.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:stacked/stacked.dart';

class AdminDeliveryChargesViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _deliveryService = locator<DeliveryChargeService>();
  final _locationService = locator<LocationService>();
  final _tokenService = locator<TokenService>();

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedLocationFilter = 'all'; // 'all' or locationId
  String get selectedLocationFilter => _selectedLocationFilter;

  List<LocationModel> _locations = [];
  List<LocationModel> get locations => _locations;

  bool _canChangeLocation = true;
  bool get canChangeLocation => _canChangeLocation;

  String? _userAssignedLocationId;
  String? get userAssignedLocationId => _userAssignedLocationId;

  List<DeliveryChargeModel> _tiers = [];
  List<DeliveryChargeModel> get tiers => _tiers;

  // Live Calculator test input
  final testAmountController = TextEditingController(text: '350');
  double? _calculatedFee;
  double? get calculatedFee => _calculatedFee;
  String? _matchedTierText;
  String? get matchedTierText => _matchedTierText;

  List<DeliveryChargeModel> get filteredTiers {
    if (_selectedLocationFilter == '__none__') return [];

    return _tiers.where((t) {
      if (_selectedLocationFilter != 'all') {
        final matchesLocId = t.locationId == _selectedLocationFilter;
        final isGlobal = t.locationId == null || t.locationId!.isEmpty;
        if (!matchesLocId && !isGlobal) return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchDesc = (t.description ?? '').toLowerCase().contains(q);
        final matchTier = t.tierDisplay.toLowerCase().contains(q);
        final matchLoc = (t.locationName ?? '').toLowerCase().contains(q);
        if (!matchDesc && !matchTier && !matchLoc) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) => a.fromAmount.compareTo(b.fromAmount));
  }

  int get totalTiers => _tiers.length;
  int get activeTiers => _tiers.where((t) => t.isActive).length;

  double? get freeDeliveryThreshold {
    final freeTier = _tiers.where((t) => t.isActive && t.deliveryCharge == 0);
    if (freeTier.isNotEmpty) {
      return freeTier.first.fromAmount;
    }
    return null;
  }

  @override
  Future<void> futureToRun() async {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    TokenService.locationNotifier.addListener(_onLocationNotifierChanged);

    _canChangeLocation = await _tokenService.canChangeLocation();
    _userAssignedLocationId = await _tokenService.getUserLocationId();

    try {
      _locations = await _locationService.getLocations();
    } catch (_) {
      _locations = [];
    }

    if (!_canChangeLocation &&
        (_userAssignedLocationId == null || _userAssignedLocationId!.isEmpty)) {
      _selectedLocationFilter = '__none__';
    } else if (_userAssignedLocationId != null &&
        _userAssignedLocationId!.isNotEmpty &&
        _userAssignedLocationId != 'all') {
      _selectedLocationFilter = _userAssignedLocationId!;
    } else {
      _selectedLocationFilter = 'all';
    }

    await loadTiers();
    calculateTestFee();
  }

  void _onLocationNotifierChanged() {
    final newLocId = TokenService.locationNotifier.locationId;
    _selectedLocationFilter =
        (newLocId != null && newLocId.isNotEmpty) ? newLocId : 'all';
    loadTiers();
  }

  @override
  void dispose() {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    testAmountController.dispose();
    super.dispose();
  }

  Future<void> loadTiers() async {
    setBusy(true);
    try {
      if (_selectedLocationFilter == '__none__') {
        _tiers = [];
      } else {
        _tiers = await _deliveryService.getDeliveryCharges(
          locationId:
              _selectedLocationFilter == 'all' ? null : _selectedLocationFilter,
        );
      }
      calculateTestFee();
    } catch (_) {
      _tiers = DeliveryChargeModel.defaultTiers();
    } finally {
      setBusy(false);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void setSelectedLocationFilter(String locationId) {
    _selectedLocationFilter = locationId;
    if (_canChangeLocation) {
      locator<TokenService>().saveUserLocation(
        locationId: locationId == 'all' ? null : locationId,
        locationName:
            locationId != 'all' && _locations.any((l) => l.id == locationId)
                ? _locations.firstWhere((l) => l.id == locationId).name
                : 'All Locations (HQ)',
      );
    }
    loadTiers();
  }

  void calculateTestFee() {
    final amount = double.tryParse(testAmountController.text.trim()) ?? 0.0;
    final activeList = _tiers.where((t) => t.isActive).toList()
      ..sort((a, b) => a.fromAmount.compareTo(b.fromAmount));

    for (final tier in activeList) {
      if (amount >= tier.fromAmount &&
          (tier.toAmount == null || amount <= tier.toAmount!)) {
        _calculatedFee = tier.deliveryCharge;
        _matchedTierText = '${tier.tierDisplay} → ${tier.chargeDisplay}';
        notifyListeners();
        return;
      }
    }

    _calculatedFee = DeliveryChargeModel.calculateFallback(amount);
    _matchedTierText = 'Fallback Rule → ₹${_calculatedFee!.toInt()}';
    notifyListeners();
  }

  Future<void> saveTier({
    String? id,
    required double fromAmount,
    double? toAmount,
    required double deliveryCharge,
    String? locationId,
    String? locationName,
    String? description,
    bool isActive = true,
  }) async {
    setBusy(true);
    try {
      final tier = DeliveryChargeModel(
        id: id ?? '',
        fromAmount: fromAmount,
        toAmount: toAmount,
        deliveryCharge: deliveryCharge,
        locationId:
            (locationId != null && locationId.isNotEmpty && locationId != 'all')
                ? locationId
                : null,
        locationName: locationName ?? 'All Locations (HQ)',
        description: description,
        isActive: isActive,
      );

      if (id == null || id.isEmpty) {
        // Create new
        await _deliveryService.createDeliveryCharge(tier);
      } else {
        // Update existing
        await _deliveryService.updateDeliveryCharge(id, tier);
      }

      await loadTiers();
    } catch (e) {
      debugPrint('Error saving delivery tier: $e');
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  Future<void> toggleStatus(DeliveryChargeModel tier) async {
    final updated = tier.copyWith(isActive: !tier.isActive);
    setBusy(true);
    try {
      await _deliveryService.updateDeliveryCharge(tier.id, updated);
      await loadTiers();
    } catch (e) {
      debugPrint('Error toggling tier status: $e');
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  Future<void> deleteTier(String id) async {
    setBusy(true);
    try {
      await _deliveryService.deleteDeliveryCharge(id);
      await loadTiers();
    } catch (e) {
      debugPrint('Error deleting tier: $e');
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }
}
