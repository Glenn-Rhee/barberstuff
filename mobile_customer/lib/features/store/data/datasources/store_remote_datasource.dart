import 'package:dio/dio.dart';

import 'package:mobile_barberstuff/core/config/api_endpoint.dart';
import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/core/network/api_response.dart';
import 'package:mobile_barberstuff/features/store/data/models/service_item_model.dart';
import 'package:mobile_barberstuff/features/store/data/models/store_detail_model.dart';
import 'package:mobile_barberstuff/features/store/data/models/store_summary_model.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/service_item.dart';

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

  Future<List<StoreSummaryModel>> getStores({
    String? name,
    int page = 1,
    int limit = 20,
  }) async {
    final Response<dynamic> res = await _dio.get<dynamic>(
      ApiEndpoint.stores,
      queryParameters: <String, dynamic>{
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        'page': page,
        'limit': limit,
      },
    );

    final ApiResponse<List<StoreSummaryModel>> parsed =
        ApiResponse.listFromJson<StoreSummaryModel>(
          res.data as Map<String, dynamic>,
          StoreSummaryModel.fromJson,
        );

    if (!parsed.isSuccess || parsed.data == null) {
      _fail(parsed, res.statusCode);
    }

    return parsed.data!;
  }

  Future<StoreDetailModel> getStoreDetail(String id) async {
    final Response<dynamic> res = await _dio.get<dynamic>(
      ApiEndpoint.storeDetail(id),
    );

    final ApiResponse<StoreDetailModel> parsed =
        ApiResponse<StoreDetailModel>.fromJson(
          res.data as Map<String, dynamic>,
          StoreDetailModel.fromJson,
        );

    if (!parsed.isSuccess || parsed.data == null) {
      _fail(parsed, res.statusCode);
    }

    return parsed.data!;
  }

  Future<List<CapsterItemModel>> getCapsters(String idStore) async {
    final Response<dynamic> res = await _dio.get<dynamic>(
      ApiEndpoint.capsters,
      queryParameters: <String, dynamic>{
        'id_store': idStore,
        'page': 1,
        'limit': 20,
      },
    );

    final ApiResponse<List<CapsterItemModel>> parsed =
        ApiResponse.listFromJson<CapsterItemModel>(
          res.data as Map<String, dynamic>,
          CapsterItemModel.fromJson,
        );

    if (!parsed.isSuccess || parsed.data == null) {
      _fail(parsed, res.statusCode);
    }

    return parsed.data!;
  }

  Future<List<ServiceItemModel>> getServices({
    required String idStore,
    required ProductType type,
    int page = 1,
    int limit = 50,
  }) async {
    final Response<dynamic> res = await _dio.get<dynamic>(
      ApiEndpoint.services,
      queryParameters: <String, dynamic>{
        'id_store': idStore,
        'type': type.name,
        'page': page,
        'limit': limit,
      },
    );

    final ApiResponse<List<ServiceItemModel>> parsed =
        ApiResponse.listFromJson<ServiceItemModel>(
          res.data as Map<String, dynamic>,
          ServiceItemModel.fromJson,
        );

    if (!parsed.isSuccess || parsed.data == null) {
      _fail(parsed, res.statusCode);
    }

    return parsed.data!;
  }
}
