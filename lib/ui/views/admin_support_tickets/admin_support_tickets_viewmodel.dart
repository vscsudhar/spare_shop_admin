import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/admin_support_ticket_service.dart';
import 'package:spare_shop_admin/core/services/location_service.dart';
import 'package:spare_shop_admin/core/services/socket_service.dart';
import 'package:spare_shop_admin/core/services/token_service.dart';
import 'package:spare_shop_admin/ui/common/admin_support_ticket_models.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:stacked/stacked.dart';

class AdminSupportTicketsViewModel extends BaseViewModel with NavigationMixin {
  final _ticketService = locator<AdminSupportTicketService>();
  final _socketService = locator<SocketService>();
  final _locationService = locator<LocationService>();
  final _tokenService = locator<TokenService>();

  String _selectedStatus = 'All';
  String get selectedStatus => _selectedStatus;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedLocationFilter = 'all'; // 'all', locationId, or 'unassigned'
  String get selectedLocationFilter => _selectedLocationFilter;

  List<LocationModel> _locations = [];
  List<LocationModel> get locations => _locations;

  bool _canChangeLocation = true;
  bool get canChangeLocation => _canChangeLocation;

  String? _userAssignedLocationId;
  String? get userAssignedLocationId => _userAssignedLocationId;

  String? _userAssignedLocationName;
  String? get userAssignedLocationName => _userAssignedLocationName;

  List<AdminSupportTicket> _tickets = [];
  List<AdminSupportTicket> get tickets => _tickets;

  int get allCount => filteredByLocationTickets.length;
  int get openCount => filteredByLocationTickets
      .where((t) => t.status == AdminTicketStatus.open)
      .length;
  int get pendingCount => filteredByLocationTickets
      .where((t) => t.status == AdminTicketStatus.pending)
      .length;
  int get resolvedCount => filteredByLocationTickets
      .where((t) => t.status == AdminTicketStatus.resolved)
      .length;
  int get closedCount => filteredByLocationTickets
      .where((t) => t.status == AdminTicketStatus.closed)
      .length;

  List<AdminSupportTicket> get filteredByLocationTickets {
    if (_selectedLocationFilter == '__none__') return [];

    return _tickets.where((t) {
      if (_selectedLocationFilter == 'unassigned') {
        return t.locationId == null || t.locationId!.isEmpty;
      } else if (_selectedLocationFilter != 'all') {
        return (t.locationId == _selectedLocationFilter) ||
            (t.locationName != null &&
                t.locationName!.isNotEmpty &&
                _locations.any((l) =>
                    l.id == _selectedLocationFilter &&
                    l.name.toLowerCase() == t.locationName!.toLowerCase()));
      }
      return true;
    }).toList();
  }

  List<AdminSupportTicket> get filteredTickets {
    var result = filteredByLocationTickets;

    if (_selectedStatus != 'All') {
      result = result
          .where((t) =>
              t.status.name.toLowerCase() == _selectedStatus.toLowerCase())
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result.where((t) {
        final numberMatch = t.ticketNumber.toLowerCase().contains(_searchQuery);
        final nameMatch = t.customerName.toLowerCase().contains(_searchQuery);
        final emailMatch = t.customerEmail.toLowerCase().contains(_searchQuery);
        final phoneMatch = t.customerPhone.toLowerCase().contains(_searchQuery);
        final subjectMatch = t.subject.toLowerCase().contains(_searchQuery);
        final categoryMatch = t.category.toLowerCase().contains(_searchQuery);
        final locMatch =
            (t.locationName ?? '').toLowerCase().contains(_searchQuery);
        return numberMatch ||
            nameMatch ||
            emailMatch ||
            phoneMatch ||
            subjectMatch ||
            categoryMatch ||
            locMatch;
      }).toList();
    }

    return result;
  }

  bool _initialized = false;

  Future<void> init() async {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    TokenService.locationNotifier.addListener(_onLocationNotifierChanged);

    if (_initialized) return;
    _initialized = true;
    await loadTickets();
    _setupSocket();
  }

  void _onLocationNotifierChanged() {
    final newLocId = TokenService.locationNotifier.locationId;
    _selectedLocationFilter =
        (newLocId != null && newLocId.isNotEmpty) ? newLocId : 'all';
    loadTickets();
  }

  Future<void> loadTickets() async {
    setBusy(true);
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
        _tickets = [];
        setBusy(false);
        return;
      }

      _tickets = await _ticketService.getAllTickets();

      // Auto-sync location names
      for (int i = 0; i < _tickets.length; i++) {
        final t = _tickets[i];
        if (t.locationId != null &&
            (t.locationName == null || t.locationName!.isEmpty)) {
          final match = _locations.where((l) => l.id == t.locationId);
          if (match.isNotEmpty) {
            _tickets[i] = t.copyWith(locationName: match.first.name);
          }
        }
      }
    } catch (_) {}
    setBusy(false);
  }

  void _setupSocket() {
    try {
      _socketService.connect();
      _socketService.joinRoom('admin:support-tickets');

      _socketService.off('support_ticket:new');
      _socketService.off('support_ticket:updated');

      _socketService.on('support_ticket:new', (data) {
        if (data is Map<String, dynamic>) {
          final newTicket = AdminSupportTicket.fromJson(data);
          final existingIdx = _tickets.indexWhere((t) => t.id == newTicket.id);
          if (existingIdx >= 0) {
            _tickets[existingIdx] = newTicket;
          } else {
            _tickets.insert(0, newTicket);
          }
          rebuildUi();
        }
      });

      _socketService.on('support_ticket:updated', (data) {
        if (data is Map<String, dynamic>) {
          final ticketId = data['ticketId'] ?? data['_id'] ?? data['id'];
          if (ticketId != null) {
            final idx = _tickets.indexWhere((t) => t.id == ticketId.toString());
            if (idx >= 0) {
              if (data['status'] != null) {
                _tickets[idx] = _tickets[idx].copyWith(
                  status:
                      AdminTicketStatus.fromString(data['status'].toString()),
                );
              }
              rebuildUi();
            } else {
              loadTickets();
            }
          }
        }
      });
    } catch (_) {}
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    rebuildUi();
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
    loadTickets();
  }

  void assignTicketLocation(
      AdminSupportTicket ticket, LocationModel? location) {
    final idx = _tickets.indexWhere((t) => t.id == ticket.id);
    if (idx >= 0) {
      _tickets[idx] = ticket.copyWith(
        locationId: location?.id,
        locationName: location?.name,
      );
      rebuildUi();
    }
  }

  void onSearch(String query) {
    _searchQuery = query.toLowerCase().trim();
    rebuildUi();
  }

  void openTicketChat(AdminSupportTicket ticket) async {
    await goToAdminTicketChat(ticketId: ticket.id);
    await loadTickets();
  }

  @override
  void dispose() {
    TokenService.locationNotifier.removeListener(_onLocationNotifierChanged);
    try {
      _socketService.leaveRoom('admin:support-tickets');
    } catch (_) {}
    super.dispose();
  }
}
