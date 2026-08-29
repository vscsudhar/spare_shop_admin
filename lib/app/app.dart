import 'package:spare_shop_admin/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:spare_shop_admin/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:spare_shop_admin/ui/views/home/home_view.dart';
import 'package:spare_shop_admin/ui/views/startup/startup_view.dart';
import 'package:spare_shop_admin/ui/views/admin_dashboard/admin_dashboard_view.dart';
import 'package:spare_shop_admin/ui/views/admin_orders/admin_orders_view.dart';
import 'package:spare_shop_admin/ui/views/admin_order_detail/admin_order_detail_view.dart';
import 'package:spare_shop_admin/ui/views/admin_products/admin_products_view.dart';
import 'package:spare_shop_admin/ui/views/admin_inventory/admin_inventory_view.dart';
import 'package:spare_shop_admin/ui/views/admin_purchases/admin_purchases_view.dart';
import 'package:spare_shop_admin/ui/views/admin_customers/admin_customers_view.dart';
import 'package:spare_shop_admin/ui/views/admin_billing/admin_billing_view.dart';
import 'package:spare_shop_admin/ui/views/admin_reports/admin_reports_view.dart';
import 'package:spare_shop_admin/ui/views/admin_staff_roles/admin_staff_roles_view.dart';
import 'package:spare_shop_admin/ui/views/admin_rare_requests/admin_rare_requests_view.dart';
import 'package:spare_shop_admin/ui/views/admin_rare_request_chat/admin_rare_request_chat_view.dart';
import 'package:spare_shop_admin/ui/views/admin_create_quotation/admin_create_quotation_view.dart';
import 'package:spare_shop_admin/ui/views/admin_approved_request/admin_approved_request_view.dart';
import 'package:spare_shop_admin/ui/views/admin_cancelled_request/admin_cancelled_request_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import 'package:spare_shop_admin/ui/views/admin_login/admin_login_view.dart';
import 'package:spare_shop_admin/ui/views/admin_suppliers/admin_suppliers_view.dart';
import 'package:spare_shop_admin/ui/views/admin_supplier_detail/admin_supplier_detail_view.dart';
import 'package:spare_shop_admin/ui/views/admin_supplier_form/admin_supplier_form_view.dart';
import 'package:spare_shop_admin/ui/views/admin_settings/admin_settings_view.dart';
import 'package:spare_shop_admin/core/theme/theme_service.dart';
import 'package:spare_shop_admin/core/services/rare_request_mock_service.dart';
import 'package:spare_shop_admin/core/services/token_service.dart';
import 'package:spare_shop_admin/core/services/api_client.dart';
import 'package:spare_shop_admin/core/services/upload_service.dart';
import 'package:spare_shop_admin/core/services/socket_service.dart';
import 'package:spare_shop_admin/core/services/network_info_service.dart';
import 'package:spare_shop_admin/core/services/auth_service.dart';
import 'package:spare_shop_admin/core/services/product_service.dart';
import 'package:spare_shop_admin/core/services/cart_service.dart';
import 'package:spare_shop_admin/core/services/wishlist_service.dart';
import 'package:spare_shop_admin/core/services/address_service.dart';
import 'package:spare_shop_admin/core/services/order_service.dart';
import 'package:spare_shop_admin/core/services/rare_request_service.dart';
import 'package:spare_shop_admin/core/services/admin_dashboard_service.dart';
import 'package:spare_shop_admin/core/services/admin_supplier_service.dart';
import 'package:spare_shop_admin/core/services/admin_purchase_service.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: StartupView, initial: true),
    MaterialRoute(page: HomeView),
    MaterialRoute(page: AdminDashboardView),
    MaterialRoute(page: AdminOrdersView),
    MaterialRoute(page: AdminOrderDetailView),
    MaterialRoute(page: AdminProductsView),
    MaterialRoute(page: AdminInventoryView),
    MaterialRoute(page: AdminPurchasesView),
    MaterialRoute(page: AdminCustomersView),
    MaterialRoute(page: AdminBillingView),
    MaterialRoute(page: AdminReportsView),
    MaterialRoute(page: AdminStaffRolesView),
    MaterialRoute(page: AdminRareRequestsView),
    MaterialRoute(page: AdminRareRequestChatView),
    MaterialRoute(page: AdminCreateQuotationView),
    MaterialRoute(page: AdminApprovedRequestView),
    MaterialRoute(page: AdminCancelledRequestView),
    MaterialRoute(page: AdminLoginView),
    MaterialRoute(page: AdminSuppliersView),
    MaterialRoute(page: AdminSupplierDetailView),
    MaterialRoute(page: AdminSupplierFormView),
    MaterialRoute(page: AdminSettingsView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: ThemeService),
    LazySingleton(classType: RareRequestMockService),
    LazySingleton(classType: TokenService),
    LazySingleton(classType: ApiClient),
    LazySingleton(classType: UploadService),
    LazySingleton(classType: SocketService),
    LazySingleton(classType: NetworkInfoService),
    LazySingleton(classType: AuthService),
    LazySingleton(classType: ProductService),
    LazySingleton(classType: CartService),
    LazySingleton(classType: WishlistService),
    LazySingleton(classType: AddressService),
    LazySingleton(classType: OrderService),
    LazySingleton(classType: RareRequestService),
    LazySingleton(classType: AdminDashboardService),
    LazySingleton(classType: AdminSupplierService),
    LazySingleton(classType: AdminPurchaseService),
    // @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}
