class RegisterRequestApi {
  const RegisterRequestApi({
    required this.name,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.email,
    required this.password
  });

  final String name;
  final String phoneNumber;
  final DateTime dateOfBirth;
  final String gender;
  final String email;
  final String password;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'phoneNumber': phoneNumber,
    'date_of_birth': _iso(dateOfBirth),
    'gender': gender,
    'email': email,
    'password': password
  };

  // helper to convert
  static String _iso(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}T00:00:00Z';
  }
}