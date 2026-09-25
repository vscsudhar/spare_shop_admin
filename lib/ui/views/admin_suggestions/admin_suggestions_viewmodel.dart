import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/core/mixins/navigation_mixin.dart';
import 'package:spare_shop_admin/core/services/suggestion_service.dart';
import 'package:spare_shop_admin/ui/common/suggestion_models.dart';
import 'package:stacked/stacked.dart';

class AdminSuggestionsViewModel extends BaseViewModel with NavigationMixin {
  final _suggestionService = locator<SuggestionService>();

  List<SuggestionModel> _suggestions = [];
  List<SuggestionModel> get suggestions => _suggestions;

  String _selectedFilter = 'all';
  String get selectedFilter => _selectedFilter;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  int get totalCount => _suggestions.length;
  int get pendingCount =>
      _suggestions.where((s) => s.status.toLowerCase() == 'pending').length;
  int get reviewedCount =>
      _suggestions.where((s) => s.status.toLowerCase() == 'reviewed').length;
  int get resolvedCount =>
      _suggestions.where((s) => s.status.toLowerCase() == 'resolved').length;

  Future<void> init() async {
    await fetchSuggestions();
  }

  Future<void> fetchSuggestions() async {
    setBusy(true);
    try {
      _suggestions = await _suggestionService.getSuggestions(
        status: _selectedFilter == 'all' ? null : _selectedFilter,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
    } catch (e) {
      _suggestions = [];
    } finally {
      setBusy(false);
    }
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    fetchSuggestions();
  }

  void onSearch(String query) {
    _searchQuery = query.trim();
    fetchSuggestions();
  }

  Future<void> updateStatus(
    String id,
    String status, {
    String? adminNotes,
    BuildContext? context,
  }) async {
    try {
      await _suggestionService.updateStatus(id, status, adminNotes: adminNotes);
      await fetchSuggestions();
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Suggestion marked as ${status.toUpperCase()}'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (_) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update status'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> deleteSuggestion(String id, [BuildContext? context]) async {
    try {
      await _suggestionService.deleteSuggestion(id);
      await fetchSuggestions();
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Suggestion deleted successfully'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (_) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete suggestion'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
