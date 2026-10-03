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

  static const String stores = '/store/';
  static String storeDetail(String id) => '/store/$id';

  static const String services = '/service/';
  static const String capsters = '/capster/';

  static const String bookingStore = '/booking/store';
  static const String booking = '/booking/';
  static const String bookingLock = '/booking/lock';
  static const String bookingCustomer = '/booking/customer';

  static const String rating = '/rating/';

  static const String uploadPresign = '/upload/presign';
}
