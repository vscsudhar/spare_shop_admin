import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/app/app.router.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
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

  Future<dynamic>? goToReturnsExchanges() {
    return navigationService.navigateTo(Routes.adminReturnsListView);
  }

  Future<dynamic>? goToNewReturn({String? prefillBill}) {
    return navigationService.navigateTo(
      Routes.adminNewReturnView,
      arguments: AdminNewReturnViewArguments(prefillBill: prefillBill),
    );
  }

  Future<dynamic>? goToReturnDetail({required String caseId}) {
    return navigationService.navigateTo(
      Routes.adminReturnDetailView,
      arguments: AdminReturnDetailViewArguments(caseId: caseId),
    );
  }

  Future<dynamic>? goToAdminDamagedProducts() {
    return navigationService.navigateTo(Routes.adminDamagedProductsView);
  }

  Future<dynamic>? goToAdminCategories() {
    return navigationService.navigateTo(Routes.adminCategoriesView);
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

  Future<dynamic>? goToAdminSuggestions() {
    return navigationService.navigateTo(Routes.adminSuggestionsView);
  }

  Future<dynamic>? goToAdminSupportTickets() {
    return navigationService.navigateTo(Routes.adminSupportTicketsView);
  }

  Future<dynamic>? goToAdminTicketChat({required String ticketId}) {
    return navigationService.navigateTo(
      Routes.adminTicketChatView,
      arguments: AdminTicketChatViewArguments(ticketId: ticketId),
    );
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

  Future<dynamic>? goToAdminLocations() {
    return navigationService.navigateTo(Routes.adminLocationsView);
  }

  Future<dynamic>? goToAdminLocationForm() {
    return navigationService.navigateTo(Routes.adminLocationFormView);
  }

  Future<dynamic>? goToEditAdminLocation({
    required String locationId,
  }) {
    return navigationService.navigateTo(
      Routes.adminLocationFormView,
      arguments: AdminLocationFormViewArguments(locationId: locationId),
    );
  }

  Future<dynamic>? goToAdminLocationInventory({
    required String locationId,
    LocationModel? location,
  }) {
    return navigationService.navigateTo(
      Routes.adminLocationInventoryView,
      arguments: AdminLocationInventoryViewArguments(
        locationId: locationId,
        location: location,
      ),
    );
  }

  Future<dynamic>? goToAdminDeliveryCharges() {
    return navigationService.navigateTo(Routes.adminDeliveryChargesView);
  }

  Future<dynamic>? goToAdminForgotPassword() {
    return navigationService.navigateTo(Routes.adminForgotPasswordView);
  }
}
