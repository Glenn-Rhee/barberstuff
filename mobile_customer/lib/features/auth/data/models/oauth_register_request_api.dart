import 'package:mobile_barberstuff/core/utils/date_format.dart';

class OauthRegisterRequestApi {
  const OauthRegisterRequestApi({
    required this.name,
    required this.tempToken,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
  });

  final String name;
  final String tempToken;
  final String phoneNumber;
  final DateTime dateOfBirth;
  final String gender;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'temp_token': tempToken,
    'phoneNumber': phoneNumber,
    'date_of_birth': formatApiDate(dateOfBirth),
    'gender': gender,
  };
}
