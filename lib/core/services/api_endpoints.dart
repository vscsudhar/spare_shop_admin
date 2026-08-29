
class ApiEndpoints {
  static const String hostIp = '192.168.0.174';

  static String get baseUrl => 'http://$hostIp:5000/api/v1';
  static String get socketUrl => 'http://$hostIp:5000';

  // Authentication
  static const String customerLogin = '/auth/customer/login';
  static const String customerRegister = '/auth/customer/register';
  static const String adminLogin = '/auth/admin/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String logoutAll = '/auth/logout-all';
  static const String me = '/auth/me';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  // Catalog
  static const String products = '/products';
  static const String categories = '/categories';
  static const String vehicleBrands = '/vehicle-brands';
  static const String vehicleModels = '/vehicle-models';

  // Sourcing (Rare requests)
  static const String rareRequests = '/rare-requests';
  static const String quotations = '/quotations';
  static const String chat = '/chat';

  // Customer features
  static const String wishlist = '/wishlist';
  static const String cart = '/cart';
  static const String addresses = '/addresses';
  static const String orders = '/orders';
  static const String checkout = '/checkout';

  // Admin features
  static const String dashboard = '/admin/dashboard';
  static const String adminOrders = '/admin/orders';
  static const String adminRareRequests = '/admin/rare-requests';
  static const String inventory = '/inventory';
  static const String purchases = '/purchases';
  static const String suppliers = '/suppliers';
  static const String customers = '/customers';
  static const String billing = '/billing';
  static const String reports = '/reports';
  static const String staff = '/staff';
  static const String roles = '/roles';
  static const String permissions = '/permissions';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
}
