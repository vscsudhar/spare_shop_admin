import 'dart:convert';
import 'package:spare_shop_admin/core/services/invoice_service.dart';
import 'package:spare_shop_admin/ui/common/app_strings.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';

enum PriceTierType {
  retail,
  least1,
  least2,
  custom,
}

extension PriceTierTypeExtension on PriceTierType {
  String get displayName {
    switch (this) {
      case PriceTierType.retail:
        return 'Retail MRP/Selling';
      case PriceTierType.least1:
        return 'Least Selling Price 1';
      case PriceTierType.least2:
        return 'Least Selling Price 2';
      case PriceTierType.custom:
        return 'Custom Special Rate';
    }
  }

  String get shortName {
    switch (this) {
      case PriceTierType.retail:
        return 'Retail';
      case PriceTierType.least1:
        return 'Least 1';
      case PriceTierType.least2:
        return 'Least 2';
      case PriceTierType.custom:
        return 'Custom';
    }
  }

  String get value {
    switch (this) {
      case PriceTierType.retail:
        return 'retail';
      case PriceTierType.least1:
        return 'least1';
      case PriceTierType.least2:
        return 'least2';
      case PriceTierType.custom:
        return 'custom';
    }
  }

  static PriceTierType fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'least1':
      case 'least_1':
      case 'leastprice1':
        return PriceTierType.least1;
      case 'least2':
      case 'least_2':
      case 'leastprice2':
        return PriceTierType.least2;
      case 'custom':
        return PriceTierType.custom;
      case 'retail':
      default:
        return PriceTierType.retail;
    }
  }
}

/// A line item inside a B2B quotation or bulk sell order
class BulkQuotationItemModel {
  final String productId;
  final String productName;
  final String partNumber;
  final String hsnCode;
  final String category;
  final String image;
  final int quantity;
  final PriceTierType priceTier;
  final double retailPrice;
  final double leastSellingPrice1;
  final double leastSellingPrice2;
  final double unitPrice; // Active selling price applied
  final double gstRate; // e.g. 18.0 or 28.0

  const BulkQuotationItemModel({
    required this.productId,
    required this.productName,
    this.partNumber = '',
    this.hsnCode = '8708',
    this.category = '',
    this.image = '',
    required this.quantity,
    this.priceTier = PriceTierType.retail,
    required this.retailPrice,
    this.leastSellingPrice1 = 0.0,
    this.leastSellingPrice2 = 0.0,
    required this.unitPrice,
    this.gstRate = 18.0,
  });

  /// Factory from a ProductModel with default price tier selection
  factory BulkQuotationItemModel.fromProduct(
    ProductModel product, {
    int quantity = 1,
    PriceTierType tier = PriceTierType.retail,
    double? customPrice,
    double gstRate = 18.0,
  }) {
    double price;
    switch (tier) {
      case PriceTierType.least1:
        price = product.leastSellingPrice1 > 0
            ? product.leastSellingPrice1
            : product.price;
        break;
      case PriceTierType.least2:
        price = product.leastSellingPrice2 > 0
            ? product.leastSellingPrice2
            : (product.leastSellingPrice1 > 0
                ? product.leastSellingPrice1
                : product.price);
        break;
      case PriceTierType.custom:
        price = customPrice ?? product.price;
        break;
      case PriceTierType.retail:
      default:
        price = product.price;
        break;
    }

    return BulkQuotationItemModel(
      productId: product.id,
      productName: product.name,
      partNumber: product.fitmentBadge ?? '',
      hsnCode: '8708',
      category: product.vehicleType,
      image: product.imageAsset ?? '',
      quantity: quantity,
      priceTier: tier,
      retailPrice: product.price,
      leastSellingPrice1: product.leastSellingPrice1,
      leastSellingPrice2: product.leastSellingPrice2,
      unitPrice: price,
      gstRate: gstRate,
    );
  }

  double get totalTaxable => quantity * unitPrice;
  double get taxAmount => (totalTaxable * gstRate) / 100.0;
  double get grandTotal => totalTaxable + taxAmount;

  BulkQuotationItemModel copyWith({
    String? productId,
    String? productName,
    String? partNumber,
    String? hsnCode,
    String? category,
    String? image,
    int? quantity,
    PriceTierType? priceTier,
    double? retailPrice,
    double? leastSellingPrice1,
    double? leastSellingPrice2,
    double? unitPrice,
    double? gstRate,
  }) {
    return BulkQuotationItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      partNumber: partNumber ?? this.partNumber,
      hsnCode: hsnCode ?? this.hsnCode,
      category: category ?? this.category,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      priceTier: priceTier ?? this.priceTier,
      retailPrice: retailPrice ?? this.retailPrice,
      leastSellingPrice1: leastSellingPrice1 ?? this.leastSellingPrice1,
      leastSellingPrice2: leastSellingPrice2 ?? this.leastSellingPrice2,
      unitPrice: unitPrice ?? this.unitPrice,
      gstRate: gstRate ?? this.gstRate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'partNumber': partNumber,
      'hsnCode': hsnCode,
      'category': category,
      'image': image,
      'quantity': quantity,
      'priceTier': priceTier.value,
      'retailPrice': retailPrice,
      'leastSellingPrice1': leastSellingPrice1,
      'leastSellingPrice2': leastSellingPrice2,
      'unitPrice': unitPrice,
      'gstRate': gstRate,
      'taxableValue': totalTaxable,
      'taxAmount': taxAmount,
      'grandTotal': grandTotal,
    };
  }

  factory BulkQuotationItemModel.fromJson(Map<String, dynamic> json) {
    return BulkQuotationItemModel(
      productId: (json['productId'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      partNumber: (json['partNumber'] ?? '').toString(),
      hsnCode: (json['hsnCode'] ?? '8708').toString(),
      category: (json['category'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      priceTier:
          PriceTierTypeExtension.fromString(json['priceTier']?.toString()),
      retailPrice: (json['retailPrice'] as num?)?.toDouble() ?? 0.0,
      leastSellingPrice1:
          (json['leastSellingPrice1'] as num?)?.toDouble() ?? 0.0,
      leastSellingPrice2:
          (json['leastSellingPrice2'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      gstRate: (json['gstRate'] as num?)?.toDouble() ?? 18.0,
    );
  }
}

/// A B2B Quotation record which can be searched, viewed, and converted to an Invoice
class BulkQuotationModel {
  final String id;
  final String quotationNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String customerGst;
  final String customerAddress;
  final String businessName;
  final List<BulkQuotationItemModel> items;
  final double subtotal; // Sum of taxable values
  final double totalTax;
  final double grandTotal;
  final String status; // 'Quotation', 'Converted to Invoice', 'Cancelled'
  final String? invoiceNumber;
  final String? invoiceId;
  final String notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? validUntil;

  const BulkQuotationModel({
    required this.id,
    required this.quotationNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail = '',
    this.customerGst = '',
    this.customerAddress = '',
    this.businessName = '',
    required this.items,
    required this.subtotal,
    required this.totalTax,
    required this.grandTotal,
    this.status = 'Quotation',
    this.invoiceNumber,
    this.invoiceId,
    this.notes =
        'Prices valid for 15 days from quotation date. Subject to stock availability.',
    required this.createdAt,
    this.updatedAt,
    this.validUntil,
  });

  bool get isConverted =>
      status.toLowerCase().contains('converted') ||
      (invoiceNumber != null && invoiceNumber!.isNotEmpty);

  BulkQuotationModel copyWith({
    String? id,
    String? quotationNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? customerGst,
    String? customerAddress,
    String? businessName,
    List<BulkQuotationItemModel>? items,
    double? subtotal,
    double? totalTax,
    double? grandTotal,
    String? status,
    String? invoiceNumber,
    String? invoiceId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? validUntil,
  }) {
    return BulkQuotationModel(
      id: id ?? this.id,
      quotationNumber: quotationNumber ?? this.quotationNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      customerGst: customerGst ?? this.customerGst,
      customerAddress: customerAddress ?? this.customerAddress,
      businessName: businessName ?? this.businessName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      totalTax: totalTax ?? this.totalTax,
      grandTotal: grandTotal ?? this.grandTotal,
      status: status ?? this.status,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceId: invoiceId ?? this.invoiceId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      validUntil: validUntil ?? this.validUntil,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quotationNumber': quotationNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'customerGst': customerGst,
      'customerAddress': customerAddress,
      'businessName': businessName,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'totalTax': totalTax,
      'grandTotal': grandTotal,
      'status': status,
      'invoiceNumber': invoiceNumber,
      'invoiceId': invoiceId,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
    };
  }

  factory BulkQuotationModel.fromJson(Map<String, dynamic> json) {
    return BulkQuotationModel(
      id: (json['id'] ?? '').toString(),
      quotationNumber: (json['quotationNumber'] ?? '').toString(),
      customerId: (json['customerId'] ?? '').toString(),
      customerName: (json['customerName'] ?? '').toString(),
      customerPhone: (json['customerPhone'] ?? '').toString(),
      customerEmail: (json['customerEmail'] ?? '').toString(),
      customerGst: (json['customerGst'] ?? '').toString(),
      customerAddress: (json['customerAddress'] ?? '').toString(),
      businessName: (json['businessName'] ?? '').toString(),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) =>
                  BulkQuotationItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      totalTax: (json['totalTax'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      status: (json['status'] ?? 'Quotation').toString(),
      invoiceNumber: json['invoiceNumber']?.toString(),
      invoiceId: json['invoiceId']?.toString(),
      notes: (json['notes'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      validUntil: json['validUntil'] != null
          ? DateTime.tryParse(json['validUntil'].toString())
          : null,
    );
  }

  /// Converts this Quotation into a full GST Tax InvoiceModel for immediate preview and print
  InvoiceModel toInvoiceModel({
    InvoiceBusinessInfo? businessInfo,
    String? explicitInvoiceNumber,
    String paymentMethod = 'B2B / Net-30',
    String paymentStatus = 'PENDING',
  }) {
    final business = businessInfo ?? const InvoiceBusinessInfo();
    final invNum = explicitInvoiceNumber ??
        invoiceNumber ??
        'INV-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}-${quotationNumber.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0')}';

    const isIntraState = true; // Default intra-state Karnataka
    int sNo = 1;

    final invoiceItems = items.map((item) {
      final taxable = item.totalTaxable;
      final gstRate = item.gstRate;
      final totalTax = item.taxAmount;

      final cgstRate = isIntraState ? gstRate / 2.0 : 0.0;
      final cgstAmount = isIntraState ? totalTax / 2.0 : 0.0;
      final sgstRate = isIntraState ? gstRate / 2.0 : 0.0;
      final sgstAmount = isIntraState ? totalTax / 2.0 : 0.0;
      final igstRate = !isIntraState ? gstRate : 0.0;
      final igstAmount = !isIntraState ? totalTax : 0.0;

      final iModel = InvoiceItemModel(
        sNo: sNo++,
        name: item.productName,
        sku: item.partNumber.isNotEmpty
            ? item.partNumber
            : 'SKU-${item.productId.substring(0, item.productId.length > 6 ? 6 : item.productId.length)}',
        hsnCode: item.hsnCode,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        taxableValue: taxable,
        gstRate: gstRate,
        cgstRate: cgstRate,
        cgstAmount: cgstAmount,
        sgstRate: sgstRate,
        sgstAmount: sgstAmount,
        igstRate: igstRate,
        igstAmount: igstAmount,
        total: item.grandTotal,
      );
      return iModel;
    }).toList();

    final totalCgst = isIntraState ? totalTax / 2.0 : 0.0;
    final totalSgst = isIntraState ? totalTax / 2.0 : 0.0;
    final totalIgst = !isIntraState ? totalTax : 0.0;

    final summary = InvoiceSummary(
      subtotal: subtotal,
      totalDiscount: 0.0,
      taxableAmount: subtotal,
      totalCgst: totalCgst,
      totalSgst: totalSgst,
      totalIgst: totalIgst,
      totalTax: totalTax,
      deliveryCharges: 0.0,
      grandTotal: grandTotal,
      amountInWords: _numberToWords(grandTotal.round()),
      isIntraState: isIntraState,
    );

    final customer = InvoiceCustomerInfo(
      name: businessName.isNotEmpty
          ? '$businessName ($customerName)'
          : customerName,
      phone: customerPhone,
      address: customerAddress.isNotEmpty
          ? customerAddress
          : 'Direct B2B Customer Address',
      gstin: customerGst.isNotEmpty ? customerGst : 'URP (Unregistered Person)',
      state: 'Karnataka',
      stateCode: '29',
    );

    return InvoiceModel(
      invoiceNumber: invNum,
      invoiceDate: DateTime.now(),
      orderId: id,
      orderNumber: quotationNumber,
      orderDate: createdAt,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      orderStatus: 'DELIVERED',
      channel: 'b2b_wholesale',
      fulfillmentHub: 'Central Warehouse (HQ)',
      business: business,
      customer: customer,
      items: invoiceItems,
      summary: summary,
      terms: [
        'Payment terms: As mutually agreed under B2B commercial terms.',
        'Goods once sold cannot be returned without prior authorization.',
        'All disputes are subject to local jurisdiction.',
        'This is a computer-generated B2B Tax Invoice based on Quotation $quotationNumber.',
      ],
    );
  }

  static String _numberToWords(int number) {
    if (number == 0) return 'Zero Rupees Only';
    final units = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen'
    ];
    final tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety'
    ];

    String convertBelowThousand(int n) {
      if (n == 0) return '';
      if (n < 20) return '${units[n]} ';
      if (n < 100) return '${tens[n ~/ 10]} ${units[n % 10]} ';
      return '${units[n ~/ 100]} Hundred ${convertBelowThousand(n % 100)}';
    }

    String result = '';
    if (number >= 10000000) {
      result += '${convertBelowThousand(number ~/ 10000000)}Crore ';
      number %= 10000000;
    }
    if (number >= 100000) {
      result += '${convertBelowThousand(number ~/ 100000)}Lakh ';
      number %= 100000;
    }
    if (number >= 1000) {
      result += '${convertBelowThousand(number ~/ 1000)}Thousand ';
      number %= 1000;
    }
    if (number > 0) {
      result += convertBelowThousand(number);
    }

    return 'INR ${result.trim().replaceAll(RegExp(r'\s+'), ' ')} Only';
  }
}
