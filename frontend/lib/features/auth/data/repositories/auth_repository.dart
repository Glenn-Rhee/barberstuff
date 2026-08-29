import 'package:mobile_barberstuff/core/services/dio_client.dart';
import 'package:mobile_barberstuff/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile_barberstuff/features/auth/data/models/login_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/login_result.dart';
import 'package:mobile_barberstuff/features/auth/data/models/register_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/register_result.dart';
import 'package:mobile_barberstuff/features/auth/data/models/verify_otp_request_api.dart';
import 'package:mobile_barberstuff/features/auth/data/models/verify_otp_result.dart';

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

  Future<VerifyOtpResult> verifyOtp(VerifyOtpRequestApi request) async {
    try {
      return await _remote.verifyCredential(request);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }

  Future<LoginResult> login(LoginRequestApi request) async {
    try {
      return await _remote.loginCredential(request);
    } catch (e) {
      throw DioClient.mapError(e);
    }
  }
}
