import 'package:dio/dio.dart';

import 'package:mobile_barberstuff/core/config/api_endpoint.dart';
import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/core/network/api_response.dart';
import 'package:mobile_barberstuff/features/history/domain/entities/booking_history.dart';

class HistoryRemoteDataSource {
  HistoryRemoteDataSource(this._dio);

  final Dio _dio;

  /// Batas maksimal `limit` di backend.
  static const int pageLimit = 50;

  static String statusOf(HistoryTab tab) {
    switch (tab) {
      case HistoryTab.upcoming:
        return 'upcoming';
      case HistoryTab.done:
        return 'done';
      case HistoryTab.canceled:
        return 'cancel';
    }
  }

  /// Booking milik akun yang sedang login, disaring server lewat token.
  Future<List<Map<String, dynamic>>> getBookings(HistoryTab tab) async {
    final Response<dynamic> res = await _dio.get<dynamic>(
      ApiEndpoint.bookingCustomer,
      queryParameters: <String, dynamic>{
        'status_booking': statusOf(tab),
        'sort_by': 'scheduled_at',
        'order': 'desc',
        'page': 1,
        'limit': pageLimit,
      },
    );

    final ApiResponse<List<Map<String, dynamic>>> parsed =
        ApiResponse.listFromJson<Map<String, dynamic>>(
          res.data as Map<String, dynamic>,
          (Map<String, dynamic> json) => json,
        );

    if (!parsed.isSuccess || parsed.data == null) {
      throw ApiException(
        ApiErrorType.server,
        statusCode: res.statusCode,
        rawMessage: parsed.message,
      );
    }

    return parsed.data!;
  }

  Future<void> createRating(Map<String, dynamic> body) async {
    final Response<dynamic> res = await _dio.post<dynamic>(
      ApiEndpoint.rating,
      data: body,
    );

    final ApiResponse<Object?> parsed = ApiResponse<Object?>.fromJson(
      res.data as Map<String, dynamic>,
      null,
    );

    if (!parsed.isSuccess) {
      throw ApiException(
        ApiErrorType.server,
        statusCode: res.statusCode,
        rawMessage: parsed.message,
      );
    }
  }
}
