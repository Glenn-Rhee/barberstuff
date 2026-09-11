import 'package:mobile_barberstuff/core/services/dio_client.dart';
import 'package:mobile_barberstuff/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_api_model.dart';

class BookingRepository {
  BookingRepository(this._remote);

  final BookingRemoteDataSource _remote;

  Future<List<StoreSummary>> getStores({String? name}) async {
    try {
      return await _remote.getStores(name: name);
    } catch (e) {
      throw DioClient.mapError(e);
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
