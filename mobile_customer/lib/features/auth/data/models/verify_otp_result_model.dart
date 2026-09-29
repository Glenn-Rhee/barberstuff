import 'package:mobile_barberstuff/features/auth/domain/entities/verify_otp_result.dart';

class VerifyOtpResultModel extends VerifyOtpResult {
  const VerifyOtpResultModel({super.resetToken});

  factory VerifyOtpResultModel.fromJson(Map<String, dynamic> json) =>
      VerifyOtpResultModel(resetToken: json['reset_token'] as String?);
}
