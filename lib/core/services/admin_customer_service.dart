import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/services/order_service.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class CustomerVehicleModel {
  final String id;
  final String brand;
  final String model;
  final String? variant;
  final int? year;
  final String? registrationNumber;

  CustomerVehicleModel({
    required this.id,
    required this.brand,
    required this.model,
    this.variant,
    this.year,
    this.registrationNumber,
  });

  factory CustomerVehicleModel.fromJson(Map<String, dynamic> json) {
    return CustomerVehicleModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      brand: json['brand']?.toString() ?? 'EV Vehicle',
      model: json['model']?.toString() ?? 'Standard',
      variant: json['variant']?.toString(),
      year: json['year'] is int ? json['year'] : int.tryParse(json['year']?.toString() ?? ''),
      registrationNumber: json['registrationNumber']?.toString() ?? json['regNumber']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'variant': variant,
      'year': year,
      'registrationNumber': registrationNumber,
    };
  }

  String get displayName {
    final y = year != null ? ' ($year)' : '';
    final reg = registrationNumber != null && registrationNumber!.isNotEmpty ? ' • $registrationNumber' : '';
    return '$brand $model$y$reg';
  }
}

class AdminCustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final String type; // 'Retail Customer', 'Workshop Owner', 'Fleet Owner', 'Wholesaler'
  final String status; // 'Active', 'Suspended', 'Disabled'
  final String source; // 'Mobile App' or 'Store POS' / 'In-Store'
  final int ordersCount;
  final double totalSpend;
  final double outstandingDue;
  final String? locationId;
  final String? locationName;
  final String address;
  final List<CustomerVehicleModel> vehicles;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  AdminCustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage = '',
    this.type = 'Retail Customer',
    this.status = 'Active',
    this.source = 'Mobile App',
    this.ordersCount = 0,
    this.totalSpend = 0.0,
    this.outstandingDue = 0.0,
    this.locationId,
    this.locationName,
    this.address = '',
    this.vehicles = const [],
    this.createdAt,
    this.lastLoginAt,
  });

  bool get isMobileUser {
    final s = source.toLowerCase();
    return s.contains('mobile') || s.contains('app') || s == 'online';
  }

  bool get isStoreUser => !isMobileUser;

  String get sourceDisplayName => isMobileUser ? 'Mobile App User' : 'Store / POS User';

  factory AdminCustomerModel.fromJson(Map<String, dynamic> json) {
    List<CustomerVehicleModel> parsedVehicles = [];
    if (json['vehicles'] is List) {
      parsedVehicles = (json['vehicles'] as List)
          .map((v) => v is Map<String, dynamic> ? CustomerVehicleModel.fromJson(v) : null)
          .whereType<CustomerVehicleModel>()
          .toList();
    } else if (json['garage'] is List) {
      parsedVehicles = (json['garage'] as List)
          .map((v) => v is Map<String, dynamic> ? CustomerVehicleModel.fromJson(v) : null)
          .whereType<CustomerVehicleModel>()
          .toList();
    }

    DateTime? parsedCreatedAt;
    if (json['createdAt'] != null) {
      parsedCreatedAt = DateTime.tryParse(json['createdAt'].toString());
    }

    DateTime? parsedLastLogin;
    if (json['lastLoginAt'] != null) {
      parsedLastLogin = DateTime.tryParse(json['lastLoginAt'].toString());
    } else if (json['lastActive'] != null) {
      parsedLastLogin = DateTime.tryParse(json['lastActive'].toString());
    }

    // Comprehensive parsing for orders count
    int parsedOrdersCount = 0;
    if (json['ordersCount'] != null) {
      parsedOrdersCount = json['ordersCount'] is int
          ? json['ordersCount']
          : int.tryParse(json['ordersCount'].toString()) ?? 0;
    } else if (json['totalOrders'] != null) {
      parsedOrdersCount = json['totalOrders'] is int
          ? json['totalOrders']
          : int.tryParse(json['totalOrders'].toString()) ?? 0;
    } else if (json['orderCount'] != null) {
      parsedOrdersCount = json['orderCount'] is int
          ? json['orderCount']
          : int.tryParse(json['orderCount'].toString()) ?? 0;
    } else if (json['orders_count'] != null) {
      parsedOrdersCount = json['orders_count'] is int
          ? json['orders_count']
          : int.tryParse(json['orders_count'].toString()) ?? 0;
    } else if (json['orders'] is List) {
      parsedOrdersCount = (json['orders'] as List).length;
    } else if (json['stats'] is Map && json['stats']['ordersCount'] != null) {
      parsedOrdersCount = int.tryParse(json['stats']['ordersCount'].toString()) ?? 0;
    } else if (json['metrics'] is Map && json['metrics']['ordersCount'] != null) {
      parsedOrdersCount = int.tryParse(json['metrics']['ordersCount'].toString()) ?? 0;
    }

    // Comprehensive parsing for total spend
    double parsedTotalSpend = 0.0;
    dynamic rawSpend = json['totalSpend'] ??
        json['totalSpent'] ??
        json['spent'] ??
        json['totalAmount'] ??
        json['lifetimeSpend'] ??
        json['total_spend'];
    if (rawSpend == null && json['stats'] is Map) {
      rawSpend = json['stats']['totalSpend'] ?? json['stats']['totalSpent'];
    }
    if (rawSpend == null && json['metrics'] is Map) {
      rawSpend = json['metrics']['totalSpend'] ?? json['metrics']['totalSpent'];
    }

    if (rawSpend is num) {
      parsedTotalSpend = rawSpend.toDouble();
    } else if (rawSpend != null) {
      parsedTotalSpend = double.tryParse(rawSpend.toString()) ?? 0.0;
    }

    // Source parsing (Mobile App vs In-Store / POS)
    String parsedSource = 'Mobile App';
    final rawSource = json['source']?.toString() ??
        json['userSource']?.toString() ??
        json['channel']?.toString() ??
        json['origin']?.toString() ??
        json['registeredFrom']?.toString() ??
        json['platform']?.toString();

    if (rawSource != null && rawSource.isNotEmpty) {
      final s = rawSource.toLowerCase();
      if (s.contains('store') || s.contains('pos') || s.contains('walk') || s.contains('offline') || s.contains('counter')) {
        parsedSource = 'Store / POS';
      } else {
        parsedSource = 'Mobile App';
      }
    } else if (json['isWalkIn'] == true || json['isPosUser'] == true) {
      parsedSource = 'Store / POS';
    }

    return AdminCustomerModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Customer',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString() ?? '',
      profileImage: json['profileImage']?.toString() ??
          json['avatar']?.toString() ??
          json['photoUrl']?.toString() ??
          '',
      type: json['type']?.toString() ??
          (json['role'] == 'workshop' ? 'Workshop Owner' : 'Retail Customer'),
      status: json['status']?.toString() ?? 'Active',
      source: parsedSource,
      ordersCount: parsedOrdersCount,
      totalSpend: parsedTotalSpend,
      outstandingDue: json['outstandingDue'] is num
          ? (json['outstandingDue'] as num).toDouble()
          : double.tryParse(json['outstandingDue']?.toString() ?? '0.0') ?? 0.0,
      locationId: json['locationId']?.toString(),
      locationName: json['locationName']?.toString() ?? json['hubName']?.toString(),
      address: json['address']?.toString() ?? json['city']?.toString() ?? '',
      vehicles: parsedVehicles,
      createdAt: parsedCreatedAt,
      lastLoginAt: parsedLastLogin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'type': type,
      'status': status,
      'source': source,
      'ordersCount': ordersCount,
      'totalSpend': totalSpend,
      'outstandingDue': outstandingDue,
      'locationId': locationId,
      'locationName': locationName,
      'address': address,
      'vehicles': vehicles.map((v) => v.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  AdminCustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? type,
    String? status,
    String? source,
    int? ordersCount,
    double? totalSpend,
    double? outstandingDue,
    String? locationId,
    String? locationName,
    String? address,
    List<CustomerVehicleModel>? vehicles,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return AdminCustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      type: type ?? this.type,
      status: status ?? this.status,
      source: source ?? this.source,
      ordersCount: ordersCount ?? this.ordersCount,
      totalSpend: totalSpend ?? this.totalSpend,
      outstandingDue: outstandingDue ?? this.outstandingDue,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      address: address ?? this.address,
      vehicles: vehicles ?? this.vehicles,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'VS';
    if (parts.length == 1) return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class AdminCustomerService {
  final ApiClient _apiClient;
  static const String _cacheKey = 'voltspare_admin_customers_cache_v3';

  AdminCustomerService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  final List<AdminCustomerModel> _defaultCustomers = [
    AdminCustomerModel(
      id: 'cust_001',
      name: 'Ravi Kumar',
      email: 'ravi.kumar@gmail.com',
      phone: '+91 98765 43210',
      profileImage: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
      type: 'Workshop Owner',
      status: 'Active',
      source: 'Mobile App',
      ordersCount: 28,
      totalSpend: 54900.00,
      outstandingDue: 4500.00,
      locationId: 'loc_01',
      locationName: 'Madukkarai',
      address: '142 Main Road, Madukkarai, Coimbatore',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
      vehicles: [
        CustomerVehicleModel(id: 'v1', brand: 'Ather', model: '450X Gen 3', year: 2023, registrationNumber: 'TN 37 CY 4921'),
        CustomerVehicleModel(id: 'v2', brand: 'Ola Electric', model: 'S1 Pro Gen 2', year: 2024, registrationNumber: 'TN 38 BE 1092'),
      ],
    ),
    AdminCustomerModel(
      id: 'cust_002',
      name: 'Anjali Sharma',
      email: 'anjali.sharma@live.com',
      phone: '+91 98123 45678',
      profileImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
      type: 'Retail Customer',
      status: 'Active',
      source: 'Mobile App',
      ordersCount: 6,
      totalSpend: 9800.00,
      outstandingDue: 0.00,
      locationId: 'loc_02',
      locationName: 'Gandhipuram',
      address: '7B Crosscut Road, Gandhipuram, Coimbatore',
      createdAt: DateTime.now().subtract(const Duration(days: 75)),
      lastLoginAt: DateTime.now().subtract(const Duration(days: 1)),
      vehicles: [
        CustomerVehicleModel(id: 'v3', brand: 'TVS', model: 'iQube S', year: 2023, registrationNumber: 'TN 66 AB 8841'),
      ],
    ),
    AdminCustomerModel(
      id: 'cust_003',
      name: 'Suresh EV Services',
      email: 'contact@sureshev.com',
      phone: '+91 94440 12345',
      profileImage: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=200&q=80',
      type: 'Workshop Owner',
      status: 'Active',
      source: 'Store / POS',
      ordersCount: 94,
      totalSpend: 268000.00,
      outstandingDue: 18500.00,
      locationId: 'loc_01',
      locationName: 'Madukkarai',
      address: '22 Workshop Hub, Madukkarai Bypass',
      createdAt: DateTime.now().subtract(const Duration(days: 210)),
      lastLoginAt: DateTime.now().subtract(const Duration(minutes: 45)),
      vehicles: [
        CustomerVehicleModel(id: 'v4', brand: 'Bajaj', model: 'Chetak Premium', year: 2023, registrationNumber: 'TN 37 EA 9081'),
        CustomerVehicleModel(id: 'v5', brand: 'Hero Electric', model: 'Optima CX', year: 2022, registrationNumber: 'TN 38 CD 4410'),
      ],
    ),
    AdminCustomerModel(
      id: 'cust_004',
      name: 'Pooja Sundaram',
      email: 'pooja.sundaram@gmail.com',
      phone: '+91 98840 99881',
      profileImage: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      type: 'Retail Customer',
      status: 'Active',
      source: 'Mobile App',
      ordersCount: 3,
      totalSpend: 4200.00,
      outstandingDue: 0.00,
      locationId: 'loc_02',
      locationName: 'Gandhipuram',
      address: '12 Ram Nagar, Gandhipuram',
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
      lastLoginAt: DateTime.now().subtract(const Duration(days: 3)),
      vehicles: [
        CustomerVehicleModel(id: 'v6', brand: 'Ather', model: '450S', year: 2024, registrationNumber: 'TN 37 FF 1120'),
      ],
    ),
    AdminCustomerModel(
      id: 'cust_005',
      name: 'Karthik Fleet Solutions',
      email: 'ops@karthikfleet.in',
      phone: '+91 97910 55432',
      profileImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      type: 'Fleet Owner',
      status: 'Active',
      source: 'Store / POS',
      ordersCount: 42,
      totalSpend: 182400.00,
      outstandingDue: 7800.00,
      locationId: null,
      locationName: null,
      address: 'Avinashi Road, Peelamedu, Coimbatore',
      createdAt: DateTime.now().subtract(const Duration(days: 95)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 5)),
      vehicles: [
        CustomerVehicleModel(id: 'v7', brand: 'Ola Electric', model: 'S1 Air', year: 2023, registrationNumber: 'TN 37 KK 5512'),
        CustomerVehicleModel(id: 'v8', brand: 'TVS', model: 'iQube ST', year: 2024, registrationNumber: 'TN 37 KK 5513'),
      ],
    ),
    AdminCustomerModel(
      id: 'cust_006',
      name: 'Manoj Kumar',
      email: 'manoj.k@outlook.com',
      phone: '+91 95001 22334',
      profileImage: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      type: 'Retail Customer',
      status: 'Suspended',
      source: 'Mobile App',
      ordersCount: 1,
      totalSpend: 1500.00,
      outstandingDue: 1500.00,
      locationId: 'loc_01',
      locationName: 'Madukkarai',
      address: 'Palakkad Main Rd, Madukkarai',
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
      lastLoginAt: DateTime.now().subtract(const Duration(days: 45)),
      vehicles: [],
    ),
    AdminCustomerModel(
      id: 'cust_007',
      name: 'Saravanan Store Walk-in',
      email: 'saravanan.store@gmail.com',
      phone: '+91 94882 11223',
      profileImage: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&q=80',
      type: 'Workshop Owner',
      status: 'Active',
      source: 'Store / POS',
      ordersCount: 15,
      totalSpend: 42300.00,
      outstandingDue: 2100.00,
      locationId: 'loc_02',
      locationName: 'Gandhipuram',
      address: 'Cross Cut Road, Gandhipuram',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      lastLoginAt: DateTime.now().subtract(const Duration(days: 2)),
      vehicles: [],
    ),
  ];

  Future<List<AdminCustomerModel>> getCustomers({
    String? search,
    String? locationId,
    String? status,
    String? source,
  }) async {
    List<AdminCustomerModel> result = [];
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (locationId != null && locationId.isNotEmpty && locationId != 'all') {
        queryParams['locationId'] = locationId;
      }
      if (status != null && status.isNotEmpty && status != 'all') {
        queryParams['status'] = status;
      }

      final response = await _apiClient.get(
        ApiEndpoints.customers,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        List<dynamic> items = [];
        if (data is List) {
          items = data;
        } else if (data is Map && data['customers'] is List) {
          items = data['customers'];
        } else if (data is Map && data['users'] is List) {
          items = data['users'];
        } else if (data is Map && data['items'] is List) {
          items = data['items'];
        }

        if (items.isNotEmpty) {
          result = items.map((json) => AdminCustomerModel.fromJson(json as Map<String, dynamic>)).toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('AdminCustomerService.getCustomers API error (falling back to cache/local): $e');
      }
    }

    if (result.isEmpty) {
      result = await _loadCachedCustomers();
    }

    // Correlate with live order system to ensure orders count and total spend are accurate
    try {
      final orderService = locator<OrderService>();
      final allOrders = await orderService.adminGetAllOrders();
      if (allOrders.isNotEmpty) {
        result = result.map((customer) {
          final customerPhoneClean = customer.phone.replaceAll(RegExp(r'\D'), '');
          final matchedOrders = allOrders.where((order) {
            final orderPhoneClean = order.address.phone.replaceAll(RegExp(r'\D'), '');
            final phoneMatches = customerPhoneClean.isNotEmpty &&
                orderPhoneClean.isNotEmpty &&
                (customerPhoneClean.contains(orderPhoneClean) || orderPhoneClean.contains(customerPhoneClean));
            final nameMatches = order.address.name.trim().toLowerCase() == customer.name.trim().toLowerCase();
            return phoneMatches || nameMatches;
          }).toList();

          if (matchedOrders.isNotEmpty) {
            final orderCount = matchedOrders.length;
            final spend = matchedOrders.fold(0.0, (sum, o) => sum + o.total);

            // Determine primary source
            final posOrders = matchedOrders.where((o) => o.isPosOrder).length;
            final appOrders = matchedOrders.length - posOrders;
            final detectedSource = posOrders > appOrders ? 'Store / POS' : 'Mobile App';

            return customer.copyWith(
              ordersCount: customer.ordersCount > orderCount ? customer.ordersCount : orderCount,
              totalSpend: customer.totalSpend > spend ? customer.totalSpend : spend,
              source: customer.source.isNotEmpty ? customer.source : detectedSource,
            );
          }
          return customer;
        }).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Order correlation for customer stats: $e');
      }
    }

    await _saveCachedCustomers(result);
    return result;
  }

  Future<AdminCustomerModel> getCustomerById(String id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.customers}/$id');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        final item = data is Map<String, dynamic> && data['customer'] != null ? data['customer'] : data;
        return AdminCustomerModel.fromJson(item as Map<String, dynamic>);
      }
    } catch (e) {
      if (kDebugMode) {
        print('AdminCustomerService.getCustomerById API error: $e');
      }
    }

    final cached = await _loadCachedCustomers();
    return cached.firstWhere(
      (c) => c.id == id,
      orElse: () => _defaultCustomers.first,
    );
  }

  Future<AdminCustomerModel> updateCustomer(String id, Map<String, dynamic> data) async {
    AdminCustomerModel? updated;
    try {
      final response = await _apiClient.put('${ApiEndpoints.customers}/$id', data: data);
      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data['data'];
        final item = resData is Map<String, dynamic> && resData['customer'] != null ? resData['customer'] : resData;
        if (item is Map<String, dynamic>) {
          updated = AdminCustomerModel.fromJson(item);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('AdminCustomerService.updateCustomer API error: $e');
      }
    }

    final cached = await _loadCachedCustomers();
    final index = cached.indexWhere((c) => c.id == id);
    if (index != -1) {
      final current = cached[index];
      updated ??= current.copyWith(
        name: data['name']?.toString() ?? current.name,
        email: data['email']?.toString() ?? current.email,
        phone: data['phone']?.toString() ?? current.phone,
        profileImage: data['profileImage']?.toString() ?? current.profileImage,
        type: data['type']?.toString() ?? current.type,
        status: data['status']?.toString() ?? current.status,
        source: data['source']?.toString() ?? current.source,
        ordersCount: data['ordersCount'] != null
            ? (int.tryParse(data['ordersCount'].toString()) ?? current.ordersCount)
            : current.ordersCount,
        totalSpend: data['totalSpend'] != null
            ? (double.tryParse(data['totalSpend'].toString()) ?? current.totalSpend)
            : current.totalSpend,
        outstandingDue: data['outstandingDue'] != null
            ? (double.tryParse(data['outstandingDue'].toString()) ?? current.outstandingDue)
            : current.outstandingDue,
        locationId: data.containsKey('locationId') ? data['locationId']?.toString() : current.locationId,
        locationName: data.containsKey('locationName') ? data['locationName']?.toString() : current.locationName,
        address: data['address']?.toString() ?? current.address,
      );
      cached[index] = updated;
      await _saveCachedCustomers(cached);
      return updated;
    }

    return updated ?? _defaultCustomers.first;
  }

  Future<AdminCustomerModel> updateCustomerStatus(String id, String status) async {
    try {
      final response = await _apiClient.patch(
        '${ApiEndpoints.customers}/$id/status',
        data: {'status': status},
      );
      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data['data'];
        final item = resData is Map<String, dynamic> && resData['customer'] != null ? resData['customer'] : resData;
        if (item is Map<String, dynamic>) {
          final updated = AdminCustomerModel.fromJson(item);
          final cached = await _loadCachedCustomers();
          final index = cached.indexWhere((c) => c.id == id);
          if (index != -1) {
            cached[index] = updated;
            await _saveCachedCustomers(cached);
          }
          return updated;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('AdminCustomerService.updateCustomerStatus API error: $e');
      }
    }

    final cached = await _loadCachedCustomers();
    final index = cached.indexWhere((c) => c.id == id);
    if (index != -1) {
      final updated = cached[index].copyWith(status: status);
      cached[index] = updated;
      await _saveCachedCustomers(cached);
      return updated;
    }
    throw Exception('Customer not found');
  }

  Future<bool> deleteCustomer(String id) async {
    try {
      await _apiClient.delete('${ApiEndpoints.customers}/$id');
    } catch (e) {
      if (kDebugMode) {
        print('AdminCustomerService.deleteCustomer API error: $e');
      }
    }

    final cached = await _loadCachedCustomers();
    cached.removeWhere((c) => c.id == id);
    await _saveCachedCustomers(cached);
    return true;
  }

  Future<AdminCustomerModel> createCustomer(Map<String, dynamic> data) async {
    AdminCustomerModel? created;
    try {
      final response = await _apiClient.post(ApiEndpoints.customers, data: data);
      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        final resData = response.data['data'];
        final item = resData is Map<String, dynamic> && resData['customer'] != null ? resData['customer'] : resData;
        if (item is Map<String, dynamic>) {
          created = AdminCustomerModel.fromJson(item);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('AdminCustomerService.createCustomer API error: $e');
      }
    }

    created ??= AdminCustomerModel(
      id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
      name: data['name']?.toString() ?? 'New Customer',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      profileImage: data['profileImage']?.toString() ?? '',
      type: data['type']?.toString() ?? 'Retail Customer',
      status: data['status']?.toString() ?? 'Active',
      source: data['source']?.toString() ?? 'Mobile App',
      ordersCount: int.tryParse(data['ordersCount']?.toString() ?? '0') ?? 0,
      totalSpend: double.tryParse(data['totalSpend']?.toString() ?? '0.0') ?? 0.0,
      outstandingDue: double.tryParse(data['outstandingDue']?.toString() ?? '0.0') ?? 0.0,
      locationId: data['locationId']?.toString(),
      locationName: data['locationName']?.toString(),
      address: data['address']?.toString() ?? '',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      vehicles: [],
    );

    final cached = await _loadCachedCustomers();
    cached.insert(0, created);
    await _saveCachedCustomers(cached);
    return created;
  }

  Future<List<AdminCustomerModel>> _loadCachedCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_cacheKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded.map((e) => AdminCustomerModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cached customers: $e');
      }
    }
    return List<AdminCustomerModel>.from(_defaultCustomers);
  }

  Future<void> _saveCachedCustomers(List<AdminCustomerModel> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(list.map((c) => c.toJson()).toList());
      await prefs.setString(_cacheKey, encoded);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving customers cache: $e');
      }
    }
  }
}
