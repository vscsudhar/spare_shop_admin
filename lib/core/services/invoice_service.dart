import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/services/api_client.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';

/// Representation of a product line item in a professional GST Tax Invoice
class InvoiceItemModel {
  final int sNo;
  final String name;
  final String sku;
  final String hsnCode;
  final int quantity;
  final double unitPrice; // Price before tax
  final double discount;
  final double taxableValue;
  final double gstRate; // e.g. 18.0
  final double cgstRate;
  final double cgstAmount;
  final double sgstRate;
  final double sgstAmount;
  final double igstRate;
  final double igstAmount;
  final double total;

  const InvoiceItemModel({
    required this.sNo,
    required this.name,
    required this.sku,
    this.hsnCode = '8708',
    required this.quantity,
    required this.unitPrice,
    this.discount = 0.0,
    required this.taxableValue,
    required this.gstRate,
    required this.cgstRate,
    required this.cgstAmount,
    required this.sgstRate,
    required this.sgstAmount,
    required this.igstRate,
    required this.igstAmount,
    required this.total,
  });
}

/// Business/Company Information for GST Invoicing
class InvoiceBusinessInfo {
  final String name;
  final String legalName;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String stateCode;
  final String pincode;
  final String phone;
  final String email;
  final String gstin;
  final String pan;
  final String website;

  const InvoiceBusinessInfo({
    this.name = 'VoltSpare Automotive',
    this.legalName = 'VoltSpare Automotive Technologies Pvt. Ltd.',
    this.addressLine1 = '12, MG Road, Landmark Block',
    this.addressLine2 = 'Indiranagar Commercial Zone',
    this.city = 'Bangalore',
    this.state = 'Karnataka',
    this.stateCode = '29',
    this.pincode = '560001',
    this.phone = '+91 99000 88000',
    this.email = 'billing@voltspare.com',
    this.gstin = '29AAAAA0000A1Z1',
    this.pan = 'AAAAA0000A',
    this.website = 'www.voltspare.com',
  });
}

/// Customer & Shipping Information
class InvoiceCustomerInfo {
  final String name;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String stateCode;
  final String gstin;

  const InvoiceCustomerInfo({
    required this.name,
    required this.phone,
    required this.address,
    this.city = '',
    this.state = 'Karnataka',
    this.stateCode = '29',
    this.gstin = 'URP (Unregistered Person)',
  });
}

/// Tax & Grand Total Summary
class InvoiceSummary {
  final double subtotal; // Sum of taxable values
  final double totalDiscount;
  final double taxableAmount;
  final double totalCgst;
  final double totalSgst;
  final double totalIgst;
  final double totalTax;
  final double deliveryCharges;
  final double grandTotal;
  final String amountInWords;
  final bool isIntraState;

  const InvoiceSummary({
    required this.subtotal,
    required this.totalDiscount,
    required this.taxableAmount,
    required this.totalCgst,
    required this.totalSgst,
    required this.totalIgst,
    required this.totalTax,
    required this.deliveryCharges,
    required this.grandTotal,
    required this.amountInWords,
    required this.isIntraState,
  });
}

/// Full Tax Invoice Model
class InvoiceModel {
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String orderId;
  final String orderNumber;
  final DateTime orderDate;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String channel; // 'pos' or 'app'
  final String? fulfillmentHub;
  final InvoiceBusinessInfo business;
  final InvoiceCustomerInfo customer;
  final List<InvoiceItemModel> items;
  final InvoiceSummary summary;
  final List<String> terms;

  const InvoiceModel({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.orderId,
    required this.orderNumber,
    required this.orderDate,
    required this.paymentMethod,
    this.paymentStatus = 'PAID',
    required this.orderStatus,
    required this.channel,
    this.fulfillmentHub,
    required this.business,
    required this.customer,
    required this.items,
    required this.summary,
    this.terms = const [
      'Goods once sold are covered under VoltSpare 7-day verified RMA warranty.',
      'All disputes are subject to Bangalore jurisdiction only.',
      'This is a computer-generated tax invoice and requires no physical signature under IT Act 2000.',
    ],
  });
}

/// Service to handle Invoice Creation, Calculations, Caching, and PDF/Web Printing
class InvoiceService {
  final ApiClient _apiClient;

  // In-memory cache for deterministic invoice IDs per order to prevent duplicates
  static final Map<String, String> _invoiceNumberCache = {};

  // Cached business settings from backend general settings
  static InvoiceBusinessInfo? _cachedBusinessInfo;

  InvoiceService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  InvoiceBusinessInfo get businessInfo => _cachedBusinessInfo ?? const InvoiceBusinessInfo();

  /// Load and cache the dynamic business information from general settings
  Future<InvoiceBusinessInfo> loadBusinessSettings() async {
    try {
      final response = await _apiClient.get('/settings');
      final data = response.data['data'] ?? {};
      final g = data['general'] ?? {};
      _cachedBusinessInfo = InvoiceBusinessInfo(
        name: (g['appName'] ?? 'VoltSpare Automotive').toString(),
        legalName: (g['legalName'] ?? g['appName'] ?? 'VoltSpare Automotive Technologies Pvt. Ltd.').toString(),
        addressLine1: (g['addressLine1'] ?? g['address'] ?? '12, MG Road, Landmark Block').toString(),
        addressLine2: (g['addressLine2'] ?? '').toString(),
        city: (g['city'] ?? 'Bangalore').toString(),
        state: (g['state'] ?? 'Karnataka').toString(),
        stateCode: (g['stateCode'] ?? getStateCode(g['state'] ?? 'Karnataka')).toString(),
        pincode: (g['postalCode'] ?? g['pincode'] ?? '560001').toString(),
        phone: (g['supportPhone'] ?? '+91 99000 88000').toString(),
        email: (g['supportEmail'] ?? 'billing@voltspare.com').toString(),
        gstin: (g['gstin'] ?? g['gstNumber'] ?? '29AAAAA0000A1Z1').toString(),
        pan: (g['pan'] ?? 'AAAAA0000A').toString(),
        website: (g['website'] ?? 'www.voltspare.com').toString(),
      );
      return _cachedBusinessInfo!;
    } catch (_) {
      return _cachedBusinessInfo ?? const InvoiceBusinessInfo();
    }
  }

  /// Manually update cached business info when saved in Settings View
  static void updateCachedBusinessInfo(InvoiceBusinessInfo info) {
    _cachedBusinessInfo = info;
  }

  /// Generate or retrieve an immutable invoice number for an order
  static String getOrGenerateInvoiceNumber(OrderModel order) {
    if (_invoiceNumberCache.containsKey(order.id)) {
      return _invoiceNumberCache[order.id]!;
    }

    // Check if orderNumber already has POS or INV prefix
    final rawNum = order.orderNumber.toUpperCase();
    final year = order.date.year;

    if (rawNum.startsWith('INV-')) {
      _invoiceNumberCache[order.id] = order.orderNumber;
      return order.orderNumber;
    }

    // Extract digits or suffix from order number
    final digits = rawNum.replaceAll(RegExp(r'[^0-9]'), '');
    String suffix;
    if (digits.isNotEmpty) {
      suffix = digits.length >= 6
          ? digits.substring(digits.length - 6)
          : digits.padLeft(6, '0');
    } else if (order.id.isNotEmpty) {
      final cleanId = order.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
      suffix = cleanId.length >= 6
          ? cleanId.substring(cleanId.length - 6).toUpperCase()
          : cleanId.padLeft(6, '0').toUpperCase();
    } else {
      suffix = '000001';
    }

    final invoiceNum = 'INV-$year-$suffix';
    _invoiceNumberCache[order.id] = invoiceNum;
    return invoiceNum;
  }

  /// Map Indian state name or string to GST State Code
  static String getStateCode(String stateName) {
    final s = stateName.toLowerCase().trim();
    if (s.contains('karnataka') || s.contains('bangalore') || s.contains('blr')) return '29';
    if (s.contains('tamil') || s.contains('chennai') || s.contains('tn')) return '33';
    if (s.contains('maharashtra') || s.contains('mumbai') || s.contains('pune')) return '27';
    if (s.contains('delhi') || s.contains('ncr')) return '07';
    if (s.contains('telangana') || s.contains('hyderabad')) return '36';
    if (s.contains('andhra')) return '37';
    if (s.contains('kerala') || s.contains('kochi')) return '32';
    if (s.contains('gujarat') || s.contains('ahmedabad')) return '24';
    if (s.contains('uttar pradesh') || s.contains('up') || s.contains('noida')) return '09';
    if (s.contains('rajasthan') || s.contains('jaipur')) return '08';
    if (s.contains('west bengal') || s.contains('kolkata')) return '19';
    if (s.contains('haryana') || s.contains('gurgaon')) return '06';
    if (s.contains('punjab')) return '03';
    if (s.contains('madhya')) return '23';
    if (s.contains('bihar')) return '10';
    if (s.contains('odisha') || s.contains('orissa')) return '21';
    if (s.contains('goa')) return '30';
    return '29'; // Default to Karnataka
  }

  /// Converts a numeric amount to Indian Currency Words
  static String convertAmountToWords(double amount) {
    if (amount <= 0) return 'Zero Rupees Only';

    final int wholePart = amount.floor();
    final int decimalPart = ((amount - wholePart) * 100).round();

    final words = _convertNumberToWords(wholePart);
    String result = 'Indian Rupees $words';

    if (decimalPart > 0) {
      final paiseWords = _convertNumberToWords(decimalPart);
      result += ' and $paiseWords Paise';
    }

    return '$result Only';
  }

  static String _convertNumberToWords(int number) {
    if (number == 0) return 'Zero';

    final units = [
      '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
      'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
      'Seventeen', 'Eighteen', 'Nineteen'
    ];

    final tens = [
      '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
    ];

    String formatUnderThousand(int n) {
      String str = '';
      if (n >= 100) {
        str += '${units[n ~/ 100]} Hundred ';
        n %= 100;
      }
      if (n >= 20) {
        str += '${tens[n ~/ 10]} ';
        n %= 10;
      }
      if (n > 0) {
        str += '${units[n]} ';
      }
      return str.trim();
    }

    String result = '';

    // Indian Numbering System: Crores, Lakhs, Thousands, Hundreds
    if (number >= 10000000) {
      final crores = number ~/ 10000000;
      result += '${formatUnderThousand(crores)} Crore ';
      number %= 10000000;
    }

    if (number >= 100000) {
      final lakhs = number ~/ 100000;
      result += '${formatUnderThousand(lakhs)} Lakh ';
      number %= 100000;
    }

    if (number >= 1000) {
      final thousands = number ~/ 1000;
      result += '${formatUnderThousand(thousands)} Thousand ';
      number %= 1000;
    }

    if (number > 0) {
      result += formatUnderThousand(number);
    }

    return result.trim();
  }

  /// Build a complete, professional InvoiceModel from an OrderModel
  InvoiceModel createInvoiceFromOrder(
    OrderModel order, {
    InvoiceBusinessInfo? businessInfo,
    double defaultTaxPercentage = 18.0,
  }) {
    final business = businessInfo ?? _cachedBusinessInfo ?? const InvoiceBusinessInfo();
    final invoiceNumber = getOrGenerateInvoiceNumber(order);

    // Extract customer address details
    final customerState = order.address.addressLine.contains('Tamil')
        ? 'Tamil Nadu'
        : (order.address.addressLine.contains('Maharashtra')
            ? 'Maharashtra'
            : (order.address.addressLine.contains('Delhi')
                ? 'Delhi'
                : business.state));
    final customerStateCode = getStateCode(customerState);

    // Determine GST intra-state vs inter-state
    final bool isIntraState = customerStateCode == business.stateCode;

    final customer = InvoiceCustomerInfo(
      name: order.address.name.isNotEmpty ? order.address.name : 'Valued Customer',
      phone: order.address.phone.isNotEmpty ? order.address.phone : '+91 99000 88000',
      address: order.address.addressLine.isNotEmpty
          ? order.address.addressLine
          : 'Standard Delivery Address',
      city: business.city,
      state: customerState,
      stateCode: customerStateCode,
      gstin: 'URP (Unregistered Person)',
    );

    // Calculate itemized GST amounts
    double computedTaxableSum = 0.0;
    double computedCgstSum = 0.0;
    double computedSgstSum = 0.0;
    double computedIgstSum = 0.0;
    double computedTotalSum = 0.0;

    final List<InvoiceItemModel> invoiceItems = [];

    for (int i = 0; i < order.items.length; i++) {
      final item = order.items[i];
      final qty = item.quantity > 0 ? item.quantity : 1;
      final rate = item.product.taxPercentage > 0
          ? item.product.taxPercentage
          : defaultTaxPercentage;

      // Selling price per item
      final double totalItemPrice = item.product.price * qty;
      
      // Calculate taxable base value from total item price
      // Taxable Base = Total / (1 + rate / 100)
      final double taxableVal = totalItemPrice / (1.0 + (rate / 100.0));
      final double unitTaxable = taxableVal / qty;
      final double totalTax = totalItemPrice - taxableVal;

      double cgstRate = 0.0;
      double cgstAmt = 0.0;
      double sgstRate = 0.0;
      double sgstAmt = 0.0;
      double igstRate = 0.0;
      double igstAmt = 0.0;

      if (isIntraState) {
        cgstRate = rate / 2.0;
        sgstRate = rate / 2.0;
        cgstAmt = totalTax / 2.0;
        sgstAmt = totalTax / 2.0;
        computedCgstSum += cgstAmt;
        computedSgstSum += sgstAmt;
      } else {
        igstRate = rate;
        igstAmt = totalTax;
        computedIgstSum += igstAmt;
      }

      computedTaxableSum += taxableVal;
      computedTotalSum += totalItemPrice;

      // SKU resolution
      final String sku = item.product.id.length >= 8
          ? 'VS-SKU-${item.product.id.substring(item.product.id.length - 6).toUpperCase()}'
          : (item.product.id.isNotEmpty ? 'VS-${item.product.id.toUpperCase()}' : 'VS-GEN-${i + 1}');

      invoiceItems.add(
        InvoiceItemModel(
          sNo: i + 1,
          name: item.product.name.isNotEmpty ? item.product.name : 'Spare Part Item',
          sku: sku,
          hsnCode: '8708',
          quantity: qty,
          unitPrice: unitTaxable,
          discount: 0.0,
          taxableValue: taxableVal,
          gstRate: rate,
          cgstRate: cgstRate,
          cgstAmount: cgstAmt,
          sgstRate: sgstRate,
          sgstAmount: sgstAmt,
          igstRate: igstRate,
          igstAmount: igstAmt,
          total: totalItemPrice,
        ),
      );
    }

    // Shipping / Delivery charges: Pos orders 0, App orders match delivery charge tiers
    double deliveryCharges = 0.0;
    if (order.isAppOrder) {
      if (order.total > computedTotalSum) {
        deliveryCharges = order.total - computedTotalSum;
      } else if (computedTotalSum > 0 && computedTotalSum < 999) {
        deliveryCharges = 59.0;
      }
    }

    final double grandTotal = order.total > 0 && order.total >= (computedTotalSum + deliveryCharges - 1)
        ? order.total
        : (computedTotalSum + deliveryCharges);

    final summary = InvoiceSummary(
      subtotal: computedTaxableSum,
      totalDiscount: 0.0,
      taxableAmount: computedTaxableSum,
      totalCgst: computedCgstSum,
      totalSgst: computedSgstSum,
      totalIgst: computedIgstSum,
      totalTax: computedCgstSum + computedSgstSum + computedIgstSum,
      deliveryCharges: deliveryCharges,
      grandTotal: grandTotal,
      amountInWords: convertAmountToWords(grandTotal),
      isIntraState: isIntraState,
    );

    return InvoiceModel(
      invoiceNumber: invoiceNumber,
      invoiceDate: order.date,
      orderId: order.id,
      orderNumber: order.orderNumber,
      orderDate: order.date,
      paymentMethod: order.paymentMethod.toUpperCase(),
      paymentStatus: order.status == OrderStatus.cancelled ? 'CANCELLED' : 'PAID',
      orderStatus: order.status.name.toUpperCase(),
      channel: order.channel,
      fulfillmentHub: order.locationName,
      business: business,
      customer: customer,
      items: invoiceItems,
      summary: summary,
    );
  }

  /// Build a complete InvoiceModel from POS billing record
  InvoiceModel createInvoiceFromPosData(
    Map<String, dynamic> posData, {
    InvoiceBusinessInfo? businessInfo,
    double defaultTaxPercentage = 18.0,
  }) {
    final business = businessInfo ?? _cachedBusinessInfo ?? const InvoiceBusinessInfo();
    final invoiceNumber = (posData['invoiceNumber'] ?? 'INV-POS-UNKNOWN').toString();
    final customerName = (posData['customerName'] ?? 'Walk-in Guest').toString();
    final locationName = (posData['locationName'] ?? 'Main Branch').toString();
    final dateStr = (posData['dateStr'] ?? '').toString();
    final invoiceDate = DateTime.tryParse(dateStr) ?? DateTime.now();

    final rawItems = posData['items'] as List<dynamic>? ?? [];
    final double rawGrandTotal = (posData['grandTotal'] as num?)?.toDouble() ?? 0.0;
    final double rawDiscount = (posData['discount'] as num?)?.toDouble() ?? 0.0;

    final customer = InvoiceCustomerInfo(
      name: customerName,
      phone: '+91 99000 88000',
      address: 'POS Counter Sale - Walk-in Store, $locationName',
      city: business.city,
      state: business.state,
      stateCode: business.stateCode,
    );

    double computedTaxable = 0.0;
    double computedCgst = 0.0;
    double computedSgst = 0.0;
    final List<InvoiceItemModel> items = [];

    for (int i = 0; i < rawItems.length; i++) {
      final it = rawItems[i];
      final name = (it['name'] ?? 'Automotive Part').toString();
      final qty = (it['quantity'] as num?)?.toInt() ?? 1;
      final totalPrice = (it['totalPrice'] as num?)?.toDouble() ??
          (((it['unitPrice'] as num?)?.toDouble() ?? 0.0) * qty);

      final rate = defaultTaxPercentage;
      final taxable = totalPrice / (1.0 + (rate / 100.0));
      final unitTaxable = taxable / (qty > 0 ? qty : 1);
      final tax = totalPrice - taxable;
      final cgst = tax / 2.0;
      final sgst = tax / 2.0;

      computedTaxable += taxable;
      computedCgst += cgst;
      computedSgst += sgst;

      items.add(
        InvoiceItemModel(
          sNo: i + 1,
          name: name,
          sku: 'VS-POS-${i + 1}',
          hsnCode: '8708',
          quantity: qty,
          unitPrice: unitTaxable,
          taxableValue: taxable,
          gstRate: rate,
          cgstRate: rate / 2.0,
          cgstAmount: cgst,
          sgstRate: rate / 2.0,
          sgstAmount: sgst,
          igstRate: 0.0,
          igstAmount: 0.0,
          total: totalPrice,
        ),
      );
    }

    final summary = InvoiceSummary(
      subtotal: computedTaxable,
      totalDiscount: rawDiscount,
      taxableAmount: computedTaxable,
      totalCgst: computedCgst,
      totalSgst: computedSgst,
      totalIgst: 0.0,
      totalTax: computedCgst + computedSgst,
      deliveryCharges: 0.0,
      grandTotal: rawGrandTotal > 0 ? rawGrandTotal : (computedTaxable + computedCgst + computedSgst),
      amountInWords: convertAmountToWords(rawGrandTotal > 0 ? rawGrandTotal : (computedTaxable + computedCgst + computedSgst)),
      isIntraState: true,
    );

    return InvoiceModel(
      invoiceNumber: invoiceNumber,
      invoiceDate: invoiceDate,
      orderId: invoiceNumber,
      orderNumber: invoiceNumber,
      orderDate: invoiceDate,
      paymentMethod: 'POS COUNTER PAYMENT',
      orderStatus: 'DELIVERED',
      channel: 'pos',
      fulfillmentHub: locationName,
      business: business,
      customer: customer,
      items: items,
      summary: summary,
    );
  }

  /// Parse backend JSON response into admin InvoiceModel
  InvoiceModel createInvoiceFromJson(Map<String, dynamic> json) {
    double parseNum(dynamic v) {
      if (v == null) return 0.0;
      double val = 0.0;
      if (v is num) {
        val = v.toDouble();
      } else {
        val = double.tryParse(v.toString()) ?? 0.0;
      }
      if (val >= 10000 && val % 100 == 0) {
        return val / 100.0;
      }
      return val;
    }

    DateTime parseDate(dynamic d) {
      if (d is DateTime) return d;
      if (d != null) {
        final parsed = DateTime.tryParse(d.toString());
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    final rawBusiness = json['business'] as Map<String, dynamic>? ?? {};
    final business = InvoiceBusinessInfo(
      name: (rawBusiness['name'] ?? 'VoltSpare Automotive').toString(),
      legalName: (rawBusiness['legalName'] ?? 'VoltSpare Automotive Technologies Pvt. Ltd.').toString(),
      addressLine1: (rawBusiness['addressLine1'] ?? '12, MG Road, Landmark Block').toString(),
      addressLine2: (rawBusiness['addressLine2'] ?? 'Indiranagar Commercial Zone').toString(),
      city: (rawBusiness['city'] ?? 'Bangalore').toString(),
      state: (rawBusiness['state'] ?? 'Karnataka').toString(),
      stateCode: (rawBusiness['stateCode'] ?? '29').toString(),
      pincode: (rawBusiness['postalCode'] ?? rawBusiness['pincode'] ?? '560001').toString(),
      phone: (rawBusiness['phone'] ?? '+91 99000 88000').toString(),
      email: (rawBusiness['email'] ?? 'billing@voltspare.com').toString(),
      gstin: (rawBusiness['gstin'] ?? '29AAAAA0000A1Z1').toString(),
      pan: (rawBusiness['pan'] ?? 'AAAAA0000A').toString(),
      website: (rawBusiness['website'] ?? 'www.voltspare.com').toString(),
    );

    final rawCustomer = json['customer'] as Map<String, dynamic>? ?? {};
    final customer = InvoiceCustomerInfo(
      name: (rawCustomer['name'] ?? 'Valued Customer').toString(),
      phone: (rawCustomer['phone'] ?? '').toString(),
      address: (rawCustomer['address'] ?? rawCustomer['addressLine1'] ?? 'Standard Address').toString(),
      city: (rawCustomer['city'] ?? '').toString(),
      state: (rawCustomer['state'] ?? 'Tamil Nadu').toString(),
      stateCode: (rawCustomer['stateCode'] ?? '33').toString(),
      gstin: (rawCustomer['gstin'] ?? 'URP (Unregistered Person)').toString(),
    );

    final rawItems = json['items'] as List<dynamic>? ?? [];
    final List<InvoiceItemModel> items = [];
    for (int i = 0; i < rawItems.length; i++) {
      final it = rawItems[i] as Map<String, dynamic>;
      final qty = (it['quantity'] is num) ? (it['quantity'] as num).toInt() : 1;
      final rawUnitPrice = parseNum(it['unitPrice']);
      final rate = parseNum(it['taxPercentage'] ?? it['gstRate'] ?? 18);
      final total = parseNum(it['total']);
      final taxable = parseNum(it['taxableValue'] ?? it['amount'] ?? (total > 0 ? total / (1.0 + (rate / 100.0)) : (rawUnitPrice * qty)));
      final taxableUnitRate = qty > 0 ? (taxable / qty) : taxable;

      items.add(
        InvoiceItemModel(
          sNo: i + 1,
          name: (it['productName'] ?? it['name'] ?? 'Automotive Part').toString(),
          sku: (it['sku'] ?? 'SKU-UNKNOWN').toString(),
          hsnCode: (it['hsnCode'] ?? '8708').toString(),
          quantity: qty,
          unitPrice: taxableUnitRate,
          taxableValue: taxable,
          gstRate: rate,
          cgstRate: parseNum(it['cgstRate']),
          cgstAmount: parseNum(it['cgstAmount']),
          sgstRate: parseNum(it['sgstRate']),
          sgstAmount: parseNum(it['sgstAmount']),
          igstRate: parseNum(it['igstRate']),
          igstAmount: parseNum(it['igstAmount']),
          total: total > 0 ? total : (taxable + parseNum(it['tax'])),
        ),
      );
    }

    final subtotal = parseNum(json['subtotal'] ?? json['subTotal']);
    final grandTotal = parseNum(json['grandTotal'] ?? json['total']);
    final totalTax = parseNum(json['taxAmount'] ?? json['totalTax'] ?? json['tax']);
    final deliveryCharges = parseNum(json['deliveryCharge'] ?? json['deliveryFee']);
    final totalDiscount = parseNum(json['discount'] ?? json['discountAmount']);
    final isIntraState = json['isIntraState'] ?? true;

    final taxableAmount = parseNum(json['taxableAmount'] ?? json['taxableValue'] ?? subtotal);

    final summary = InvoiceSummary(
      subtotal: subtotal,
      totalDiscount: totalDiscount,
      taxableAmount: taxableAmount,
      totalCgst: parseNum(json['totalCgst']),
      totalSgst: parseNum(json['totalSgst']),
      totalIgst: parseNum(json['totalIgst']),
      totalTax: totalTax,
      deliveryCharges: deliveryCharges,
      grandTotal: grandTotal,
      amountInWords: (json['amountInWords'] ?? convertAmountToWords(grandTotal)).toString(),
      isIntraState: isIntraState,
    );

    final orderRef = json['order'];
    String ordId = '';
    if (orderRef is Map) {
      ordId = (orderRef['_id'] ?? orderRef['id'] ?? '').toString();
    } else {
      ordId = (orderRef ?? json['orderId'] ?? '').toString();
    }

    final rawTerms = json['terms'] as List<dynamic>?;
    final List<String> termsList = rawTerms != null
        ? rawTerms.map((t) => t.toString()).toList()
        : const [
            'Goods once sold are covered under VoltSpare 7-day verified RMA warranty.',
            'All disputes are subject to Bangalore jurisdiction only.',
            'This is a computer-generated tax invoice and requires no physical signature under IT Act 2000.',
          ];

    return InvoiceModel(
      invoiceNumber: (json['invoiceNumber'] ?? 'INV-UNKNOWN').toString(),
      invoiceDate: parseDate(json['invoiceDate'] ?? json['createdAt']),
      orderId: ordId,
      orderNumber: (json['orderNumber'] ?? 'ORD-UNKNOWN').toString(),
      orderDate: parseDate(json['orderDate'] ?? json['createdAt']),
      paymentMethod: (json['paymentMethod'] ?? 'Online Payment').toString(),
      paymentStatus: (json['paymentStatus'] ?? 'PAID').toString(),
      orderStatus: (json['orderStatus'] ?? 'processing').toString(),
      channel: (json['channel'] ?? 'app').toString(),
      fulfillmentHub: json['fulfillmentHub']?.toString(),
      business: business,
      customer: customer,
      items: items,
      summary: summary,
      terms: termsList,
    );
  }

  /// Fetch persistent InvoiceModel directly from backend
  Future<InvoiceModel?> fetchInvoiceFromBackend(String orderId) async {
    try {
      final response = await _apiClient.get('/orders/$orderId/invoice');
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return createInvoiceFromJson(data);
      }
    } catch (_) {
      try {
        final response = await _apiClient.post('/orders/$orderId/invoice');
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return createInvoiceFromJson(data);
        }
      } catch (_) {}
    }
    return null;
  }

  /// Print the invoice using a seamless hidden iframe (avoids popup blockers and keeps styles intact)
  Future<void> printInvoice(InvoiceModel invoice) async {
    try {
      final htmlContent = _generateInvoiceHtml(invoice);
      final blob = html.Blob([htmlContent], 'text/html;charset=utf-8');
      final blobUrl = html.Url.createObjectUrlFromBlob(blob);

      final iframe = html.IFrameElement()
        ..src = blobUrl
        ..style.position = 'fixed'
        ..style.right = '0'
        ..style.bottom = '0'
        ..style.width = '0'
        ..style.height = '0'
        ..style.border = '0';

      html.document.body?.append(iframe);

      iframe.onLoad.listen((_) {
        Future.delayed(const Duration(milliseconds: 350), () {
          try {
            (iframe.contentWindow as dynamic)?.focus();
            (iframe.contentWindow as dynamic)?.print();
          } catch (e) {
            debugPrint('IFrame print fallback to window: $e');
            html.window.open(blobUrl, '_blank');
          }
          Future.delayed(const Duration(seconds: 30), () {
            iframe.remove();
            html.Url.revokeObjectUrl(blobUrl);
          });
        });
      });
    } catch (e) {
      debugPrint('Error printing invoice: $e');
      openInvoiceInNewTab(invoice);
    }
  }

  /// Download the stand-alone self-contained HTML invoice file directly to user device
  void downloadInvoiceFile(InvoiceModel invoice) {
    try {
      final htmlContent = _generateInvoiceHtml(invoice);
      final blob = html.Blob([htmlContent], 'text/html;charset=utf-8');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '${invoice.invoiceNumber}.html')
        ..style.display = 'none';
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      Future.delayed(const Duration(seconds: 5), () {
        html.Url.revokeObjectUrl(url);
      });
    } catch (e) {
      debugPrint('Error downloading invoice file: $e');
    }
  }

  /// Open full-page invoice in a new browser tab with print dialog
  void openInvoiceInNewTab(InvoiceModel invoice) {
    try {
      final htmlContent = _generateInvoiceHtml(invoice);
      final blob = html.Blob([htmlContent], 'text/html;charset=utf-8');
      final blobUrl = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(blobUrl, '_blank');
    } catch (e) {
      debugPrint('Error opening invoice tab: $e');
    }
  }

  /// Master method for print or PDF download
  Future<void> printOrDownloadInvoice(InvoiceModel invoice) async {
    await printInvoice(invoice);
  }

  /// Generate high-precision, clean, print-friendly A4 GST HTML Invoice
  String _generateInvoiceHtml(InvoiceModel invoice) {
    final business = invoice.business;
    final customer = invoice.customer;
    final summary = invoice.summary;
    final dateFormatted = invoice.invoiceDate.toString().substring(0, 10);
    final orderDateFormatted = invoice.orderDate.toString().substring(0, 10);
    final businessStreet = [business.addressLine1, business.addressLine2]
        .where((s) => s.trim().isNotEmpty)
        .join(', ');
    final businessCityState = [business.city, business.state]
        .where((s) => s.trim().isNotEmpty)
        .join(', ');
    final businessPin = business.pincode.trim().isNotEmpty ? ' - ${business.pincode.trim()}' : '';

    final itemsRows = invoice.items.map((item) {
      final cgstText = summary.isIntraState
          ? '₹${item.cgstAmount.toStringAsFixed(2)}<br><small style="color:#666;">(${item.cgstRate}%)</small>'
          : '-';
      final sgstOrIgstText = summary.isIntraState
          ? '₹${item.sgstAmount.toStringAsFixed(2)}<br><small style="color:#666;">(${item.sgstRate}%)</small>'
          : '₹${item.igstAmount.toStringAsFixed(2)}<br><small style="color:#666;">(${item.igstRate}%)</small>';

      return '''
        <tr>
          <td style="text-align: center;">${item.sNo}</td>
          <td>
            <strong>${item.name}</strong><br>
            <span style="font-size: 10px; color: #555;">SKU: ${item.sku} | HSN: ${item.hsnCode}</span>
          </td>
          <td style="text-align: center;">${item.hsnCode}</td>
          <td style="text-align: center;">${item.quantity}</td>
          <td style="text-align: right;">₹${item.unitPrice.toStringAsFixed(2)}</td>
          <td style="text-align: right;">₹${item.taxableValue.toStringAsFixed(2)}</td>
          <td style="text-align: right;">$cgstText</td>
          <td style="text-align: right;">$sgstOrIgstText</td>
          <td style="text-align: right; font-weight: 600;">₹${item.total.toStringAsFixed(2)}</td>
        </tr>
      ''';
    }).join('');

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>${invoice.invoiceNumber}</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');
    
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    
    body {
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      font-size: 12px;
      color: #1a1a1a;
      background-color: #f8fafc;
      padding: 24px;
    }

    .invoice-container {
      max-width: 210mm;
      margin: 0 auto;
      background: #ffffff;
      padding: 32px;
      border-radius: 8px;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
      border: 1px solid #e2e8f0;
    }

    .header-bar {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      border-bottom: 2px solid #0f172a;
      padding-bottom: 16px;
      margin-bottom: 20px;
    }

    .brand-section h1 {
      font-size: 22px;
      font-weight: 700;
      color: #0f172a;
      letter-spacing: -0.5px;
      margin-bottom: 4px;
    }

    .brand-section .subtitle {
      font-size: 11px;
      color: #64748b;
      margin-bottom: 6px;
    }

    .brand-details {
      font-size: 11px;
      line-height: 1.5;
      color: #334155;
    }

    .invoice-tag-section {
      text-align: right;
    }

    .invoice-badge {
      display: inline-block;
      background: #0f172a;
      color: #ffffff;
      font-size: 14px;
      font-weight: 700;
      letter-spacing: 1px;
      padding: 6px 14px;
      border-radius: 4px;
      margin-bottom: 8px;
    }

    .invoice-meta-table {
      margin-top: 4px;
      font-size: 11px;
      text-align: right;
    }

    .invoice-meta-table td {
      padding: 2px 0;
    }

    .invoice-meta-table td.label {
      color: #64748b;
      padding-right: 8px;
    }

    .invoice-meta-table td.val {
      font-weight: 600;
      color: #0f172a;
    }

    .info-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 20px;
      margin-bottom: 24px;
    }

    .info-card {
      background: #f8fafc;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      padding: 14px;
    }

    .info-card h3 {
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      color: #64748b;
      font-weight: 700;
      margin-bottom: 8px;
      border-bottom: 1px solid #e2e8f0;
      padding-bottom: 4px;
    }

    .info-card p {
      font-size: 12px;
      line-height: 1.5;
      color: #1e293b;
    }

    .items-table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 20px;
      font-size: 11px;
    }

    .items-table th {
      background: #f1f5f9;
      color: #334155;
      font-weight: 600;
      text-align: left;
      padding: 8px 10px;
      border: 1px solid #cbd5e1;
      font-size: 11px;
    }

    .items-table td {
      padding: 8px 10px;
      border: 1px solid #e2e8f0;
      vertical-align: top;
    }

    .items-table tbody tr:nth-child(even) {
      background: #fafafa;
    }

    .bottom-section {
      display: grid;
      grid-template-columns: 1.3fr 1fr;
      gap: 20px;
      margin-top: 10px;
    }

    .summary-card {
      background: #f8fafc;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      padding: 12px;
    }

    .summary-table {
      width: 100%;
      border-collapse: collapse;
      font-size: 11px;
    }

    .summary-table td {
      padding: 4px 6px;
    }

    .summary-table tr.grand-total td {
      font-size: 13px;
      font-weight: 700;
      color: #0f172a;
      border-top: 2px solid #0f172a;
      border-bottom: 2px solid #0f172a;
      padding: 8px 6px;
    }

    .words-box {
      margin-top: 14px;
      padding: 10px;
      background: #f1f5f9;
      border-radius: 6px;
      font-size: 11px;
      border-left: 3px solid #10b981;
    }

    .terms-box {
      margin-top: 20px;
      padding-top: 12px;
      border-top: 1px dashed #cbd5e1;
      font-size: 10px;
      color: #64748b;
      line-height: 1.4;
    }

    .signature-box {
      text-align: right;
      margin-top: 30px;
    }

    .sign-line {
      display: inline-block;
      width: 180px;
      border-top: 1px solid #0f172a;
      margin-top: 36px;
      padding-top: 4px;
      font-size: 11px;
      font-weight: 600;
      color: #334155;
    }

    .no-print-bar {
      position: fixed;
      top: 12px;
      right: 20px;
      background: #0f172a;
      color: #fff;
      padding: 8px 16px;
      border-radius: 6px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.25);
      z-index: 9999;
      display: flex;
      gap: 12px;
      align-items: center;
    }

    .no-print-bar button {
      background: #10b981;
      color: #fff;
      border: none;
      padding: 6px 14px;
      border-radius: 4px;
      font-weight: 600;
      cursor: pointer;
      font-size: 12px;
    }

    @media print {
      body {
        background: #ffffff;
        padding: 0;
        margin: 0;
      }
      .invoice-container {
        box-shadow: none;
        border: none;
        padding: 10mm;
        max-width: 100%;
      }
      .no-print-bar {
        display: none !important;
      }
      @page {
        size: A4 portrait;
        margin: 8mm;
      }
    }
  </style>
</head>
<body>

  <div class="no-print-bar">
    <span>GST Tax Invoice Preview</span>
    <button onclick="window.print()">Print / Save PDF</button>
  </div>

  <div class="invoice-container">
    <!-- Header -->
    <div class="header-bar">
      <div class="brand-section">
        <h1>${business.name}</h1>
        <div class="subtitle">${business.legalName}</div>
        <div class="brand-details">
          ${businessStreet.isNotEmpty ? '$businessStreet<br>' : ''}
          ${businessCityState.isNotEmpty || businessPin.isNotEmpty ? '$businessCityState$businessPin<br>' : ''}
          <strong>GSTIN:</strong> ${business.gstin} | <strong>PAN:</strong> ${business.pan}<br>
          <strong>Email:</strong> ${business.email} | <strong>Phone:</strong> ${business.phone}
        </div>
      </div>
      <div class="invoice-tag-section">
        <div class="invoice-badge">TAX INVOICE</div>
        <table class="invoice-meta-table">
          <tr>
            <td class="label">Invoice No:</td>
            <td class="val">${invoice.invoiceNumber}</td>
          </tr>
          <tr>
            <td class="label">Invoice Date:</td>
            <td class="val">$dateFormatted</td>
          </tr>
          <tr>
            <td class="label">Order No:</td>
            <td class="val">${invoice.orderNumber}</td>
          </tr>
          <tr>
            <td class="label">Order Date:</td>
            <td class="val">$orderDateFormatted</td>
          </tr>
          <tr>
            <td class="label">Payment Mode:</td>
            <td class="val">${invoice.paymentMethod}</td>
          </tr>
          <tr>
            <td class="label">Place of Supply:</td>
            <td class="val">${customer.state} (${customer.stateCode})</td>
          </tr>
        </table>
      </div>
    </div>

    <!-- Customer & Billing Information -->
    <div class="info-grid">
      <div class="info-card">
        <h3>Billed To & Shipped To (Customer)</h3>
        <p>
          <strong>${customer.name}</strong><br>
          ${customer.address}<br>
          ${customer.city.isNotEmpty ? '${customer.city}, ' : ''}${customer.state} (Code: ${customer.stateCode})<br>
          <strong>Phone:</strong> ${customer.phone}<br>
          <strong>GSTIN:</strong> ${customer.gstin}
        </p>
      </div>
      <div class="info-card">
        <h3>Dispatch & Fulfillment Details</h3>
        <p>
          <strong>Fulfillment Hub:</strong> ${invoice.fulfillmentHub ?? 'Central Dispatch Hub'}<br>
          <strong>Sales Channel:</strong> ${invoice.channel.toUpperCase()}<br>
          <strong>Order Status:</strong> ${invoice.orderStatus}<br>
          <strong>Payment Status:</strong> ${invoice.paymentStatus}<br>
          <strong>Reverse Charge:</strong> No (Applicable under Forward Charge)
        </p>
      </div>
    </div>

    <!-- Product Itemized Table -->
    <table class="items-table">
      <thead>
        <tr>
          <th style="width: 35px; text-align: center;">#</th>
          <th>Item Description & SKU</th>
          <th style="width: 60px; text-align: center;">HSN</th>
          <th style="width: 45px; text-align: center;">Qty</th>
          <th style="width: 75px; text-align: right;">Unit Price<br><small style="font-weight: normal; font-size: 9px; color: #64748b;">(Excl. Tax)</small></th>
          <th style="width: 80px; text-align: right;">Taxable Value<br><small style="font-weight: normal; font-size: 9px; color: #64748b;">(Excl. Tax)</small></th>
          <th style="width: 70px; text-align: right;">CGST</th>
          <th style="width: 70px; text-align: right;">${summary.isIntraState ? 'SGST' : 'IGST'}</th>
          <th style="width: 85px; text-align: right;">Total (₹)<br><small style="font-weight: normal; font-size: 9px; color: #64748b;">(Incl. Tax)</small></th>
        </tr>
      </thead>
      <tbody>
        $itemsRows
      </tbody>
    </table>

    <!-- Bottom Breakdown & Totals -->
    <div class="bottom-section">
      <div>
        <div class="words-box">
          <strong>Amount in Words:</strong><br>
          <span>${summary.amountInWords}</span>
        </div>

        <div class="terms-box">
          <strong>Terms & Conditions:</strong>
          <ol style="padding-left: 16px; margin-top: 4px;">
            ${invoice.terms.map((t) => '<li>$t</li>').join('')}
          </ol>
        </div>
      </div>

      <div class="summary-card">
        <table class="summary-table">
          <tr>
            <td>Total Taxable Value:</td>
            <td style="text-align: right;">₹${summary.taxableAmount.toStringAsFixed(2)}</td>
          </tr>
          ${summary.isIntraState ? '''
          <tr>
            <td>Central GST (CGST):</td>
            <td style="text-align: right;">₹${summary.totalCgst.toStringAsFixed(2)}</td>
          </tr>
          <tr>
            <td>State GST (SGST):</td>
            <td style="text-align: right;">₹${summary.totalSgst.toStringAsFixed(2)}</td>
          </tr>
          ''' : '''
          <tr>
            <td>Integrated GST (IGST):</td>
            <td style="text-align: right;">₹${summary.totalIgst.toStringAsFixed(2)}</td>
          </tr>
          '''}
          ${summary.deliveryCharges > 0 ? '''
          <tr>
            <td>Delivery / Freight Charges:</td>
            <td style="text-align: right;">₹${summary.deliveryCharges.toStringAsFixed(2)}</td>
          </tr>
          ''' : ''}
          ${summary.totalDiscount > 0 ? '''
          <tr>
            <td>Discount Applied:</td>
            <td style="text-align: right; color: #dc2626;">-₹${summary.totalDiscount.toStringAsFixed(2)}</td>
          </tr>
          ''' : ''}
          <tr class="grand-total">
            <td>Grand Total:</td>
            <td style="text-align: right;">₹${summary.grandTotal.toStringAsFixed(2)}</td>
          </tr>
        </table>

        <div class="signature-box">
          <div class="sign-line">
            For ${business.name}<br>
            <span style="font-size: 10px; color: #64748b; font-weight: normal;">Authorized Signatory</span>
          </div>
        </div>
      </div>
    </div>
  </div>

</body>
</html>
    ''';
  }
}
