import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/admin_support_ticket_service.dart';
import 'package:spare_shop_admin/core/services/socket_service.dart';
import 'package:spare_shop_admin/ui/common/admin_support_ticket_models.dart';
import 'package:stacked/stacked.dart';

class AdminSupportTicketsViewModel extends BaseViewModel with NavigationMixin {
  final _ticketService = locator<AdminSupportTicketService>();
  final _socketService = locator<SocketService>();

  String _selectedStatus = 'All';
  String get selectedStatus => _selectedStatus;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<AdminSupportTicket> _tickets = [];
  List<AdminSupportTicket> get tickets => _tickets;

  int get allCount => _tickets.length;
  int get openCount =>
      _tickets.where((t) => t.status == AdminTicketStatus.open).length;
  int get pendingCount =>
      _tickets.where((t) => t.status == AdminTicketStatus.pending).length;
  int get resolvedCount =>
      _tickets.where((t) => t.status == AdminTicketStatus.resolved).length;
  int get closedCount =>
      _tickets.where((t) => t.status == AdminTicketStatus.closed).length;

  List<AdminSupportTicket> get filteredTickets {
    var result = _tickets;

    if (_selectedStatus != 'All') {
      result = result
          .where((t) =>
              t.status.name.toLowerCase() == _selectedStatus.toLowerCase())
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result.where((t) {
        final numberMatch =
            t.ticketNumber.toLowerCase().contains(_searchQuery);
        final nameMatch = t.customerName.toLowerCase().contains(_searchQuery);
        final emailMatch =
            t.customerEmail.toLowerCase().contains(_searchQuery);
        final phoneMatch =
            t.customerPhone.toLowerCase().contains(_searchQuery);
        final subjectMatch = t.subject.toLowerCase().contains(_searchQuery);
        final categoryMatch = t.category.toLowerCase().contains(_searchQuery);
        return numberMatch ||
            nameMatch ||
            emailMatch ||
            phoneMatch ||
            subjectMatch ||
            categoryMatch;
      }).toList();
    }

    return result;
  }

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await loadTickets();
    _setupSocket();
  }

  Future<void> loadTickets() async {
    setBusy(true);
    try {
      _tickets = await _ticketService.getAllTickets();
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
                  status: AdminTicketStatus.fromString(data['status'].toString()),
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
    try {
      _socketService.leaveRoom('admin:support-tickets');
    } catch (_) {}
    super.dispose();
  }
}
