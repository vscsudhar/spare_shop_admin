import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/services/api_client.dart';
import 'package:spare_shop_admin/ui/common/delivery_charge_models.dart';

class DeliveryChargeService {
  static const String _storageKey = 'voltspare_persisted_delivery_charges_v1';
  final ApiClient _apiClient;

  List<DeliveryChargeModel> _cache = [];

  DeliveryChargeService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  Future<List<DeliveryChargeModel>> getDeliveryCharges({String? locationId}) async {
    // 1. Load from SharedPreferences cache first
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _cache = decoded
            .map((item) => DeliveryChargeModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (_cache.isEmpty) {
        _cache = DeliveryChargeModel.defaultTiers();
        await _persistTiers();
      }
    } catch (e) {
      debugPrint('Error loading cached delivery charges: $e');
      if (_cache.isEmpty) {
        _cache = DeliveryChargeModel.defaultTiers();
      }
    }

    // 2. Try fetching from backend API and merge
    try {
      final queryParams = <String, dynamic>{};
      if (locationId != null && locationId.isNotEmpty && locationId != 'all') {
        queryParams['locationId'] = locationId;
      }
      final response = await _apiClient.get(
        '/delivery-charges',
        queryParameters: queryParams,
      );
      final List<dynamic>? list = response.data['data'];
      if (list != null && list.isNotEmpty) {
        final backendTiers =
            list.map((item) => DeliveryChargeModel.fromJson(item)).toList();
        for (final bt in backendTiers) {
          final idx = _cache.indexWhere((t) => t.id == bt.id);
          if (idx != -1) {
            _cache[idx] = bt;
          } else {
            _cache.add(bt);
          }
        }
        await _persistTiers();
      }
    } catch (e) {
      debugPrint('Backend delivery charges sync: $e');
    }

    if (locationId != null && locationId.isNotEmpty && locationId != 'all') {
      return _cache.where((t) =>
          t.locationId == locationId ||
          t.locationId == null ||
          t.locationId!.isEmpty).toList();
    }

    return List<DeliveryChargeModel>.from(_cache);
  }

  Future<DeliveryChargeModel> createDeliveryCharge(DeliveryChargeModel tier) async {
    await getDeliveryCharges();
    final newId = tier.id.isNotEmpty
        ? tier.id
        : 'dc_tier_${DateTime.now().millisecondsSinceEpoch}';
    final newTier = tier.copyWith(id: newId);

    _cache.add(newTier);
    await _persistTiers();

    // Sync with backend API
    try {
      final response = await _apiClient.post(
        '/delivery-charges',
        data: newTier.toJson(),
      );
      if (response.data != null && response.data['data'] != null) {
        final data = response.data['data'];
        final serverTier = DeliveryChargeModel.fromJson(data);
        final idx = _cache.indexWhere((t) => t.id == newId);
        if (idx != -1) {
          _cache[idx] = serverTier;
          await _persistTiers();
          return serverTier;
        }
      }
    } catch (e) {
      debugPrint('API create delivery charge error: $e');
    }

    return newTier;
  }

  Future<DeliveryChargeModel> updateDeliveryCharge(
      String id, DeliveryChargeModel tier) async {
    await getDeliveryCharges();
    final idx = _cache.indexWhere((t) => t.id == id);
    final updatedTier = tier.copyWith(id: id);

    if (idx != -1) {
      _cache[idx] = updatedTier;
    } else {
      _cache.add(updatedTier);
    }
    await _persistTiers();

    // Sync with backend API
    try {
      await _apiClient.put(
        '/delivery-charges/$id',
        data: updatedTier.toJson(),
      );
    } catch (e) {
      debugPrint('API update delivery charge error: $e');
    }

    return updatedTier;
  }

  Future<void> deleteDeliveryCharge(String id) async {
    await getDeliveryCharges();
    _cache.removeWhere((t) => t.id == id);
    await _persistTiers();

    try {
      await _apiClient.delete('/delivery-charges/$id');
    } catch (e) {
      debugPrint('API delete delivery charge error: $e');
    }
  }

  Future<double> calculateCharge(
      {required double orderAmount, String? locationId}) async {
    final tiers = await getDeliveryCharges(locationId: locationId);
    final activeList = tiers.where((t) => t.isActive).toList()
      ..sort((a, b) => a.fromAmount.compareTo(b.fromAmount));

    for (final tier in activeList) {
      if (orderAmount >= tier.fromAmount &&
          (tier.toAmount == null || orderAmount <= tier.toAmount!)) {
        return tier.deliveryCharge;
      }
    }

    return DeliveryChargeModel.calculateFallback(orderAmount);
  }

  Future<void> _persistTiers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_cache.map((t) => t.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error persisting delivery charges: $e');
    }
  }
}
