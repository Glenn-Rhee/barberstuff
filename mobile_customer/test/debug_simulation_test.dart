import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/core/network/dio_client.dart';
import 'package:mobile_barberstuff/core/storage/app_cache.dart';
import 'package:mobile_barberstuff/features/debug/presentation/provider/debug_overrides.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:mobile_barberstuff/features/store/data/datasources/store_remote_datasource.dart';
import 'package:mobile_barberstuff/features/store/data/models/store_summary_model.dart';
import 'package:mobile_barberstuff/features/store/data/repositories/store_repository_impl.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';
import 'package:mobile_barberstuff/features/store/domain/repositories/store_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppCache> _freshCache() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  return AppCache.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DebugOverrides', () {
    test('durasi lock dan mode offline ikut menandai override aktif', () {
      final DebugOverrides d = DebugOverrides();
      expect(d.isActive, isFalse);
      expect(d.lockDuration, isNull);
      expect(d.forceOffline, isFalse);

      d.setLockDuration(const Duration(seconds: 15));
      expect(d.isActive, isTrue);
      expect(d.lockDuration, const Duration(seconds: 15));

      d.setForceOffline(true);
      expect(d.forceOffline, isTrue);

      d.reset();
      expect(d.isActive, isFalse);
      expect(d.lockDuration, isNull);
      expect(d.forceOffline, isFalse);
    });

    test('reset tidak menghapus override tier dan poin secara terpisah', () {
      final DebugOverrides d = DebugOverrides();
      d.setTier(MemberTier.gold);
      d.setPoints(1250);
      d.setForceOffline(true);

      expect(d.isActive, isTrue);
      d.reset();

      expect(d.tier, isNull);
      expect(d.points, isNull);
      expect(d.forceOffline, isFalse);
    });
  });

  group('paksa offline', () {
    test('DioClient menolak request ketika flag offline menyala', () async {
      bool offline = true;
      final DioClient client = DioClient(isOffline: () => offline);

      Object? caught;
      try {
        await client.dio.get<dynamic>('/store/');
      } on Object catch (e) {
        caught = e;
      }

      expect(caught, isA<DioException>());
      expect(
        DioClient.mapError(caught!),
        isA<ApiException>().having(
          (ApiException e) => e.type,
          'type',
          ApiErrorType.connection,
        ),
      );

      offline = false;
    });

    test('repo cabang memakai cache saat offline dipaksa', () async {
      final AppCache cache = await _freshCache();
      await cache.writeJson(AppCache.keyStores, <Map<String, dynamic>>[
        const StoreSummaryModel(
          id: 'store-1',
          name: 'Barberstuff Kemang Raya',
          address: 'Jl. Kemang',
          phoneNumber: '',
          bannerUrl: '',
          storeType: 'lite',
          status: 'open',
          avgRating: 4.8,
          totalCapster: 1,
          totalService: 1,
          totalPackage: 0,
        ).toJson(),
      ]);

      final DioClient client = DioClient(isOffline: () => true);
      final StoreRepository repo = StoreRepositoryImpl(
        StoreRemoteDataSource(client.dio),
        cache,
      );

      final CachedResult<List<StoreSummary>> result = await repo.getStores();

      expect(result.fromCache, isTrue);
      expect(result.data.single.name, 'Barberstuff Kemang Raya');
    });
  });
}
