import 'package:flutter/foundation.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/return_exchange_service.dart';
import 'package:spare_shop_admin/ui/common/return_exchange_models.dart';
import 'package:stacked/stacked.dart';

class AdminDamagedProductsViewModel extends FutureViewModel<void> with NavigationMixin {
  final _returnsService = locator<ReturnExchangeService>();

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedDamageType = 'all';
  String get selectedDamageType => _selectedDamageType;

  String _selectedResolution = 'all';
  String get selectedResolution => _selectedResolution;

  List<DamagedItemRecord> _damagedItems = [];
  List<DamagedItemRecord> get damagedItems => _damagedItems;

  DamagedItemsMetrics? _metrics;
  DamagedItemsMetrics? get metrics => _metrics;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  bool _initialized = false;

  @override
  Future<void> futureToRun() async {
    if (_initialized) return;
    _initialized = true;
    await loadDamagedProducts();
  }

  Future<void> loadDamagedProducts() async {
    setBusy(true);
    try {
      final res = await _returnsService.getDamagedItems(
        damageType: _selectedDamageType,
        damageResolution: _selectedResolution,
        search: _searchQuery,
      );
      _damagedItems = res.items;
      _metrics = res.metrics;
      _totalCount = res.total;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading damaged products: $e');
    } finally {
      setBusy(false);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadDamagedProducts();
  }

  void setFilterDamageType(String type) {
    _selectedDamageType = type;
    loadDamagedProducts();
  }

  void setFilterResolution(String resolution) {
    _selectedResolution = resolution;
    loadDamagedProducts();
  }

  Future<void> openCaseDetail(String caseId) async {
    await goToReturnDetail(caseId: caseId);
    await loadDamagedProducts();
  }
}
