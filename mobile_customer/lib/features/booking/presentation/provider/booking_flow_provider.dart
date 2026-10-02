import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/core/storage/app_cache.dart';
import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_draft.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_slot.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/booking_slot_params.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/create_booking.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/get_booking_draft.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/get_store_slots.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/lock_booking_slot.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/release_booking_slot.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/save_booking_lock.dart';
import 'package:mobile_barberstuff/features/booking/domain/usecases/save_booking_terms.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/service_item.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';
import 'package:mobile_barberstuff/features/store/domain/usecases/get_store_services.dart';
import 'package:mobile_barberstuff/features/store/domain/usecases/get_stores.dart';

/// Urutan langkah booking. Urutan ini juga dipakai IndexedStack di halaman.
enum BookingStep { terms, branch, schedule, capster, service, confirm }

/// State seluruh alur booking, dari setuju syarat sampai booking dibuat.
///
/// Isi file ini dikelompokkan per langkah, dari atas ke bawah:
/// navigasi → syarat → cabang → jadwal → barber → kunci slot → layanan →
/// konfirmasi.
class BookingFlowProvider extends ChangeNotifier {
  BookingFlowProvider({
    required GetStores getStores,
    required GetStoreServices getServices,
    required GetStoreSlots getSlots,
    required LockBookingSlot lockSlot,
    required ReleaseBookingSlot releaseSlot,
    required CreateBooking createBooking,
    required GetBookingDraft getDraft,
    required SaveBookingTerms saveTerms,
    required SaveBookingLock saveLock,
    LocationService? location,
    Duration? lockDuration,
    StoreSummary? store,
  }) : _getStores = getStores,
       _getServices = getServices,
       _getSlots = getSlots,
       _lockSlot = lockSlot,
       _releaseSlot = releaseSlot,
       _createBooking = createBooking,
       _saveTerms = saveTerms,
       _saveLock = saveLock,
       _location = location,
       _lockDuration = lockDuration ?? defaultLockDuration {
    searchController.addListener(_onSearchChanged);
    _selectedDay = DateUtils.dateOnly(DateTime.now());

    final BookingDraft draft = getDraft(const NoParams());
    _agreed = draft.termsAgreed;
    final BookingLock? lock = draft.lock;
    if (lock != null) _restoreLock(lock);

    // Masuk dari detail cabang: cabangnya sudah pasti, jadi langkah pilih
    // cabang dilewati. Slot yang masih terkunci tetap didahulukan.
    if (store != null && !hasLock) {
      _store = store;
      _storeFixed = true;
    }
  }

  static const Duration defaultLockDuration = Duration(minutes: 5);
  static const int dayCount = 14;
  static const int minimumLeadMinutes = 30;

  final GetStores _getStores;
  final GetStoreServices _getServices;
  final GetStoreSlots _getSlots;
  final LockBookingSlot _lockSlot;
  final ReleaseBookingSlot _releaseSlot;
  final CreateBooking _createBooking;
  final SaveBookingTerms _saveTerms;
  final SaveBookingLock _saveLock;
  final LocationService? _location;
  final Duration _lockDuration;

  // ===========================================================================
  // Navigasi antar langkah
  // ===========================================================================

  BookingStep _step = BookingStep.terms;

  /// true kalau cabang sudah dipilih dari detail cabang.
  bool _storeFixed = false;

  BookingStep get step => _step;
  bool get isLastStep => _step == BookingStep.confirm;

  /// Label "Langkah x dari y". Pilih cabang tidak ikut dihitung kalau
  /// cabangnya sudah dipilih dari detail cabang.
  int get stepCount => _storeFixed ? 4 : 5;
  int get stepNumber => _storeFixed && _step.index > BookingStep.branch.index
      ? _step.index - 1
      : _step.index;

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

  Future<void> next() async {
    if (!canContinue || isLastStep) return;

    switch (_step) {
      case BookingStep.terms when _storeFixed:
        _step = BookingStep.schedule;
        notifyListeners();
        await loadSlots();
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

  /// Mundur satu langkah. false kalau sudah di langkah pertama, artinya
  /// halaman booking boleh ditutup.
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

      case BookingStep.schedule when _storeFixed:
        _step = BookingStep.terms;

      case BookingStep.branch:
      case BookingStep.schedule:
      case BookingStep.capster:
        _step = BookingStep.values[_step.index - 1];
    }

    notifyListeners();
    return true;
  }

  // ===========================================================================
  // Langkah 1 — Syarat & ketentuan
  // ===========================================================================

  bool _agreed = false;

  bool get agreed => _agreed;

  void setAgreed(bool value) {
    if (_agreed == value) return;
    _agreed = value;
    notifyListeners();
    _saveTerms(value);
  }

  // ===========================================================================
  // Langkah 2 — Pilih cabang
  // ===========================================================================

  final TextEditingController searchController = TextEditingController();
  String _query = '';

  List<StoreSummary> _stores = const <StoreSummary>[];
  UserPosition? _position;
  bool _loadingStores = false;
  bool _storesFromCache = false;
  ApiException? _storesError;
  StoreSummary? _store;

  List<StoreSummary> get stores => _stores;
  bool get loadingStores => _loadingStores;
  bool get storesFromCache => _storesFromCache;
  ApiException? get storesError => _storesError;
  StoreSummary? get store => _store;

  double? distanceOf(StoreSummary store) => storeDistanceKm(store, _position);

  Future<void> loadStores() async {
    _loadingStores = true;
    _storesError = null;
    notifyListeners();

    try {
      final CachedResult<List<StoreSummary>> result = await _getStores(
        GetStoresParams(name: _query.isEmpty ? null : _query),
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

  void _onSearchChanged() {
    final String next = searchController.text.trim();
    if (_query == next) return;
    _query = next;
    notifyListeners();
  }

  // ===========================================================================
  // Langkah 3 — Pilih jadwal (hari + jam)
  // ===========================================================================

  late DateTime _selectedDay;
  StoreSlots? _storeSlots;
  bool _loadingSlots = false;
  ApiException? _slotsError;
  BookingSlot? _slot;

  DateTime get selectedDay => _selectedDay;
  List<BookingSlot> get slots => _storeSlots?.slots ?? const <BookingSlot>[];
  bool get loadingSlots => _loadingSlots;
  ApiException? get slotsError => _slotsError;
  BookingSlot? get slot => _slot;

  /// Hari yang bisa dipilih: hari ini sampai [dayCount] hari ke depan.
  List<DateTime> get days {
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    return List<DateTime>.generate(
      dayCount,
      (int i) => today.add(Duration(days: i)),
    );
  }

  /// Hari terpilih + jam slot ("HH:mm"). null kalau slot belum dipilih.
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

  /// Slot kurang dari [minimumLeadMinutes] menit lagi tidak boleh dipesan.
  bool get isSlotTooSoon {
    final DateTime? at = bookingDateTime;
    if (at == null) return false;
    return at.isBefore(
      DateTime.now().add(const Duration(minutes: minimumLeadMinutes)),
    );
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
      _storeSlots = await _getSlots(
        GetStoreSlotsParams(storeId: picked.id, date: _selectedDay),
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

  // ===========================================================================
  // Langkah 4 — Pilih barber
  // ===========================================================================

  SlotCapster? _capster;

  List<SlotCapster> get capsters => _slot?.capsters ?? const <SlotCapster>[];
  SlotCapster? get capster => _capster;

  void selectCapster(SlotCapster value) {
    if (!value.available) return;
    _capster = value;
    notifyListeners();
  }

  // ===========================================================================
  // Kunci slot — dipegang sejak barber dipilih sampai booking dibuat
  // ===========================================================================

  bool _locking = false;
  ApiException? _lockError;
  DateTime? _lockExpiresAt;
  Timer? _ticker;

  bool get locking => _locking;
  ApiException? get lockError => _lockError;
  bool get hasLock => _lockExpiresAt != null;

  Duration get lockRemaining {
    final DateTime? until = _lockExpiresAt;
    if (until == null) return Duration.zero;
    final Duration left = until.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  /// Kunci slot di server lalu lanjut ke pilih layanan.
  Future<bool> lockAndContinue() async {
    final BookingSlotParams? params = _currentSlotParams();
    if (params == null) return false;

    _locking = true;
    _lockError = null;
    notifyListeners();

    try {
      await _lockSlot(params);

      _startCountdown(DateTime.now().add(_lockDuration));
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

  /// Melepas kunci slot di server. Mengembalikan false kalau server
  /// menolak; kunci server tetap habis sendiri setelah masa kuncinya lewat.
  Future<bool> releaseLock() async {
    final BookingSlotParams? params = _currentSlotParams();

    _stopCountdown();
    notifyListeners();

    if (params == null) return true;

    try {
      await _releaseSlot(params);
      return true;
    } on ApiException catch (_) {
      return false;
    }
  }

  /// Cabang + barber + jam yang sedang dipilih, dalam bentuk yang dikirim
  /// ke server. null kalau salah satunya belum dipilih.
  BookingSlotParams? _currentSlotParams() {
    final StoreSummary? pickedStore = _store;
    final SlotCapster? pickedCapster = _capster;
    final DateTime? at = bookingDateTime;

    if (pickedStore == null || pickedCapster == null || at == null) {
      return null;
    }

    return BookingSlotParams(
      storeId: pickedStore.id,
      capsterId: pickedCapster.id,
      bookingDate: at,
    );
  }

  /// Hitung mundur sampai [until]; setiap detik layar diperbarui.
  void _startCountdown(DateTime until) {
    _ticker?.cancel();
    _lockExpiresAt = until;
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
    _saveLock(null);
  }

  /// Simpan kunci di perangkat supaya bisa dilanjutkan kalau aplikasi
  /// ditutup di tengah jalan.
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

    _saveLock(
      BookingLock(
        store: pickedStore,
        capster: pickedCapster,
        slotTime: pickedSlot.time,
        day: _selectedDay,
        expiresAt: until,
      ),
    );
  }

  /// Slot yang masih terkunci dari sesi sebelumnya: lanjut di pilih layanan.
  void _restoreLock(BookingLock lock) {
    _store = lock.store;
    _capster = lock.capster;
    _selectedDay = DateUtils.dateOnly(lock.day);
    _slot = BookingSlot(
      time: lock.slotTime,
      available: true,
      capsters: <SlotCapster>[lock.capster],
    );

    _startCountdown(lock.expiresAt);

    _agreed = true;
    _step = BookingStep.service;
    loadServices();
  }

  /// Waktu kunci habis: pilihan barber dan layanan dibuang, kembali ke
  /// pilih jadwal dengan daftar slot terbaru.
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

  // ===========================================================================
  // Langkah 5 — Pilih layanan / paket
  // ===========================================================================

  ProductType _serviceTab = ProductType.service;
  final Map<ProductType, List<ServiceItem>> _services =
      <ProductType, List<ServiceItem>>{};
  bool _loadingServices = false;
  ApiException? _servicesError;
  final Map<ProductType, List<ServiceItem>> _picked =
      <ProductType, List<ServiceItem>>{};

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

  double get subTotal => selectedServices.fold<double>(
    0,
    (double sum, ServiceItem s) => sum + s.price,
  );

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
      _services[_serviceTab] = await _getServices(
        GetStoreServicesParams(storeId: picked.id, type: _serviceTab),
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

  // ===========================================================================
  // Langkah 6 — Konfirmasi & buat booking
  // ===========================================================================

  bool _submitting = false;
  ApiException? _submitError;
  BookingRecord? _record;

  bool get submitting => _submitting;
  ApiException? get submitError => _submitError;
  BookingRecord? get record => _record;

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
      _record = await _createBooking(
        CreateBookingParams(
          storeId: pickedStore.id,
          capster: pickedCapster,
          serviceId: pickedServices.first.id,
          bookingDate: at,
        ),
      );
      _stopCountdown();
      return true;
    } on ApiException catch (e) {
      _submitError = e;
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
