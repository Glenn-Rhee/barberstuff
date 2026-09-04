import 'package:mobile_barberstuff/core/services/dio_client.dart';
import 'package:mobile_barberstuff/features/forgot_password/domain/models/forgot_password_request_api.dart';
import 'package:mobile_barberstuff/features/forgot_password/domain/models/forgot_password_result.dart';
import 'package:mobile_barberstuff/features/forgot_password/domain/models/reset_password_request_api.dart';

Future<ForgotPasswordResult> forgotPassword(
  ForgotPasswordRequestApi request
) async {
  try {
    return await _remote.forgotPassword(request);
  } catch (e) {
    throw DioClient.mapError(e);
  }
}

Future<void> resetPassword(ResetPasswordRequestApi request) async {
  try {
    await _remote.resetPassword(request);
  }catch (e) {
    throw DioClient.mapError(e);
  }
}