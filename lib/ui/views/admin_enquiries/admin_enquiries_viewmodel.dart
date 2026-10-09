import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/enquiry_service.dart';
import 'package:spare_shop_admin/ui/common/enquiry_models.dart';
import 'package:stacked/stacked.dart';

class AdminEnquiriesViewModel extends BaseViewModel with NavigationMixin {
  final _enquiryService = locator<EnquiryService>();

  List<EnquiryModel> _enquiries = [];
  List<EnquiryModel> get enquiries => _enquiries;

  String _selectedFilter = 'all';
  String get selectedFilter => _selectedFilter;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  int get totalCount => _enquiries.length;
  int get pendingCount =>
      _enquiries.where((e) => e.status.toLowerCase() == 'pending').length;
  int get callUserCount =>
      _enquiries.where((e) => e.status.toLowerCase() == 'call_user').length;
  int get deniedCount =>
      _enquiries.where((e) => e.status.toLowerCase() == 'denied').length;
  int get completedCount =>
      _enquiries.where((e) => e.status.toLowerCase() == 'completed').length;

  Future<void> init() async {
    await fetchEnquiries();
  }

  Future<void> fetchEnquiries() async {
    setBusy(true);
    try {
      _enquiries = await _enquiryService.getEnquiries(
        status: _selectedFilter == 'all' ? null : _selectedFilter,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
    } catch (_) {
      _enquiries = [];
    } finally {
      setBusy(false);
    }
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    fetchEnquiries();
  }

  void onSearch(String query) {
    _searchQuery = query.trim();
    fetchEnquiries();
  }

  Future<void> updateStatus(
    String id,
    String status, {
    String? adminNotes,
    BuildContext? context,
  }) async {
    try {
      await _enquiryService.updateStatus(id, status, adminNotes: adminNotes);
      await fetchEnquiries();
      if (context != null && context.mounted) {
        String displayStatus = status;
        if (status == 'call_user') displayStatus = 'Call User';
        if (status == 'denied') displayStatus = 'Denied';
        if (status == 'completed') displayStatus = 'Completed';
        if (status == 'pending') displayStatus = 'Pending';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Enquiry status updated to ${displayStatus.toUpperCase()}'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update enquiry status'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> deleteEnquiry(String id, [BuildContext? context]) async {
    try {
      await _enquiryService.deleteEnquiry(id);
      await fetchEnquiries();
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enquiry deleted successfully'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (_) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete enquiry'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
