import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_catalog.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_content.dart';

enum BookingStep { terms, branch, barber }

class BookingFlowProvider extends ChangeNotifier {
  BookingFlowProvider(this._catalog) {
    _catalog.addListener(_onCatalogChanged);
    searchController.addListener(_onSearchChanged);
  }

  final BookingCatalog _catalog;

  final TextEditingController searchController = TextEditingController();

  BookingStep _step = BookingStep.terms;
  bool _agreed = false;
  String? _storeId;
  String? _capsterId;
  String _query = '';

  BookingStep get step => _step;
  bool get agreed => _agreed;
  String? get storeId => _storeId;
  String? get capsterId => _capsterId;

  List<BookingStore> get stores {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return _catalog.stores;

    return _catalog.stores
        .where(
          (BookingStore s) =>
              s.name.toLowerCase().contains(q) ||
              s.address.toLowerCase().contains(q),
        )
        .toList();
  }

  List<BookingCapster> get capsters => _catalog.capsters;

  bool get canContinue {
    switch (_step) {
      case BookingStep.terms:
        return _agreed;
      case BookingStep.branch:
        return _storeId != null;
      case BookingStep.barber:
        return _capsterId != null;
    }
  }

  bool get isLastStep => _step == BookingStep.barber;

  void setAgreed(bool value) {
    _agreed = value;
    notifyListeners();
  }

  void selectStore(String id) {
    _storeId = id;
    notifyListeners();
  }

  void selectCapster(String id) {
    _capsterId = id;
    notifyListeners();
  }

  void next() {
    if (!canContinue || isLastStep) return;
    _step = BookingStep.values[_step.index + 1];
    notifyListeners();
  }

  bool back() {
    if (_step == BookingStep.terms) return false;
    _step = BookingStep.values[_step.index - 1];
    notifyListeners();
    return true;
  }

  void _onSearchChanged() {
    final String next = searchController.text;
    if (_query == next) return;
    _query = next;
    notifyListeners();
  }

  void _onCatalogChanged() {
    if (_storeId != null &&
        !_catalog.stores.any((BookingStore s) => s.id == _storeId)) {
      _storeId = null;
    }
    if (_capsterId != null &&
        !_catalog.capsters.any((BookingCapster c) => c.id == _capsterId)) {
      _capsterId = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _catalog.removeListener(_onCatalogChanged);
    searchController.dispose();
    super.dispose();
  }
}
