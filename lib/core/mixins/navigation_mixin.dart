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
    return navigationService.replaceWith(Routes.adminDashboardView);
  }

  Future<dynamic>? replaceWithAdminDashboard() {
    return navigationService.replaceWith(Routes.adminDashboardView);
  }

  Future<dynamic>? goToAdminOrders() {
    return navigationService.replaceWith(Routes.adminOrdersView);
  }

  Future<dynamic>? goToAdminDeliveryManagement() {
    return navigationService.replaceWith(Routes.adminDeliveryManagementView);
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
    return navigationService.replaceWith(Routes.adminReturnsListView);
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
    return navigationService.replaceWith(Routes.adminDamagedProductsView);
  }

  Future<dynamic>? goToAdminCategories() {
    return navigationService.replaceWith(Routes.adminCategoriesView);
  }

  Future<dynamic>? goToAdminProducts() {
    return navigationService.replaceWith(Routes.adminProductsView);
  }

  Future<dynamic>? goToAdminBulkProductSell() {
    return navigationService.replaceWith(Routes.adminBulkProductSellView);
  }

  Future<dynamic>? goToAdminInventory() {
    return navigationService.replaceWith(Routes.adminInventoryView);
  }

  Future<dynamic>? goToAdminPurchases() {
    return navigationService.replaceWith(Routes.adminPurchasesView);
  }

  Future<dynamic>? goToAdminCustomers() {
    return navigationService.replaceWith(Routes.adminCustomersView);
  }

  Future<dynamic>? goToAdminBilling() {
    return navigationService.replaceWith(Routes.adminBillingView);
  }

  Future<dynamic>? goToAdminReports() {
    return navigationService.replaceWith(Routes.adminReportsView);
  }

  Future<dynamic>? goToAdminStaffRoles() {
    return navigationService.replaceWith(Routes.adminStaffRolesView);
  }

  Future<dynamic>? goToAdminSuggestions() {
    return navigationService.replaceWith(Routes.adminSuggestionsView);
  }

  Future<dynamic>? goToAdminEnquiries() {
    return navigationService.replaceWith(Routes.adminEnquiriesView);
  }

  Future<dynamic>? goToAdminSupportTickets() {
    return navigationService.replaceWith(Routes.adminSupportTicketsView);
  }

  Future<dynamic>? goToAdminTicketChat({required String ticketId}) {
    return navigationService.navigateTo(
      Routes.adminTicketChatView,
      arguments: AdminTicketChatViewArguments(ticketId: ticketId),
    );
  }

  Future<dynamic>? goToAdminRareRequests() {
    return navigationService.replaceWith(Routes.adminRareRequestsView);
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
    return navigationService.replaceWith(Routes.adminSuppliersView);
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
    return navigationService.navigateTo(
      Routes.adminSupplierFormView,
    );
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
    return navigationService.replaceWith(Routes.adminSettingsView);
  }

  Future<dynamic>? goToAdminLocations() {
    return navigationService.replaceWith(Routes.adminLocationsView);
  }

  Future<dynamic>? goToAdminLocationForm() {
    return navigationService.navigateTo(
      Routes.adminLocationFormView,
    );
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
    return navigationService.replaceWith(Routes.adminDeliveryChargesView);
  }

  Future<dynamic>? goToAdminForgotPassword() {
    return navigationService.navigateTo(Routes.adminForgotPasswordView);
  }
}
