import 'package:spare_shop_admin/app/app.locator.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import 'token_service.dart';

class AuthService {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  AuthService({ApiClient? apiClient, TokenService? tokenService})
      : _apiClient = apiClient ?? locator<ApiClient>(),
        _tokenService = tokenService ?? locator<TokenService>();

  Future<bool> loginCustomer(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.customerLogin,
      data: {'email': email, 'password': password},
    );
    final data = response.data['data'];
    final accessToken = data['accessToken'];
    final refreshToken = data['refreshToken'];
    final user = data['user'];

    await _tokenService.saveTokens(
        accessToken: accessToken, refreshToken: refreshToken);
    await _tokenService.saveUserRole(user['role']?['name'] ?? 'customer');
    await _tokenService.saveUserEmail(user['email'] ?? '');

    final perms = user['role']?['permissions'] as List<dynamic>? ?? [];
    final permNames =
        perms.map((p) => (p is Map ? p['name'] : p).toString()).toList();
    await _tokenService.saveUserPermissions(permNames);

    return true;
  }

  Future<bool> loginAdmin(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.adminLogin,
      data: {'email': email, 'password': password},
    );
    final data = response.data['data'];
    final accessToken = data['accessToken'];
    final refreshToken = data['refreshToken'];
    final user = data['user'];

    await _tokenService.saveTokens(
        accessToken: accessToken, refreshToken: refreshToken);
    await _tokenService.saveUserRole(user['role']?['name'] ?? 'admin');
    await _tokenService.saveUserEmail(user['email'] ?? '');

    final perms = user['role']?['permissions'] as List<dynamic>? ?? [];
    final permNames =
        perms.map((p) => (p is Map ? p['name'] : p).toString()).toList();
    await _tokenService.saveUserPermissions(permNames);

    return true;
  }

  Future<bool> registerCustomer(
      String name, String email, String phone, String password) async {
    await _apiClient.post(
      ApiEndpoints.customerRegister,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
    return true;
  }

  Future<void> sendOtp(String email) async {
    await _apiClient.post(ApiEndpoints.sendOtp, data: {'email': email});
  }

  Future<void> verifyOtp(String email, String otp) async {
    await _apiClient
        .post(ApiEndpoints.verifyOtp, data: {'identifier': email, 'otp': otp});
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken != null) {
        await _apiClient
            .post(ApiEndpoints.logout, data: {'refreshToken': refreshToken});
      }
    } catch (_) {}
    await _tokenService.clearTokens();
  }
}
