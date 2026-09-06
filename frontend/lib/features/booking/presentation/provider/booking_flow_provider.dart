import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_catalog.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_content.dart';

enum BookingStep { terms, branch, barber, schedule, service }

class BookingFlowProvider extends ChangeNotifier {
  BookingFlowProvider(this._catalog) {
    _catalog.addListener(_onCatalogChanged);
    searchController.addListener(_onSearchChanged);
  }

  static const int dayCount = 14;
  static const int _openHour = 9;
  static const int _closeHour = 21;

  final BookingCatalog _catalog;

  final TextEditingController searchController = TextEditingController();

  BookingStep _step = BookingStep.terms;
  bool _agreed = false;
  String? _storeId;
  String? _capsterId;
  DateTime? _date;
  TimeOfDay? _time;
  final Set<String> _serviceIds = <String>{};
  String _query = '';
  bool _packageExpanded = true;
  bool _submitting = false;
  String? _orderId;

  BookingStep get step => _step;
  bool get agreed => _agreed;
  String? get storeId => _storeId;
  String? get capsterId => _capsterId;
  DateTime? get date => _date;
  TimeOfDay? get time => _time;
  Set<String> get serviceIds => Set<String>.unmodifiable(_serviceIds);
  bool get packageExpanded => _packageExpanded;
  bool get submitting => _submitting;
  String? get orderId => _orderId;

  List<DateTime> get days {
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    return List<DateTime>.generate(
      dayCount,
      (int i) => today.add(Duration(days: i)),
    );
  }

  List<TimeOfDay> get slots {
    return List<TimeOfDay>.generate(
      (_closeHour - _openHour) * 2,
      (int i) => TimeOfDay(hour: _openHour + i ~/ 2, minute: i.isEven ? 0 : 30),
    );
  }

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

  BookingStore? get selectedStore {
    for (final BookingStore s in _catalog.stores) {
      if (s.id == _storeId) return s;
    }
    return null;
  }

  BookingCapster? get selectedCapster {
    for (final BookingCapster c in _catalog.capsters) {
      if (c.id == _capsterId) return c;
    }
    return null;
  }

  List<BookingService> get selectedServices => _catalog.services
      .where((BookingService s) => _serviceIds.contains(s.id))
      .toList();

  int get totalPrice =>
      selectedServices.fold(0, (int sum, BookingService s) => sum + s.price);

  bool get canContinue {
    switch (_step) {
      case BookingStep.terms:
        return _agreed;
      case BookingStep.branch:
        return _storeId != null;
      case BookingStep.barber:
        return _capsterId != null;
      case BookingStep.schedule:
        return _date != null && _time != null;
      case BookingStep.service:
        return _serviceIds.isNotEmpty;
    }
  }

  bool get isLastStep => _step == BookingStep.service;

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

  void selectDate(DateTime value) {
    _date = value;
    notifyListeners();
  }

  void selectTime(TimeOfDay value) {
    _time = value;
    notifyListeners();
  }

  void toggleService(String id) {
    if (!_serviceIds.add(id)) _serviceIds.remove(id);
    notifyListeners();
  }

  void togglePackageSection() {
    _packageExpanded = !_packageExpanded;
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

  Future<void> submit() async {
    if (!canContinue || _submitting) return;

    _submitting = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 1400));

    _orderId = DateTime.now().millisecondsSinceEpoch
        .toRadixString(36)
        .toUpperCase();
    _submitting = false;
    notifyListeners();
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
    _serviceIds.removeWhere(
      (String id) => !_catalog.services.any((BookingService s) => s.id == id),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _catalog.removeListener(_onCatalogChanged);
    searchController.dispose();
    super.dispose();
  }
}
