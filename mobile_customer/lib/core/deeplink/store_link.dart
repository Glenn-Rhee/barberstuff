/// Tautan bagikan cabang: https://api.barberstuff.my.id/s/<id-cabang>
///
/// Di WhatsApp tautan https bisa diklik. Kalau aplikasi terpasang dan
/// domainnya sudah terverifikasi, Android langsung membuka aplikasi ke
/// detail cabang. Kalau tidak terpasang, tautan terbuka di browser dan
/// memang tidak ada halaman untuknya.
///
/// Host dan awalan path di sini WAJIB sama persis dengan intent-filter
/// di android/app/src/main/AndroidManifest.xml.
class StoreLink {
  const StoreLink._();

  static const String host = 'api.barberstuff.my.id';
  static const String segment = 's';

  /// Id cabang dari server berbentuk UUID. Pola ini menolak isi aneh
  /// dari tautan yang diketik tangan sebelum sempat dikirim ke API.
  static final RegExp _idPattern = RegExp(r'^[0-9a-fA-F-]{8,64}$');

  static String? _pending;

  static Uri forStore(String storeId) => Uri.https(host, '/$segment/$storeId');

  /// Ambil id cabang dari nama rute seperti "/s/abc-123".
  /// null kalau rutenya bukan tautan cabang.
  static String? storeIdFrom(String? routeName) {
    if (routeName == null || routeName.isEmpty) return null;

    final Uri? uri = Uri.tryParse(routeName);
    if (uri == null) return null;

    final List<String> parts = uri.pathSegments
        .where((String p) => p.isNotEmpty)
        .toList(growable: false);
    if (parts.length != 2 || parts.first != segment) return null;

    final String id = parts[1];
    return _idPattern.hasMatch(id) ? id : null;
  }

  /// Simpan tautan yang datang sebelum user sampai di beranda,
  /// misalnya waktu aplikasi baru dibuka atau user belum login.
  static void hold(String storeId) => _pending = storeId;

  /// Ambil tautan yang tertunda sekali saja, lalu dikosongkan.
  static String? take() {
    final String? id = _pending;
    _pending = null;
    return id;
  }
}
