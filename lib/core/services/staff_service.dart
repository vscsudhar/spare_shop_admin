import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class StaffMemberModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String phone;
  final String shift;
  final String status; // 'Active', 'On Leave', 'Inactive'
  final String? locationId;
  final String locationName;

  const StaffMemberModel({
    required this.id,
    required this.name,
    this.email = '',
    this.password = 'Staff12345!',
    required this.role,
    required this.phone,
    required this.shift,
    required this.status,
    this.locationId,
    this.locationName = 'All Locations (HQ)',
  });

  bool get isLocationBound =>
      locationId != null && locationId!.isNotEmpty && locationId != 'all';

  StaffMemberModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? role,
    String? phone,
    String? shift,
    String? status,
    String? locationId,
    String? locationName,
  }) {
    return StaffMemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      shift: shift ?? this.shift,
      status: status ?? this.status,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'phone': phone,
      'shift': shift,
      'status': status,
      'locationId': locationId,
      'locationName': locationName,
    };
  }

  factory StaffMemberModel.fromJson(Map<String, dynamic> json) {
    final email = json['email']?.toString() ?? '';
    final id = (json['_id'] ?? json['id'])?.toString() ?? '';
    final isOwner = email.toLowerCase() == 'owner@voltspare.com' || id == 'staff_1';
    final defaultPass = isOwner ? 'OwnerPassword123!' : 'Staff12345!';
    final rawPass = json['password']?.toString();
    final password = (rawPass != null && rawPass.trim().isNotEmpty) ? rawPass.trim() : defaultPass;

    String roleName = 'Inventory Specialist';
    if (json['role'] is Map) {
      roleName = json['role']['name']?.toString() ?? 'Inventory Specialist';
    } else if (json['role'] != null && json['role'].toString().isNotEmpty) {
      roleName = json['role'].toString();
    }
    if (isOwner && !roleName.toLowerCase().contains('owner')) {
      roleName = 'Owner / Admin';
    }

    String statusStr = 'Active';
    final rawStatus = json['status']?.toString().toLowerCase();
    if (rawStatus == 'inactive' || rawStatus == 'disabled') {
      statusStr = 'Inactive';
    } else if (rawStatus == 'on leave' || rawStatus == 'suspended') {
      statusStr = 'On Leave';
    }

    String? locId;
    String locName = isOwner ? 'All Locations (HQ)' : 'Madukkarai';
    if (json['locationId'] is Map) {
      locId = (json['locationId']['_id'] ?? json['locationId']['id'])?.toString();
      locName = json['locationId']['name']?.toString() ?? locName;
    } else if (json['locationId'] != null) {
      locId = json['locationId'].toString();
    }
    if (json['locationName'] != null) {
      locName = json['locationName'].toString();
    }

    return StaffMemberModel(
      id: id,
      name: json['name']?.toString() ?? '',
      email: email.trim(),
      password: password,
      role: roleName,
      phone: json['phone']?.toString() ?? '',
      shift: json['shift']?.toString() ?? '09:00 AM - 06:00 PM',
      status: statusStr,
      locationId: (locId == 'all' || locId == null) ? null : locId,
      locationName: locName,
    );
  }
}

class StaffRoleDefinition {
  final String id;
  final String roleName;
  final String description;
  final bool isLocationScoped;
  final List<String> permissions;

  const StaffRoleDefinition({
    required this.id,
    required this.roleName,
    required this.description,
    required this.isLocationScoped,
    required this.permissions,
  });
}

class StaffService {
  static const String _passwordsStorageKey = 'voltspare_custom_user_passwords_v2';
  static const String _staffStorageKey = 'voltspare_staff_list_v2';
  static Map<String, String> _customPasswords = {};

  final ApiClient _apiClient;

  StaffService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>() {
    _loadCustomPasswords();
  }

  static final List<StaffMemberModel> _defaultStaff = [
    const StaffMemberModel(
      id: 'staff_1',
      name: 'Amit Patel',
      email: 'owner@voltspare.com',
      password: 'OwnerPassword123!',
      role: 'Owner / Admin',
      phone: '+91 99880 77665',
      shift: 'Flexible (HQ)',
      status: 'Active',
      locationId: null,
      locationName: 'All Locations (HQ)',
    ),
    const StaffMemberModel(
      id: 'staff_2',
      name: 'Rohan Deshmukh',
      email: 'rohan.d@voltspare.com',
      password: 'Staff12345!',
      role: 'Inventory Specialist',
      phone: '+91 98887 66554',
      shift: '09:00 AM - 06:00 PM',
      status: 'Active',
      locationId: '6aaa4372a8009fa74492d9ca',
      locationName: 'Madukkarai',
    ),
    const StaffMemberModel(
      id: 'staff_3',
      name: 'Priya Nair',
      email: 'priya.nair@voltspare.com',
      password: 'Staff12345!',
      role: 'Sales & POS Staff',
      phone: '+91 97776 55443',
      shift: '10:00 AM - 07:00 PM',
      status: 'Active',
      locationId: '6aaa4372a8009fa74492d9ca',
      locationName: 'Madukkarai',
    ),
    const StaffMemberModel(
      id: 'staff_4',
      name: 'Vikram Singh',
      email: 'vikram.s@voltspare.com',
      password: 'Staff12345!',
      role: 'Delivery Driver',
      phone: '+91 96665 44332',
      shift: '08:00 AM - 05:00 PM',
      status: 'On Leave',
      locationId: '6aaa4372a8009fa74492d9ca',
      locationName: 'Madukkarai',
    ),
  ];

  List<StaffMemberModel> _cache = [];

  Future<void> _loadCustomPasswords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_passwordsStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(raw);
        _customPasswords = decoded.map((k, v) => MapEntry(k.toLowerCase(), v.toString()));
      }
    } catch (e) {
      debugPrint('Error loading custom passwords: $e');
    }
  }

  Future<void> _saveCustomPasswords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_passwordsStorageKey, jsonEncode(_customPasswords));
    } catch (e) {
      debugPrint('Error saving custom passwords: $e');
    }
  }

  String? getPasswordForEmail(String email) {
    final clean = email.trim().toLowerCase();
    if (_customPasswords.containsKey(clean)) {
      return _customPasswords[clean];
    }
    if (clean == 'owner@voltspare.com') {
      return 'OwnerPassword123!';
    }
    if (clean == 'rohan.d@voltspare.com' || clean == 'priya.nair@voltspare.com' || clean == 'vikram.s@voltspare.com') {
      return 'Staff12345!';
    }
    final match = _cache.where((s) => s.email.trim().toLowerCase() == clean);
    if (match.isNotEmpty && match.first.password.isNotEmpty) {
      return match.first.password;
    }
    return null;
  }

  Future<void> updatePassword(String email, String newPassword) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = newPassword.trim();
    if (cleanEmail.isEmpty || cleanPass.isEmpty) return;

    await _loadCustomPasswords();
    _customPasswords[cleanEmail] = cleanPass;
    await _saveCustomPasswords();

    // Update in cache
    await getStaffMembers();
    for (int i = 0; i < _cache.length; i++) {
      if (_cache[i].email.trim().toLowerCase() == cleanEmail) {
        _cache[i] = _cache[i].copyWith(password: cleanPass);
      }
    }
    await _persistStaff();
  }

  Future<List<StaffMemberModel>> getStaffMembers({String? locationId}) async {
    await _loadCustomPasswords();

    // 1. First load local storage cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_staffStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _cache = decoded
            .map((item) => StaffMemberModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (_cache.isEmpty) {
        _cache = List<StaffMemberModel>.from(_defaultStaff);
        await _persistStaff();
      }
    } catch (e) {
      debugPrint('Error loading cached staff: $e');
      if (_cache.isEmpty) {
        _cache = List<StaffMemberModel>.from(_defaultStaff);
      }
    }

    // Apply any custom passwords to cache
    for (int i = 0; i < _cache.length; i++) {
      final emailLower = _cache[i].email.trim().toLowerCase();
      if (_customPasswords.containsKey(emailLower)) {
        _cache[i] = _cache[i].copyWith(password: _customPasswords[emailLower]);
      }
    }

    // 2. Fetch live staff list from backend API
    try {
      final endpoint = (locationId != null &&
              locationId.isNotEmpty &&
              locationId != 'All' &&
              locationId != 'all')
          ? '${ApiEndpoints.staff}?locationId=$locationId'
          : ApiEndpoints.staff;
      final response = await _apiClient.get(endpoint);
      final dynamic rawData = response.data['data'];
      if (rawData is List) {
        for (final item in rawData) {
          if (item is Map<String, dynamic>) {
            final backendStaff = StaffMemberModel.fromJson(item);
            final emailLower = backendStaff.email.trim().toLowerCase();
            final existingIdx = _cache.indexWhere(
              (s) =>
                  s.id == backendStaff.id ||
                  s.email.toLowerCase() == emailLower,
            );

            // Determine preserved password (custom password > existing cache password > backend staff password)
            String preservedPass = backendStaff.password;
            if (_customPasswords.containsKey(emailLower)) {
              preservedPass = _customPasswords[emailLower]!;
            } else if (existingIdx != -1 && _cache[existingIdx].password.isNotEmpty) {
              preservedPass = _cache[existingIdx].password;
            }

            final staffWithPass = backendStaff.copyWith(password: preservedPass);

            if (existingIdx != -1) {
              _cache[existingIdx] = staffWithPass;
            } else {
              _cache.add(staffWithPass);
            }
          }
        }
        await _persistStaff();
      }
    } catch (e) {
      debugPrint('Backend staff API sync: $e');
    }

    if (locationId != null &&
        locationId.isNotEmpty &&
        locationId != 'All' &&
        locationId != 'all') {
      return _cache
          .where((m) =>
              m.locationId == locationId ||
              (m.locationId == null && locationId == 'all_hq'))
          .toList();
    }

    return List<StaffMemberModel>.from(_cache);
  }

  Future<void> saveStaffMember(StaffMemberModel staff) async {
    // 1. Update local cache & storage immediately
    await getStaffMembers();
    final cleanEmail = staff.email.trim().toLowerCase();
    if (staff.password.isNotEmpty) {
      _customPasswords[cleanEmail] = staff.password.trim();
      await _saveCustomPasswords();
    }

    final idx = _cache.indexWhere((s) =>
        s.id == staff.id ||
        s.email.toLowerCase() == cleanEmail);
    if (idx != -1) {
      _cache[idx] = staff;
    } else {
      _cache.add(staff);
    }
    await _persistStaff();

    // 2. Hit backend API to create or update staff
    try {
      final response = await _apiClient.post(
        ApiEndpoints.staff,
        data: {
          'name': staff.name,
          'email': staff.email,
          'phone': staff.phone,
          'password': staff.password,
          'role': staff.role,
          'status': staff.status.toLowerCase(),
          'locationId': staff.locationId,
          'shift': staff.shift,
        },
      );
      if (response.data != null &&
          response.data['data'] != null &&
          response.data['data']['_id'] != null) {
        final realId = response.data['data']['_id'].toString();
        final updatedStaff = staff.copyWith(id: realId);
        final cacheIdx = _cache.indexWhere((s) =>
            s.id == staff.id ||
            s.email.toLowerCase() == cleanEmail);
        if (cacheIdx != -1) {
          _cache[cacheIdx] = updatedStaff;
          await _persistStaff();
        }
      }
    } catch (e) {
      debugPrint('API staff create error (persisted locally): $e');
    }
  }

  Future<void> updateStaffMember(StaffMemberModel staff) async {
    // 1. Update local cache & storage
    await getStaffMembers();
    final cleanEmail = staff.email.trim().toLowerCase();
    if (staff.password.isNotEmpty) {
      _customPasswords[cleanEmail] = staff.password.trim();
      await _saveCustomPasswords();
    }

    final idx = _cache.indexWhere((s) =>
        s.id == staff.id ||
        s.email.toLowerCase() == cleanEmail);
    if (idx != -1) {
      _cache[idx] = staff;
    } else {
      _cache.add(staff);
    }
    await _persistStaff();

    // 2. Hit backend API to update staff details
    try {
      final updatePayload = <String, dynamic>{
        'name': staff.name,
        'email': staff.email,
        'phone': staff.phone,
        'role': staff.role,
        'locationId': staff.locationId,
        'shift': staff.shift,
        'status': staff.status.toLowerCase() == 'inactive'
            ? 'disabled'
            : (staff.status.toLowerCase() == 'on leave'
                ? 'suspended'
                : 'active'),
      };
      if (staff.password.isNotEmpty) {
        updatePayload['password'] = staff.password;
      }

      if (!staff.id.startsWith('staff_')) {
        await _apiClient.patch(
          '${ApiEndpoints.staff}/${staff.id}',
          data: updatePayload,
        );
      } else {
        // If it was a mock staff ID, create it on the backend
        final resp = await _apiClient.post(
          ApiEndpoints.staff,
          data: updatePayload,
        );
        if (resp.data != null &&
            resp.data['data'] != null &&
            resp.data['data']['_id'] != null) {
          final realId = resp.data['data']['_id'].toString();
          final updatedStaff = staff.copyWith(id: realId);
          final cacheIdx = _cache.indexWhere((s) =>
              s.id == staff.id ||
              s.email.toLowerCase() == cleanEmail);
          if (cacheIdx != -1) {
            _cache[cacheIdx] = updatedStaff;
            await _persistStaff();
          }
        }
      }
    } catch (e) {
      debugPrint('API staff update error: $e');
    }

    // 3. Update status on backend API
    try {
      if (!staff.id.startsWith('staff_')) {
        await _apiClient.patch(
          '${ApiEndpoints.staff}/${staff.id}/status',
          data: {
            'status': staff.status.toLowerCase() == 'inactive'
                ? 'disabled'
                : (staff.status.toLowerCase() == 'on leave'
                    ? 'suspended'
                    : 'active'),
          },
        );
      }
    } catch (e) {
      debugPrint('API staff status update error: $e');
    }

    // 4. If updating profile of current user
    try {
      final profilePayload = <String, dynamic>{
        'name': staff.name,
        'email': staff.email,
        'phone': staff.phone,
      };
      if (staff.password.isNotEmpty) {
        profilePayload['password'] = staff.password;
      }
      await _apiClient.put(
        '/users/profile',
        data: profilePayload,
      );
    } catch (e) {
      debugPrint('API user profile update notice: $e');
    }
  }

  Future<void> deleteStaffMember(String id) async {
    // 1. Update local cache & storage
    await getStaffMembers();
    _cache.removeWhere((s) => s.id == id);
    await _persistStaff();

    // 2. Hit backend API delete
    try {
      if (!id.startsWith('staff_')) {
        await _apiClient.delete('${ApiEndpoints.staff}/$id');
      }
    } catch (e) {
      debugPrint('API staff delete error: $e');
    }
  }

  Future<StaffMemberModel?> authenticateStaff(String email, String password) async {
    await _loadCustomPasswords();
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    // 1. Check custom passwords map directly
    if (_customPasswords.containsKey(cleanEmail) && _customPasswords[cleanEmail] == cleanPassword) {
      final staffList = await getStaffMembers();
      final match = staffList.where((s) => s.email.trim().toLowerCase() == cleanEmail);
      if (match.isNotEmpty) {
        return match.first.copyWith(password: cleanPassword);
      }
      // Create fallback model if user has updated password but not in staff list
      return StaffMemberModel(
        id: cleanEmail == 'owner@voltspare.com' ? 'staff_1' : 'staff_custom',
        name: cleanEmail == 'owner@voltspare.com' ? 'Amit Patel' : 'Staff Member',
        email: cleanEmail,
        password: cleanPassword,
        role: cleanEmail == 'owner@voltspare.com' ? 'Owner / Admin' : 'Staff Member',
        phone: '+91 99880 77665',
        shift: 'Flexible',
        status: 'Active',
      );
    }

    // 2. Check full staff members list
    final staffList = await getStaffMembers();
    for (final staff in staffList) {
      if (staff.email.trim().toLowerCase() == cleanEmail &&
          staff.password.trim() == cleanPassword) {
        return staff;
      }
    }
    return null;
  }

  Future<void> _persistStaff() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_cache.map((s) => s.toJson()).toList());
      await prefs.setString(_staffStorageKey, encoded);
    } catch (e) {
      debugPrint('Error persisting staff list: $e');
    }
  }
}

