import 'package:dio/dio.dart';

import 'package:mobile_barberstuff/core/config/api_endpoint.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/api_response.dart';
import 'package:mobile_barberstuff/features/profile/data/models/customer_profile.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._dio);

  final Dio _dio;

  Future<CustomerProfile> getCustomerProfile() async {
    final Response<dynamic> res = await _dio.get<dynamic>(
      ApiEndpoint.profileCustomer,
    );

    final ApiResponse<CustomerProfile> parsed =
        ApiResponse<CustomerProfile>.fromJson(
          res.data as Map<String, dynamic>,
          CustomerProfile.fromJson,
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
}
