import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/features/history/data/history_repository.dart';
import 'package:mobile_barberstuff/features/history/domain/booking_history.dart';

class HistoryProvider extends ChangeNotifier {
  HistoryProvider(this._repository) {
    searchController.addListener(_onSearchChanged);
    _repository.addListener(load);
    load();
  }

  final HistoryRepository _repository;

  final TextEditingController searchController = TextEditingController();

  List<BookingHistory> _all = const <BookingHistory>[];
  HistoryTab _tab = HistoryTab.upcoming;
  String _query = '';
  bool _isLoading = false;
  bool _isSubmitting = false;

  HistoryTab get tab => _tab;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;

  List<BookingHistory> get items {
    final String needle = _query.toLowerCase();

    return _all.where((BookingHistory item) {
      if (item.tab != _tab) return false;
      if (needle.isEmpty) return true;
      return item.serviceName.toLowerCase().contains(needle) ||
          item.storeName.toLowerCase().contains(needle);
    }).toList(growable: false);
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _all = await _repository.getHistory();

    _isLoading = false;
    notifyListeners();
  }

  void setTab(HistoryTab value) {
    if (_tab == value) return;
    _tab = value;
    notifyListeners();
  }

  Future<bool> submitReview(String bookingId, ReviewDraft draft) async {
    if (!draft.isComplete || _isSubmitting) return false;

    _isSubmitting = true;
    notifyListeners();

    await _repository.submitReview(bookingId, draft);
    _all = await _repository.getHistory();

    _isSubmitting = false;
    notifyListeners();
    return true;
  }

  void _onSearchChanged() {
    final String next = searchController.text.trim();
    if (_query == next) return;
    _query = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.removeListener(load);
    searchController.dispose();
    super.dispose();
  }
}
