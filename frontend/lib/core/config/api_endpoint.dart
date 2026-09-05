class ApiEndpoint {
  const ApiEndpoint._();

  static const String registerCredential = '/auth/register/credential';
  static const String verifyCredential = '/auth/verify-credential';
  static const String loginCredential = '/auth/login/credential';

  static const String authProvider = '/auth/provider';
  static const String registerOauth = '/auth/register/oauth';

  static const String forgotPassword = '/auth/forgot';
  static const String resetPassword = '/auth/reset';

  static const String profileCustomer = '/profile/customer';
}
