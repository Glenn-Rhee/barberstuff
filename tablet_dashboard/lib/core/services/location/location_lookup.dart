import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

// Titik GPS untuk peta cabang: posisi tablet sekarang, atau cari dari
// alamat lewat OpenStreetMap Nominatim (gratis, tanpa API key)
class LocationLookup {
  LocationLookup({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              // Wajib oleh kebijakan Nominatim
              headers: {'User-Agent': 'BarberstuffDashboard/1.0'},
            ),
          );

  final Dio _dio;

  Future<(double, double)> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException('GPS tablet belum dinyalakan');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationException('Izin lokasi ditolak');
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return (position.latitude, position.longitude);
    } on Exception {
      throw const LocationException('Lokasi tablet tidak ditemukan');
    }
  }

  // null kalau alamat tidak ketemu
  Future<(double, double)?> search(String address) async {
    try {
      final res = await _dio.get<List<dynamic>>(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': address,
          'format': 'json',
          'limit': 1,
          'countrycodes': 'id',
        },
      );
      final first = res.data?.firstOrNull;
      if (first is! Map) return null;
      final lat = double.tryParse('${first['lat']}');
      final long = double.tryParse('${first['lon']}');
      return lat == null || long == null ? null : (lat, long);
    } on DioException {
      throw const LocationException('Pencarian alamat gagal, cek koneksi');
    }
  }
}
