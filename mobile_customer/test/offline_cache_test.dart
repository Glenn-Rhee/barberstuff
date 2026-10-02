import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/core/storage/app_cache.dart';
import 'package:mobile_barberstuff/features/booking/data/datasources/booking_local_datasource.dart';
import 'package:mobile_barberstuff/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:mobile_barberstuff/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:mobile_barberstuff/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:mobile_barberstuff/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:mobile_barberstuff/features/profile/domain/entities/customer_profile.dart';
import 'package:mobile_barberstuff/features/profile/domain/repositories/profile_repository.dart';
import 'package:mobile_barberstuff/features/store/data/datasources/store_remote_datasource.dart';
import 'package:mobile_barberstuff/features/store/data/models/store_summary_model.dart';
import 'package:mobile_barberstuff/features/store/data/repositories/store_repository_impl.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_summary.dart';
import 'package:mobile_barberstuff/features/store/domain/repositories/store_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _OfflineProfileSource extends ProfileRemoteDataSource {
  _OfflineProfileSource() : super(Dio());

  @override
  Future<Map<String, dynamic>> getCustomerProfile() async {
    throw const ApiException(ApiErrorType.connection);
  }
}

class _OfflineStoreSource extends StoreRemoteDataSource {
  _OfflineStoreSource() : super(Dio());

  @override
  Future<List<StoreSummaryModel>> getStores({
    String? name,
    int page = 1,
    int limit = 20,
  }) async {
    throw const ApiException(ApiErrorType.connection);
  }
}

Future<AppCache> _freshCache() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  return AppCache.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const Map<String, dynamic> profileJson = <String, dynamic>{
    'id': 'cust-1',
    'name': 'Obinna Michael',
    'email': 'obinna@mail.com',
    'phone_number': '081234567890',
    'gender': 'male',
    'member_points': 1250,
    'premium_type': 'gold',
    'image_url': '',
  };

  test('AppCache menyimpan dan membaca kembali payload', () async {
    final AppCache cache = await _freshCache();

    await cache.writeJson('demo', <String, dynamic>{'a': 1});
    final CachedPayload? read = cache.readJson('demo');

    expect(read, isNotNull);
    expect(read!.asMap!['a'], 1);
    expect(
      read.savedAt.difference(DateTime.now()).inSeconds.abs(),
      lessThan(5),
    );
  });

  test('AppCache mengembalikan null untuk key yang belum ada', () async {
    final AppCache cache = await _freshCache();
    expect(cache.readJson('belum-ada'), isNull);
    expect(cache.readBool('belum-ada'), isFalse);
  });

  test('profil tetap terbaca dari cache saat koneksi mati', () async {
    final AppCache cache = await _freshCache();
    await cache.writeJson(AppCache.keyCustomerProfile, profileJson);

    final ProfileRepository repo = ProfileRepositoryImpl(
      _OfflineProfileSource(),
      cache,
    );
    final CachedResult<CustomerProfile> result = await repo
        .getCustomerProfile();

    expect(result.fromCache, isTrue);
    expect(result.data.name, 'Obinna Michael');
    expect(result.data.tier, MemberTier.gold);
    expect(result.savedAt, isNotNull);
  });

  test('profil melempar error kalau offline dan cache kosong', () async {
    final AppCache cache = await _freshCache();
    final ProfileRepository repo = ProfileRepositoryImpl(
      _OfflineProfileSource(),
      cache,
    );

    expect(() => repo.getCustomerProfile(), throwsA(isA<ApiException>()));
  });

  test('daftar cabang jatuh ke cache saat koneksi mati', () async {
    final AppCache cache = await _freshCache();
    await cache.writeJson(AppCache.keyStores, <Map<String, dynamic>>[
      const StoreSummaryModel(
        id: 'store-1',
        name: 'Barberstuff Kemang Raya',
        address: 'Jl. Metro Pondok Indah No. 12',
        phoneNumber: '081234567890',
        bannerUrl: '',
        storeType: 'lite',
        status: 'open',
        avgRating: 4.8,
        totalCapster: 3,
        totalService: 5,
        totalPackage: 2,
      ).toJson(),
    ]);

    final StoreRepository repo = StoreRepositoryImpl(
      _OfflineStoreSource(),
      cache,
    );
    final CachedResult<List<StoreSummary>> result = await repo.getStores();

    expect(result.fromCache, isTrue);
    expect(result.data.single.name, 'Barberstuff Kemang Raya');
    expect(result.data.single.isLite, isTrue);
  });

  test('pencarian cabang tetap jalan di atas data cache', () async {
    final AppCache cache = await _freshCache();
    await cache.writeJson(AppCache.keyStores, <Map<String, dynamic>>[
      const StoreSummaryModel(
        id: 'store-1',
        name: 'Kemang Raya',
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
      const StoreSummaryModel(
        id: 'store-2',
        name: 'Pondok Indah',
        address: 'Jl. Pondok Indah',
        phoneNumber: '',
        bannerUrl: '',
        storeType: 'reguler',
        status: 'open',
        avgRating: 4.6,
        totalCapster: 1,
        totalService: 1,
        totalPackage: 0,
      ).toJson(),
    ]);

    final StoreRepository repo = StoreRepositoryImpl(
      _OfflineStoreSource(),
      cache,
    );
    final CachedResult<List<StoreSummary>> result = await repo.getStores(
      name: 'pondok',
    );

    expect(result.fromCache, isTrue);
    expect(result.data.single.id, 'store-2');
  });

  test('lock booking kedaluwarsa tidak ikut dipulihkan', () async {
    final AppCache cache = await _freshCache();
    await cache.writeJson(AppCache.keyBookingLock, <String, dynamic>{
      'expires_at': DateTime.now()
          .subtract(const Duration(minutes: 1))
          .millisecondsSinceEpoch,
    });

    final BookingRepositoryImpl repo = BookingRepositoryImpl(
      BookingRemoteDataSource(Dio()),
      BookingLocalDataSource(cache),
    );

    expect(repo.readDraft().lock, isNull);
    await Future<void>.delayed(Duration.zero);
    expect(cache.readJson(AppCache.keyBookingLock), isNull);
  });
}
