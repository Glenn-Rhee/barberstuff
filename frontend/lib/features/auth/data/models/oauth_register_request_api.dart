class OauthRegisterRequestApi {
  const OauthRegisterRequestApi({
    required this.name,
    required this.tempToken,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    this.imageUrl,
  });

  final String name;
  final String tempToken;
  final String phoneNumber;
  final DateTime dateOfBirth;
  final String gender;
  final String? imageUrl;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'temp_token': tempToken,
    'phoneNumber': phoneNumber,
    'date_of_birth': _iso(dateOfBirth),
    'gender': gender,
    if (imageUrl != null && imageUrl!.isNotEmpty) 'image_url': imageUrl,
  };

  static String _iso(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}T00:00:00Z';
  }
}
