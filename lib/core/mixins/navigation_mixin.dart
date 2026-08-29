import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

mixin NavigationMixin {
  final NavigationService navigationService = locator<NavigationService>();

  void goBack() {
    navigationService.back();
  }

  void goToAdminLogin() {
    navigationService.clearStackAndShow(Routes.adminLoginView);
  }

  Future<dynamic>? goToAdminDashboard() {
    return navigationService.navigateTo(Routes.adminDashboardView);
  }

  Future<dynamic>? replaceWithAdminDashboard() {
    return navigationService.replaceWith(Routes.adminDashboardView);
  }

  Future<dynamic>? goToAdminOrders() {
    return navigationService.navigateTo(Routes.adminOrdersView);
  }

  Future<dynamic>? goToAdminOrderDetail({
    required dynamic order,
  }) {
    return navigationService.navigateTo(
      Routes.adminOrderDetailView,
      arguments: AdminOrderDetailViewArguments(order: order),
    );
  }

  Future<dynamic>? goToAdminProducts() {
    return navigationService.navigateTo(Routes.adminProductsView);
  }

  Future<dynamic>? goToAdminInventory() {
    return navigationService.navigateTo(Routes.adminInventoryView);
  }

  Future<dynamic>? goToAdminPurchases() {
    return navigationService.navigateTo(Routes.adminPurchasesView);
  }

  Future<dynamic>? goToAdminCustomers() {
    return navigationService.navigateTo(Routes.adminCustomersView);
  }

  Future<dynamic>? goToAdminBilling() {
    return navigationService.navigateTo(Routes.adminBillingView);
  }

  Future<dynamic>? goToAdminReports() {
    return navigationService.navigateTo(Routes.adminReportsView);
  }

  Future<dynamic>? goToAdminStaffRoles() {
    return navigationService.navigateTo(Routes.adminStaffRolesView);
  }

  Future<dynamic>? goToAdminRareRequests() {
    return navigationService.navigateTo(Routes.adminRareRequestsView);
  }

  Future<dynamic>? goToAdminRareRequestChat({
    required String requestId,
  }) {
    return navigationService.navigateTo(
      Routes.adminRareRequestChatView,
      arguments: AdminRareRequestChatViewArguments(requestId: requestId),
    );
  }

  Future<dynamic>? goToAdminCreateQuotation({
    required String requestId,
  }) {
    return navigationService.navigateTo(
      Routes.adminCreateQuotationView,
      arguments: AdminCreateQuotationViewArguments(requestId: requestId),
    );
  }

  Future<dynamic>? goToAdminApprovedRequest({
    required String requestId,
  }) {
    return navigationService.navigateTo(
      Routes.adminApprovedRequestView,
      arguments: AdminApprovedRequestViewArguments(requestId: requestId),
    );
  }

  Future<dynamic>? goToAdminCancelledRequest({
    required String requestId,
  }) {
    return navigationService.navigateTo(
      Routes.adminCancelledRequestView,
      arguments: AdminCancelledRequestViewArguments(requestId: requestId),
    );
  }

  Future<dynamic>? goToAdminSuppliers() {
    return navigationService.navigateTo(Routes.adminSuppliersView);
  }

  Future<dynamic>? goToAdminSupplierDetail({
    required String supplierId,
  }) {
    return navigationService.navigateTo(
      Routes.adminSupplierDetailView,
      arguments: AdminSupplierDetailViewArguments(supplierId: supplierId),
    );
  }

  Future<dynamic>? goToAdminSupplierForm() {
    return navigationService.navigateTo(Routes.adminSupplierFormView);
  }

  Future<dynamic>? goToEditAdminSupplier({
    required String supplierId,
  }) {
    return navigationService.navigateTo(
      Routes.adminSupplierFormView,
      arguments: AdminSupplierFormViewArguments(supplierId: supplierId),
    );
  }

  Future<dynamic>? goToAdminSettings() {
    return navigationService.navigateTo(Routes.adminSettingsView);
  }
}
