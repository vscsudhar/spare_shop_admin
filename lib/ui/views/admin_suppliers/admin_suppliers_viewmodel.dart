import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/admin_supplier_service.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

class AdminSuppliersViewModel extends FutureViewModel<void>
    with NavigationMixin {
  final _supplierService = locator<AdminSupplierService>();

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _categoryFilter = 'All'; // 'All', 'EV', 'Petrol'
  String get categoryFilter => _categoryFilter;

  String _statusFilter = 'All'; // 'All', 'Active', 'Inactive'
  String get statusFilter => _statusFilter;

  List<SupplierModel> _allSuppliers = [];

  List<SupplierModel> get suppliers {
    return _allSuppliers.where((s) {
      final matchesSearch = s.companyName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          s.contactPerson.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.phone.contains(_searchQuery);

      final matchesCategory = _categoryFilter == 'All' ||
          (_categoryFilter == 'EV' && s.suppliesEvParts) ||
          (_categoryFilter == 'Petrol' && s.suppliesPetrolParts);

      final matchesStatus = _statusFilter == 'All' ||
          (_statusFilter == 'Active' && s.isActive) ||
          (_statusFilter == 'Inactive' && !s.isActive);

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  int get totalSuppliers => _allSuppliers.length;
  int get activeSuppliers => _allSuppliers.where((s) => s.isActive).length;

  double get outstandingPayable {
    final totalPaise =
        _allSuppliers.fold(0, (sum, s) => sum + s.outstandingAmountInPaise);
    return totalPaise / 100.0;
  }

  @override
  Future<void> futureToRun() async {
    await loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    try {
      _allSuppliers = await _supplierService.getSuppliers();
      rebuildUi();
    } catch (e) {
      print('Error loading admin suppliers: $e');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String val) {
    _categoryFilter = val;
    notifyListeners();
  }

  void setStatusFilter(String val) {
    _statusFilter = val;
    notifyListeners();
  }

  Future<void> toggleStatus(SupplierModel s) async {
    setBusy(true);
    try {
      await _supplierService.updateSupplier(s.id, {
        'status': s.isActive ? 'inactive' : 'active',
      });
      await loadSuppliers();
    } catch (e) {
      print('Error toggling supplier status: $e');
    } finally {
      setBusy(false);
    }
  }
}
