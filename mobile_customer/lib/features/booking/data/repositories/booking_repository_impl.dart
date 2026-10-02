import 'dart:async';

import 'package:mobile_barberstuff/core/network/dio_client.dart';
import 'package:mobile_barberstuff/features/booking/data/datasources/booking_local_datasource.dart';
import 'package:mobile_barberstuff/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_lock_model.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_record_model.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_result_model.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_draft.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_record.dart';
import 'package:mobile_barberstuff/features/booking/domain/entities/booking_slot.dart';
import 'package:mobile_barberstuff/features/booking/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._remote, this._local);

  final BookingRemoteDataSource _remote;
  final BookingLocalDataSource _local;

  final StreamController<BookingRecord> _created =
      StreamController<BookingRecord>.broadcast();

  @override
  Stream<BookingRecord> get createdBookings => _created.stream;

  @override
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

  @override
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

  @override
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

  @override
  Future<BookingRecord> createBooking({
    required String idStore,
    required String idCapster,
    required String capsterName,
    required String idService,
    required DateTime bookingDate,
    String? idPromoClaimed,
  }) async {
    final BookingResultModel result;
    try {
      result = await _remote.createBooking(
        idStore: idStore,
        idCapster: idCapster,
        idService: idService,
        bookingDate: bookingDate,
        idPromoClaimed: idPromoClaimed,
      );
    } catch (e) {
      throw DioClient.mapError(e);
    }

    final BookingRecord record = BookingRecordModel.fromResult(
      result,
      capsterId: idCapster,
      capsterName: capsterName,
    );
    await _local.add(record);
    _created.add(record);
    return record;
  }

  @override
  BookingDraft readDraft() {
    return BookingDraft(
      termsAgreed: _local.readTermsAgreed(),
      lock: _readLock(),
    );
  }

  /// Kunci yang sudah habis langsung dibuang supaya tidak dipulihkan lagi.
  BookingLock? _readLock() {
    final Map<String, dynamic>? raw = _local.readLock();
    if (raw == null) return null;

    if (!BookingLockModel.expiresAtOf(raw).isAfter(DateTime.now())) {
      _local.clearLock();
      return null;
    }

    return BookingLockModel.fromJson(raw);
  }

  @override
  Future<void> saveTermsAgreed(bool value) => _local.writeTermsAgreed(value);

  @override
  Future<void> saveLock(BookingLock? lock) {
    if (lock == null) return _local.clearLock();
    return _local.writeLock(BookingLockModel.fromEntity(lock).toJson());
  }
}
