import 'package:geolocator/geolocator.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_detail.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';

/// Tautan peta yang cocok dengan keadaan HP pengguna. Rute butuh lokasi
/// pengguna; kalau izinnya belum diberi atau GPS mati, aplikasi peta cuma
/// bisa bingung mencari titik awal. Jadi tampilkan saja titik tokonya.
Future<Uri> mapUriFor(StoreDetail detail) async {
  return await _userLocationReady() ? directionsUri(detail) : placeUri(detail);
}

Future<bool> _userLocationReady() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    final LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  } on Object catch (_) {
    return false;
  }
}

/// Titik toko di peta, tanpa rute. Tidak butuh lokasi pengguna sama sekali.
Uri placeUri(StoreDetail detail) {
  final StoreCoordinate? at = detail.coordinate;
  final String query = at == null
      ? Uri.encodeComponent('${detail.name}, ${detail.address}')
      : '${at.latitude},${at.longitude}';

  return Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
}

/// Rute belok-per-belok diserahkan ke aplikasi peta, bukan digambar sendiri.
Uri directionsUri(StoreDetail detail) {
  final StoreCoordinate? at = detail.coordinate;
  final String destination = at == null
      ? Uri.encodeComponent(detail.address)
      : '${at.latitude},${at.longitude}';

  return Uri.parse(
    'https://www.google.com/maps/dir/?api=1'
    '&destination=$destination&travelmode=driving',
  );
}
