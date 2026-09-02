import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/return_exchange_service.dart';
import 'package:spare_shop_admin/ui/common/return_exchange_models.dart';
import 'package:stacked/stacked.dart';

class AdminReturnDetailViewModel extends FutureViewModel<void> with NavigationMixin {
  final String caseId;
  final _returnsService = locator<ReturnExchangeService>();

  final statusNoteController = TextEditingController();

  ReturnExchangeCase? _kase;
  ReturnExchangeCase? get kase => _kase;

  String? _selectedNewStatus;
  String? get selectedNewStatus => _selectedNewStatus;

  AdminReturnDetailViewModel({required this.caseId});

  void handleBack() {
    try {
      navigationService.back();
    } catch (_) {
      goToReturnsExchanges();
    }
  }

  @override
  Future<void> futureToRun() => loadCase();

  Future<void> loadCase() async {
    setBusy(true);
    try {
      _kase = await _returnsService.getCaseById(caseId);
      _selectedNewStatus = null;
      statusNoteController.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading return case detail: $e');
    } finally {
      setBusy(false);
    }
  }

  void setSelectedNewStatus(String? status) {
    _selectedNewStatus = status;
    notifyListeners();
  }

  List<String> get availableNextStatuses {
    if (_kase == null) return [];
    final current = _kase!.status.toLowerCase();

    switch (current) {
      case 'pending':
        return ['approved', 'rejected', 'cancelled'];
      case 'approved':
        return ['completed', 'received', 'processing', 'cancelled'];
      case 'received':
        return ['processing', 'completed', 'cancelled'];
      case 'processing':
        return ['completed', 'cancelled'];
      default:
        return []; // Terminal states
    }
  }

  Future<void> updateStatus(BuildContext context) async {
    if (_selectedNewStatus == null || isBusy) return;

    setBusy(true);
    try {
      _kase = await _returnsService.updateCaseStatus(
        caseId,
        _selectedNewStatus!,
        notes: statusNoteController.text.trim(),
      );

      _selectedNewStatus = null;
      statusNoteController.clear();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Case status updated to ${_kase!.status.toUpperCase()}'),
            backgroundColor: Colors.green,
          ),
        );
      }
      notifyListeners();
    } catch (e) {
      final msg = e.toString().replaceAll('Exception:', '').trim();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg.isNotEmpty ? msg : 'Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    statusNoteController.dispose();
    super.dispose();
  }
}
