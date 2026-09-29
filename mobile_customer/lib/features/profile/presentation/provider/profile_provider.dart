import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/app_cache.dart';
import 'package:mobile_barberstuff/core/usecase/usecase.dart';
import 'package:mobile_barberstuff/features/debug/presentation/provider/debug_overrides.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/domain/usecases/get_customer_profile.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._getProfile, this._overrides) {
    _overrides.addListener(notifyListeners);
    load();
  }

  final GetCustomerProfile _getProfile;
  final DebugOverrides _overrides;

  CustomerProfile? _fetched;
  bool _isLoading = false;
  ApiException? _error;
  bool _fromCache = false;
  DateTime? _cachedAt;

  CustomerProfile? get fetched => _fetched;
  CustomerProfile? get profile => _overrides.apply(_fetched);

  bool get isLoading => _isLoading;
  ApiException? get error => _error;

  /// Belum ada data dan belum pernah gagal = masih menunggu, tampilkan
  /// kerangka. Dulu cuma `_isLoading`, jadi sesudah logout lalu login lagi
  /// (data sudah di-reset tapi belum dimuat ulang) yang muncul malah pesan
  /// "Terjadi kesalahan" padahal tidak ada kesalahan apa pun.
  bool get isFirstLoad => _fetched == null && (_isLoading || _error == null);
  bool get isFromCache => _fromCache;
  DateTime? get cachedAt => _cachedAt;

  /// Dipanggil saat logout supaya sesi berikutnya tidak melihat data lama.
  void reset() {
    _fetched = null;
    _error = null;
    _fromCache = false;
    _cachedAt = null;
    notifyListeners();
  }

  Future<void>? _inFlight;

  /// Pemanggil yang datang saat masih memuat ikut menunggu muatan yang sama,
  /// bukan langsung pulang. Penting untuk tarik-ulang dan [ensureLoaded].
  Future<void> load() => _inFlight ??= _load().whenComplete(() {
    _inFlight = null;
  });

  /// Dipanggil saat masuk beranda. Provider ini hidup sepanjang aplikasi,
  /// jadi sesudah logout (reset) lalu login lagi tidak ada yang memuat ulang
  /// profil. Muat kalau belum punya data atau percobaan terakhir gagal.
  Future<void> ensureLoaded() async {
    final Future<void>? running = _inFlight;
    if (running != null) await running;
    if (_fetched != null && _error == null) return;
    await load();
  }

  Future<void> _load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final CachedResult<CustomerProfile> result = await _getProfile(
        const NoParams(),
      );
      _fetched = result.data;
      _fromCache = result.fromCache;
      _cachedAt = result.savedAt;
      _error = null;
    } on ApiException catch (e) {
      _error = e;
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _overrides.removeListener(notifyListeners);
    super.dispose();
  }
}
