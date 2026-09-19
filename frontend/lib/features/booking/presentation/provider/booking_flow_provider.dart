import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/app_cache.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/features/booking/data/booking_journal.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_api_model.dart';
import 'package:mobile_barberstuff/features/booking/data/repositories/booking_repository.dart';
import 'package:mobile_barberstuff/features/booking/domain/booking_record.dart';
import 'package:mobile_barberstuff/features/booking/domain/store_distance.dart';

enum BookingStep { terms, branch, schedule, capster, service, confirm }

class BookingFlowProvider extends ChangeNotifier {
  BookingFlowProvider(
    this._repo,
    this._cache, {
    LocationService? location,
    BookingJournal? journal,
    Duration? lockDuration,
  }) : _location = location,
       _journal = journal,
       _lockDuration = lockDuration ?? defaultLockDuration {
    searchController.addListener(_onSearchChanged);
    _selectedDay = DateUtils.dateOnly(DateTime.now());
    _agreed = _cache.readBool(AppCache.keyBookingTermsAgreed);
    _restoreLock();
  }

  static const Duration defaultLockDuration = Duration(minutes: 5);
  static const int dayCount = 14;
  static const int minimumLeadMinutes = 30;

  final BookingRepository _repo;
  final AppCache _cache;
  final LocationService? _location;
  final BookingJournal? _journal;
  final Duration _lockDuration;

  final TextEditingController searchController = TextEditingController();

  BookingStep _step = BookingStep.terms;
  bool _agreed = false;
  String _query = '';

  List<StoreSummary> _stores = const <StoreSummary>[];
  UserPosition? _position;
  bool _loadingStores = false;
  bool _storesFromCache = false;
  ApiException? _storesError;
  StoreSummary? _store;

  late DateTime _selectedDay;
  StoreSlots? _storeSlots;
  bool _loadingSlots = false;
  ApiException? _slotsError;
  BookingSlot? _slot;

  SlotCapster? _capster;

  bool _locking = false;
  ApiException? _lockError;
  DateTime? _lockExpiresAt;
  Timer? _ticker;

  ProductType _serviceTab = ProductType.service;
  final Map<ProductType, List<ServiceItem>> _services =
      <ProductType, List<ServiceItem>>{};
  bool _loadingServices = false;
  ApiException? _servicesError;
  final Map<ProductType, List<ServiceItem>> _picked =
      <ProductType, List<ServiceItem>>{};

  bool _submitting = false;
  ApiException? _submitError;
  BookingResult? _result;
  BookingRecord? _record;

  BookingStep get step => _step;
  bool get agreed => _agreed;

  List<StoreSummary> get stores => _stores;

  double? distanceOf(StoreSummary store) => storeDistanceKm(store, _position);

  void _sortByDistance() {
    _stores = sortStoresByDistance(_stores, _position);
  }

  Future<void> _refreshPosition() async {
    final LocationService? service = _location;
    if (service == null) return;

    _position ??= service.lastKnown;
    final UserPosition? fresh = await service.current();
    if (fresh == null) return;

    _position = fresh;
    _sortByDistance();
    notifyListeners();
  }

  bool get loadingStores => _loadingStores;
  bool get storesFromCache => _storesFromCache;
  ApiException? get storesError => _storesError;
  StoreSummary? get store => _store;

  DateTime get selectedDay => _selectedDay;
  List<BookingSlot> get slots => _storeSlots?.slots ?? const <BookingSlot>[];
  bool get loadingSlots => _loadingSlots;
  ApiException? get slotsError => _slotsError;
  BookingSlot? get slot => _slot;

  List<SlotCapster> get capsters => _slot?.capsters ?? const <SlotCapster>[];
  SlotCapster? get capster => _capster;

  bool get locking => _locking;
  ApiException? get lockError => _lockError;
  bool get hasLock => _lockExpiresAt != null;
  Duration get lockRemaining {
    final DateTime? until = _lockExpiresAt;
    if (until == null) return Duration.zero;
    final Duration left = until.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  ProductType get serviceTab => _serviceTab;
  List<ServiceItem> get visibleServices =>
      _services[_serviceTab] ?? const <ServiceItem>[];
  bool get loadingServices => _loadingServices;
  ApiException? get servicesError => _servicesError;

  /// Semua pilihan dari tab Layanan dan tab Paket digabung. Dulu cuma tab
  /// yang sedang aktif, jadi paket hilang dari konfirmasi kalau user
  /// terakhir membuka tab Layanan, begitu juga sebaliknya.
  List<ServiceItem> get selectedServices => <ServiceItem>[
    ..._picked[ProductType.service] ?? const <ServiceItem>[],
    ..._picked[ProductType.package] ?? const <ServiceItem>[],
  ];

  /// Pilihan di tab yang sedang dibuka saja, dipakai saat menambah/menghapus.
  List<ServiceItem> get _pickedInTab =>
      _picked[_serviceTab] ?? const <ServiceItem>[];

  bool isServiceSelected(ServiceItem item) =>
      selectedServices.any((ServiceItem s) => s.id == item.id);

  /// Server (POST /booking) cuma menerima satu `id_service` per booking.
  /// Pilihan dari kedua tab tetap ditampilkan supaya user sadar apa saja
  /// yang dia pilih, tapi Lanjut ditahan kalau lebih dari satu, karena
  /// kalau diteruskan server hanya mencatat yang pertama dan harganya
  /// jadi tidak cocok dengan yang tampil di layar.
  bool get exceedsServerLimit => selectedServices.length > 1;

  bool get submitting => _submitting;
  ApiException? get submitError => _submitError;
  BookingResult? get result => _result;
  BookingRecord? get record => _record;

  List<DateTime> get days {
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    return List<DateTime>.generate(
      dayCount,
      (int i) => today.add(Duration(days: i)),
    );
  }

  DateTime? get bookingDateTime {
    final BookingSlot? picked = _slot;
    if (picked == null) return null;

    final List<String> parts = picked.time.split(':');
    if (parts.length < 2) return null;

    final int? hour = int.tryParse(parts[0]);
    final int? minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    return DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      hour,
      minute,
    );
  }

  bool get isSlotTooSoon {
    final DateTime? at = bookingDateTime;
    if (at == null) return false;
    return at.isBefore(
      DateTime.now().add(const Duration(minutes: minimumLeadMinutes)),
    );
  }

  double get subTotal => selectedServices.fold<double>(
    0,
    (double sum, ServiceItem s) => sum + s.price,
  );

  bool get canContinue {
    switch (_step) {
      case BookingStep.terms:
        return _agreed;
      case BookingStep.branch:
        return _store != null;
      case BookingStep.schedule:
        return _slot != null && !isSlotTooSoon;
      case BookingStep.capster:
        return _capster != null && !_locking;
      case BookingStep.service:
        return selectedServices.isNotEmpty;
      case BookingStep.confirm:
        return !_submitting;
    }
  }

  bool get isLastStep => _step == BookingStep.confirm;

  void setAgreed(bool value) {
    if (_agreed == value) return;
    _agreed = value;
    notifyListeners();
    _cache.writeJson(AppCache.keyBookingTermsAgreed, value);
  }

  Future<void> loadStores() async {
    _loadingStores = true;
    _storesError = null;
    notifyListeners();

    try {
      final CachedResult<List<StoreSummary>> result = await _repo.getStores(
        name: _query.isEmpty ? null : _query,
      );
      _stores = result.data;
      _storesFromCache = result.fromCache;
      _position ??= _location?.lastKnown;
      _sortByDistance();
    } on ApiException catch (e) {
      _storesError = e;
    } finally {
      _loadingStores = false;
      notifyListeners();
    }

    await _refreshPosition();
  }

  void selectStore(StoreSummary value) {
    if (_store?.id == value.id) return;
    _store = value;
    _storeSlots = null;
    _slot = null;
    _capster = null;
    _picked.clear();
    _services.clear();
    notifyListeners();
  }

  Future<void> selectDay(DateTime day) async {
    _selectedDay = DateUtils.dateOnly(day);
    _slot = null;
    _capster = null;
    notifyListeners();
    await loadSlots();
  }

  Future<void> loadSlots() async {
    final StoreSummary? picked = _store;
    if (picked == null) return;

    _loadingSlots = true;
    _slotsError = null;
    notifyListeners();

    try {
      _storeSlots = await _repo.getStoreSlots(
        idStore: picked.id,
        date: _selectedDay,
      );
    } on ApiException catch (e) {
      _slotsError = e;
      _storeSlots = null;
    } finally {
      _loadingSlots = false;
      notifyListeners();
    }
  }

  void selectSlot(BookingSlot value) {
    if (!value.available) return;
    _slot = value;
    _capster = null;
    notifyListeners();
  }

  void selectCapster(SlotCapster value) {
    if (!value.available) return;
    _capster = value;
    notifyListeners();
  }

  Future<bool> lockAndContinue() async {
    final StoreSummary? pickedStore = _store;
    final SlotCapster? pickedCapster = _capster;
    final DateTime? at = bookingDateTime;

    if (pickedStore == null || pickedCapster == null || at == null) {
      return false;
    }

    _locking = true;
    _lockError = null;
    notifyListeners();

    try {
      await _repo.lockBooking(
        idStore: pickedStore.id,
        idCapster: pickedCapster.id,
        bookingDate: at,
      );

      _startCountdown();
      _persistLock();
      _step = BookingStep.service;
      notifyListeners();
      await loadServices();
      return true;
    } on ApiException catch (e) {
      _lockError = e;
      return false;
    } finally {
      _locking = false;
      notifyListeners();
    }
  }

  void _startCountdown() {
    _ticker?.cancel();
    _lockExpiresAt = DateTime.now().add(_lockDuration);
    _ticker = Timer.periodic(const Duration(seconds: 1), (Timer _) {
      if (lockRemaining == Duration.zero) {
        _onLockExpired();
        return;
      }
      notifyListeners();
    });
  }

  void _stopCountdown() {
    _ticker?.cancel();
    _ticker = null;
    _lockExpiresAt = null;
    _cache.remove(AppCache.keyBookingLock);
  }

  void _persistLock() {
    final StoreSummary? pickedStore = _store;
    final SlotCapster? pickedCapster = _capster;
    final BookingSlot? pickedSlot = _slot;
    final DateTime? until = _lockExpiresAt;

    if (pickedStore == null ||
        pickedCapster == null ||
        pickedSlot == null ||
        until == null) {
      return;
    }

    _cache.writeJson(AppCache.keyBookingLock, <String, dynamic>{
      'store': pickedStore.toJson(),
      'capster': pickedCapster.toJson(),
      'slot_time': pickedSlot.time,
      'day': _selectedDay.toIso8601String(),
      'expires_at': until.millisecondsSinceEpoch,
    });
  }

  void _restoreLock() {
    final Map<String, dynamic>? raw = _cache
        .readJson(AppCache.keyBookingLock)
        ?.asMap;
    if (raw == null) return;

    final int millis = (raw['expires_at'] as num?)?.toInt() ?? 0;
    final DateTime until = DateTime.fromMillisecondsSinceEpoch(millis);
    if (!until.isAfter(DateTime.now())) {
      _cache.remove(AppCache.keyBookingLock);
      return;
    }

    final Object? store = raw['store'];
    final Object? capster = raw['capster'];
    if (store is! Map<String, dynamic> || capster is! Map<String, dynamic>) {
      return;
    }

    _store = StoreSummary.fromJson(store);
    _capster = SlotCapster.fromJson(capster);
    _selectedDay = DateUtils.dateOnly(
      DateTime.tryParse('${raw['day']}') ?? DateTime.now(),
    );
    _slot = BookingSlot(
      time: '${raw['slot_time']}',
      available: true,
      capsters: <SlotCapster>[_capster!],
    );

    _lockExpiresAt = until;
    _ticker = Timer.periodic(const Duration(seconds: 1), (Timer _) {
      if (lockRemaining == Duration.zero) {
        _onLockExpired();
        return;
      }
      notifyListeners();
    });

    _agreed = true;
    _step = BookingStep.service;
    loadServices();
  }

  void _onLockExpired() {
    _stopCountdown();
    _picked.clear();
    _services.clear();
    _capster = null;
    _slot = null;
    _step = BookingStep.schedule;
    notifyListeners();
    loadSlots();
  }

  /// Melepas kunci slot di server. Mengembalikan false kalau server
  /// menolak; kunci server tetap habis sendiri setelah masa kuncinya lewat.
  Future<bool> releaseLock() async {
    final StoreSummary? pickedStore = _store;
    final SlotCapster? pickedCapster = _capster;
    final DateTime? at = bookingDateTime;

    _stopCountdown();
    notifyListeners();

    if (pickedStore == null || pickedCapster == null || at == null) {
      return true;
    }

    try {
      await _repo.releaseLock(
        idStore: pickedStore.id,
        idCapster: pickedCapster.id,
        bookingDate: at,
      );
      return true;
    } on ApiException catch (_) {
      return false;
    }
  }

  void setServiceTab(ProductType value) {
    if (_serviceTab == value) return;
    _serviceTab = value;
    notifyListeners();
    if (!_services.containsKey(value)) loadServices();
  }

  Future<void> loadServices() async {
    final StoreSummary? picked = _store;
    if (picked == null) return;

    _loadingServices = true;
    _servicesError = null;
    notifyListeners();

    try {
      _services[_serviceTab] = await _repo.getServices(
        idStore: picked.id,
        type: _serviceTab,
      );
    } on ApiException catch (e) {
      _servicesError = e;
    } finally {
      _loadingServices = false;
      notifyListeners();
    }
  }

  /// Tab layanan maksimal satu pilihan, tab paket boleh lebih dari satu.
  void toggleService(ServiceItem value) {
    final List<ServiceItem> current = List<ServiceItem>.of(_pickedInTab);
    final int at = current.indexWhere((ServiceItem s) => s.id == value.id);

    if (_serviceTab == ProductType.service) {
      _picked[_serviceTab] = at >= 0
          ? const <ServiceItem>[]
          : <ServiceItem>[value];
    } else {
      if (at >= 0) {
        current.removeAt(at);
      } else {
        current.add(value);
      }
      _picked[_serviceTab] = List<ServiceItem>.unmodifiable(current);
    }

    notifyListeners();
  }

  Future<bool> submit() async {
    final StoreSummary? pickedStore = _store;
    final SlotCapster? pickedCapster = _capster;
    final List<ServiceItem> pickedServices = selectedServices;
    final DateTime? at = bookingDateTime;

    if (pickedStore == null ||
        pickedCapster == null ||
        pickedServices.length != 1 ||
        at == null ||
        _submitting) {
      return false;
    }

    _submitting = true;
    _submitError = null;
    notifyListeners();

    try {
      final BookingResult created = await _repo.createBooking(
        idStore: pickedStore.id,
        idCapster: pickedCapster.id,
        idService: pickedServices.first.id,
        bookingDate: at,
      );
      _result = created;
      _stopCountdown();

      _record = BookingRecord.fromResult(
        created,
        capsterId: pickedCapster.id,
        capsterName: pickedCapster.name,
      );
      await _journal?.add(_record!);
      return true;
    } on ApiException catch (e) {
      _submitError = e;
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<void> next() async {
    if (!canContinue || isLastStep) return;

    switch (_step) {
      case BookingStep.terms:
        _step = BookingStep.branch;
        notifyListeners();
        await loadStores();
      case BookingStep.branch:
        _step = BookingStep.schedule;
        notifyListeners();
        await loadSlots();
      case BookingStep.schedule:
        _step = BookingStep.capster;
        notifyListeners();
      case BookingStep.capster:
        await lockAndContinue();
      case BookingStep.service:
        _step = BookingStep.confirm;
        notifyListeners();
      case BookingStep.confirm:
        return;
    }
  }

  /// Dialog "batalkan booking?" cuma perlu muncul saat mundur dari langkah
  /// pilih layanan, karena mundur dari situ berarti melepas slot barber.
  /// Dari langkah konfirmasi, mundur cukup kembali ke pilih layanan dan
  /// kuncinya tetap dipegang, jadi tidak perlu ditanya.
  bool get needsCancelConfirm => hasLock && _step == BookingStep.service;

  bool back() {
    switch (_step) {
      case BookingStep.terms:
        return false;

      case BookingStep.confirm:
        // Masih dalam masa kunci, pilihan layanan tetap dipertahankan.
        _step = BookingStep.service;

      case BookingStep.service:
        // Kunci di server sudah dilepas lewat releaseLock() oleh halaman.
        // Barber sengaja tetap terpilih, jadi tombol Lanjut langsung aktif
        // dan menekan Lanjut akan mengunci ulang slot yang sama.
        _stopCountdown();
        _picked.clear();
        _services.clear();
        _serviceTab = ProductType.service;
        _step = BookingStep.capster;

      case BookingStep.branch:
      case BookingStep.schedule:
      case BookingStep.capster:
        _step = BookingStep.values[_step.index - 1];
    }

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
    _ticker?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
