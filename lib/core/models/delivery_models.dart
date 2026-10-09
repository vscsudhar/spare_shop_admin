import 'dart:math' as math;

class DeliveryPartnerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String status;
  final String? locationId;
  final String locationName;
  final int activeOrdersCount;

  const DeliveryPartnerModel({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    required this.role,
    this.status = 'Active',
    this.locationId,
    this.locationName = 'All Locations (HQ)',
    this.activeOrdersCount = 0,
  });

  bool get isActive => status.toLowerCase() == 'active';

  bool get isDeliveryRole {
    final r = role.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ');
    return r.contains('delivery') ||
        r.contains('driver') ||
        r.contains('dispatch') ||
        r.contains('courier');
  }

  DeliveryPartnerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? status,
    String? locationId,
    String? locationName,
    int? activeOrdersCount,
  }) {
    return DeliveryPartnerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      activeOrdersCount: activeOrdersCount ?? this.activeOrdersCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'status': status,
        'locationId': locationId,
        'locationName': locationName,
        'activeOrdersCount': activeOrdersCount,
      };

  factory DeliveryPartnerModel.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'])?.toString() ?? '';
    final name = (json['name'] ?? '').toString();
    final email = (json['email'] ?? '').toString();
    final phone = (json['phone'] ?? '').toString();

    String roleName = 'Delivery Driver';
    if (json['role'] is Map) {
      roleName = json['role']['name']?.toString() ?? roleName;
    } else if (json['role'] != null) {
      roleName = json['role'].toString();
    }

    String statusStr = 'Active';
    final rawStatus = json['status']?.toString().toLowerCase();
    if (rawStatus == 'inactive' || rawStatus == 'disabled') {
      statusStr = 'Inactive';
    } else if (rawStatus == 'on leave' || rawStatus == 'suspended') {
      statusStr = 'On Leave';
    }

    return DeliveryPartnerModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: roleName,
      status: statusStr,
      locationId: json['locationId']?.toString(),
      locationName: json['locationName']?.toString() ?? 'All Locations (HQ)',
      activeOrdersCount: json['activeOrdersCount'] is num
          ? (json['activeOrdersCount'] as num).toInt()
          : 0,
    );
  }
}

class DeliveryOrderModel {
  final String id;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final String address;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final String direction; // 'North', 'South', 'East', 'West', 'Central'
  final double amount;
  final String paymentStatus;
  final String paymentMethod;
  final String orderStatus;
  final String? assignedPartnerId;
  final String? assignedPartnerName;
  final int sequence;
  final String notes;

  const DeliveryOrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    this.customerPhone = '',
    required this.address,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.direction = 'North',
    required this.amount,
    this.paymentStatus = 'unpaid',
    this.paymentMethod = 'Online',
    this.orderStatus = 'processing',
    this.assignedPartnerId,
    this.assignedPartnerName,
    this.sequence = 1,
    this.notes = '',
  });

  bool get hasCoordinates =>
      latitude != null &&
      longitude != null &&
      latitude != 0.0 &&
      longitude != 0.0;

  bool get isAssigned =>
      assignedPartnerId != null && assignedPartnerId!.isNotEmpty;

  DeliveryOrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerName,
    String? customerPhone,
    String? address,
    double? latitude,
    double? longitude,
    double? distanceKm,
    String? direction,
    double? amount,
    String? paymentStatus,
    String? paymentMethod,
    String? orderStatus,
    String? assignedPartnerId,
    String? assignedPartnerName,
    int? sequence,
    String? notes,
  }) {
    return DeliveryOrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceKm: distanceKm ?? this.distanceKm,
      direction: direction ?? this.direction,
      amount: amount ?? this.amount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderStatus: orderStatus ?? this.orderStatus,
      assignedPartnerId: assignedPartnerId ?? this.assignedPartnerId,
      assignedPartnerName: assignedPartnerName ?? this.assignedPartnerName,
      sequence: sequence ?? this.sequence,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNumber': orderNumber,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'distanceKm': distanceKm,
        'direction': direction,
        'amount': amount,
        'paymentStatus': paymentStatus,
        'paymentMethod': paymentMethod,
        'orderStatus': orderStatus,
        'assignedPartnerId': assignedPartnerId,
        'assignedPartnerName': assignedPartnerName,
        'sequence': sequence,
        'notes': notes,
      };

  /// Robust payment status resolver that correctly recognizes online / prepaid methods
  static String resolvePaymentStatus({String? status, String? method}) {
    final s = (status ?? '').trim().toLowerCase();
    final m = (method ?? '').trim().toLowerCase();

    // Explicitly paid status
    if (s == 'paid' || s == 'completed' || s == 'success' || s == 'settled') {
      return 'paid';
    }

    // Online payment methods (Prepaid)
    if (m.contains('online') ||
        m.contains('upi') ||
        m.contains('card') ||
        m.contains('gpay') ||
        m.contains('google pay') ||
        m.contains('phonepe') ||
        m.contains('paytm') ||
        m.contains('netbanking') ||
        m.contains('net banking') ||
        m.contains('razorpay') ||
        m.contains('stripe') ||
        m.contains('prepaid') ||
        m.contains('credit') ||
        m.contains('debit') ||
        m.contains('pos counter') ||
        m.contains('wallet')) {
      return 'paid';
    }

    // Cash on Delivery
    if (m.contains('cod') || m.contains('cash')) {
      return (s == 'paid') ? 'paid' : 'unpaid';
    }

    // If method is present and not COD, default to paid
    if (m.isNotEmpty && !m.contains('cod') && !m.contains('cash')) {
      return 'paid';
    }

    return s.isNotEmpty ? s : 'unpaid';
  }

  factory DeliveryOrderModel.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'])?.toString() ?? '';
    final orderNum = (json['orderNumber'] ?? '').toString();

    String custName = 'Customer';
    String custPhone = '';
    String addrStr = 'Delivery Address';
    double? lat;
    double? lng;

    if (json['shippingAddress'] is Map) {
      final sa = json['shippingAddress'];
      custName = sa['recipientName']?.toString() ?? custName;
      custPhone = sa['phone']?.toString() ?? custPhone;
      lat = double.tryParse(sa['latitude']?.toString() ?? '');
      lng = double.tryParse(sa['longitude']?.toString() ?? '');

      final parts = [
        sa['addressLine1'],
        sa['addressLine2'],
        sa['city'],
        sa['state'],
        sa['postalCode'],
      ]
          .where((p) => p != null && p.toString().trim().isNotEmpty)
          .map((p) => p.toString().trim())
          .toList();
      if (parts.isNotEmpty) {
        addrStr = parts.join(', ');
      }
    } else if (json['customerName'] != null) {
      custName = json['customerName'].toString();
      custPhone = json['customerPhone']?.toString() ?? '';
      addrStr = json['address']?.toString() ?? addrStr;
      lat = double.tryParse(json['latitude']?.toString() ?? '');
      lng = double.tryParse(json['longitude']?.toString() ?? '');
    }

    if (json['user'] is Map) {
      if (custName == 'Customer') {
        custName = json['user']['name']?.toString() ?? custName;
      }
      if (custPhone.isEmpty) {
        custPhone = json['user']['phone']?.toString() ?? custPhone;
      }
    }

    double amt = 0.0;
    if (json['amount'] != null) {
      if (json['amount'] is num) {
        amt = (json['amount'] as num).toDouble();
      } else {
        amt = double.tryParse(json['amount'].toString()) ?? 0.0;
      }
    } else {
      final rawAmt = json['grandTotal'] ?? json['total'];
      if (rawAmt is num) {
        amt = rawAmt >= 10000 ? (rawAmt.toDouble() / 100.0) : rawAmt.toDouble();
      } else if (rawAmt != null) {
        final parsed = double.tryParse(rawAmt.toString());
        if (parsed != null) {
          amt = parsed >= 10000 ? (parsed / 100.0) : parsed;
        }
      }
    }

    String? partnerId;
    String? partnerName;
    if (json['deliveryAssignment'] is Map) {
      final da = json['deliveryAssignment'];
      if (da['driver'] is Map) {
        partnerId = (da['driver']['_id'] ?? da['driver']['id'])?.toString();
        partnerName = da['driver']['name']?.toString();
      } else if (da['driver'] != null) {
        partnerId = da['driver'].toString();
      }
    } else if (json['assignedPartnerId'] != null) {
      partnerId = json['assignedPartnerId']?.toString();
      partnerName = json['assignedPartnerName']?.toString();
    }

    double? dist = double.tryParse(
        json['distanceFromLocationKm']?.toString() ??
            json['distanceKm']?.toString() ??
            '');

    if ((dist == null || dist <= 0.0) &&
        lat != null &&
        lng != null &&
        lat != 0.0 &&
        lng != 0.0) {
      dist = calculateDistance(10.9027, 76.9606, lat, lng);
    }

    String dir = json['direction']?.toString() ?? '';
    if (dir.isEmpty && lat != null && lng != null) {
      dir = calculateDirectionFromHub(lat, lng);
    }
    if (dir.isEmpty) {
      dir = 'North';
    }

    final rawPaymentMethod = (json['paymentMethod'] ?? '').toString();
    final rawPaymentStatus = json['paymentStatus']?.toString();
    final resolvedStatus = resolvePaymentStatus(
      status: rawPaymentStatus,
      method: rawPaymentMethod,
    );

    return DeliveryOrderModel(
      id: id,
      orderNumber: orderNum.isNotEmpty ? orderNum : 'ORD-$id',
      customerName: custName,
      customerPhone: custPhone,
      address: addrStr,
      latitude: lat,
      longitude: lng,
      distanceKm: dist,
      direction: dir,
      amount: amt,
      paymentStatus: resolvedStatus,
      paymentMethod: rawPaymentMethod.isNotEmpty
          ? rawPaymentMethod
          : (resolvedStatus == 'paid' ? 'Online Payment' : 'Cash on Delivery'),
      orderStatus: (json['status'] ?? json['orderStatus'] ?? 'processing').toString(),
      assignedPartnerId: partnerId,
      assignedPartnerName: partnerName,
      sequence: json['sequence'] is num
          ? (json['sequence'] as num).toInt()
          : 1,
      notes: json['notes']?.toString() ?? '',
    );
  }

  /// Calculates straight/road distance in kilometers using the Haversine formula
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2, {
    bool applyRoadFactor = true,
  }) {
    const r = 6371.0; // Earth radius in km
    final dLat = (lat2 - lat1) * (math.pi / 180.0);
    final dLon = (lon2 - lon1) * (math.pi / 180.0);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180.0)) *
            math.cos(lat2 * (math.pi / 180.0)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final straight = r * c;
    if (applyRoadFactor) {
      // 1.25x road factor for urban navigation
      return double.parse((straight * 1.25).toStringAsFixed(1));
    }
    return double.parse(straight.toStringAsFixed(1));
  }

  static String calculateDirectionFromHub(double lat, double lng,
      {double hubLat = 10.9027, double hubLng = 76.9606}) {
    final dLat = lat - hubLat;
    final dLng = lng - hubLng;

    if (dLat.abs() < 0.005 && dLng.abs() < 0.005) {
      return 'Central';
    }

    final angle = math.atan2(dLng, dLat) * (180 / math.pi);
    if (angle >= -45 && angle < 45) return 'North';
    if (angle >= 45 && angle < 135) return 'East';
    if (angle >= -135 && angle < -45) return 'West';
    return 'South';
  }
}

class DeliveryHistoryItem {
  final String action;
  final String changedByName;
  final DateTime timestamp;
  final String notes;

  const DeliveryHistoryItem({
    required this.action,
    this.changedByName = 'Admin',
    required this.timestamp,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'action': action,
        'changedByName': changedByName,
        'timestamp': timestamp.toIso8601String(),
        'notes': notes,
      };

  factory DeliveryHistoryItem.fromJson(Map<String, dynamic> json) {
    return DeliveryHistoryItem(
      action: (json['action'] ?? 'Update').toString(),
      changedByName: (json['changedByName'] ?? json['changedBy'] ?? 'Admin').toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      notes: (json['notes'] ?? '').toString(),
    );
  }
}

class DeliveryAssignmentModel {
  final String id;
  final String batchNumber;
  final String driverId;
  final String driverName;
  final List<DeliveryOrderModel> orders;
  final String status; // 'assigned', 'in_transit', 'completed', 'cancelled'
  final int totalOrders;
  final double? totalDistanceKm;
  final double? estimatedDurationMin;
  final String assignedByName;
  final DateTime assignedAt;
  final String locationName;
  final String notes;
  final List<DeliveryHistoryItem> history;

  const DeliveryAssignmentModel({
    required this.id,
    required this.batchNumber,
    required this.driverId,
    required this.driverName,
    required this.orders,
    this.status = 'assigned',
    required this.totalOrders,
    this.totalDistanceKm,
    this.estimatedDurationMin,
    this.assignedByName = 'System Admin',
    required this.assignedAt,
    this.locationName = 'Madukkarai Hub',
    this.notes = '',
    this.history = const [],
  });

  double get totalAmount => orders.fold(0.0, (sum, o) => sum + o.amount);

  DeliveryAssignmentModel copyWith({
    String? id,
    String? batchNumber,
    String? driverId,
    String? driverName,
    List<DeliveryOrderModel>? orders,
    String? status,
    int? totalOrders,
    double? totalDistanceKm,
    double? estimatedDurationMin,
    String? assignedByName,
    DateTime? assignedAt,
    String? locationName,
    String? notes,
    List<DeliveryHistoryItem>? history,
  }) {
    return DeliveryAssignmentModel(
      id: id ?? this.id,
      batchNumber: batchNumber ?? this.batchNumber,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      orders: orders ?? this.orders,
      status: status ?? this.status,
      totalOrders: totalOrders ?? this.totalOrders,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      estimatedDurationMin: estimatedDurationMin ?? this.estimatedDurationMin,
      assignedByName: assignedByName ?? this.assignedByName,
      assignedAt: assignedAt ?? this.assignedAt,
      locationName: locationName ?? this.locationName,
      notes: notes ?? this.notes,
      history: history ?? this.history,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'batchNumber': batchNumber,
        'driverId': driverId,
        'driverName': driverName,
        'orders': orders.map((o) => o.toJson()).toList(),
        'status': status,
        'totalOrders': totalOrders,
        'totalDistanceKm': totalDistanceKm,
        'estimatedDurationMin': estimatedDurationMin,
        'assignedByName': assignedByName,
        'assignedAt': assignedAt.toIso8601String(),
        'locationName': locationName,
        'notes': notes,
        'history': history.map((h) => h.toJson()).toList(),
      };

  factory DeliveryAssignmentModel.fromJson(Map<String, dynamic> json) {
    final rawOrders = json['orders'] as List? ?? [];
    final ordersList = rawOrders
        .whereType<Map>()
        .map((o) => DeliveryOrderModel.fromJson(Map<String, dynamic>.from(o)))
        .toList();

    final rawHistory = json['history'] as List? ?? [];
    final historyList = rawHistory
        .whereType<Map>()
        .map((h) => DeliveryHistoryItem.fromJson(Map<String, dynamic>.from(h)))
        .toList();

    return DeliveryAssignmentModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      batchNumber: (json['batchNumber'] ?? 'BATCH-000').toString(),
      driverId: (json['driverId'] ?? json['driver']?['_id'] ?? json['driver'] ?? '').toString(),
      driverName: (json['driverName'] ?? json['driver']?['name'] ?? 'Driver').toString(),
      orders: ordersList,
      status: (json['status'] ?? 'assigned').toString(),
      totalOrders: json['totalOrders'] is num
          ? (json['totalOrders'] as num).toInt()
          : ordersList.length,
      totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble(),
      estimatedDurationMin: (json['estimatedDurationMin'] as num?)?.toDouble(),
      assignedByName: (json['assignedByName'] ?? 'System Admin').toString(),
      assignedAt: json['assignedAt'] != null
          ? DateTime.tryParse(json['assignedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      locationName: (json['locationName'] ?? 'Madukkarai Hub').toString(),
      notes: (json['notes'] ?? '').toString(),
      history: historyList,
    );
  }
}
