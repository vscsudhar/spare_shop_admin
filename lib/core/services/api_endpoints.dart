import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'api_client.dart';

class ApiEndpoints {
  static const String prefBaseUrlKey = 'api_base_url';
  static const String prefHostIpKey = 'api_host_ip';
  static const String prefPortKey = 'api_port';

  static const String defaultLanIp = '192.168.0.174';
  static const String defaultPort = '5000';

  static const String _envHost = String.fromEnvironment('API_HOST');
  static const String _envPort = String.fromEnvironment('API_PORT');

  static String? _customHost;
  static String? _customPort;
  static String? _customBaseUrl;

  static Future<void> initFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBaseUrl = prefs.getString(prefBaseUrlKey);
      final savedHost = prefs.getString(prefHostIpKey);
      final savedPort = prefs.getString(prefPortKey);

      if (savedBaseUrl != null && savedBaseUrl.trim().isNotEmpty) {
        final clean = savedBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
        if (clean.contains('192.168.0.175') || clean.contains('localhost') || clean.contains('127.0.0.1')) {
          await prefs.remove(prefBaseUrlKey);
        } else {
          _customBaseUrl = clean;
        }
      }
      if (savedHost != null && savedHost.trim().isNotEmpty) {
        if (savedHost.trim() == '192.168.0.175' || savedHost.trim() == 'localhost' || savedHost.trim() == '127.0.0.1') {
          await prefs.remove(prefHostIpKey);
        } else {
          _customHost = savedHost.trim();
        }
      }
      if (savedPort != null && savedPort.trim().isNotEmpty) {
        _customPort = savedPort.trim();
      }
      debugPrint('⚡ [Admin ApiEndpoints] Initialized: baseUrl=$baseUrl (custom=$_customBaseUrl)');
    } catch (e) {
      debugPrint('⚠️ [Admin ApiEndpoints] Failed to load preferences: $e');
    }
  }

  static void configure({String? host, String? port, String? baseUrl}) {
    if (host != null && host.isNotEmpty) _customHost = host.trim();
    if (port != null && port.isNotEmpty) _customPort = port.trim();
    if (baseUrl != null && baseUrl.isNotEmpty) {
      _customBaseUrl = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    }
    _syncApiClient();
  }

  static Future<void> saveBaseUrl(String url) async {
    final cleanUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
    _customBaseUrl = cleanUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefBaseUrlKey, cleanUrl);
    _syncApiClient();
    debugPrint('⚡ [Admin ApiEndpoints] Saved custom Base URL: $cleanUrl');
  }

  static Future<void> saveHostAndPort({required String host, required String port}) async {
    _customHost = host.trim();
    _customPort = port.trim();
    _customBaseUrl = 'http://$_customHost:$_customPort/api/v1';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefHostIpKey, _customHost!);
    await prefs.setString(prefPortKey, _customPort!);
    await prefs.setString(prefBaseUrlKey, _customBaseUrl!);
    _syncApiClient();
    debugPrint('⚡ [Admin ApiEndpoints] Saved custom Host/Port: $baseUrl');
  }

  static Future<void> resetToDefault() async {
    _customBaseUrl = null;
    _customHost = null;
    _customPort = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefBaseUrlKey);
    await prefs.remove(prefHostIpKey);
    await prefs.remove(prefPortKey);
    _syncApiClient();
    debugPrint('⚡ [Admin ApiEndpoints] Reset to default Base URL: $baseUrl');
  }

  static Future<Map<String, dynamic>> testConnection(String targetUrl) async {
    final stopwatch = Stopwatch()..start();
    try {
      var clean = targetUrl.trim().replaceAll(RegExp(r'/+$'), '');
      if (!clean.startsWith('http://') && !clean.startsWith('https://')) {
        clean = 'http://$clean';
      }

      final healthUrl = clean.endsWith('/api/v1')
          ? '$clean/health'
          : '$clean/api/v1/health';

      final testDio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
      ));

      final response = await testDio.get(healthUrl);
      stopwatch.stop();

      if (response.statusCode == 200) {
        return {
          'success': true,
          'latencyMs': stopwatch.elapsedMilliseconds,
          'message': 'Connected successfully (${stopwatch.elapsedMilliseconds}ms)',
          'resolvedUrl': clean,
        };
      } else {
        return {
          'success': false,
          'latencyMs': stopwatch.elapsedMilliseconds,
          'message': 'Server responded with status ${response.statusCode}',
        };
      }
    } catch (e) {
      stopwatch.stop();
      String errorMsg = 'Unable to reach server';
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          errorMsg = 'Connection timed out (verify IP address & Wi-Fi)';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMsg = 'Connection refused (verify backend is running)';
        } else {
          errorMsg = e.message ?? errorMsg;
        }
      }
      return {
        'success': false,
        'latencyMs': stopwatch.elapsedMilliseconds,
        'message': errorMsg,
      };
    }
  }

  static void _syncApiClient() {
    try {
      if (locator.isRegistered<ApiClient>()) {
        locator<ApiClient>().updateBaseUrl(baseUrl);
      }
    } catch (_) {}
  }

  static bool get isCustomConfigured =>
      _customBaseUrl != null || _customHost != null;

  static String get defaultBaseUrl {
    return 'http://$defaultLanIp:$defaultPort/api/v1';
  }

  static String get hostIp {
    if (_customHost != null && _customHost!.isNotEmpty) {
      return _customHost!;
    }
    if (_envHost.isNotEmpty) return _envHost;
    return defaultLanIp;
  }

  static String get port {
    if (_customPort != null && _customPort!.isNotEmpty) {
      return _customPort!;
    }
    return _envPort.isNotEmpty ? _envPort : defaultPort;
  }

  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    return 'http://$hostIp:$port/api/v1';
  }

  static String get socketUrl {
    final baseUri = Uri.tryParse(baseUrl);
    if (baseUri != null && baseUri.hasScheme && baseUri.host.isNotEmpty) {
      final portPart = baseUri.hasPort ? ':${baseUri.port}' : '';
      return '${baseUri.scheme}://${baseUri.host}$portPart';
    }
    return 'http://$hostIp:$port';
  }

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
  static const String customerForgotPassword = '/auth/customer/forgot-password';
  static const String customerResetPassword = '/auth/customer/reset-password';
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
  static const String notificationsSendSingle = '/notifications/send-single';
  static const String notificationsSendBulk = '/notifications/send-bulk';
  static const String notificationsAdminHistory = '/notifications/admin/history';
  static const String notificationsCustomersList = '/notifications/customers-list';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String locations = '/admin/locations';
  static const String adminSuggestions = '/admin/suggestions';
  static const String enquiries = '/enquiries';
  static const String adminEnquiries = '/admin/enquiries';
}
