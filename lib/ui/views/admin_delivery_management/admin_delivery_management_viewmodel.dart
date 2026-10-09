import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/models/delivery_models.dart';
import 'package:spare_shop_admin/core/services/delivery_service.dart';
import 'package:stacked/stacked.dart';

class AdminDeliveryManagementViewModel extends BaseViewModel {
  final DeliveryService _deliveryService = locator<DeliveryService>();

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  // --- TAB 1: ASSIGN DELIVERIES STATE ---
  List<DeliveryPartnerModel> _deliveryPartners = [];
  List<DeliveryPartnerModel> get deliveryPartners => _deliveryPartners;

  DeliveryPartnerModel? _selectedPartner1;
  DeliveryPartnerModel? get selectedPartner1 => _selectedPartner1;

  DeliveryPartnerModel? _selectedPartner2;
  DeliveryPartnerModel? get selectedPartner2 => _selectedPartner2;

  bool _isSplitMode = false;
  bool get isSplitMode => _isSplitMode;

  List<DeliveryOrderModel> _eligibleOrders = [];
  List<DeliveryOrderModel> get eligibleOrders => _eligibleOrders;

  final List<DeliveryOrderModel> _partner1Orders = [];
  List<DeliveryOrderModel> get partner1Orders => _partner1Orders;

  final List<DeliveryOrderModel> _partner2Orders = [];
  List<DeliveryOrderModel> get partner2Orders => _partner2Orders;

  String _orderSearchQuery = '';
  String get orderSearchQuery => _orderSearchQuery;

  String _selectedDirectionFilter = 'All';
  String get selectedDirectionFilter => _selectedDirectionFilter;

  RouteResult? _partner1Route;
  RouteResult? get partner1Route => _partner1Route;

  RouteResult? _partner2Route;
  RouteResult? get partner2Route => _partner2Route;

  bool _hasAnswered10OrderPrompt = false;
  bool _isCalculatingRoute1 = false;
  bool get isCalculatingRoute1 => _isCalculatingRoute1;

  bool _isCalculatingRoute2 = false;
  bool get isCalculatingRoute2 => _isCalculatingRoute2;

  // --- TAB 2: DELIVERY ASSIGNMENTS STATE ---
  List<DeliveryAssignmentModel> _assignments = [];
  List<DeliveryAssignmentModel> get assignments => _assignments;

  String _assignmentStatusFilter = 'All';
  String get assignmentStatusFilter => _assignmentStatusFilter;

  String _assignmentPartnerFilter = 'All';
  String get assignmentPartnerFilter => _assignmentPartnerFilter;

  String _assignmentSearchQuery = '';
  String get assignmentSearchQuery => _assignmentSearchQuery;

  // --- TAB 3: MONITOR STATE ---
  List<DeliveryPartnerModel> _monitorPartners = [];
  List<DeliveryPartnerModel> get monitorPartners => _monitorPartners;

  int get totalSelectedOrdersCount =>
      _partner1Orders.length + _partner2Orders.length;

  Future<void> init() async {
    setBusy(true);
    await loadData();
    setBusy(false);
  }

  Future<void> loadData() async {
    try {
      _deliveryPartners = await _deliveryService.getDeliveryPartners();
      _monitorPartners = List.from(_deliveryPartners);

      // Default select first partner if not selected
      if (_selectedPartner1 == null && _deliveryPartners.isNotEmpty) {
        _selectedPartner1 = _deliveryPartners.first;
      }

      _eligibleOrders = await _deliveryService.getEligibleOrders();
      _assignments = await _deliveryService.getAssignments();

      await _refreshRoutes();
    } catch (e) {
      debugPrint('[AdminDeliveryManagementViewModel] Error loading data: $e');
    }
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
    if (index == 1) {
      refreshAssignments();
    } else if (index == 2) {
      refreshMonitor();
    }
  }

  // -------------------------------------------------------------
  // TAB 1: ASSIGN DELIVERIES METHODS
  // -------------------------------------------------------------

  void setPartner1(DeliveryPartnerModel? partner) {
    _selectedPartner1 = partner;
    notifyListeners();
    _refreshRoutes();
  }

  void setPartner2(DeliveryPartnerModel? partner) {
    _selectedPartner2 = partner;
    notifyListeners();
    _refreshRoutes();
  }

  void setOrderSearchQuery(String query) {
    _orderSearchQuery = query;
    notifyListeners();
  }

  void setDirectionFilter(String dir) {
    _selectedDirectionFilter = dir;
    notifyListeners();
  }

  List<DeliveryOrderModel> get filteredEligibleOrders {
    return _eligibleOrders.where((order) {
      // Exclude already added to partner 1 or 2
      final inP1 = _partner1Orders.any((o) => o.id == order.id);
      final inP2 = _partner2Orders.any((o) => o.id == order.id);
      if (inP1 || inP2) return false;

      // Filter by direction
      if (_selectedDirectionFilter != 'All' &&
          order.direction.toLowerCase() !=
              _selectedDirectionFilter.toLowerCase()) {
        return false;
      }

      // Filter by search query
      if (_orderSearchQuery.isNotEmpty) {
        final q = _orderSearchQuery.toLowerCase();
        final matchNum = order.orderNumber.toLowerCase().contains(q);
        final matchCust = order.customerName.toLowerCase().contains(q);
        final matchAddr = order.address.toLowerCase().contains(q);
        if (!matchNum && !matchCust && !matchAddr) return false;
      }

      return true;
    }).toList();
  }

  bool isOrderSelected(DeliveryOrderModel order) {
    return _partner1Orders.any((o) => o.id == order.id) ||
        _partner2Orders.any((o) => o.id == order.id);
  }

  /// Handles adding an individual order with the exact 10-order confirmation business rule
  Future<void> toggleOrderSelection(
    DeliveryOrderModel order,
    BuildContext context,
  ) async {
    final currentlySelected = isOrderSelected(order);

    if (currentlySelected) {
      // Remove order
      _partner1Orders.removeWhere((o) => o.id == order.id);
      _partner2Orders.removeWhere((o) => o.id == order.id);
      _reindexSequences();
      notifyListeners();
      _refreshRoutes();
      return;
    }

    // Checking count before adding
    final currentTotal = totalSelectedOrdersCount;

    // Check if adding this order will become the 11th order (>10 selected orders)
    if (currentTotal == 10 && !_hasAnswered10OrderPrompt && !_isSplitMode) {
      final shouldSplit = await showMoreThan10OrdersDialog(context);
      _hasAnswered10OrderPrompt = true;

      if (shouldSplit == true) {
        // "Yes, Select Second Partner"
        _isSplitMode = true;
        if (_selectedPartner2 == null) {
          // Auto select a different delivery partner for convenience
          final secondCandidates = _deliveryPartners
              .where((p) => p.id != _selectedPartner1?.id)
              .toList();
          if (secondCandidates.isNotEmpty) {
            _selectedPartner2 = secondCandidates.first;
          }
        }
        // Add 11th order to Partner 2
        _partner2Orders.add(order.copyWith(sequence: _partner2Orders.length + 1));
      } else {
        // "No, Assign to First Partner"
        _isSplitMode = false;
        _partner1Orders.add(order.copyWith(sequence: _partner1Orders.length + 1));
      }
    } else {
      // Regular addition: If in split mode with Partner 2 active and Partner 1 already >= 10, add to Partner 2, else Partner 1
      if (_isSplitMode && _partner1Orders.length >= 10) {
        _partner2Orders.add(order.copyWith(sequence: _partner2Orders.length + 1));
      } else {
        _partner1Orders.add(order.copyWith(sequence: _partner1Orders.length + 1));
      }
    }

    _reindexSequences();
    notifyListeners();
    _refreshRoutes();
  }

  void enableSplitMode() {
    _isSplitMode = true;
    if (_selectedPartner2 == null) {
      final secondCandidates =
          _deliveryPartners.where((p) => p.id != _selectedPartner1?.id).toList();
      if (secondCandidates.isNotEmpty) {
        _selectedPartner2 = secondCandidates.first;
      }
    }
    notifyListeners();
    _refreshRoutes();
  }

  void disableSplitMode() {
    // Merge partner 2 orders back into partner 1
    _partner1Orders.addAll(_partner2Orders);
    _partner2Orders.clear();
    _isSplitMode = false;
    _reindexSequences();
    notifyListeners();
    _refreshRoutes();
  }

  void transferToPartner2(DeliveryOrderModel order) {
    _partner1Orders.removeWhere((o) => o.id == order.id);
    _partner2Orders.add(order);
    _reindexSequences();
    notifyListeners();
    _refreshRoutes();
  }

  void transferToPartner1(DeliveryOrderModel order) {
    _partner2Orders.removeWhere((o) => o.id == order.id);
    _partner1Orders.add(order);
    _reindexSequences();
    notifyListeners();
    _refreshRoutes();
  }

  void removePendingOrder(DeliveryOrderModel order) {
    _partner1Orders.removeWhere((o) => o.id == order.id);
    _partner2Orders.removeWhere((o) => o.id == order.id);
    _reindexSequences();
    notifyListeners();
    _refreshRoutes();
  }

  void movePartner1Stop(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _partner1Orders.removeAt(oldIndex);
    _partner1Orders.insert(newIndex, item);
    _reindexSequences();
    notifyListeners();
    _refreshRoutes();
  }

  void movePartner2Stop(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _partner2Orders.removeAt(oldIndex);
    _partner2Orders.insert(newIndex, item);
    _reindexSequences();
    notifyListeners();
    _refreshRoutes();
  }

  void _reindexSequences() {
    for (int i = 0; i < _partner1Orders.length; i++) {
      _partner1Orders[i] = _partner1Orders[i].copyWith(sequence: i + 1);
    }
    for (int i = 0; i < _partner2Orders.length; i++) {
      _partner2Orders[i] = _partner2Orders[i].copyWith(sequence: i + 1);
    }
  }

  Future<void> _refreshRoutes() async {
    if (_partner1Orders.isNotEmpty) {
      _isCalculatingRoute1 = true;
      notifyListeners();
      _partner1Route = await _deliveryService.calculateRoute(_partner1Orders);
      _isCalculatingRoute1 = false;
      notifyListeners();
    } else {
      _partner1Route = null;
    }

    if (_isSplitMode && _partner2Orders.isNotEmpty) {
      _isCalculatingRoute2 = true;
      notifyListeners();
      _partner2Route = await _deliveryService.calculateRoute(_partner2Orders);
      _isCalculatingRoute2 = false;
      notifyListeners();
    } else {
      _partner2Route = null;
    }
    notifyListeners();
  }

  /// Dialog when 11th order is added
  Future<bool?> showMoreThan10OrdersDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 28),
              SizedBox(width: 10),
              Text(
                'More Than 10 Orders',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            'You have selected more than 10 orders. Do you want to assign the additional orders to a second delivery partner?',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade800,
                side: BorderSide(color: Colors.grey.shade400),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(false), // No, Assign to First Partner
              child: const Text('No, Assign to First Partner'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F9F59),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(true), // Yes, Select Second Partner
              child: const Text('Yes, Select Second Partner'),
            ),
          ],
        );
      },
    );
  }

  /// Final Confirmation & Save Action
  Future<void> confirmAssignment(BuildContext context) async {
    if (_selectedPartner1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery partner first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_partner1Orders.isEmpty && (!_isSplitMode || _partner2Orders.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one order to assign.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isSplitMode && _partner2Orders.isNotEmpty && _selectedPartner2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid second delivery partner.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show Confirmation Dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Delivery Assignment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Partner 1: ${_selectedPartner1!.name} (${_partner1Orders.length} orders)'),
            if (_isSplitMode && _partner2Orders.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Partner 2: ${_selectedPartner2?.name ?? "None"} (${_partner2Orders.length} orders)'),
            ],
            const SizedBox(height: 12),
            const Text(
              'Are you sure you want to save and dispatch these delivery assignments?',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F9F59),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm & Save'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setBusy(true);
    try {
      // 1. Create Batch for Partner 1
      if (_partner1Orders.isNotEmpty && _selectedPartner1 != null) {
        await _deliveryService.createAssignment(
          driverId: _selectedPartner1!.id,
          driverName: _selectedPartner1!.name,
          orders: _partner1Orders,
          locationName: _selectedPartner1!.locationName,
        );
      }

      // 2. Create Batch for Partner 2 if in split mode
      if (_isSplitMode && _partner2Orders.isNotEmpty && _selectedPartner2 != null) {
        await _deliveryService.createAssignment(
          driverId: _selectedPartner2!.id,
          driverName: _selectedPartner2!.name,
          orders: _partner2Orders,
          locationName: _selectedPartner2!.locationName,
        );
      }

      // Clear pending selections
      _partner1Orders.clear();
      _partner2Orders.clear();
      _isSplitMode = false;
      _hasAnswered10OrderPrompt = false;

      // Reload fresh data
      await loadData();
      setBusy(false);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery assignments saved successfully!'),
            backgroundColor: Color(0xFF0F9F59),
          ),
        );
        // Automatically switch to Delivery Assignments tab
        setTabIndex(1);
      }
    } catch (e) {
      setBusy(false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving assignment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // -------------------------------------------------------------
  // TAB 2: DELIVERY ASSIGNMENTS METHODS
  // -------------------------------------------------------------

  void setAssignmentStatusFilter(String status) {
    _assignmentStatusFilter = status;
    notifyListeners();
  }

  void setAssignmentPartnerFilter(String partnerId) {
    _assignmentPartnerFilter = partnerId;
    notifyListeners();
  }

  void setAssignmentSearchQuery(String query) {
    _assignmentSearchQuery = query;
    notifyListeners();
  }

  List<DeliveryAssignmentModel> get filteredAssignments {
    return _assignments.where((a) {
      if (_assignmentStatusFilter != 'All' &&
          a.status.toLowerCase() != _assignmentStatusFilter.toLowerCase()) {
        return false;
      }
      if (_assignmentPartnerFilter != 'All' &&
          a.driverId != _assignmentPartnerFilter) {
        return false;
      }
      if (_assignmentSearchQuery.isNotEmpty) {
        final q = _assignmentSearchQuery.toLowerCase();
        final matchBatch = a.batchNumber.toLowerCase().contains(q);
        final matchDriver = a.driverName.toLowerCase().contains(q);
        final matchOrders = a.orders.any((o) =>
            o.orderNumber.toLowerCase().contains(q) ||
            o.customerName.toLowerCase().contains(q));
        if (!matchBatch && !matchDriver && !matchOrders) return false;
      }
      return true;
    }).toList();
  }

  Future<void> refreshAssignments() async {
    _assignments = await _deliveryService.getAssignments();
    notifyListeners();
  }

  Future<void> reassignDriverInBatch(
    DeliveryAssignmentModel assignment,
    DeliveryPartnerModel newPartner,
    BuildContext context,
  ) async {
    try {
      await _deliveryService.reassignDriver(
        assignment.id,
        newPartner.id,
        newPartner.name,
      );
      await refreshAssignments();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reassigned ${assignment.batchNumber} to ${newPartner.name}'),
            backgroundColor: const Color(0xFF0F9F59),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> removeOrderFromBatch(
    DeliveryAssignmentModel assignment,
    DeliveryOrderModel order,
    BuildContext context,
  ) async {
    try {
      await _deliveryService.removeOrderFromAssignment(
        assignment.id,
        order.id,
        reason: 'Removed by Admin from batch management',
      );
      await loadData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Order ${order.orderNumber} removed from assignment. Customer order is active & ready for re-assignment.',
            ),
            backgroundColor: const Color(0xFF0F9F59),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> addOrderToBatch(
    DeliveryAssignmentModel assignment,
    DeliveryOrderModel order,
    BuildContext context,
  ) async {
    try {
      await _deliveryService.addOrderToAssignment(assignment.id, order);
      await loadData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order ${order.orderNumber} added to ${assignment.batchNumber}'),
            backgroundColor: const Color(0xFF0F9F59),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> updateBatchStopSequence(
    DeliveryAssignmentModel assignment,
    List<DeliveryOrderModel> reorderedStops,
    BuildContext context,
  ) async {
    try {
      await _deliveryService.updateStopSequence(assignment.id, reorderedStops);
      await refreshAssignments();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stop sequence updated successfully!'),
            backgroundColor: Color(0xFF0F9F59),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> updateBatchStatus(
    DeliveryAssignmentModel assignment,
    String status,
    BuildContext context,
  ) async {
    try {
      await _deliveryService.updateAssignmentStatus(assignment.id, status);
      await refreshAssignments();
      _eligibleOrders = await _deliveryService.getEligibleOrders();
      notifyListeners();
      if (context.mounted) {
        final formatted = status.toUpperCase().replaceAll('_', ' ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Batch ${assignment.batchNumber} marked as $formatted. Orders module updated successfully.',
            ),
            backgroundColor: const Color(0xFF0F9F59),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> updateOrderStopStatus(
    DeliveryAssignmentModel assignment,
    DeliveryOrderModel order,
    String newOrderStatus,
    BuildContext context,
  ) async {
    try {
      await _deliveryService.updateOrderStopStatus(
        assignment.id,
        order.id,
        newOrderStatus,
      );
      await refreshAssignments();
      _eligibleOrders = await _deliveryService.getEligibleOrders();
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stop ${order.orderNumber} marked as ${newOrderStatus.toUpperCase().replaceAll('_', ' ')} (Synced to Orders module)',
            ),
            backgroundColor: const Color(0xFF0F9F59),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // -------------------------------------------------------------
  // TAB 3: MONITOR METHODS
  // -------------------------------------------------------------

  Future<void> refreshMonitor() async {
    _deliveryPartners = await _deliveryService.getDeliveryPartners();
    _monitorPartners = List.from(_deliveryPartners);
    notifyListeners();
  }

  void showMonitorPlaceholder(BuildContext context, DeliveryPartnerModel partner) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.radar_rounded, color: Color(0xFF3B82F6), size: 26),
            const SizedBox(width: 8),
            Text('Monitor – ${partner.name}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Partner: ${partner.name} (${partner.role})'),
            const SizedBox(height: 4),
            Text('Current Assigned Orders: ${partner.activeOrdersCount}'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Live delivery partner monitoring will be available in a future update.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
