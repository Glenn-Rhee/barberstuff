import 'package:mobile_barberstuff/core/services/dio_client.dart';
import 'package:mobile_barberstuff/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile_barberstuff/features/auth/data/models/register_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/register_result.dart';

class AuthRepository {
  AuthRepository(this._remote);
  final AuthRemoteDataSource _remote;

  Future<RegisterResult> register(RegisterRequestApi request) async {
    try {
      return await _remote.registerCredential(request);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }
}