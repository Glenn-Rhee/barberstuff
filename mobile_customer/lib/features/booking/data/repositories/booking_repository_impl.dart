import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/app_cache.dart';
import 'package:mobile_barberstuff/core/services/dio_client.dart';
import 'package:mobile_barberstuff/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_api_model.dart';

class BookingRepository {
  BookingRepository(this._remote, this._cache);

  final BookingRemoteDataSource _remote;
  final AppCache _cache;

  AppCache get cache => _cache;

  Future<CachedResult<List<StoreSummary>>> getStores({String? name}) async {
    try {
      final List<StoreSummary> stores = await _remote.getStores(name: name);
      if (name == null || name.isEmpty) {
        await _cache.writeJson(
          AppCache.keyStores,
          stores.map((StoreSummary s) => s.toJson()).toList(growable: false),
        );
      }
      return CachedResult<List<StoreSummary>>(stores, fromCache: false);
    } catch (e) {
      final ApiException failure = DioClient.mapError(e);
      final CachedPayload? cached = _cache.readJson(AppCache.keyStores);

      if (cached != null && cached.asList.isNotEmpty) {
        final List<StoreSummary> stores = cached.asList
            .map(StoreSummary.fromJson)
            .toList(growable: false);

        final String needle = (name ?? '').toLowerCase();
        return CachedResult<List<StoreSummary>>(
          needle.isEmpty
              ? stores
              : stores
                    .where(
                      (StoreSummary s) =>
                          s.name.toLowerCase().contains(needle) ||
                          s.address.toLowerCase().contains(needle),
                    )
                    .toList(growable: false),
          fromCache: true,
          savedAt: cached.savedAt,
        );
      }

      throw failure;
    }
  }

  Future<StoreSlots> getStoreSlots({
    required String idStore,
    required DateTime date,
  }) async {
    try {
      return await _remote.getStoreSlots(idStore: idStore, date: date);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<List<ServiceItem>> getServices({
    required String idStore,
    required ProductType type,
  }) async {
    try {
      return await _remote.getServices(idStore: idStore, type: type);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<void> lockBooking({
    required String idStore,
    required String idCapster,
    required DateTime bookingDate,
  }) async {
    try {
      await _remote.lockBooking(
        idStore: idStore,
        idCapster: idCapster,
        bookingDate: bookingDate,
      );
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<void> releaseLock({
    required String idStore,
    required String idCapster,
    required DateTime bookingDate,
  }) async {
    try {
      await _remote.releaseLock(
        idStore: idStore,
        idCapster: idCapster,
        bookingDate: bookingDate,
      );
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<BookingResult> createBooking({
    required String idStore,
    required String idCapster,
    required String idService,
    required DateTime bookingDate,
    String? idPromoClaimed,
  }) async {
    try {
      return await _remote.createBooking(
        idStore: idStore,
        idCapster: idCapster,
        idService: idService,
        bookingDate: bookingDate,
        idPromoClaimed: idPromoClaimed,
      );
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }
}
