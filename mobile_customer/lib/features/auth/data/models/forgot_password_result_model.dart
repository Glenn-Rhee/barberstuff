import 'package:mobile_barberstuff/features/auth/domain/entities/forgot_password_result.dart';

class ForgotPasswordResultModel extends ForgotPasswordResult {
  const ForgotPasswordResultModel({required super.userId});

  factory ForgotPasswordResultModel.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordResultModel(userId: (json['user_id'] as String?) ?? '');
}
