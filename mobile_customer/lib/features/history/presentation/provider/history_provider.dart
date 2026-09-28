import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_record.dart';
import 'package:mobile_barberstuff/features/history/data/history_repository.dart';
import 'package:mobile_barberstuff/features/history/domain/booking_history.dart';

class HistoryProvider extends ChangeNotifier {
  HistoryProvider(this._repository) {
    searchController.addListener(_onSearchChanged);
    _repository.addListener(_sync);
    _sync();
    load();
  }

  final HistoryRepository _repository;

  final TextEditingController searchController = TextEditingController();

  List<BookingHistory> _all = const <BookingHistory>[];
  HistoryTab _tab = HistoryTab.upcoming;
  String _query = '';
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _disposed = false;
  ApiException? _error;
  ApiException? _submitError;

  HistoryTab get tab => _tab;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  ApiException? get error => _error;
  ApiException? get submitError => _submitError;

  List<BookingHistory> get items {
    final String needle = _query.toLowerCase();

    return _all
        .where((BookingHistory item) {
          if (item.tab != _tab) return false;
          if (needle.isEmpty) return true;
          return item.serviceName.toLowerCase().contains(needle) ||
              item.storeName.toLowerCase().contains(needle);
        })
        .toList(growable: false);
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    _notify();

    try {
      await _repository.refresh();
    } on ApiException catch (e) {
      _error = e;
    }

    _isLoading = false;
    _notify();
  }

  void setTab(HistoryTab value) {
    if (_tab == value) return;
    _tab = value;
    notifyListeners();
  }

  Future<bool> submitReview(String bookingId, ReviewDraft draft) async {
    if (!draft.isComplete || _isSubmitting) return false;

    _isSubmitting = true;
    _submitError = null;
    _notify();

    try {
      await _repository.submitReview(bookingId, draft);
      return true;
    } on ApiException catch (e) {
      _submitError = e;
      return false;
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  void _sync() {
    final DateTime now = DateTime.now();
    _all = _repository.records
        .map((BookingRecord r) => r.toHistory(now))
        .toList(growable: false);
    _notify();
  }

  void _onSearchChanged() {
    final String next = searchController.text.trim();
    if (_query == next) return;
    _query = next;
    notifyListeners();
  }

  /// Muatan jaringan bisa selesai sesudah halaman ditutup.
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _repository.removeListener(_sync);
    searchController.dispose();
    super.dispose();
  }
}
