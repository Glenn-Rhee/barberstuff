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
    'date_of_birth': _iso(dateOfBirth),
    'gender': gender,
    'email': email,
    'password': password,
    if (imageUrl != null && imageUrl!.isNotEmpty) 'image_url': imageUrl,
  };

  static String _iso(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}T00:00:00Z';
  }
}
