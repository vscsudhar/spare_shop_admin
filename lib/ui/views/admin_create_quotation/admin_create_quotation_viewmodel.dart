import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/rare_request_service.dart';
import 'package:stacked/stacked.dart';

class AdminCreateQuotationViewModel extends BaseViewModel with NavigationMixin {
  final _rareRequestService = locator<RareRequestService>();

  late String _requestId;
  String get requestId => _requestId;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final shippingController = TextEditingController();
  final discountController = TextEditingController();
  final timelineController = TextEditingController();
  final notesController = TextEditingController();

  double _total = 0.0;
  double get total => _total;
  double _gst = 0.0;
  double get gst => _gst;

  bool _isInitialized = false;

  void initialize(String id) async {
    if (_isInitialized && _requestId == id) return;
    _requestId = id;
    _isInitialized = true;
    setBusy(true);
    try {
      final req = await _rareRequestService.adminGetRequestById(_requestId);
      nameController.text = req.partName ?? 'Genuine EV Spare Component';
      priceController.text =
          req.budget != null ? req.budget!.toStringAsFixed(0) : '1200';
      shippingController.text = '100';
      discountController.text = '16';
      timelineController.text = req.urgency == 'Urgent'
          ? '2 - 3 Days Delivery'
          : '5 - 7 Days Delivery';
      notesController.text = 'Oem factory compatibility confirmed.';
      calculateTotal();
      rebuildUi();
    } catch (_) {
    } finally {
      setBusy(false);
    }
  }

  void calculateTotal() {
    final price = double.tryParse(priceController.text) ?? 0.0;
    final shipping = double.tryParse(shippingController.text) ?? 0.0;
    final discount = double.tryParse(discountController.text) ?? 0.0;

    _gst = price * 0.18;
    _total = price + shipping + _gst - discount;
    notifyListeners();
  }

  Future<void> sendQuotation() async {
    if (!formKey.currentState!.validate()) return;

    final price = double.tryParse(priceController.text) ?? 0.0;
    final shipping = double.tryParse(shippingController.text) ?? 0.0;
    final discount = double.tryParse(discountController.text) ?? 0.0;

    setBusy(true);
    try {
      final quotation = await _rareRequestService.adminCreateQuotationDraft(
        _requestId,
        partName: nameController.text.trim(),
        price: price,
        shippingCharge: shipping,
        gst: _gst,
        discount: discount,
        deliveryTimeline: timelineController.text.trim(),
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        adminNotes: notesController.text.trim(),
      );

      await _rareRequestService.adminSendQuotation(_requestId, quotation.id);

      setBusy(false);
      goBack();
    } catch (_) {
      setBusy(false);
    }
  }
}
