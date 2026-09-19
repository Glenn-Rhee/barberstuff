import 'package:dio/dio.dart';

import 'package:mobile_barberstuff/core/config/api_endpoint.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/api_response.dart';
import 'package:mobile_barberstuff/features/store/data/models/store_detail.dart';

class StoreRemoteDataSource {
  StoreRemoteDataSource(this._dio);

  final Dio _dio;

  Never _fail(ApiResponse<Object?> parsed, int? statusCode) {
    throw ApiException(
      ApiErrorType.server,
      statusCode: statusCode,
      rawMessage: parsed.message,
    );
  }

  Future<StoreDetail> getStoreDetail(String id) async {
    final Response<dynamic> res = await _dio.get<dynamic>(
      ApiEndpoint.storeDetail(id),
    );

    final ApiResponse<StoreDetail> parsed = ApiResponse<StoreDetail>.fromJson(
      res.data as Map<String, dynamic>,
      StoreDetail.fromJson,
    );

    if (!parsed.isSuccess || parsed.data == null) {
      _fail(parsed, res.statusCode);
    }

    return parsed.data!;
  }

  Future<List<CapsterItem>> getCapsters(String idStore) async {
    final Response<dynamic> res = await _dio.get<dynamic>(
      ApiEndpoint.capsters,
      queryParameters: <String, dynamic>{
        'id_store': idStore,
        'page': 1,
        'limit': 20,
      },
    );

    final ApiResponse<List<CapsterItem>> parsed =
        ApiResponse.listFromJson<CapsterItem>(
          res.data as Map<String, dynamic>,
          CapsterItem.fromJson,
        );

    if (!parsed.isSuccess || parsed.data == null) {
      _fail(parsed, res.statusCode);
    }

    return parsed.data!;
  }
}
