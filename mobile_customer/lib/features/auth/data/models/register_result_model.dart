import 'package:mobile_barberstuff/features/auth/domain/entities/register_result.dart';

class RegisterResultModel extends RegisterResult {
  const RegisterResultModel({required super.id, required super.email});

  factory RegisterResultModel.fromJson(Map<String, dynamic> json) =>
      RegisterResultModel(
        id: (json['id'] as String?) ?? '',
        email: (json['email'] as String?) ?? '',
      );
}
