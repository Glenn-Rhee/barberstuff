import 'package:dio/dio.dart';

import 'package:mobile_barberstuff/core/config/api_endpoint.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/api_response.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_result_model.dart';
import 'package:mobile_barberstuff/features/booking/data/models/booking_slot_model.dart';

class BookingRemoteDataSource {
  BookingRemoteDataSource(this._dio);

  final Dio _dio;

  static String _isoDate(DateTime value) {
    final DateTime utc = value.toUtc();
    return '${utc.toIso8601String().split('.').first}Z';
  }

  Never _fail(ApiResponse<Object?> parsed, int? statusCode) {
    throw ApiException(
      ApiErrorType.server,
      statusCode: statusCode,
      rawMessage: parsed.message,
    );
  }

  Future<StoreSlotsModel> getStoreSlots({
    required String idStore,
    required DateTime date,
  }) async {
    final Response<dynamic> res = await _dio.get<dynamic>(
      ApiEndpoint.bookingStore,
      queryParameters: <String, dynamic>{
        'id_store': idStore,
        'date': _isoDate(date),
      },
    );

    final ApiResponse<StoreSlotsModel> parsed =
        ApiResponse<StoreSlotsModel>.fromJson(
          res.data as Map<String, dynamic>,
          StoreSlotsModel.fromJson,
        );

    if (!parsed.isSuccess || parsed.data == null) {
      _fail(parsed, res.statusCode);
    }

    return parsed.data!;
  }

  Future<void> lockBooking({
    required String idStore,
    required String idCapster,
    required DateTime bookingDate,
  }) async {
    final Response<dynamic> res = await _dio.post<dynamic>(
      ApiEndpoint.bookingLock,
      data: <String, dynamic>{
        'id_store': idStore,
        'id_capster': idCapster,
        'booking_date': _isoDate(bookingDate),
      },
    );

    final ApiResponse<Object?> parsed = ApiResponse<Object?>.fromJson(
      res.data as Map<String, dynamic>,
      null,
    );

    if (!parsed.isSuccess) _fail(parsed, res.statusCode);
  }

  Future<void> releaseLock({
    required String idStore,
    required String idCapster,
    required DateTime bookingDate,
  }) async {
    final Response<dynamic> res = await _dio.delete<dynamic>(
      ApiEndpoint.bookingLock,
      queryParameters: <String, dynamic>{
        'id_store': idStore,
        'id_capster': idCapster,
        'booking_date': _isoDate(bookingDate),
      },
    );

    final ApiResponse<Object?> parsed = ApiResponse<Object?>.fromJson(
      res.data as Map<String, dynamic>,
      null,
    );

    if (!parsed.isSuccess) _fail(parsed, res.statusCode);
  }

  Future<BookingResultModel> createBooking({
    required String idStore,
    required String idCapster,
    required String idService,
    required DateTime bookingDate,
    String? idPromoClaimed,
  }) async {
    final Response<dynamic> res = await _dio.post<dynamic>(
      ApiEndpoint.booking,
      data: <String, dynamic>{
        'id_store': idStore,
        'id_capster': idCapster,
        'id_service': idService,
        'booking_date': _isoDate(bookingDate),
        if (idPromoClaimed != null) 'id_promo_claimed': idPromoClaimed,
      },
    );

    final ApiResponse<BookingResultModel> parsed =
        ApiResponse<BookingResultModel>.fromJson(
          res.data as Map<String, dynamic>,
          BookingResultModel.fromJson,
        );

    if (!parsed.isSuccess || parsed.data == null) {
      _fail(parsed, res.statusCode);
    }

    return parsed.data!;
  }
}
