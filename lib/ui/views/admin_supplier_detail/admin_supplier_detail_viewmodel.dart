import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/ui/common/voltspare_mock_data.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

class AdminSupplierDetailViewModel extends BaseViewModel with NavigationMixin {
  late String _supplierId;

  SupplierModel? get supplier {
    final index = mockSuppliers.indexWhere((s) => s.id == _supplierId);
    return index != -1 ? mockSuppliers[index] : null;
  }

  void init(String id) {
    _supplierId = id;
    notifyListeners();
  }

  void toggleStatus() {
    final s = supplier;
    if (s != null) {
      final index = mockSuppliers.indexWhere((item) => item.id == s.id);
      if (index != -1) {
        mockSuppliers[index] = SupplierModel(
          id: s.id,
          companyName: s.companyName,
          contactPerson: s.contactPerson,
          phone: s.phone,
          email: s.email,
          address: s.address,
          city: s.city,
          state: s.state,
          gstNumber: s.gstNumber,
          categories: s.categories,
          suppliesEvParts: s.suppliesEvParts,
          suppliesPetrolParts: s.suppliesPetrolParts,
          isActive: !s.isActive,
          outstandingAmountInPaise: s.outstandingAmountInPaise,
          lastPurchaseDate: s.lastPurchaseDate,
        );
        notifyListeners();
      }
    }
  }

  void recordPayment(double amount) {
    final s = supplier;
    if (s != null) {
      final index = mockSuppliers.indexWhere((item) => item.id == s.id);
      if (index != -1) {
        final currentOutstanding = s.outstandingAmountInPaise;
        final paymentPaise = (amount * 100).round();
        final newOutstanding = currentOutstanding - paymentPaise;
        mockSuppliers[index] = SupplierModel(
          id: s.id,
          companyName: s.companyName,
          contactPerson: s.contactPerson,
          phone: s.phone,
          email: s.email,
          address: s.address,
          city: s.city,
          state: s.state,
          gstNumber: s.gstNumber,
          categories: s.categories,
          suppliesEvParts: s.suppliesEvParts,
          suppliesPetrolParts: s.suppliesPetrolParts,
          isActive: s.isActive,
          outstandingAmountInPaise: newOutstanding < 0 ? 0 : newOutstanding,
          lastPurchaseDate: s.lastPurchaseDate,
        );
        notifyListeners();
      }
    }
  }
}
