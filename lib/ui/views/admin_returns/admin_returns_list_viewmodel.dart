import 'package:flutter/foundation.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/return_exchange_service.dart';
import 'package:spare_shop_admin/ui/common/return_exchange_models.dart';
import 'package:stacked/stacked.dart';

class AdminReturnsListViewModel extends FutureViewModel<void> with NavigationMixin {
  final _returnsService = locator<ReturnExchangeService>();

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedType = 'all';
  String get selectedType => _selectedType;

  String _selectedStatus = 'all';
  String get selectedStatus => _selectedStatus;

  List<ReturnExchangeCase> _cases = [];
  List<ReturnExchangeCase> get cases => _cases;

  List<ReturnExchangeCase> get filteredCases {
    return _cases.where((c) {
      final matchesSearch = _searchQuery.isEmpty ||
          c.caseNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.billNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.customerPhone.contains(_searchQuery);

      final matchesType =
          _selectedType == 'all' || c.type.toLowerCase() == _selectedType.toLowerCase();

      final matchesStatus =
          _selectedStatus == 'all' || c.status.toLowerCase() == _selectedStatus.toLowerCase();

      return matchesSearch && matchesType && matchesStatus;
    }).toList();
  }

  bool _initialized = false;

  @override
  Future<void> futureToRun() async {
    if (_initialized) return;
    _initialized = true;
    await loadCases();
  }

  Future<void> loadCases() async {
    setBusy(true);
    try {
      _cases = await _returnsService.getCases();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading return cases: $e');
    } finally {
      setBusy(false);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void setFilterStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  Future<void> openCaseDetail(ReturnExchangeCase kase) async {
    await goToReturnDetail(caseId: kase.id);
    await loadCases();
  }

  Future<void> openNewReturn() async {
    await goToNewReturn();
    await loadCases();
  }
}
