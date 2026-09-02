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
    final customer = json['customer'] as Map<String, dynamic>? ?? {};
    final rawItems = json['items'] as List<dynamic>? ?? [];

    DateTime dt = DateTime.now();
    if (json['orderDate'] != null) {
      try {
        dt = DateTime.parse(json['orderDate'].toString());
      } catch (_) {}
    }

    return BillLookupResult(
      orderId: json['orderId']?.toString() ?? '',
      orderNumber: json['orderNumber'] ?? '',
      billNumber: json['billNumber'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      customerName: customer['name'] ?? 'Walk-in Customer',
      customerPhone: customer['phone'] ?? '',
      customerEmail: customer['email'] ?? '',
      orderDate: dt,
      orderStatus: json['orderStatus'] ?? 'delivered',
      paymentStatus: json['paymentStatus'] ?? 'paid',
      paymentMethod: json['paymentMethod'] ?? 'cash',
      grandTotal: ((json['grandTotal'] ?? 0) as num).toDouble() / 100.0,
      items: rawItems.map((i) => BillItemProcessedSummary.fromJson(i)).toList(),
      existingCases: json['existingCases'] as List<dynamic>? ?? [],
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
    return ReturnExchangeItem(
      orderItemId: json['orderItemId']?.toString() ?? '',
      productId: json['product'] is Map ? (json['product']['_id']?.toString() ?? '') : (json['product']?.toString() ?? ''),
      productName: json['productNameSnapshot'] ?? '',
      sku: json['skuSnapshot'] ?? '',
      unitPrice: ((json['unitPrice'] ?? 0) as num).toDouble() / 100.0,
      originalQty: json['originalQty'] ?? 1,
      processedQty: json['processedQty'] ?? 1,
      action: json['action'] ?? 'return',
      reasonText: json['reasonText'] ?? '',
      condition: json['condition'] ?? 'unused',
      inventoryDisposition: json['inventoryDisposition'] ?? 'sellable',
      refundRequired: json['refundRequired'] ?? false,
      refundAmount: ((json['refundAmount'] ?? 0) as num).toDouble() / 100.0,
      refundMethod: json['refundMethod'] ?? 'none',
      refundStatus: json['refundStatus'] ?? 'na',
      replacementProductId: json['replacementProduct'] is Map
          ? (json['replacementProduct']['_id']?.toString())
          : (json['replacementProduct']?.toString()),
      replacementProductName: json['replacementProductNameSnapshot'] ?? '',
      replacementQty: json['replacementQty'] ?? 0,
      differenceType: json['differenceType'] ?? 'none',
      differenceAmount: ((json['differenceAmount'] ?? 0) as num).toDouble() / 100.0,
      damageType: json['damageType'] ?? 'na',
      damageDiscoveredAt: json['damageDiscoveredAt'] ?? 'na',
      damageResolution: json['damageResolution'] ?? 'na',
      notes: json['notes'] ?? '',
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
    final customer = json['customerSnapshot'] as Map<String, dynamic>? ?? {};
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final rawHistory = json['history'] as List<dynamic>? ?? [];
    final createdBy = json['createdBy'] as Map<String, dynamic>? ?? {};

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

    return ReturnExchangeCase(
      id: json['_id']?.toString() ?? '',
      caseNumber: json['caseNumber'] ?? '',
      orderId: json['order'] is Map ? (json['order']['_id']?.toString() ?? '') : (json['order']?.toString() ?? ''),
      billNumber: json['billNumber'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      customerName: customer['name'] ?? 'Walk-in Customer',
      customerPhone: customer['phone'] ?? '',
      type: json['type'] ?? 'return',
      status: json['status'] ?? 'pending',
      items: rawItems.map((i) => ReturnExchangeItem.fromJson(i)).toList(),
      totalRefundAmount: ((json['totalRefundAmount'] ?? 0) as num).toDouble() / 100.0,
      totalPayableAmount: ((json['totalPayableAmount'] ?? 0) as num).toDouble() / 100.0,
      history: rawHistory.map((h) => ReturnExchangeHistory.fromJson(h)).toList(),
      adminNotes: json['adminNotes'] ?? '',
      createdByName: createdBy['name'] ?? 'Admin',
      createdAt: dtCreated,
      updatedAt: dtUpdated,
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
      totalDamagedQty: json['totalDamagedQty'] ?? 0,
      totalLossValue: ((json['totalLossValue'] ?? 0) as num).toDouble() / 100.0,
      scrappedCount: json['scrappedCount'] ?? 0,
      vendorClaimCount: json['vendorClaimCount'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
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

    return DamagedItemRecord(
      caseId: json['caseId']?.toString() ?? '',
      caseNumber: json['caseNumber'] ?? '',
      billNumber: json['billNumber'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      customerName: json['customerName'] ?? 'Walk-in Customer',
      customerPhone: json['customerPhone'] ?? '',
      caseStatus: json['caseStatus'] ?? 'pending',
      createdAt: dtCreated,
      itemId: json['itemId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: json['productName'] ?? '',
      sku: json['sku'] ?? '',
      image: json['image'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: ((json['unitPrice'] ?? 0) as num).toDouble() / 100.0,
      totalLoss: ((json['totalLoss'] ?? 0) as num).toDouble() / 100.0,
      damageType: json['damageType'] ?? 'physical',
      damageDiscoveredAt: json['damageDiscoveredAt'] ?? 'customer',
      damageResolution: json['damageResolution'] ?? 'no_refund',
      reasonText: json['reasonText'] ?? '',
      notes: json['notes'] ?? '',
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
