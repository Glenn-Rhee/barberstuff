import 'package:mobile_barberstuff/core/utils/date_format.dart';
import 'package:mobile_barberstuff/features/auth/domain/entities/registration.dart';

class RegisterRequestApi {
  const RegisterRequestApi({
    required this.name,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.email,
    required this.password,
    this.imageUrl,
  });

  final String name;
  final String phoneNumber;
  final DateTime dateOfBirth;
  final String gender;
  final String email;
  final String password;
  final String? imageUrl;

  factory RegisterRequestApi.fromEntity(Registration registration) {
    return RegisterRequestApi(
      name: registration.name,
      phoneNumber: registration.phoneNumber,
      dateOfBirth: registration.dateOfBirth,
      gender: registration.gender,
      email: registration.email,
      password: registration.password,
      imageUrl: registration.imageUrl,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'phoneNumber': phoneNumber,
    'date_of_birth': formatApiDate(dateOfBirth),
    'gender': gender,
    'email': email,
    'password': password,
    if (imageUrl != null && imageUrl!.isNotEmpty) 'image_url': imageUrl,
  };
}
