import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:stacked/stacked.dart';

class AdminCustomerModel {
  final String name;
  final String email;
  final String phone;
  final String type; // 'Retailer' or 'Workshop'
  final int ordersCount;
  final double totalSpend;
  final double outstandingDue;

  AdminCustomerModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.type,
    required this.ordersCount,
    required this.totalSpend,
    required this.outstandingDue,
  });

  AdminCustomerModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? type,
    int? ordersCount,
    double? totalSpend,
    double? outstandingDue,
  }) {
    return AdminCustomerModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      ordersCount: ordersCount ?? this.ordersCount,
      totalSpend: totalSpend ?? this.totalSpend,
      outstandingDue: outstandingDue ?? this.outstandingDue,
    );
  }
}

class AdminCustomersViewModel extends BaseViewModel with NavigationMixin {
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  final List<AdminCustomerModel> _customers = [
    AdminCustomerModel(
      name: 'Ravi Kumar',
      email: 'ravi.kumar@gmail.com',
      phone: '+91 98765 43210',
      type: 'Workshop Owner',
      ordersCount: 24,
      totalSpend: 48900.00,
      outstandingDue: 4500.00,
    ),
    AdminCustomerModel(
      name: 'Anjali Sharma',
      email: 'anjali@live.com',
      phone: '+91 98123 45678',
      type: 'Retail Customer',
      ordersCount: 4,
      totalSpend: 8400.00,
      outstandingDue: 0.00,
    ),
    AdminCustomerModel(
      name: 'Suresh EV Services',
      email: 'contact@sureshev.com',
      phone: '+91 94440 12345',
      type: 'Workshop Owner',
      ordersCount: 89,
      totalSpend: 245000.00,
      outstandingDue: 18500.00,
    ),
  ];

  List<AdminCustomerModel> get filteredCustomers {
    if (_searchQuery.isEmpty) return _customers;
    return _customers
        .where((c) =>
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.phone.contains(_searchQuery))
        .toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  double get totalOutstandingDue {
    return _customers.fold(0, (sum, c) => sum + c.outstandingDue);
  }

  void addCustomer({
    required String name,
    required String email,
    required String phone,
    required String type,
    required double outstandingDue,
  }) {
    _customers.add(
      AdminCustomerModel(
        name: name,
        email: email,
        phone: phone,
        type: type,
        ordersCount: 0,
        totalSpend: 0.0,
        outstandingDue: outstandingDue,
      ),
    );
    notifyListeners();
  }

  void updateCustomer(
    AdminCustomerModel oldCustomer, {
    required String name,
    required String email,
    required String phone,
    required String type,
    required double outstandingDue,
  }) {
    final index = _customers.indexOf(oldCustomer);
    if (index != -1) {
      _customers[index] = oldCustomer.copyWith(
        name: name,
        email: email,
        phone: phone,
        type: type,
        outstandingDue: outstandingDue,
      );
      notifyListeners();
    }
  }
}
