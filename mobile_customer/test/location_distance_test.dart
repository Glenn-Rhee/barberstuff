import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/core/storage/app_cache.dart';
import 'package:mobile_barberstuff/features/store/data/models/store_summary_model.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StoreCoordinateModel.fromJson', () {
    test('membaca format lat,long', () {
      final StoreCoordinate? c = StoreCoordinateModel.fromJson(
        '-6.260278,106.813889',
      );
      expect(c, isNotNull);
      expect(c!.latitude, closeTo(-6.260278, 0.000001));
      expect(c.longitude, closeTo(106.813889, 0.000001));
    });

    test('membaca format long,lat seperti di seed backend', () {
      final StoreCoordinate? c = StoreCoordinateModel.fromJson(
        '106.821810,-6.193125',
      );
      expect(c, isNotNull);
      expect(c!.latitude, closeTo(-6.193125, 0.000001));
      expect(c.longitude, closeTo(106.821810, 0.000001));
    });

    test('menolak nilai yang tidak valid', () {
      expect(StoreCoordinateModel.fromJson(null), isNull);
      expect(StoreCoordinateModel.fromJson('bukan koordinat'), isNull);
      expect(StoreCoordinateModel.fromJson('1,2,3'), isNull);
      expect(StoreCoordinateModel.fromJson('abc,def'), isNull);
    });
  });

  group('jarak', () {
    test('menghitung jarak dalam kilometer', () {
      const UserPosition from = UserPosition(
        latitude: -6.260278,
        longitude: 106.813889,
      );

      final double same = LocationService.distanceKm(
        from: from,
        latitude: from.latitude,
        longitude: from.longitude,
      );
      expect(same, closeTo(0, 0.001));

      final double away = LocationService.distanceKm(
        from: from,
        latitude: -6.193125,
        longitude: 106.821810,
      );
      expect(away, greaterThan(6));
      expect(away, lessThan(9));
    });
  });

  group('posisi tersimpan', () {
    test('lastKnown kosong kalau belum pernah disimpan', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final AppCache cache = await AppCache.load();
      expect(LocationService(cache).lastKnown, isNull);
    });

    test('posisi tersimpan terbaca kembali untuk dipakai offline', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final AppCache cache = await AppCache.load();
      await cache.writeJson(
        LocationService.cacheKey,
        const UserPosition(latitude: -6.2, longitude: 106.8).toJson(),
      );

      final UserPosition? saved = LocationService(cache).lastKnown;
      expect(saved, isNotNull);
      expect(saved!.latitude, closeTo(-6.2, 0.000001));
      expect(saved.longitude, closeTo(106.8, 0.000001));
    });
  });
}
