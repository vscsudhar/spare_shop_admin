import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/app/app.router.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/location_service.dart';
import 'package:spare_shop_admin/core/services/rare_request_service.dart';
import 'package:spare_shop_admin/core/services/socket_service.dart';
import 'package:spare_shop_admin/core/services/token_service.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';
import 'package:stacked/stacked.dart';

class AdminRareRequestsViewModel extends BaseViewModel with NavigationMixin {
  final _rareRequestService = locator<RareRequestService>();
  final _socketService = locator<SocketService>();
  final _locationService = locator<LocationService>();
  final _tokenService = locator<TokenService>();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Function(dynamic)? _onUpdatedHandler;
  Function(dynamic)? _onNewHandler;

  String _selectedStatus = 'All';
  String get selectedStatus => _selectedStatus;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedLocationFilter = 'all'; // 'all', locationId, or 'unassigned'
  String get selectedLocationFilter => _selectedLocationFilter;

  String _selectedChannel = 'all'; // 'all', 'online', 'in_store'
  String get selectedChannel => _selectedChannel;

  List<LocationModel> _locations = [];
  List<LocationModel> get locations => _locations;

  bool _canChangeLocation = true;
  bool get canChangeLocation => _canChangeLocation;

  String? _userAssignedLocationId;
  String? get userAssignedLocationId => _userAssignedLocationId;

  String? _userAssignedLocationName;
  String? get userAssignedLocationName => _userAssignedLocationName;

  List<RareProductRequestModel> _allRequests = [];
  List<RareProductRequestModel> get allRequests => _allRequests;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Status Counters
  int get allCount => _allRequests.length;
  int get submittedCount =>
      _allRequests.where((r) => r.status == RareRequestStatus.submitted).length;
  int get searchingCount =>
      _allRequests.where((r) => r.status == RareRequestStatus.searching).length;
  int get quotationSentCount => _allRequests
      .where((r) => r.status == RareRequestStatus.quotationSent)
      .length;
  int get approvedCount =>
      _allRequests.where((r) => r.status == RareRequestStatus.approved).length;
  int get cancelledCount =>
      _allRequests.where((r) => r.status == RareRequestStatus.cancelled).length;

  List<RareProductRequestModel> get filteredRequests {
    var list = _allRequests;

    if (_selectedStatus != 'All') {
      list = list.where((r) {
        switch (_selectedStatus) {
          case 'Submitted':
            return r.status == RareRequestStatus.submitted;
          case 'Searching':
            return r.status == RareRequestStatus.searching;
          case 'Quotation Sent':
            return r.status == RareRequestStatus.quotationSent;
          case 'Approved':
            return r.status == RareRequestStatus.approved;
          case 'Cancelled':
            return r.status == RareRequestStatus.cancelled;
          default:
            return true;
        }
      }).toList();
    }

    if (_selectedLocationFilter == '__none__') return [];

    if (_selectedLocationFilter == 'unassigned') {
      list = list
          .where((r) => r.locationId == null || r.locationId!.isEmpty)
          .toList();
    } else if (_selectedLocationFilter != 'all') {
      list = list.where((r) {
        final matchesId = r.locationId == _selectedLocationFilter;
        final matchesName = r.locationName != null &&
            r.locationName!.isNotEmpty &&
            _locations.any((l) =>
                l.id == _selectedLocationFilter &&
                l.name.toLowerCase() == r.locationName!.toLowerCase());
        return matchesId || matchesName;
      }).toList();
    }

    if (_selectedChannel != 'all') {
      list = list
          .where(
              (r) => r.channel.toLowerCase() == _selectedChannel.toLowerCase())
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((r) {
        final idMatch = r.id.toLowerCase().contains(q);
        final titleMatch = (r.partName ?? '').toLowerCase().contains(q);
        final descMatch = r.description.toLowerCase().contains(q);
        final custMatch = r.customerName.toLowerCase().contains(q);
        final phoneMatch = r.phone.toLowerCase().contains(q);
        final locMatch = (r.locationName ?? '').toLowerCase().contains(q);
        final vehicleMatch = r.vehicle.displayName.toLowerCase().contains(q);
        return idMatch ||
            titleMatch ||
            descMatch ||
            custMatch ||
            phoneMatch ||
            locMatch ||
            vehicleMatch;
      }).toList();
    }

    return list;
  }

  Future<void> initialise() async {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    TokenService.locationNotifier.addListener(_onLocationNotifierChanged);

    if (_initialized) return;
    _initialized = true;

    _setupSocket();
    await loadRequests();
  }

  void _onLocationNotifierChanged() {
    final newLocId = TokenService.locationNotifier.locationId;
    _selectedLocationFilter =
        (newLocId != null && newLocId.isNotEmpty) ? newLocId : 'all';
    loadRequests();
  }

  Future<void> loadRequests() async {
    setBusy(true);
    _errorMessage = null;
    notifyListeners();

    try {
      _canChangeLocation = await _tokenService.canChangeLocation();
      _userAssignedLocationId = await _tokenService.getUserLocationId();
      _userAssignedLocationName = await _tokenService.getUserLocationName();

      try {
        _locations = await _locationService.getLocations();
      } catch (_) {
        _locations = [];
      }

      if (!_canChangeLocation &&
          (_userAssignedLocationId == null ||
              _userAssignedLocationId!.isEmpty)) {
        _selectedLocationFilter = '__none__';
      } else if (_userAssignedLocationId != null &&
          _userAssignedLocationId!.isNotEmpty &&
          _userAssignedLocationId != 'all') {
        _selectedLocationFilter = _userAssignedLocationId!;
      }

      if (_selectedLocationFilter == '__none__') {
        _allRequests = [];
        notifyListeners();
        return;
      }

      _allRequests = await _rareRequestService.adminGetAllRequests(
        locationId: _selectedLocationFilter != 'all' &&
                _selectedLocationFilter != 'unassigned'
            ? _selectedLocationFilter
            : null,
        channel: _selectedChannel != 'all' ? _selectedChannel : null,
      );

      // Auto-sync location names
      for (int i = 0; i < _allRequests.length; i++) {
        final r = _allRequests[i];
        if (r.locationId != null &&
            (r.locationName == null || r.locationName!.isEmpty)) {
          final match = _locations.where((l) => l.id == r.locationId);
          if (match.isNotEmpty) {
            _allRequests[i] = r.copyWith(locationName: match.first.name);
          }
        }
      }
    } catch (e, st) {
      debugPrint('Error loading admin rare requests: $e\n$st');
      _errorMessage = 'Failed to load requests: $e';
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void onSearch(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setSelectedLocationFilter(String locationId) {
    _selectedLocationFilter = locationId;
    if (_canChangeLocation) {
      locator<TokenService>().saveUserLocation(
        locationId: locationId == 'all' || locationId == 'unassigned'
            ? null
            : locationId,
        locationName: locationId != 'all' &&
                locationId != 'unassigned' &&
                _locations.any((l) => l.id == locationId)
            ? _locations.firstWhere((l) => l.id == locationId).name
            : 'All Locations (HQ)',
      );
    }
    loadRequests();
  }

  void setSelectedChannel(String channel) {
    _selectedChannel = channel;
    loadRequests();
  }

  Future<void> updateRequestLocation(
    String requestId,
    String locationId,
    String locationName,
    BuildContext context,
  ) async {
    setBusy(true);
    try {
      final updated = await _rareRequestService.adminUpdateRequestLocation(
        requestId,
        locationId: locationId,
        locationName: locationName,
      );

      final idx = _allRequests.indexWhere((r) => r.id == requestId);
      if (idx != -1) {
        _allRequests[idx] = updated;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request assigned to $locationName'),
            backgroundColor: Colors.green,
          ),
        );
      }
      notifyListeners();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update hub: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setBusy(false);
    }
  }

  void _setupSocket() {
    try {
      _socketService.connect();

      _onUpdatedHandler = (data) {
        if (!disposed) loadRequests();
      };
      _onNewHandler = (data) {
        if (!disposed) loadRequests();
      };

      _socketService.on('rare_request:updated', _onUpdatedHandler!);
      _socketService.on('rare_request:new', _onNewHandler!);
    } catch (e) {
      debugPrint('RareRequests Socket connection error: $e');
    }
  }

  Future<void> openChat(RareProductRequestModel request) async {
    await navigationService.navigateTo(
      Routes.adminRareRequestChatView,
      arguments: AdminRareRequestChatViewArguments(requestId: request.id),
    );
    if (!disposed) {
      await loadRequests();
    }
  }

  @override
  void dispose() {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    try {
      if (_onUpdatedHandler != null) {
        _socketService.off('rare_request:updated', _onUpdatedHandler);
      }
      if (_onNewHandler != null) {
        _socketService.off('rare_request:new', _onNewHandler);
      }
    } catch (_) {}
    super.dispose();
  }
}
