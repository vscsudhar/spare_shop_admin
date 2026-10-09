import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/models/delivery_models.dart';
import 'package:spare_shop_admin/core/services/order_service.dart';
import 'package:spare_shop_admin/core/services/staff_service.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';

class RouteResult {
  final List<LatLng> polyline;
  final double totalDistanceKm;
  final double totalDurationMinutes;
  final bool isRoadRouting;
  final String? warningMessage;

  const RouteResult({
    required this.polyline,
    required this.totalDistanceKm,
    required this.totalDurationMinutes,
    this.isRoadRouting = true,
    this.warningMessage,
  });
}

class DeliveryService {
  static const String _assignmentsStorageKey = 'voltspare_delivery_assignments_v3';
  static const double hubLatitude = 10.9027;
  static const double hubLongitude = 76.9606;
  static const String defaultHubName = 'Madukkarai Hub';

  /// Resolves exact GPS coordinates for known Coimbatore delivery localities
  static (double, double) getCoordinatesForAddress(String address, int index) {
    final a = address.toLowerCase();

    if (a.contains('eachanari')) {
      return (10.9250, 76.9740);
    } else if (a.contains('kuniyamuthur') || a.contains('palakkad main road')) {
      return (10.9540, 76.9580);
    } else if (a.contains('sundarapuram')) {
      return (10.9420, 76.9850);
    } else if (a.contains('podanur') || a.contains('chettipalayam')) {
      return (10.9620, 76.9950);
    } else if (a.contains('malumichampatti')) {
      return (10.8750, 76.9780);
    } else if (a.contains('kinathukadavu')) {
      return (10.8180, 77.0120);
    } else if (a.contains('pollachi')) {
      return (10.8900, 76.9800);
    } else if (a.contains('madukkarai')) {
      return (10.9080, 76.9620);
    } else if (a.contains('alandurai') || a.contains('siruvani')) {
      return (10.9200, 76.8400);
    } else if (a.contains('town hall') || a.contains('oppanakara')) {
      return (10.9980, 76.9620);
    } else if (a.contains('gandhipuram') || a.contains('cross cut')) {
      return (11.0180, 76.9680);
    } else if (a.contains('rs puram') ||
        a.contains('db road') ||
        a.contains('thadagam')) {
      return (11.0080, 76.9480);
    } else if (a.contains('tatabad') || a.contains('100 feet road')) {
      return (11.0210, 76.9650);
    } else if (a.contains('singanallur') || a.contains('trichy road')) {
      return (10.9980, 77.0220);
    } else if (a.contains('peelamedu') || a.contains('avinashi road')) {
      return (11.0250, 77.0150);
    } else if (a.contains('ganapathy') || a.contains('sathy road')) {
      return (11.0380, 76.9820);
    } else if (a.contains('vadavalli') || a.contains('marudhamalai')) {
      return (11.0220, 76.9020);
    } else if (a.contains('thudiyalur') || a.contains('mettupalayam road')) {
      return (11.0820, 76.9450);
    }

    final latOffsets = [
      0.022,
      -0.018,
      0.045,
      -0.035,
      0.065,
      0.082,
      0.032,
      0.095,
      -0.028,
      0.054
    ];
    final lngOffsets = [
      0.015,
      0.024,
      -0.018,
      0.038,
      0.052,
      0.012,
      -0.042,
      0.048,
      -0.022,
      0.062
    ];
    final lat = 10.9027 + latOffsets[index % latOffsets.length];
    final lng = 76.9606 + lngOffsets[index % lngOffsets.length];
    return (lat, lng);
  }

  final OrderService _orderService;
  final StaffService _staffService;
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
    ),
  );

  List<DeliveryAssignmentModel> _assignmentsCache = [];

  DeliveryService({
    OrderService? orderService,
    StaffService? staffService,
  })  : _orderService = orderService ?? locator<OrderService>(),
        _staffService = staffService ?? locator<StaffService>() {
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_assignmentsStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw);
        _assignmentsCache = decoded
            .whereType<Map>()
            .map((item) {
              final assignment = DeliveryAssignmentModel.fromJson(
                  Map<String, dynamic>.from(item));
              final validatedOrders = assignment.orders.map((o) {
                final resolvedPay = DeliveryOrderModel.resolvePaymentStatus(
                  status: o.paymentStatus,
                  method: o.paymentMethod,
                );
                final coords = (o.hasCoordinates)
                    ? (o.latitude!, o.longitude!)
                    : getCoordinatesForAddress(o.address, o.sequence);
                final dist = DeliveryOrderModel.calculateDistance(
                  hubLatitude,
                  hubLongitude,
                  coords.$1,
                  coords.$2,
                );
                return o.copyWith(
                  latitude: coords.$1,
                  longitude: coords.$2,
                  distanceKm: dist,
                  paymentStatus: resolvedPay,
                  paymentMethod: o.paymentMethod.isNotEmpty
                      ? o.paymentMethod
                      : (resolvedPay == 'paid' ? 'Online Payment' : 'Cash on Delivery'),
                );
              }).toList();
              return assignment.copyWith(orders: validatedOrders);
            })
            .toList();
      } else {
        _assignmentsCache = [];
      }
    } catch (e) {
      debugPrint('[DeliveryService] Error loading assignments: $e');
      _assignmentsCache = [];
    }
  }

  Future<void> _persistAssignments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_assignmentsCache.map((a) => a.toJson()).toList());
      await prefs.setString(_assignmentsStorageKey, encoded);
    } catch (e) {
      debugPrint('[DeliveryService] Error persisting assignments: $e');
    }
  }

  /// 1. Fetch eligible delivery partners from Staff & Roles
  Future<List<DeliveryPartnerModel>> getDeliveryPartners() async {
    await _loadAssignments();
    final staffList = await _staffService.getStaffMembers();

    // Filter staff members with delivery role or active status
    final deliveryStaff = staffList.where((s) {
      final roleLower = s.role.toLowerCase();
      final isDelivery = roleLower.contains('delivery') ||
          roleLower.contains('driver') ||
          roleLower.contains('dispatch');
      return isDelivery && s.status.toLowerCase() == 'active';
    }).toList();

    List<DeliveryPartnerModel> partners = [];

    if (deliveryStaff.isNotEmpty) {
      partners = deliveryStaff.map((s) {
        final activeOrders = _calculateActiveOrdersCount(s.id);
        return DeliveryPartnerModel(
          id: s.id,
          name: s.name,
          email: s.email,
          phone: s.phone,
          role: s.role,
          status: s.status,
          locationId: s.locationId,
          locationName: s.locationName,
          activeOrdersCount: activeOrders,
        );
      }).toList();
    } else {
      // Fallback: If no delivery staff configured yet in staff module, include active staff with delivery capability
      partners = staffList
          .where((s) => s.status.toLowerCase() == 'active')
          .map((s) {
            final activeOrders = _calculateActiveOrdersCount(s.id);
            return DeliveryPartnerModel(
              id: s.id,
              name: s.name,
              email: s.email,
              phone: s.phone,
              role: s.role.contains('Owner') || s.role.contains('Admin')
                  ? 'Delivery Driver (Admin Assigned)'
                  : s.role,
              status: s.status,
              locationId: s.locationId,
              locationName: s.locationName,
              activeOrdersCount: activeOrders,
            );
          })
          .toList();
    }

    // Fallback only if no staff members exist in database
    if (partners.isEmpty) {
      final samplePartners = [
        const DeliveryPartnerModel(
          id: 'staff_del_arun',
          name: 'Arun Kumar',
          email: 'arun.k@voltspare.com',
          phone: '+91 98765 11223',
          role: 'Delivery Driver',
          status: 'Active',
          locationName: 'Madukkarai Hub',
        ),
        const DeliveryPartnerModel(
          id: 'staff_del_kumar',
          name: 'Kumaravel S',
          email: 'kumar.s@voltspare.com',
          phone: '+91 98765 33445',
          role: 'Senior Delivery Driver',
          status: 'Active',
          locationName: 'Madukkarai Hub',
        ),
      ];

      for (final sp in samplePartners) {
        final count = _calculateActiveOrdersCount(sp.id);
        partners.add(sp.copyWith(activeOrdersCount: count));
      }
    }

    return partners;
  }

  int _calculateActiveOrdersCount(String driverId) {
    int count = 0;
    for (final b in _assignmentsCache) {
      if (b.driverId == driverId &&
          (b.status == 'assigned' || b.status == 'in_transit')) {
        count += b.orders.where((o) => o.orderStatus != 'cancelled').length;
      }
    }
    return count;
  }

  /// 2. Fetch eligible orders that can be assigned for delivery
  Future<List<DeliveryOrderModel>> getEligibleOrders({String? locationId}) async {
    await _loadAssignments();
    final List<OrderModel> allOrders =
        await _orderService.adminGetAllOrders(locationId: locationId);

    // Active assigned order IDs across all active batches
    final activeAssignedIds = <String>{};
    for (final batch in _assignmentsCache) {
      if (batch.status == 'assigned' || batch.status == 'in_transit') {
        for (final ord in batch.orders) {
          activeAssignedIds.add(ord.id);
          if (ord.orderNumber.isNotEmpty) {
            activeAssignedIds.add(ord.orderNumber);
          }
        }
      }
    }

    List<DeliveryOrderModel> eligible = [];

    for (int i = 0; i < allOrders.length; i++) {
      final order = allOrders[i];

      // ONLY include orders with 'processing' or 'shipped' status
      if (order.status != OrderStatus.processing &&
          order.status != OrderStatus.shipped) {
        continue;
      }

      // Exclude already actively assigned orders
      if (activeAssignedIds.contains(order.id) ||
          activeAssignedIds.contains(order.orderNumber)) {
        continue;
      }

      // 1. First priority: Use actual GPS coordinates from order address
      double? orderLat = order.address.latitude;
      double? orderLng = order.address.longitude;

      // 2. If coordinates not provided in address, resolve based on address landmark text
      if (orderLat == null || orderLng == null || orderLat == 0.0 || orderLng == 0.0) {
        final coords = getCoordinatesForAddress(order.address.addressLine, i);
        orderLat = coords.$1;
        orderLng = coords.$2;
      }

      // Calculate user location to Hub distance
      final double distKm = (order.address.distanceFromLocationKm != null &&
              order.address.distanceFromLocationKm! > 0)
          ? order.address.distanceFromLocationKm!
          : DeliveryOrderModel.calculateDistance(
              hubLatitude,
              hubLongitude,
              orderLat,
              orderLng,
            );
      final dir = DeliveryOrderModel.calculateDirectionFromHub(orderLat, orderLng);

      final resolvedPayStatus = DeliveryOrderModel.resolvePaymentStatus(
        status: order.paymentStatus,
        method: order.paymentMethod,
      );

      final dOrder = DeliveryOrderModel(
        id: order.id,
        orderNumber: order.orderNumber,
        customerName: order.address.name.isNotEmpty
            ? order.address.name
            : 'Customer ${i + 1}',
        customerPhone: order.address.phone.isNotEmpty
            ? order.address.phone
            : '+91 9840${(i * 1234 % 90000 + 10000)}',
        address: order.address.addressLine.isNotEmpty
            ? order.address.addressLine
            : 'Door No. ${i + 12}, Main Road, Coimbatore',
        latitude: orderLat,
        longitude: orderLng,
        distanceKm: distKm,
        direction: dir,
        amount: order.total,
        paymentStatus: resolvedPayStatus,
        paymentMethod: order.paymentMethod.isNotEmpty
            ? order.paymentMethod
            : (resolvedPayStatus == 'paid' ? 'Online UPI' : 'Cash on Delivery'),
        orderStatus: order.status.name,
        sequence: i + 1,
      );

      eligible.add(dOrder);
    }

    return eligible;
  }

  /// 3. Create a new Delivery Assignment Batch
  Future<DeliveryAssignmentModel> createAssignment({
    required String driverId,
    required String driverName,
    required List<DeliveryOrderModel> orders,
    String? notes,
    String? locationName,
    String? adminName,
  }) async {
    if (orders.isEmpty) {
      throw Exception('Cannot create assignment with zero orders.');
    }

    await _loadAssignments();

    // Sequence the stops
    final sequencedOrders = <DeliveryOrderModel>[];
    for (int i = 0; i < orders.length; i++) {
      final ord = orders[i].copyWith(
        sequence: i + 1,
        assignedPartnerId: driverId,
        assignedPartnerName: driverName,
      );
      sequencedOrders.add(ord);

      // Trigger backend order assignment update
      try {
        if (!ord.id.startsWith('ord_auto_gen_')) {
          await _orderService.adminAssignDelivery(ord.id, driverId,
              notes: 'Batch assignment to $driverName');
        }
      } catch (e) {
        debugPrint('[DeliveryService] API assign call: $e');
      }
    }

    // Compute route distance & duration
    final routeData = await calculateRoute(sequencedOrders);

    final batchCount = _assignmentsCache.length + 1;
    final batchNum = 'BATCH-DEL-${DateTime.now().year}-${batchCount.toString().padLeft(3, '0')}';

    final assignment = DeliveryAssignmentModel(
      id: 'batch_${DateTime.now().millisecondsSinceEpoch}',
      batchNumber: batchNum,
      driverId: driverId,
      driverName: driverName,
      orders: sequencedOrders,
      status: 'assigned',
      totalOrders: sequencedOrders.length,
      totalDistanceKm: routeData.totalDistanceKm,
      estimatedDurationMin: routeData.totalDurationMinutes,
      assignedByName: adminName ?? 'System Admin',
      assignedAt: DateTime.now(),
      locationName: locationName ?? defaultHubName,
      notes: notes ?? '',
      history: [
        DeliveryHistoryItem(
          action: 'Created',
          changedByName: adminName ?? 'System Admin',
          timestamp: DateTime.now(),
          notes: 'Assigned ${sequencedOrders.length} orders to $driverName',
        ),
      ],
    );

    _assignmentsCache.insert(0, assignment);
    await _persistAssignments();

    return assignment;
  }

  /// 4. Get all assignments with optional filtering
  Future<List<DeliveryAssignmentModel>> getAssignments({
    String? status,
    String? driverId,
    String? search,
  }) async {
    await _loadAssignments();
    List<DeliveryAssignmentModel> list = List.from(_assignmentsCache);

    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      list = list
          .where((a) => a.status.toLowerCase() == status.toLowerCase())
          .toList();
    }

    if (driverId != null && driverId.isNotEmpty && driverId.toLowerCase() != 'all') {
      list = list.where((a) => a.driverId == driverId).toList();
    }

    if (search != null && search.trim().isNotEmpty) {
      final s = search.trim().toLowerCase();
      list = list.where((a) {
        return a.batchNumber.toLowerCase().contains(s) ||
            a.driverName.toLowerCase().contains(s) ||
            a.orders.any((o) =>
                o.orderNumber.toLowerCase().contains(s) ||
                o.customerName.toLowerCase().contains(s));
      }).toList();
    }

    return list;
  }

  /// 5. Reassign delivery partner for a batch
  Future<DeliveryAssignmentModel> reassignDriver(
    String assignmentId,
    String newDriverId,
    String newDriverName, {
    String? adminName,
  }) async {
    await _loadAssignments();
    final idx = _assignmentsCache.indexWhere((a) => a.id == assignmentId);
    if (idx == -1) {
      throw Exception('Assignment batch not found.');
    }

    final old = _assignmentsCache[idx];
    final oldDriverName = old.driverName;

    final updatedOrders = old.orders
        .map((o) => o.copyWith(
              assignedPartnerId: newDriverId,
              assignedPartnerName: newDriverName,
            ))
        .toList();

    final updatedHistory = List<DeliveryHistoryItem>.from(old.history)
      ..add(
        DeliveryHistoryItem(
          action: 'Driver Reassigned',
          changedByName: adminName ?? 'System Admin',
          timestamp: DateTime.now(),
          notes: 'Reassigned from $oldDriverName to $newDriverName',
        ),
      );

    final updated = old.copyWith(
      driverId: newDriverId,
      driverName: newDriverName,
      orders: updatedOrders,
      history: updatedHistory,
    );

    _assignmentsCache[idx] = updated;
    await _persistAssignments();

    return updated;
  }

  /// 6. Remove an order from an active assignment (DOES NOT cancel customer order)
  Future<DeliveryAssignmentModel> removeOrderFromAssignment(
    String assignmentId,
    String orderId, {
    String? reason,
    String? adminName,
  }) async {
    await _loadAssignments();
    final idx = _assignmentsCache.indexWhere((a) => a.id == assignmentId);
    if (idx == -1) {
      throw Exception('Assignment batch not found.');
    }

    final old = _assignmentsCache[idx];
    final targetOrder = old.orders.firstWhere(
      (o) => o.id == orderId || o.orderNumber == orderId,
      orElse: () => throw Exception('Order not found in this assignment.'),
    );

    final remainingOrders = old.orders
        .where((o) => o.id != orderId && o.orderNumber != orderId)
        .toList();

    // Re-index remaining sequences
    for (int i = 0; i < remainingOrders.length; i++) {
      remainingOrders[i] = remainingOrders[i].copyWith(sequence: i + 1);
    }

    final updatedHistory = List<DeliveryHistoryItem>.from(old.history)
      ..add(
        DeliveryHistoryItem(
          action: 'Order Removed',
          changedByName: adminName ?? 'System Admin',
          timestamp: DateTime.now(),
          notes: 'Order ${targetOrder.orderNumber} removed. Reason: ${reason ?? "Removed by Admin for reassignment"}. Customer order remains active.',
        ),
      );

    final routeData = await calculateRoute(remainingOrders);

    final updated = old.copyWith(
      orders: remainingOrders,
      totalOrders: remainingOrders.length,
      totalDistanceKm: routeData.totalDistanceKm,
      estimatedDurationMin: routeData.totalDurationMinutes,
      history: updatedHistory,
    );

    _assignmentsCache[idx] = updated;
    await _persistAssignments();

    return updated;
  }

  /// 7. Add an order into an existing assignment
  Future<DeliveryAssignmentModel> addOrderToAssignment(
    String assignmentId,
    DeliveryOrderModel order, {
    String? adminName,
  }) async {
    await _loadAssignments();
    final idx = _assignmentsCache.indexWhere((a) => a.id == assignmentId);
    if (idx == -1) {
      throw Exception('Assignment batch not found.');
    }

    final old = _assignmentsCache[idx];
    final updatedOrders = List<DeliveryOrderModel>.from(old.orders);

    final newSeq = updatedOrders.length + 1;
    final newOrder = order.copyWith(
      sequence: newSeq,
      assignedPartnerId: old.driverId,
      assignedPartnerName: old.driverName,
    );
    updatedOrders.add(newOrder);

    final updatedHistory = List<DeliveryHistoryItem>.from(old.history)
      ..add(
        DeliveryHistoryItem(
          action: 'Order Added',
          changedByName: adminName ?? 'System Admin',
          timestamp: DateTime.now(),
          notes: 'Order ${newOrder.orderNumber} added to stop #$newSeq',
        ),
      );

    final routeData = await calculateRoute(updatedOrders);

    final updated = old.copyWith(
      orders: updatedOrders,
      totalOrders: updatedOrders.length,
      totalDistanceKm: routeData.totalDistanceKm,
      estimatedDurationMin: routeData.totalDurationMinutes,
      history: updatedHistory,
    );

    _assignmentsCache[idx] = updated;
    await _persistAssignments();

    return updated;
  }

  /// 8. Update stop sequence for an assignment
  Future<DeliveryAssignmentModel> updateStopSequence(
    String assignmentId,
    List<DeliveryOrderModel> reorderedOrders, {
    String? adminName,
  }) async {
    await _loadAssignments();
    final idx = _assignmentsCache.indexWhere((a) => a.id == assignmentId);
    if (idx == -1) {
      throw Exception('Assignment batch not found.');
    }

    final old = _assignmentsCache[idx];
    final updatedOrders = <DeliveryOrderModel>[];
    for (int i = 0; i < reorderedOrders.length; i++) {
      updatedOrders.add(reorderedOrders[i].copyWith(sequence: i + 1));
    }

    final updatedHistory = List<DeliveryHistoryItem>.from(old.history)
      ..add(
        DeliveryHistoryItem(
          action: 'Sequence Reordered',
          changedByName: adminName ?? 'System Admin',
          timestamp: DateTime.now(),
          notes: 'Stop sequence updated: ${updatedOrders.map((o) => o.orderNumber).join(' -> ')}',
        ),
      );

    final routeData = await calculateRoute(updatedOrders);

    final updated = old.copyWith(
      orders: updatedOrders,
      totalDistanceKm: routeData.totalDistanceKm,
      estimatedDurationMin: routeData.totalDurationMinutes,
      history: updatedHistory,
    );

    _assignmentsCache[idx] = updated;
    await _persistAssignments();

    return updated;
  }

  /// 9. Update assignment status and sync order module status
  Future<DeliveryAssignmentModel> updateAssignmentStatus(
    String assignmentId,
    String newStatus, {
    String? adminName,
    String? notes,
  }) async {
    await _loadAssignments();
    final idx = _assignmentsCache.indexWhere((a) => a.id == assignmentId);
    if (idx == -1) {
      throw Exception('Assignment batch not found.');
    }

    final old = _assignmentsCache[idx];

    // Determine corresponding order status in DB
    String dbOrderStatus = 'processing';
    if (newStatus == 'in_transit' || newStatus == 'shipped') {
      dbOrderStatus = 'shipped';
    } else if (newStatus == 'completed' || newStatus == 'delivered') {
      dbOrderStatus = 'delivered';
    } else if (newStatus == 'cancelled') {
      dbOrderStatus = 'processing';
    } else {
      dbOrderStatus = 'processing';
    }

    // Update order status on each order model within the batch
    final updatedOrders = old.orders.map((o) {
      return o.copyWith(orderStatus: dbOrderStatus);
    }).toList();

    // Synchronize every order to backend database
    for (final ord in old.orders) {
      if (!ord.id.startsWith('ord_auto_gen_')) {
        try {
          await _orderService.adminUpdateOrderStatus(ord.id, dbOrderStatus);
        } catch (e) {
          debugPrint('[DeliveryService] Failed to sync order status for ${ord.id}: $e');
        }
      }
    }

    final updatedHistory = List<DeliveryHistoryItem>.from(old.history)
      ..add(
        DeliveryHistoryItem(
          action: 'Status Changed',
          changedByName: adminName ?? 'System Admin',
          timestamp: DateTime.now(),
          notes: notes ?? 'Status updated to $newStatus (Synced ${old.orders.length} orders to $dbOrderStatus)',
        ),
      );

    final updated = old.copyWith(
      status: newStatus,
      orders: updatedOrders,
      history: updatedHistory,
    );

    _assignmentsCache[idx] = updated;
    await _persistAssignments();

    return updated;
  }

  /// 9b. Update individual stop status within a batch and sync order module
  Future<DeliveryAssignmentModel> updateOrderStopStatus(
    String assignmentId,
    String orderId,
    String newOrderStatus, {
    String? adminName,
    String? notes,
  }) async {
    await _loadAssignments();
    final idx = _assignmentsCache.indexWhere((a) => a.id == assignmentId);
    if (idx == -1) {
      throw Exception('Assignment batch not found.');
    }

    final old = _assignmentsCache[idx];

    // Map to DB status
    String dbStatus = 'processing';
    if (newOrderStatus == 'shipped' ||
        newOrderStatus == 'in_transit' ||
        newOrderStatus == 'out_for_delivery') {
      dbStatus = 'shipped';
    } else if (newOrderStatus == 'delivered' || newOrderStatus == 'completed') {
      dbStatus = 'delivered';
    } else if (newOrderStatus == 'cancelled') {
      dbStatus = 'cancelled';
    } else {
      dbStatus = 'processing';
    }

    final updatedOrders = old.orders.map((o) {
      if (o.id == orderId || o.orderNumber == orderId) {
        return o.copyWith(orderStatus: dbStatus);
      }
      return o;
    }).toList();

    // Call OrderService to sync status to MongoDB
    if (!orderId.startsWith('ord_auto_gen_')) {
      try {
        await _orderService.adminUpdateOrderStatus(orderId, dbStatus);
      } catch (e) {
        debugPrint('[DeliveryService] Failed to update single order status for $orderId: $e');
      }
    }

    // Determine batch status automatically if all stops are finished
    String batchStatus = old.status;
    final allDelivered = updatedOrders.isNotEmpty &&
        updatedOrders.every(
            (o) => o.orderStatus == 'delivered' || o.orderStatus == 'completed');
    final allCancelled = updatedOrders.isNotEmpty &&
        updatedOrders.every((o) => o.orderStatus == 'cancelled');
    final hasInTransit = updatedOrders.any((o) =>
        o.orderStatus == 'shipped' ||
        o.orderStatus == 'in_transit' ||
        o.orderStatus == 'out_for_delivery');

    if (allDelivered) {
      batchStatus = 'completed';
    } else if (allCancelled) {
      batchStatus = 'cancelled';
    } else if (hasInTransit && batchStatus == 'assigned') {
      batchStatus = 'in_transit';
    }

    final targetOrder = old.orders.firstWhere(
      (o) => o.id == orderId || o.orderNumber == orderId,
      orElse: () => old.orders.first,
    );

    final updatedHistory = List<DeliveryHistoryItem>.from(old.history)
      ..add(
        DeliveryHistoryItem(
          action: 'Order Stop Status Changed',
          changedByName: adminName ?? 'System Admin',
          timestamp: DateTime.now(),
          notes: notes ??
              'Stop ${targetOrder.orderNumber} status updated to $dbStatus',
        ),
      );

    final updated = old.copyWith(
      orders: updatedOrders,
      status: batchStatus,
      history: updatedHistory,
    );

    _assignmentsCache[idx] = updated;
    await _persistAssignments();

    return updated;
  }

  /// 10. OpenStreetMap-Based Route Planning with OSRM Road Engine & Waypoint Fallback
  Future<RouteResult> calculateRoute(
    List<DeliveryOrderModel> stops, {
    double hubLat = hubLatitude,
    double hubLng = hubLongitude,
  }) async {
    final validStops = stops.where((s) => s.hasCoordinates).toList();

    if (validStops.isEmpty) {
      return const RouteResult(
        polyline: [],
        totalDistanceKm: 0,
        totalDurationMinutes: 0,
        isRoadRouting: false,
        warningMessage: 'No delivery stops have valid GPS coordinates.',
      );
    }

    // Build waypoint coordinates starting from Hub
    final waypoints = <LatLng>[LatLng(hubLat, hubLng)];
    for (final s in validStops) {
      waypoints.add(LatLng(s.latitude!, s.longitude!));
    }

    // 1. Attempt road routing via public OSRM engine
    try {
      final coordsString =
          waypoints.map((w) => '${w.longitude},${w.latitude}').join(';');
      final url =
          'https://router.project-osrm.org/route/v1/driving/$coordsString?overview=full&geometries=geojson';

      final response = await _dio.get(url);
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['routes'] is List &&
          (response.data['routes'] as List).isNotEmpty) {
        final route = response.data['routes'][0];
        final distanceMeters = (route['distance'] as num?)?.toDouble() ?? 0;
        final durationSeconds = (route['duration'] as num?)?.toDouble() ?? 0;
        final geometry = route['geometry'];

        final polylinePoints = <LatLng>[];
        if (geometry is Map && geometry['coordinates'] is List) {
          final coordsList = geometry['coordinates'] as List;
          for (final c in coordsList) {
            if (c is List && c.length >= 2) {
              final lng = (c[0] as num).toDouble();
              final lat = (c[1] as num).toDouble();
              polylinePoints.add(LatLng(lat, lng));
            }
          }
        }

        final distKm = double.parse((distanceMeters / 1000.0).toStringAsFixed(1));
        final durMin = double.parse((durationSeconds / 60.0).toStringAsFixed(0));

        return RouteResult(
          polyline: polylinePoints.isNotEmpty ? polylinePoints : waypoints,
          totalDistanceKm: distKm,
          totalDurationMinutes: durMin,
          isRoadRouting: true,
        );
      }
    } catch (e) {
      debugPrint('[DeliveryService] OSRM Road routing fallback to waypoints: $e');
    }

    // 2. Fallback: Straight-line waypoint calculation with Haversine distance
    double totalDist = 0.0;
    for (int i = 0; i < waypoints.length - 1; i++) {
      totalDist += DeliveryOrderModel.calculateDistance(
        waypoints[i].latitude,
        waypoints[i].longitude,
        waypoints[i + 1].latitude,
        waypoints[i + 1].longitude,
        applyRoadFactor: false,
      );
    }

    // Road factor approximation (+25% over straight line for urban road networks)
    final approxRoadKm = double.parse((totalDist * 1.25).toStringAsFixed(1));
    final approxDurMin = double.parse((approxRoadKm * 2.8).toStringAsFixed(0));

    return RouteResult(
      polyline: waypoints,
      totalDistanceKm: approxRoadKm,
      totalDurationMinutes: approxDurMin,
      isRoadRouting: false,
      warningMessage: 'Online road routing unavailable. Displaying direct waypoint path.',
    );
  }
}
