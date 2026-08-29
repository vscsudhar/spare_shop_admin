# Get active local IPv4 address of the Wi-Fi or Ethernet adapter
$ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi-Fi", "Ethernet" | Where-Object {$_.IPAddress -notlike "169.254.*"} | Select-Object -First 1).IPAddress
if (-not $ip) {
    $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*"} | Select-Object -First 1).IPAddress
}

if (-not $ip) {
    Write-Output "ERROR: Could not detect local network IP address."
    exit 1
}

Write-Output "INFO: Detected Local Network IP: $ip"

# Paths
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$parentDir = Split-Path -Parent $scriptDir

$adminApiEndpoints = Join-Path $scriptDir "lib\core\services\api_endpoints.dart"
$shopApiEndpoints = Join-Path $parentDir "spare_shop\lib\core\services\api_endpoints.dart"
$backendEnv = Join-Path $parentDir "spare_api\.env"

$template = @'
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static const String hostIp = '__IP__';

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
'@

$refactoredContent = $template.Replace('__IP__', $ip)

# 1. Update spare_shop_admin
if (Test-Path $adminApiEndpoints) {
    Set-Content -Path $adminApiEndpoints -Value $refactoredContent -Encoding utf8
    Write-Output "SUCCESS: Refactored and Updated $adminApiEndpoints with IP $ip"
}

# 2. Update spare_shop
if (Test-Path $shopApiEndpoints) {
    Set-Content -Path $shopApiEndpoints -Value $refactoredContent -Encoding utf8
    Write-Output "SUCCESS: Refactored and Updated $shopApiEndpoints with IP $ip"
} else {
    Write-Output "WARNING: spare_shop folder not found at path: $shopApiEndpoints"
}

# 3. Update spare_api .env
if (Test-Path $backendEnv) {
    $content = Get-Content $backendEnv -Raw
    $content = $content -replace "CLIENT_URL=http://.*", "CLIENT_URL=http://$ip:3000"
    $content = $content -replace "FLUTTER_WEB_URL=http://.*", "FLUTTER_WEB_URL=http://$ip:50000"
    Set-Content $backendEnv $content -Encoding utf8
    Write-Output "SUCCESS: Updated $backendEnv with CLIENT_URL and FLUTTER_WEB_URL for IP $ip"
} else {
    Write-Output "WARNING: spare_api env not found at path: $backendEnv"
}
