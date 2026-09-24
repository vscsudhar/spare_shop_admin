import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationNotifier extends ChangeNotifier {
  String? _locationId;
  String? _locationName = 'All Locations (HQ)';

  String? get locationId => _locationId;
  String? get locationName => _locationName ?? 'All Locations (HQ)';

  void notifyLocationChanged(String? locId, String? locName) {
    if (locId == null || locId.isEmpty || locId == 'all') {
      _locationId = null;
      _locationName = 'All Locations (HQ)';
    } else {
      _locationId = locId;
      _locationName = (locName != null && locName.isNotEmpty) ? locName : 'Location Hub';
    }
    notifyListeners();
  }
}

class TokenService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userRoleKey = 'user_role';
  static const String _userPermissionsKey = 'user_permissions';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userLocationIdKey = 'user_location_id';
  static const String _userLocationNameKey = 'user_location_name';

  static final LocationNotifier locationNotifier = LocationNotifier();

  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userPermissionsKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userLocationIdKey);
    await prefs.remove(_userLocationNameKey);
    locationNotifier.notifyLocationChanged(null, 'All Locations (HQ)');
  }

  Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, role);
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  Future<void> saveUserPermissions(List<String> permissions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_userPermissionsKey, permissions);
  }

  Future<List<String>> getUserPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_userPermissionsKey) ?? [];
  }

  Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  Future<void> saveUserLocation(
      {String? locationId, String? locationName}) async {
    final prefs = await SharedPreferences.getInstance();
    final isGlobal = locationId == null || locationId.isEmpty || locationId == 'all';
    
    if (!isGlobal) {
      await prefs.setString(_userLocationIdKey, locationId);
      await prefs.setString(_userLocationNameKey, locationName ?? 'Location Hub');
      locationNotifier.notifyLocationChanged(locationId, locationName ?? 'Location Hub');
    } else {
      await prefs.remove(_userLocationIdKey);
      await prefs.setString(_userLocationNameKey, 'All Locations (HQ)');
      locationNotifier.notifyLocationChanged(null, 'All Locations (HQ)');
    }
  }

  Future<String?> getUserLocationId() async {
    if (locationNotifier.locationId != null) {
      return locationNotifier.locationId;
    }
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_userLocationIdKey);
    if (stored == null || stored.isEmpty || stored == 'all') {
      return null;
    }
    return stored;
  }

  Future<String?> getUserLocationName() async {
    if (locationNotifier.locationName != null && locationNotifier.locationName!.isNotEmpty) {
      return locationNotifier.locationName!;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userLocationNameKey) ?? 'All Locations (HQ)';
  }

  Future<bool> canChangeLocation() async {
    return true;
  }

  static bool isOwnerOrHubManager(
      {String? role, String? email, String? activeRole}) {
    return true;
  }

  Future<bool> hasPermission(String permission) async {
    final role = await getUserRole();
    if (role == 'owner') return true;
    final perms = await getUserPermissions();
    return perms.contains(permission);
  }
}
