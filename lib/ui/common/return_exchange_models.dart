enum AfterSalesAction {
  none,
  returnAction,
  damage,
  exchange,
}

extension AfterSalesActionExt on AfterSalesAction {
  String get apiValue {
    switch (this) {
      case AfterSalesAction.returnAction:
        return 'return';
      case AfterSalesAction.damage:
        return 'damage';
      case AfterSalesAction.exchange:
        return 'exchange';
      default:
        return 'none';
    }
  }

  String get label {
    switch (this) {
      case AfterSalesAction.returnAction:
        return 'Return';
      case AfterSalesAction.damage:
        return 'Damage';
      case AfterSalesAction.exchange:
        return 'Exchange';
      default:
        return 'No Action';
    }
  }
}

enum AfterSalesStatus {
  pending,
  approved,
  rejected,
  received,
  processing,
  completed,
  cancelled,
}

extension AfterSalesStatusExt on AfterSalesStatus {
  String get label {
    switch (this) {
      case AfterSalesStatus.pending:
        return 'Pending Review';
      case AfterSalesStatus.approved:
        return 'Approved';
      case AfterSalesStatus.rejected:
        return 'Rejected';
      case AfterSalesStatus.received:
        return 'Received';
      case AfterSalesStatus.processing:
        return 'Processing';
      case AfterSalesStatus.completed:
        return 'Completed';
      case AfterSalesStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class BillItemProcessedSummary {
  final String orderItemId;
  final String productId;
  final String name;
  final String sku;
  final String image;
  final double unitPrice; // in Rupees
  final double totalPrice; // in Rupees
  final int purchasedQty;
  final int returnedQty;
  final int damagedQty;
  final int exchangedQty;
  final int availableQty;

  const BillItemProcessedSummary({
    required this.orderItemId,
    required this.productId,
    required this.name,
    required this.sku,
    required this.image,
    required this.unitPrice,
    required this.totalPrice,
    required this.purchasedQty,
    required this.returnedQty,
    required this.damagedQty,
    required this.exchangedQty,
    required this.availableQty,
  });

  factory BillItemProcessedSummary.fromJson(Map<String, dynamic> json) {
    return BillItemProcessedSummary(
      orderItemId: json['orderItemId']?.toString() ?? '',
      productId: json['product']?.toString() ?? '',
      name: json['name'] ?? 'Spare Part',
      sku: json['sku'] ?? '',
      image: json['image'] ?? '',
      unitPrice: ((json['unitPrice'] ?? 0) as num).toDouble() / 100.0,
      totalPrice: ((json['totalPrice'] ?? 0) as num).toDouble() / 100.0,
      purchasedQty: json['purchasedQty'] ?? 1,
      returnedQty: json['returnedQty'] ?? 0,
      damagedQty: json['damagedQty'] ?? 0,
      exchangedQty: json['exchangedQty'] ?? 0,
      availableQty: json['availableQty'] ?? 0,
    );
  }
}

class BillLookupResult {
  final String orderId;
  final String orderNumber;
  final String billNumber;
  final String invoiceNumber;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final DateTime orderDate;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final double grandTotal;
  final List<BillItemProcessedSummary> items;
  final List<dynamic> existingCases;

  const BillLookupResult({
    required this.orderId,
    required this.orderNumber,
    required this.billNumber,
    required this.invoiceNumber,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.orderDate,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.grandTotal,
    required this.items,
    required this.existingCases,
  });

  factory BillLookupResult.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> customer = {};
    if (json['customer'] is Map) {
      customer = Map<String, dynamic>.from(json['customer'] as Map);
    } else if (json['customerSnapshot'] is Map) {
      customer = Map<String, dynamic>.from(json['customerSnapshot'] as Map);
    }
    final rawItems = json['items'] is List ? (json['items'] as List) : [];

    DateTime dt = DateTime.now();
    if (json['orderDate'] != null) {
      try {
        dt = DateTime.parse(json['orderDate'].toString());
      } catch (_) {}
    }

    return BillLookupResult(
      orderId: json['orderId']?.toString() ?? json['_id']?.toString() ?? '',
      orderNumber: (json['orderNumber'] ?? '').toString(),
      billNumber: (json['billNumber'] ?? '').toString(),
      invoiceNumber: (json['invoiceNumber'] ?? '').toString(),
      customerName: (customer['name'] ?? json['customerName'] ?? 'Walk-in Customer').toString(),
      customerPhone: (customer['phone'] ?? json['customerPhone'] ?? '').toString(),
      customerEmail: (customer['email'] ?? json['customerEmail'] ?? '').toString(),
      orderDate: dt,
      orderStatus: (json['orderStatus'] ?? 'delivered').toString(),
      paymentStatus: (json['paymentStatus'] ?? 'paid').toString(),
      paymentMethod: (json['paymentMethod'] ?? 'cash').toString(),
      grandTotal: ((json['grandTotal'] ?? json['total'] ?? 0) as num).toDouble() / 100.0,
      items: rawItems
          .whereType<Map>()
          .map((i) => BillItemProcessedSummary.fromJson(Map<String, dynamic>.from(i)))
          .toList(),
      existingCases: json['existingCases'] is List ? (json['existingCases'] as List) : [],
    );
  }
}

class ReturnExchangeHistory {
  final String action;
  final String fromStatus;
  final String toStatus;
  final String notes;
  final String changedByName;
  final DateTime timestamp;

  const ReturnExchangeHistory({
    required this.action,
    required this.fromStatus,
    required this.toStatus,
    required this.notes,
    required this.changedByName,
    required this.timestamp,
  });

  factory ReturnExchangeHistory.fromJson(Map<String, dynamic> json) {
    DateTime dt = DateTime.now();
    if (json['timestamp'] != null) {
      try {
        dt = DateTime.parse(json['timestamp'].toString());
      } catch (_) {}
    }

    return ReturnExchangeHistory(
      action: json['action'] ?? '',
      fromStatus: json['fromStatus'] ?? '',
      toStatus: json['toStatus'] ?? '',
      notes: json['notes'] ?? '',
      changedByName: json['changedByName'] ?? 'Admin',
      timestamp: dt,
    );
  }
}

class ReturnExchangeItem {
  final String orderItemId;
  final String productId;
  final String productName;
  final String sku;
  final double unitPrice;
  final int originalQty;
  final int processedQty;
  final String action;
  final String reasonText;
  final String condition;
  final String inventoryDisposition;
  final bool refundRequired;
  final double refundAmount;
  final String refundMethod;
  final String refundStatus;
  final String? replacementProductId;
  final String replacementProductName;
  final int replacementQty;
  final String differenceType;
  final double differenceAmount;
  final String damageType;
  final String damageDiscoveredAt;
  final String damageResolution;
  final String notes;

  const ReturnExchangeItem({
    required this.orderItemId,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.unitPrice,
    required this.originalQty,
    required this.processedQty,
    required this.action,
    required this.reasonText,
    required this.condition,
    required this.inventoryDisposition,
    required this.refundRequired,
    required this.refundAmount,
    required this.refundMethod,
    required this.refundStatus,
    this.replacementProductId,
    required this.replacementProductName,
    required this.replacementQty,
    required this.differenceType,
    required this.differenceAmount,
    required this.damageType,
    required this.damageDiscoveredAt,
    required this.damageResolution,
    required this.notes,
  });

  factory ReturnExchangeItem.fromJson(Map<String, dynamic> json) {
    String pId = '';
    String pName = (json['productNameSnapshot'] ?? json['productName'] ?? '').toString();
    String sku = (json['skuSnapshot'] ?? json['sku'] ?? '').toString();

    if (json['product'] is Map) {
      final pMap = json['product'] as Map;
      pId = (pMap['_id'] ?? pMap['id'] ?? '').toString();
      if (pName.isEmpty) pName = (pMap['name'] ?? '').toString();
      if (sku.isEmpty) sku = (pMap['sku'] ?? '').toString();
    } else {
      pId = json['product']?.toString() ?? '';
    }

    String repId = '';
    String repName = (json['replacementProductNameSnapshot'] ?? json['replacementProductName'] ?? '').toString();
    if (json['replacementProduct'] is Map) {
      final rMap = json['replacementProduct'] as Map;
      repId = (rMap['_id'] ?? rMap['id'] ?? '').toString();
      if (repName.isEmpty) repName = (rMap['name'] ?? '').toString();
    } else if (json['replacementProduct'] != null) {
      repId = json['replacementProduct'].toString();
    }

    return ReturnExchangeItem(
      orderItemId: (json['orderItemId'] ?? '').toString(),
      productId: pId,
      productName: pName.isNotEmpty ? pName : 'Spare Part',
      sku: sku,
      unitPrice: ((json['unitPrice'] ?? 0) as num).toDouble() / 100.0,
      originalQty: json['originalQty'] is num ? (json['originalQty'] as num).toInt() : 1,
      processedQty: json['processedQty'] is num ? (json['processedQty'] as num).toInt() : 1,
      action: (json['action'] ?? 'return').toString(),
      reasonText: (json['reasonText'] ?? '').toString(),
      condition: (json['condition'] ?? 'unused').toString(),
      inventoryDisposition: (json['inventoryDisposition'] ?? 'sellable').toString(),
      refundRequired: json['refundRequired'] ?? false,
      refundAmount: ((json['refundAmount'] ?? 0) as num).toDouble() / 100.0,
      refundMethod: (json['refundMethod'] ?? 'none').toString(),
      refundStatus: (json['refundStatus'] ?? 'na').toString(),
      replacementProductId: repId.isNotEmpty ? repId : null,
      replacementProductName: repName,
      replacementQty: json['replacementQty'] is num ? (json['replacementQty'] as num).toInt() : 0,
      differenceType: (json['differenceType'] ?? 'none').toString(),
      differenceAmount: ((json['differenceAmount'] ?? 0) as num).toDouble() / 100.0,
      damageType: (json['damageType'] ?? 'na').toString(),
      damageDiscoveredAt: (json['damageDiscoveredAt'] ?? 'na').toString(),
      damageResolution: (json['damageResolution'] ?? 'na').toString(),
      notes: (json['notes'] ?? '').toString(),
    );
  }
}

class ReturnExchangeCase {
  final String id;
  final String caseNumber;
  final String orderId;
  final String billNumber;
  final String invoiceNumber;
  final String customerName;
  final String customerPhone;
  final String type; // return | damage | exchange | mixed
  final String status; // pending | approved | rejected | received | processing | completed | cancelled
  final String channel; // 'online' (Mobile App) or 'in_store' (Store Visit)
  final String? locationId;
  final String? locationName;
  final List<ReturnExchangeItem> items;
  final double totalRefundAmount;
  final double totalPayableAmount;
  final List<ReturnExchangeHistory> history;
  final String adminNotes;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReturnExchangeCase({
    required this.id,
    required this.caseNumber,
    required this.orderId,
    required this.billNumber,
    required this.invoiceNumber,
    required this.customerName,
    required this.customerPhone,
    required this.type,
    required this.status,
    this.channel = 'in_store',
    this.locationId,
    this.locationName,
    required this.items,
    required this.totalRefundAmount,
    required this.totalPayableAmount,
    required this.history,
    required this.adminNotes,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReturnExchangeCase.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> customer = {};
    if (json['customerSnapshot'] is Map) {
      customer = Map<String, dynamic>.from(json['customerSnapshot'] as Map);
    } else if (json['customer'] is Map) {
      customer = Map<String, dynamic>.from(json['customer'] as Map);
    } else if (json['user'] is Map) {
      customer = Map<String, dynamic>.from(json['user'] as Map);
    }

    Map<String, dynamic> createdBy = {};
    if (json['createdBy'] is Map) {
      createdBy = Map<String, dynamic>.from(json['createdBy'] as Map);
    }

    final rawItems = json['items'] is List ? (json['items'] as List) : [];
    final rawHistory = json['history'] is List ? (json['history'] as List) : [];

    DateTime dtCreated = DateTime.now();
    DateTime dtUpdated = DateTime.now();
    if (json['createdAt'] != null) {
      try {
        dtCreated = DateTime.parse(json['createdAt'].toString());
      } catch (_) {}
    }
    if (json['updatedAt'] != null) {
      try {
        dtUpdated = DateTime.parse(json['updatedAt'].toString());
      } catch (_) {}
    }

    String? locId;
    String? locName;
    if (json['locationId'] is Map) {
      locId = (json['locationId']['_id'] ?? json['locationId']['id'])?.toString();
      locName = json['locationId']['name']?.toString();
    } else if (json['locationId'] != null) {
      locId = json['locationId'].toString();
    } else if (json['location'] is Map) {
      locId = (json['location']['_id'] ?? json['location']['id'])?.toString();
      locName = json['location']['name']?.toString();
    } else if (json['location'] != null) {
      locId = json['location'].toString();
    }

    if (json['locationName'] != null && json['locationName'].toString().isNotEmpty) {
      locName = json['locationName'].toString();
    }

    final rawChannel = (json['channel'] ?? json['source'] ?? 'in_store').toString().toLowerCase();
    final channel = rawChannel.contains('app') || rawChannel.contains('online')
        ? 'online'
        : 'in_store';

    return ReturnExchangeCase(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      caseNumber: (json['caseNumber'] ?? '').toString(),
      orderId: json['order'] is Map ? (json['order']['_id']?.toString() ?? '') : (json['order']?.toString() ?? ''),
      billNumber: (json['billNumber'] ?? '').toString(),
      invoiceNumber: (json['invoiceNumber'] ?? '').toString(),
      customerName: (customer['name'] ?? json['customerName'] ?? 'Walk-in Customer').toString(),
      customerPhone: (customer['phone'] ?? json['customerPhone'] ?? '').toString(),
      type: (json['type'] ?? 'return').toString(),
      status: (json['status'] ?? 'pending').toString(),
      channel: channel,
      locationId: locId,
      locationName: locName,
      items: rawItems
          .whereType<Map>()
          .map((i) => ReturnExchangeItem.fromJson(Map<String, dynamic>.from(i)))
          .toList(),
      totalRefundAmount: ((json['totalRefundAmount'] ?? 0) as num).toDouble() / 100.0,
      totalPayableAmount: ((json['totalPayableAmount'] ?? 0) as num).toDouble() / 100.0,
      history: rawHistory
          .whereType<Map>()
          .map((h) => ReturnExchangeHistory.fromJson(Map<String, dynamic>.from(h)))
          .toList(),
      adminNotes: (json['adminNotes'] ?? '').toString(),
      createdByName: (createdBy['name'] ?? json['createdByName'] ?? 'Admin').toString(),
      createdAt: dtCreated,
      updatedAt: dtUpdated,
    );
  }

  ReturnExchangeCase copyWith({
    String? id,
    String? caseNumber,
    String? orderId,
    String? billNumber,
    String? invoiceNumber,
    String? customerName,
    String? customerPhone,
    String? type,
    String? status,
    String? channel,
    String? locationId,
    String? locationName,
    List<ReturnExchangeItem>? items,
    double? totalRefundAmount,
    double? totalPayableAmount,
    List<ReturnExchangeHistory>? history,
    String? adminNotes,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReturnExchangeCase(
      id: id ?? this.id,
      caseNumber: caseNumber ?? this.caseNumber,
      orderId: orderId ?? this.orderId,
      billNumber: billNumber ?? this.billNumber,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      type: type ?? this.type,
      status: status ?? this.status,
      channel: channel ?? this.channel,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      items: items ?? this.items,
      totalRefundAmount: totalRefundAmount ?? this.totalRefundAmount,
      totalPayableAmount: totalPayableAmount ?? this.totalPayableAmount,
      history: history ?? this.history,
      adminNotes: adminNotes ?? this.adminNotes,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DamagedItemsMetrics {
  final int totalDamagedQty;
  final double totalLossValue;
  final int scrappedCount;
  final int vendorClaimCount;
  final int totalRecords;

  DamagedItemsMetrics({
    required this.totalDamagedQty,
    required this.totalLossValue,
    required this.scrappedCount,
    required this.vendorClaimCount,
    required this.totalRecords,
  });

  factory DamagedItemsMetrics.fromJson(Map<String, dynamic> json) {
    return DamagedItemsMetrics(
      totalDamagedQty: json['totalDamagedQty'] is num ? (json['totalDamagedQty'] as num).toInt() : 0,
      totalLossValue: ((json['totalLossValue'] ?? 0) as num).toDouble() / 100.0,
      scrappedCount: json['scrappedCount'] is num ? (json['scrappedCount'] as num).toInt() : 0,
      vendorClaimCount: json['vendorClaimCount'] is num ? (json['vendorClaimCount'] as num).toInt() : 0,
      totalRecords: json['totalRecords'] is num ? (json['totalRecords'] as num).toInt() : 0,
    );
  }
}

class DamagedItemRecord {
  final String caseId;
  final String caseNumber;
  final String billNumber;
  final String invoiceNumber;
  final String customerName;
  final String customerPhone;
  final String caseStatus;
  final String channel; // 'online' or 'in_store'
  final String? locationId;
  final String? locationName;
  final DateTime createdAt;
  final String itemId;
  final String productId;
  final String productName;
  final String sku;
  final String image;
  final int quantity;
  final double unitPrice;
  final double totalLoss;
  final String damageType;
  final String damageDiscoveredAt;
  final String damageResolution;
  final String reasonText;
  final String notes;

  DamagedItemRecord({
    required this.caseId,
    required this.caseNumber,
    required this.billNumber,
    required this.invoiceNumber,
    required this.customerName,
    required this.customerPhone,
    required this.caseStatus,
    this.channel = 'in_store',
    this.locationId,
    this.locationName,
    required this.createdAt,
    required this.itemId,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.image,
    required this.quantity,
    required this.unitPrice,
    required this.totalLoss,
    required this.damageType,
    required this.damageDiscoveredAt,
    required this.damageResolution,
    required this.reasonText,
    required this.notes,
  });

  factory DamagedItemRecord.fromJson(Map<String, dynamic> json) {
    DateTime dtCreated = DateTime.now();
    if (json['createdAt'] != null) {
      try {
        dtCreated = DateTime.parse(json['createdAt'].toString());
      } catch (_) {}
    }

    String? locId;
    String? locName;
    if (json['locationId'] is Map) {
      locId = (json['locationId']['_id'] ?? json['locationId']['id'])?.toString();
      locName = json['locationId']['name']?.toString();
    } else if (json['locationId'] != null) {
      locId = json['locationId'].toString();
    } else if (json['location'] is Map) {
      locId = (json['location']['_id'] ?? json['location']['id'])?.toString();
      locName = json['location']['name']?.toString();
    } else if (json['location'] != null) {
      locId = json['location'].toString();
    }

    if (json['locationName'] != null && json['locationName'].toString().isNotEmpty) {
      locName = json['locationName'].toString();
    }

    final rawChannel = (json['channel'] ?? json['source'] ?? 'in_store').toString().toLowerCase();
    final channel = rawChannel.contains('app') || rawChannel.contains('online')
        ? 'online'
        : 'in_store';

    String cName = (json['customerName'] ?? '').toString();
    String cPhone = (json['customerPhone'] ?? '').toString();
    if (json['customerSnapshot'] is Map) {
      final snap = json['customerSnapshot'] as Map;
      if (cName.isEmpty) cName = (snap['name'] ?? '').toString();
      if (cPhone.isEmpty) cPhone = (snap['phone'] ?? '').toString();
    }

    return DamagedItemRecord(
      caseId: (json['caseId'] ?? json['_id'] ?? '').toString(),
      caseNumber: (json['caseNumber'] ?? '').toString(),
      billNumber: (json['billNumber'] ?? '').toString(),
      invoiceNumber: (json['invoiceNumber'] ?? '').toString(),
      customerName: cName.isNotEmpty ? cName : 'Walk-in Customer',
      customerPhone: cPhone,
      caseStatus: (json['caseStatus'] ?? json['status'] ?? 'pending').toString(),
      channel: channel,
      locationId: locId,
      locationName: locName,
      createdAt: dtCreated,
      itemId: (json['itemId'] ?? json['_id'] ?? '').toString(),
      productId: json['product'] is Map ? (json['product']['_id']?.toString() ?? '') : (json['productId']?.toString() ?? json['product']?.toString() ?? ''),
      productName: (json['productName'] ?? json['productNameSnapshot'] ?? (json['product'] is Map ? json['product']['name'] : null) ?? 'Damaged Product').toString(),
      sku: (json['sku'] ?? json['skuSnapshot'] ?? (json['product'] is Map ? json['product']['sku'] : null) ?? '').toString(),
      image: (json['image'] ?? (json['product'] is Map ? json['product']['image'] : null) ?? '').toString(),
      quantity: json['quantity'] is num ? (json['quantity'] as num).toInt() : (json['processedQty'] is num ? (json['processedQty'] as num).toInt() : 1),
      unitPrice: ((json['unitPrice'] ?? 0) as num).toDouble() / 100.0,
      totalLoss: ((json['totalLoss'] ?? json['refundAmount'] ?? json['unitPrice'] ?? 0) as num).toDouble() / 100.0,
      damageType: (json['damageType'] ?? 'physical').toString(),
      damageDiscoveredAt: (json['damageDiscoveredAt'] ?? 'customer').toString(),
      damageResolution: (json['damageResolution'] ?? 'no_refund').toString(),
      reasonText: (json['reasonText'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
    );
  }

  DamagedItemRecord copyWith({
    String? caseId,
    String? caseNumber,
    String? billNumber,
    String? invoiceNumber,
    String? customerName,
    String? customerPhone,
    String? caseStatus,
    String? channel,
    String? locationId,
    String? locationName,
    DateTime? createdAt,
    String? itemId,
    String? productId,
    String? productName,
    String? sku,
    String? image,
    int? quantity,
    double? unitPrice,
    double? totalLoss,
    String? damageType,
    String? damageDiscoveredAt,
    String? damageResolution,
    String? reasonText,
    String? notes,
  }) {
    return DamagedItemRecord(
      caseId: caseId ?? this.caseId,
      caseNumber: caseNumber ?? this.caseNumber,
      billNumber: billNumber ?? this.billNumber,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      caseStatus: caseStatus ?? this.caseStatus,
      channel: channel ?? this.channel,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      createdAt: createdAt ?? this.createdAt,
      itemId: itemId ?? this.itemId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalLoss: totalLoss ?? this.totalLoss,
      damageType: damageType ?? this.damageType,
      damageDiscoveredAt: damageDiscoveredAt ?? this.damageDiscoveredAt,
      damageResolution: damageResolution ?? this.damageResolution,
      reasonText: reasonText ?? this.reasonText,
      notes: notes ?? this.notes,
    );
  }
}

class DamagedItemsResponse {
  final DamagedItemsMetrics metrics;
  final List<DamagedItemRecord> items;
  final int total;

  DamagedItemsResponse({
    required this.metrics,
    required this.items,
    required this.total,
  });
}
