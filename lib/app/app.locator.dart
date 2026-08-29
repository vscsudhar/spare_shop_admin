// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:stacked_services/src/bottom_sheet/bottom_sheet_service.dart';
import 'package:stacked_services/src/dialog/dialog_service.dart';
import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_shared/stacked_shared.dart';

import '../core/services/address_service.dart';
import '../core/services/admin_dashboard_service.dart';
import '../core/services/admin_purchase_service.dart';
import '../core/services/admin_supplier_service.dart';
import '../core/services/api_client.dart';
import '../core/services/auth_service.dart';
import '../core/services/cart_service.dart';
import '../core/services/network_info_service.dart';
import '../core/services/order_service.dart';
import '../core/services/product_service.dart';
import '../core/services/rare_request_mock_service.dart';
import '../core/services/rare_request_service.dart';
import '../core/services/socket_service.dart';
import '../core/services/token_service.dart';
import '../core/services/upload_service.dart';
import '../core/services/wishlist_service.dart';
import '../core/theme/theme_service.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator(
    {String? environment, EnvironmentFilter? environmentFilter}) async {
// Register environments
  locator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => ThemeService());
  locator.registerLazySingleton(() => RareRequestMockService());
  locator.registerLazySingleton(() => TokenService());
  locator.registerLazySingleton(() => ApiClient());
  locator.registerLazySingleton(() => UploadService());
  locator.registerLazySingleton(() => SocketService());
  locator.registerLazySingleton(() => NetworkInfoService());
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => ProductService());
  locator.registerLazySingleton(() => CartService());
  locator.registerLazySingleton(() => WishlistService());
  locator.registerLazySingleton(() => AddressService());
  locator.registerLazySingleton(() => OrderService());
  locator.registerLazySingleton(() => RareRequestService());
  locator.registerLazySingleton(() => AdminDashboardService());
  locator.registerLazySingleton(() => AdminSupplierService());
  locator.registerLazySingleton(() => AdminPurchaseService());
}
