// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart' as _i37;
import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart' as _i39;
import 'package:spare_shop_admin/ui/common/voltspare_models.dart' as _i38;
import 'package:spare_shop_admin/ui/views/admin_approved_request/admin_approved_request_view.dart'
    as _i18;
import 'package:spare_shop_admin/ui/views/admin_billing/admin_billing_view.dart'
    as _i12;
import 'package:spare_shop_admin/ui/views/admin_cancelled_request/admin_cancelled_request_view.dart'
    as _i19;
import 'package:spare_shop_admin/ui/views/admin_categories/admin_categories_view.dart'
    as _i7;
import 'package:spare_shop_admin/ui/views/admin_create_quotation/admin_create_quotation_view.dart'
    as _i17;
import 'package:spare_shop_admin/ui/views/admin_customers/admin_customers_view.dart'
    as _i11;
import 'package:spare_shop_admin/ui/views/admin_damaged_products/admin_damaged_products_view.dart'
    as _i35;
import 'package:spare_shop_admin/ui/views/admin_dashboard/admin_dashboard_view.dart'
    as _i4;
import 'package:spare_shop_admin/ui/views/admin_delivery_charges/admin_delivery_charges_view.dart'
    as _i36;
import 'package:spare_shop_admin/ui/views/admin_forgot_password/admin_forgot_password_view.dart'
    as _i21;
import 'package:spare_shop_admin/ui/views/admin_inventory/admin_inventory_view.dart'
    as _i9;
import 'package:spare_shop_admin/ui/views/admin_locations/admin_location_form_view.dart'
    as _i26;
import 'package:spare_shop_admin/ui/views/admin_locations/admin_location_inventory_view.dart'
    as _i27;
import 'package:spare_shop_admin/ui/views/admin_locations/admin_locations_view.dart'
    as _i25;
import 'package:spare_shop_admin/ui/views/admin_login/admin_login_view.dart'
    as _i20;
import 'package:spare_shop_admin/ui/views/admin_order_detail/admin_order_detail_view.dart'
    as _i6;
import 'package:spare_shop_admin/ui/views/admin_orders/admin_orders_view.dart'
    as _i5;
import 'package:spare_shop_admin/ui/views/admin_products/admin_products_view.dart'
    as _i8;
import 'package:spare_shop_admin/ui/views/admin_purchases/admin_purchases_view.dart'
    as _i10;
import 'package:spare_shop_admin/ui/views/admin_rare_request_chat/admin_rare_request_chat_view.dart'
    as _i16;
import 'package:spare_shop_admin/ui/views/admin_rare_requests/admin_rare_requests_view.dart'
    as _i15;
import 'package:spare_shop_admin/ui/views/admin_reports/admin_reports_view.dart'
    as _i13;
import 'package:spare_shop_admin/ui/views/admin_returns/admin_new_return_view.dart'
    as _i33;
import 'package:spare_shop_admin/ui/views/admin_returns/admin_return_detail_view.dart'
    as _i34;
import 'package:spare_shop_admin/ui/views/admin_returns/admin_returns_list_view.dart'
    as _i32;
import 'package:spare_shop_admin/ui/views/admin_settings/admin_settings_view.dart'
    as _i28;
import 'package:spare_shop_admin/ui/views/admin_staff_roles/admin_staff_roles_view.dart'
    as _i14;
import 'package:spare_shop_admin/ui/views/admin_suggestions/admin_suggestions_view.dart'
    as _i30;
import 'package:spare_shop_admin/ui/views/admin_supplier_detail/admin_supplier_detail_view.dart'
    as _i23;
import 'package:spare_shop_admin/ui/views/admin_supplier_form/admin_supplier_form_view.dart'
    as _i24;
import 'package:spare_shop_admin/ui/views/admin_suppliers/admin_suppliers_view.dart'
    as _i22;
import 'package:spare_shop_admin/ui/views/admin_support_tickets/admin_support_tickets_view.dart'
    as _i29;
import 'package:spare_shop_admin/ui/views/admin_ticket_chat/admin_ticket_chat_view.dart'
    as _i31;
import 'package:spare_shop_admin/ui/views/home/home_view.dart' as _i3;
import 'package:spare_shop_admin/ui/views/startup/startup_view.dart' as _i2;
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i40;

class Routes {
  static const startupView = '/';

  static const homeView = '/home-view';

  static const adminDashboardView = '/admin-dashboard-view';

  static const adminOrdersView = '/admin-orders-view';

  static const adminOrderDetailView = '/admin-order-detail-view';

  static const adminCategoriesView = '/admin-categories-view';

  static const adminProductsView = '/admin-products-view';

  static const adminInventoryView = '/admin-inventory-view';

  static const adminPurchasesView = '/admin-purchases-view';

  static const adminCustomersView = '/admin-customers-view';

  static const adminBillingView = '/admin-billing-view';

  static const adminReportsView = '/admin-reports-view';

  static const adminStaffRolesView = '/admin-staff-roles-view';

  static const adminRareRequestsView = '/admin-rare-requests-view';

  static const adminRareRequestChatView = '/admin-rare-request-chat-view';

  static const adminCreateQuotationView = '/admin-create-quotation-view';

  static const adminApprovedRequestView = '/admin-approved-request-view';

  static const adminCancelledRequestView = '/admin-cancelled-request-view';

  static const adminLoginView = '/admin-login-view';

  static const adminForgotPasswordView = '/admin-forgot-password-view';

  static const adminSuppliersView = '/admin-suppliers-view';

  static const adminSupplierDetailView = '/admin-supplier-detail-view';

  static const adminSupplierFormView = '/admin-supplier-form-view';

  static const adminLocationsView = '/admin-locations-view';

  static const adminLocationFormView = '/admin-location-form-view';

  static const adminLocationInventoryView = '/admin-location-inventory-view';

  static const adminSettingsView = '/admin-settings-view';

  static const adminSupportTicketsView = '/admin-support-tickets-view';

  static const adminSuggestionsView = '/admin-suggestions-view';

  static const adminTicketChatView = '/admin-ticket-chat-view';

  static const adminReturnsListView = '/admin-returns-list-view';

  static const adminNewReturnView = '/admin-new-return-view';

  static const adminReturnDetailView = '/admin-return-detail-view';

  static const adminDamagedProductsView = '/admin-damaged-products-view';

  static const adminDeliveryChargesView = '/admin-delivery-charges-view';

  static const all = <String>{
    startupView,
    homeView,
    adminDashboardView,
    adminOrdersView,
    adminOrderDetailView,
    adminCategoriesView,
    adminProductsView,
    adminInventoryView,
    adminPurchasesView,
    adminCustomersView,
    adminBillingView,
    adminReportsView,
    adminStaffRolesView,
    adminRareRequestsView,
    adminRareRequestChatView,
    adminCreateQuotationView,
    adminApprovedRequestView,
    adminCancelledRequestView,
    adminLoginView,
    adminForgotPasswordView,
    adminSuppliersView,
    adminSupplierDetailView,
    adminSupplierFormView,
    adminLocationsView,
    adminLocationFormView,
    adminLocationInventoryView,
    adminSettingsView,
    adminSupportTicketsView,
    adminSuggestionsView,
    adminTicketChatView,
    adminReturnsListView,
    adminNewReturnView,
    adminReturnDetailView,
    adminDamagedProductsView,
    adminDeliveryChargesView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.startupView,
      page: _i2.StartupView,
    ),
    _i1.RouteDef(
      Routes.homeView,
      page: _i3.HomeView,
    ),
    _i1.RouteDef(
      Routes.adminDashboardView,
      page: _i4.AdminDashboardView,
    ),
    _i1.RouteDef(
      Routes.adminOrdersView,
      page: _i5.AdminOrdersView,
    ),
    _i1.RouteDef(
      Routes.adminOrderDetailView,
      page: _i6.AdminOrderDetailView,
    ),
    _i1.RouteDef(
      Routes.adminCategoriesView,
      page: _i7.AdminCategoriesView,
    ),
    _i1.RouteDef(
      Routes.adminProductsView,
      page: _i8.AdminProductsView,
    ),
    _i1.RouteDef(
      Routes.adminInventoryView,
      page: _i9.AdminInventoryView,
    ),
    _i1.RouteDef(
      Routes.adminPurchasesView,
      page: _i10.AdminPurchasesView,
    ),
    _i1.RouteDef(
      Routes.adminCustomersView,
      page: _i11.AdminCustomersView,
    ),
    _i1.RouteDef(
      Routes.adminBillingView,
      page: _i12.AdminBillingView,
    ),
    _i1.RouteDef(
      Routes.adminReportsView,
      page: _i13.AdminReportsView,
    ),
    _i1.RouteDef(
      Routes.adminStaffRolesView,
      page: _i14.AdminStaffRolesView,
    ),
    _i1.RouteDef(
      Routes.adminRareRequestsView,
      page: _i15.AdminRareRequestsView,
    ),
    _i1.RouteDef(
      Routes.adminRareRequestChatView,
      page: _i16.AdminRareRequestChatView,
    ),
    _i1.RouteDef(
      Routes.adminCreateQuotationView,
      page: _i17.AdminCreateQuotationView,
    ),
    _i1.RouteDef(
      Routes.adminApprovedRequestView,
      page: _i18.AdminApprovedRequestView,
    ),
    _i1.RouteDef(
      Routes.adminCancelledRequestView,
      page: _i19.AdminCancelledRequestView,
    ),
    _i1.RouteDef(
      Routes.adminLoginView,
      page: _i20.AdminLoginView,
    ),
    _i1.RouteDef(
      Routes.adminForgotPasswordView,
      page: _i21.AdminForgotPasswordView,
    ),
    _i1.RouteDef(
      Routes.adminSuppliersView,
      page: _i22.AdminSuppliersView,
    ),
    _i1.RouteDef(
      Routes.adminSupplierDetailView,
      page: _i23.AdminSupplierDetailView,
    ),
    _i1.RouteDef(
      Routes.adminSupplierFormView,
      page: _i24.AdminSupplierFormView,
    ),
    _i1.RouteDef(
      Routes.adminLocationsView,
      page: _i25.AdminLocationsView,
    ),
    _i1.RouteDef(
      Routes.adminLocationFormView,
      page: _i26.AdminLocationFormView,
    ),
    _i1.RouteDef(
      Routes.adminLocationInventoryView,
      page: _i27.AdminLocationInventoryView,
    ),
    _i1.RouteDef(
      Routes.adminSettingsView,
      page: _i28.AdminSettingsView,
    ),
    _i1.RouteDef(
      Routes.adminSupportTicketsView,
      page: _i29.AdminSupportTicketsView,
    ),
    _i1.RouteDef(
      Routes.adminSuggestionsView,
      page: _i30.AdminSuggestionsView,
    ),
    _i1.RouteDef(
      Routes.adminTicketChatView,
      page: _i31.AdminTicketChatView,
    ),
    _i1.RouteDef(
      Routes.adminReturnsListView,
      page: _i32.AdminReturnsListView,
    ),
    _i1.RouteDef(
      Routes.adminNewReturnView,
      page: _i33.AdminNewReturnView,
    ),
    _i1.RouteDef(
      Routes.adminReturnDetailView,
      page: _i34.AdminReturnDetailView,
    ),
    _i1.RouteDef(
      Routes.adminDamagedProductsView,
      page: _i35.AdminDamagedProductsView,
    ),
    _i1.RouteDef(
      Routes.adminDeliveryChargesView,
      page: _i36.AdminDeliveryChargesView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.StartupView: (data) {
      final args = data.getArgs<StartupViewArguments>(
        orElse: () => const StartupViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i2.StartupView(key: args.key),
        settings: data,
      );
    },
    _i3.HomeView: (data) {
      final args = data.getArgs<HomeViewArguments>(
        orElse: () => const HomeViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i3.HomeView(key: args.key),
        settings: data,
      );
    },
    _i4.AdminDashboardView: (data) {
      final args = data.getArgs<AdminDashboardViewArguments>(
        orElse: () => const AdminDashboardViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i4.AdminDashboardView(key: args.key),
        settings: data,
      );
    },
    _i5.AdminOrdersView: (data) {
      final args = data.getArgs<AdminOrdersViewArguments>(
        orElse: () => const AdminOrdersViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i5.AdminOrdersView(key: args.key),
        settings: data,
      );
    },
    _i6.AdminOrderDetailView: (data) {
      final args = data.getArgs<AdminOrderDetailViewArguments>(
        orElse: () => const AdminOrderDetailViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i6.AdminOrderDetailView(key: args.key, order: args.order),
        settings: data,
      );
    },
    _i7.AdminCategoriesView: (data) {
      final args = data.getArgs<AdminCategoriesViewArguments>(
        orElse: () => const AdminCategoriesViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i7.AdminCategoriesView(key: args.key),
        settings: data,
      );
    },
    _i8.AdminProductsView: (data) {
      final args = data.getArgs<AdminProductsViewArguments>(
        orElse: () => const AdminProductsViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i8.AdminProductsView(key: args.key),
        settings: data,
      );
    },
    _i9.AdminInventoryView: (data) {
      final args = data.getArgs<AdminInventoryViewArguments>(
        orElse: () => const AdminInventoryViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i9.AdminInventoryView(key: args.key),
        settings: data,
      );
    },
    _i10.AdminPurchasesView: (data) {
      final args = data.getArgs<AdminPurchasesViewArguments>(
        orElse: () => const AdminPurchasesViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i10.AdminPurchasesView(key: args.key),
        settings: data,
      );
    },
    _i11.AdminCustomersView: (data) {
      final args = data.getArgs<AdminCustomersViewArguments>(
        orElse: () => const AdminCustomersViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i11.AdminCustomersView(key: args.key),
        settings: data,
      );
    },
    _i12.AdminBillingView: (data) {
      final args = data.getArgs<AdminBillingViewArguments>(
        orElse: () => const AdminBillingViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i12.AdminBillingView(key: args.key),
        settings: data,
      );
    },
    _i13.AdminReportsView: (data) {
      final args = data.getArgs<AdminReportsViewArguments>(
        orElse: () => const AdminReportsViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i13.AdminReportsView(key: args.key),
        settings: data,
      );
    },
    _i14.AdminStaffRolesView: (data) {
      final args = data.getArgs<AdminStaffRolesViewArguments>(
        orElse: () => const AdminStaffRolesViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i14.AdminStaffRolesView(key: args.key),
        settings: data,
      );
    },
    _i15.AdminRareRequestsView: (data) {
      final args = data.getArgs<AdminRareRequestsViewArguments>(
        orElse: () => const AdminRareRequestsViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i15.AdminRareRequestsView(key: args.key),
        settings: data,
      );
    },
    _i16.AdminRareRequestChatView: (data) {
      final args = data.getArgs<AdminRareRequestChatViewArguments>(
        orElse: () => const AdminRareRequestChatViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i16.AdminRareRequestChatView(
            key: args.key, requestId: args.requestId),
        settings: data,
      );
    },
    _i17.AdminCreateQuotationView: (data) {
      final args =
          data.getArgs<AdminCreateQuotationViewArguments>(nullOk: false);
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i17.AdminCreateQuotationView(
            key: args.key, requestId: args.requestId),
        settings: data,
      );
    },
    _i18.AdminApprovedRequestView: (data) {
      final args =
          data.getArgs<AdminApprovedRequestViewArguments>(nullOk: false);
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i18.AdminApprovedRequestView(
            key: args.key, requestId: args.requestId),
        settings: data,
      );
    },
    _i19.AdminCancelledRequestView: (data) {
      final args =
          data.getArgs<AdminCancelledRequestViewArguments>(nullOk: false);
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i19.AdminCancelledRequestView(
            key: args.key, requestId: args.requestId),
        settings: data,
      );
    },
    _i20.AdminLoginView: (data) {
      final args = data.getArgs<AdminLoginViewArguments>(
        orElse: () => const AdminLoginViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i20.AdminLoginView(key: args.key),
        settings: data,
      );
    },
    _i21.AdminForgotPasswordView: (data) {
      final args = data.getArgs<AdminForgotPasswordViewArguments>(
        orElse: () => const AdminForgotPasswordViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i21.AdminForgotPasswordView(key: args.key),
        settings: data,
      );
    },
    _i22.AdminSuppliersView: (data) {
      final args = data.getArgs<AdminSuppliersViewArguments>(
        orElse: () => const AdminSuppliersViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i22.AdminSuppliersView(key: args.key),
        settings: data,
      );
    },
    _i23.AdminSupplierDetailView: (data) {
      final args =
          data.getArgs<AdminSupplierDetailViewArguments>(nullOk: false);
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i23.AdminSupplierDetailView(
            key: args.key, supplierId: args.supplierId),
        settings: data,
      );
    },
    _i24.AdminSupplierFormView: (data) {
      final args = data.getArgs<AdminSupplierFormViewArguments>(
        orElse: () => const AdminSupplierFormViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i24.AdminSupplierFormView(
            key: args.key, supplierId: args.supplierId),
        settings: data,
      );
    },
    _i25.AdminLocationsView: (data) {
      final args = data.getArgs<AdminLocationsViewArguments>(
        orElse: () => const AdminLocationsViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i25.AdminLocationsView(key: args.key),
        settings: data,
      );
    },
    _i26.AdminLocationFormView: (data) {
      final args = data.getArgs<AdminLocationFormViewArguments>(
        orElse: () => const AdminLocationFormViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i26.AdminLocationFormView(
            key: args.key, locationId: args.locationId),
        settings: data,
      );
    },
    _i27.AdminLocationInventoryView: (data) {
      final args = data.getArgs<AdminLocationInventoryViewArguments>(
        orElse: () => const AdminLocationInventoryViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i27.AdminLocationInventoryView(
            key: args.key,
            locationId: args.locationId,
            location: args.location),
        settings: data,
      );
    },
    _i28.AdminSettingsView: (data) {
      final args = data.getArgs<AdminSettingsViewArguments>(
        orElse: () => const AdminSettingsViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i28.AdminSettingsView(key: args.key),
        settings: data,
      );
    },
    _i29.AdminSupportTicketsView: (data) {
      final args = data.getArgs<AdminSupportTicketsViewArguments>(
        orElse: () => const AdminSupportTicketsViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i29.AdminSupportTicketsView(key: args.key),
        settings: data,
      );
    },
    _i30.AdminSuggestionsView: (data) {
      final args = data.getArgs<AdminSuggestionsViewArguments>(
        orElse: () => const AdminSuggestionsViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i30.AdminSuggestionsView(key: args.key),
        settings: data,
      );
    },
    _i31.AdminTicketChatView: (data) {
      final args = data.getArgs<AdminTicketChatViewArguments>(
        orElse: () => const AdminTicketChatViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i31.AdminTicketChatView(key: args.key, ticketId: args.ticketId),
        settings: data,
      );
    },
    _i32.AdminReturnsListView: (data) {
      final args = data.getArgs<AdminReturnsListViewArguments>(
        orElse: () => const AdminReturnsListViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i32.AdminReturnsListView(key: args.key),
        settings: data,
      );
    },
    _i33.AdminNewReturnView: (data) {
      final args = data.getArgs<AdminNewReturnViewArguments>(
        orElse: () => const AdminNewReturnViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i33.AdminNewReturnView(
            key: args.key, prefillBill: args.prefillBill),
        settings: data,
      );
    },
    _i34.AdminReturnDetailView: (data) {
      final args = data.getArgs<AdminReturnDetailViewArguments>(nullOk: false);
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i34.AdminReturnDetailView(key: args.key, caseId: args.caseId),
        settings: data,
      );
    },
    _i35.AdminDamagedProductsView: (data) {
      final args = data.getArgs<AdminDamagedProductsViewArguments>(
        orElse: () => const AdminDamagedProductsViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i35.AdminDamagedProductsView(key: args.key),
        settings: data,
      );
    },
    _i36.AdminDeliveryChargesView: (data) {
      final args = data.getArgs<AdminDeliveryChargesViewArguments>(
        orElse: () => const AdminDeliveryChargesViewArguments(),
      );
      return _i37.MaterialPageRoute<dynamic>(
        builder: (context) => _i36.AdminDeliveryChargesView(key: args.key),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class StartupViewArguments {
  const StartupViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant StartupViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class HomeViewArguments {
  const HomeViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant HomeViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminDashboardViewArguments {
  const AdminDashboardViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminDashboardViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminOrdersViewArguments {
  const AdminOrdersViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminOrdersViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminOrderDetailViewArguments {
  const AdminOrderDetailViewArguments({
    this.key,
    this.order,
  });

  final _i37.Key? key;

  final _i38.OrderModel? order;

  @override
  String toString() {
    return '{"key": "$key", "order": "$order"}';
  }

  @override
  bool operator ==(covariant AdminOrderDetailViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.order == order;
  }

  @override
  int get hashCode {
    return key.hashCode ^ order.hashCode;
  }
}

class AdminCategoriesViewArguments {
  const AdminCategoriesViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminCategoriesViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminProductsViewArguments {
  const AdminProductsViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminProductsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminInventoryViewArguments {
  const AdminInventoryViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminInventoryViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminPurchasesViewArguments {
  const AdminPurchasesViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminPurchasesViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminCustomersViewArguments {
  const AdminCustomersViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminCustomersViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminBillingViewArguments {
  const AdminBillingViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminBillingViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminReportsViewArguments {
  const AdminReportsViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminReportsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminStaffRolesViewArguments {
  const AdminStaffRolesViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminStaffRolesViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminRareRequestsViewArguments {
  const AdminRareRequestsViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminRareRequestsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminRareRequestChatViewArguments {
  const AdminRareRequestChatViewArguments({
    this.key,
    this.requestId = '',
  });

  final _i37.Key? key;

  final String requestId;

  @override
  String toString() {
    return '{"key": "$key", "requestId": "$requestId"}';
  }

  @override
  bool operator ==(covariant AdminRareRequestChatViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.requestId == requestId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ requestId.hashCode;
  }
}

class AdminCreateQuotationViewArguments {
  const AdminCreateQuotationViewArguments({
    this.key,
    required this.requestId,
  });

  final _i37.Key? key;

  final String requestId;

  @override
  String toString() {
    return '{"key": "$key", "requestId": "$requestId"}';
  }

  @override
  bool operator ==(covariant AdminCreateQuotationViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.requestId == requestId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ requestId.hashCode;
  }
}

class AdminApprovedRequestViewArguments {
  const AdminApprovedRequestViewArguments({
    this.key,
    required this.requestId,
  });

  final _i37.Key? key;

  final String requestId;

  @override
  String toString() {
    return '{"key": "$key", "requestId": "$requestId"}';
  }

  @override
  bool operator ==(covariant AdminApprovedRequestViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.requestId == requestId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ requestId.hashCode;
  }
}

class AdminCancelledRequestViewArguments {
  const AdminCancelledRequestViewArguments({
    this.key,
    required this.requestId,
  });

  final _i37.Key? key;

  final String requestId;

  @override
  String toString() {
    return '{"key": "$key", "requestId": "$requestId"}';
  }

  @override
  bool operator ==(covariant AdminCancelledRequestViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.requestId == requestId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ requestId.hashCode;
  }
}

class AdminLoginViewArguments {
  const AdminLoginViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminLoginViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminForgotPasswordViewArguments {
  const AdminForgotPasswordViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminForgotPasswordViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminSuppliersViewArguments {
  const AdminSuppliersViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminSuppliersViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminSupplierDetailViewArguments {
  const AdminSupplierDetailViewArguments({
    this.key,
    required this.supplierId,
  });

  final _i37.Key? key;

  final String supplierId;

  @override
  String toString() {
    return '{"key": "$key", "supplierId": "$supplierId"}';
  }

  @override
  bool operator ==(covariant AdminSupplierDetailViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.supplierId == supplierId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ supplierId.hashCode;
  }
}

class AdminSupplierFormViewArguments {
  const AdminSupplierFormViewArguments({
    this.key,
    this.supplierId,
  });

  final _i37.Key? key;

  final String? supplierId;

  @override
  String toString() {
    return '{"key": "$key", "supplierId": "$supplierId"}';
  }

  @override
  bool operator ==(covariant AdminSupplierFormViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.supplierId == supplierId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ supplierId.hashCode;
  }
}

class AdminLocationsViewArguments {
  const AdminLocationsViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminLocationsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminLocationFormViewArguments {
  const AdminLocationFormViewArguments({
    this.key,
    this.locationId,
  });

  final _i37.Key? key;

  final String? locationId;

  @override
  String toString() {
    return '{"key": "$key", "locationId": "$locationId"}';
  }

  @override
  bool operator ==(covariant AdminLocationFormViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.locationId == locationId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ locationId.hashCode;
  }
}

class AdminLocationInventoryViewArguments {
  const AdminLocationInventoryViewArguments({
    this.key,
    this.locationId,
    this.location,
  });

  final _i37.Key? key;

  final String? locationId;

  final _i39.LocationModel? location;

  @override
  String toString() {
    return '{"key": "$key", "locationId": "$locationId", "location": "$location"}';
  }

  @override
  bool operator ==(covariant AdminLocationInventoryViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.locationId == locationId &&
        other.location == location;
  }

  @override
  int get hashCode {
    return key.hashCode ^ locationId.hashCode ^ location.hashCode;
  }
}

class AdminSettingsViewArguments {
  const AdminSettingsViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminSettingsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminSupportTicketsViewArguments {
  const AdminSupportTicketsViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminSupportTicketsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminSuggestionsViewArguments {
  const AdminSuggestionsViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminSuggestionsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminTicketChatViewArguments {
  const AdminTicketChatViewArguments({
    this.key,
    this.ticketId = '',
  });

  final _i37.Key? key;

  final String ticketId;

  @override
  String toString() {
    return '{"key": "$key", "ticketId": "$ticketId"}';
  }

  @override
  bool operator ==(covariant AdminTicketChatViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.ticketId == ticketId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ ticketId.hashCode;
  }
}

class AdminReturnsListViewArguments {
  const AdminReturnsListViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminReturnsListViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminNewReturnViewArguments {
  const AdminNewReturnViewArguments({
    this.key,
    this.prefillBill,
  });

  final _i37.Key? key;

  final String? prefillBill;

  @override
  String toString() {
    return '{"key": "$key", "prefillBill": "$prefillBill"}';
  }

  @override
  bool operator ==(covariant AdminNewReturnViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.prefillBill == prefillBill;
  }

  @override
  int get hashCode {
    return key.hashCode ^ prefillBill.hashCode;
  }
}

class AdminReturnDetailViewArguments {
  const AdminReturnDetailViewArguments({
    this.key,
    required this.caseId,
  });

  final _i37.Key? key;

  final String caseId;

  @override
  String toString() {
    return '{"key": "$key", "caseId": "$caseId"}';
  }

  @override
  bool operator ==(covariant AdminReturnDetailViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.caseId == caseId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ caseId.hashCode;
  }
}

class AdminDamagedProductsViewArguments {
  const AdminDamagedProductsViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminDamagedProductsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AdminDeliveryChargesViewArguments {
  const AdminDeliveryChargesViewArguments({this.key});

  final _i37.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AdminDeliveryChargesViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

extension NavigatorStateExtension on _i40.NavigationService {
  Future<dynamic> navigateToStartupView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.startupView,
        arguments: StartupViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToHomeView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.homeView,
        arguments: HomeViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminDashboardView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminDashboardView,
        arguments: AdminDashboardViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminOrdersView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminOrdersView,
        arguments: AdminOrdersViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminOrderDetailView({
    _i37.Key? key,
    _i38.OrderModel? order,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminOrderDetailView,
        arguments: AdminOrderDetailViewArguments(key: key, order: order),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminCategoriesView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminCategoriesView,
        arguments: AdminCategoriesViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminProductsView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminProductsView,
        arguments: AdminProductsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminInventoryView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminInventoryView,
        arguments: AdminInventoryViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminPurchasesView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminPurchasesView,
        arguments: AdminPurchasesViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminCustomersView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminCustomersView,
        arguments: AdminCustomersViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminBillingView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminBillingView,
        arguments: AdminBillingViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminReportsView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminReportsView,
        arguments: AdminReportsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminStaffRolesView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminStaffRolesView,
        arguments: AdminStaffRolesViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminRareRequestsView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminRareRequestsView,
        arguments: AdminRareRequestsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminRareRequestChatView({
    _i37.Key? key,
    String requestId = '',
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminRareRequestChatView,
        arguments:
            AdminRareRequestChatViewArguments(key: key, requestId: requestId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminCreateQuotationView({
    _i37.Key? key,
    required String requestId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminCreateQuotationView,
        arguments:
            AdminCreateQuotationViewArguments(key: key, requestId: requestId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminApprovedRequestView({
    _i37.Key? key,
    required String requestId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminApprovedRequestView,
        arguments:
            AdminApprovedRequestViewArguments(key: key, requestId: requestId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminCancelledRequestView({
    _i37.Key? key,
    required String requestId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminCancelledRequestView,
        arguments:
            AdminCancelledRequestViewArguments(key: key, requestId: requestId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminLoginView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminLoginView,
        arguments: AdminLoginViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminForgotPasswordView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminForgotPasswordView,
        arguments: AdminForgotPasswordViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminSuppliersView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminSuppliersView,
        arguments: AdminSuppliersViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminSupplierDetailView({
    _i37.Key? key,
    required String supplierId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminSupplierDetailView,
        arguments:
            AdminSupplierDetailViewArguments(key: key, supplierId: supplierId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminSupplierFormView({
    _i37.Key? key,
    String? supplierId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminSupplierFormView,
        arguments:
            AdminSupplierFormViewArguments(key: key, supplierId: supplierId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminLocationsView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminLocationsView,
        arguments: AdminLocationsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminLocationFormView({
    _i37.Key? key,
    String? locationId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminLocationFormView,
        arguments:
            AdminLocationFormViewArguments(key: key, locationId: locationId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminLocationInventoryView({
    _i37.Key? key,
    String? locationId,
    _i39.LocationModel? location,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminLocationInventoryView,
        arguments: AdminLocationInventoryViewArguments(
            key: key, locationId: locationId, location: location),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminSettingsView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminSettingsView,
        arguments: AdminSettingsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminSupportTicketsView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminSupportTicketsView,
        arguments: AdminSupportTicketsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminSuggestionsView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminSuggestionsView,
        arguments: AdminSuggestionsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminTicketChatView({
    _i37.Key? key,
    String ticketId = '',
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminTicketChatView,
        arguments: AdminTicketChatViewArguments(key: key, ticketId: ticketId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminReturnsListView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminReturnsListView,
        arguments: AdminReturnsListViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminNewReturnView({
    _i37.Key? key,
    String? prefillBill,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminNewReturnView,
        arguments:
            AdminNewReturnViewArguments(key: key, prefillBill: prefillBill),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminReturnDetailView({
    _i37.Key? key,
    required String caseId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminReturnDetailView,
        arguments: AdminReturnDetailViewArguments(key: key, caseId: caseId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminDamagedProductsView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminDamagedProductsView,
        arguments: AdminDamagedProductsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAdminDeliveryChargesView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.adminDeliveryChargesView,
        arguments: AdminDeliveryChargesViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStartupView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.startupView,
        arguments: StartupViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.homeView,
        arguments: HomeViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminDashboardView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminDashboardView,
        arguments: AdminDashboardViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminOrdersView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminOrdersView,
        arguments: AdminOrdersViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminOrderDetailView({
    _i37.Key? key,
    _i38.OrderModel? order,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminOrderDetailView,
        arguments: AdminOrderDetailViewArguments(key: key, order: order),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminCategoriesView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminCategoriesView,
        arguments: AdminCategoriesViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminProductsView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminProductsView,
        arguments: AdminProductsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminInventoryView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminInventoryView,
        arguments: AdminInventoryViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminPurchasesView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminPurchasesView,
        arguments: AdminPurchasesViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminCustomersView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminCustomersView,
        arguments: AdminCustomersViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminBillingView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminBillingView,
        arguments: AdminBillingViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminReportsView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminReportsView,
        arguments: AdminReportsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminStaffRolesView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminStaffRolesView,
        arguments: AdminStaffRolesViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminRareRequestsView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminRareRequestsView,
        arguments: AdminRareRequestsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminRareRequestChatView({
    _i37.Key? key,
    String requestId = '',
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminRareRequestChatView,
        arguments:
            AdminRareRequestChatViewArguments(key: key, requestId: requestId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminCreateQuotationView({
    _i37.Key? key,
    required String requestId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminCreateQuotationView,
        arguments:
            AdminCreateQuotationViewArguments(key: key, requestId: requestId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminApprovedRequestView({
    _i37.Key? key,
    required String requestId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminApprovedRequestView,
        arguments:
            AdminApprovedRequestViewArguments(key: key, requestId: requestId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminCancelledRequestView({
    _i37.Key? key,
    required String requestId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminCancelledRequestView,
        arguments:
            AdminCancelledRequestViewArguments(key: key, requestId: requestId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminLoginView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminLoginView,
        arguments: AdminLoginViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminForgotPasswordView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminForgotPasswordView,
        arguments: AdminForgotPasswordViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminSuppliersView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminSuppliersView,
        arguments: AdminSuppliersViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminSupplierDetailView({
    _i37.Key? key,
    required String supplierId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminSupplierDetailView,
        arguments:
            AdminSupplierDetailViewArguments(key: key, supplierId: supplierId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminSupplierFormView({
    _i37.Key? key,
    String? supplierId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminSupplierFormView,
        arguments:
            AdminSupplierFormViewArguments(key: key, supplierId: supplierId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminLocationsView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminLocationsView,
        arguments: AdminLocationsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminLocationFormView({
    _i37.Key? key,
    String? locationId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminLocationFormView,
        arguments:
            AdminLocationFormViewArguments(key: key, locationId: locationId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminLocationInventoryView({
    _i37.Key? key,
    String? locationId,
    _i39.LocationModel? location,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminLocationInventoryView,
        arguments: AdminLocationInventoryViewArguments(
            key: key, locationId: locationId, location: location),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminSettingsView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminSettingsView,
        arguments: AdminSettingsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminSupportTicketsView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminSupportTicketsView,
        arguments: AdminSupportTicketsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminSuggestionsView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminSuggestionsView,
        arguments: AdminSuggestionsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminTicketChatView({
    _i37.Key? key,
    String ticketId = '',
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminTicketChatView,
        arguments: AdminTicketChatViewArguments(key: key, ticketId: ticketId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminReturnsListView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminReturnsListView,
        arguments: AdminReturnsListViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminNewReturnView({
    _i37.Key? key,
    String? prefillBill,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminNewReturnView,
        arguments:
            AdminNewReturnViewArguments(key: key, prefillBill: prefillBill),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminReturnDetailView({
    _i37.Key? key,
    required String caseId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminReturnDetailView,
        arguments: AdminReturnDetailViewArguments(key: key, caseId: caseId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminDamagedProductsView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminDamagedProductsView,
        arguments: AdminDamagedProductsViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAdminDeliveryChargesView({
    _i37.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.adminDeliveryChargesView,
        arguments: AdminDeliveryChargesViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
