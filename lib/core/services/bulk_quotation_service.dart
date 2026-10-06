import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spare_shop_admin/core/models/bulk_quotation_model.dart';
import 'package:spare_shop_admin/core/services/invoice_service.dart';

class BulkQuotationService {
  static const String _storageKey = 'voltspare_b2b_quotations_v1';
  final List<BulkQuotationModel> _inMemoryQuotations = [];
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw);
        _inMemoryQuotations.clear();
        for (final item in decoded) {
          try {
            _inMemoryQuotations.add(BulkQuotationModel.fromJson(item as Map<String, dynamic>));
          } catch (_) {}
        }
      }
    } catch (_) {}
    _initialized = true;
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _inMemoryQuotations.map((q) => q.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  Future<List<BulkQuotationModel>> getQuotations({String? search, String? statusFilter}) async {
    await _init();
    var list = List<BulkQuotationModel>.from(_inMemoryQuotations);

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      list = list.where((item) {
        return item.quotationNumber.toLowerCase().contains(q) ||
            item.customerName.toLowerCase().contains(q) ||
            item.customerPhone.toLowerCase().contains(q) ||
            item.customerGst.toLowerCase().contains(q) ||
            item.businessName.toLowerCase().contains(q) ||
            (item.invoiceNumber != null && item.invoiceNumber!.toLowerCase().contains(q));
      }).toList();
    }

    if (statusFilter != null && statusFilter.isNotEmpty && statusFilter != 'All') {
      if (statusFilter == 'Converted') {
        list = list.where((item) => item.isConverted).toList();
      } else if (statusFilter == 'Active') {
        list = list.where((item) => !item.isConverted && item.status != 'Cancelled').toList();
      } else {
        list = list.where((item) => item.status.toLowerCase() == statusFilter.toLowerCase()).toList();
      }
    }

    // Sort descending by creation date
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<String> generateNextQuotationNumber() async {
    await _init();
    final now = DateTime.now();
    final prefix = 'QUO-${now.year}${now.month.toString().padLeft(2, '0')}';
    int maxSeq = 0;

    for (final q in _inMemoryQuotations) {
      if (q.quotationNumber.startsWith(prefix)) {
        final parts = q.quotationNumber.split('-');
        if (parts.length >= 3) {
          final seq = int.tryParse(parts.last) ?? 0;
          if (seq > maxSeq) maxSeq = seq;
        }
      }
    }

    final nextSeq = (maxSeq + 1).toString().padLeft(3, '0');
    return '$prefix-$nextSeq';
  }

  Future<BulkQuotationModel> saveQuotation(BulkQuotationModel quotation) async {
    await _init();
    final index = _inMemoryQuotations.indexWhere((q) => q.id == quotation.id);
    if (index != -1) {
      _inMemoryQuotations[index] = quotation.copyWith(updatedAt: DateTime.now());
    } else {
      _inMemoryQuotations.insert(0, quotation);
    }
    await _persist();
    return quotation;
  }

  Future<bool> deleteQuotation(String id) async {
    await _init();
    final initialLen = _inMemoryQuotations.length;
    _inMemoryQuotations.removeWhere((q) => q.id == id);
    if (_inMemoryQuotations.length != initialLen) {
      await _persist();
      return true;
    }
    return false;
  }

  Future<BulkQuotationModel> convertToInvoice(
    BulkQuotationModel quotation, {
    String? customInvoiceNumber,
  }) async {
    await _init();
    final now = DateTime.now();
    final invNumber = customInvoiceNumber ??
        'INV-${now.year}${now.month.toString().padLeft(2, '0')}-${quotation.quotationNumber.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0')}';

    final updated = quotation.copyWith(
      status: 'Converted to Invoice',
      invoiceNumber: invNumber,
      invoiceId: 'inv_${quotation.id}',
      updatedAt: now,
    );

    await saveQuotation(updated);
    return updated;
  }
}
