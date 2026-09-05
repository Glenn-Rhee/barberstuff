// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localization.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Barberstuff';

  @override
  String get onboardingFirstTitle => 'Style that fits your day';

  @override
  String get onboardingFirstDescription =>
      'Find a cut that matches your character and daily routine.';

  @override
  String get onboardingSecondTitle => 'Booking made simple';

  @override
  String get onboardingSecondDescription =>
      'Pick your branch, barber, and time slot without queueing.';

  @override
  String get onboardingThirdTitle => 'Enjoy member benefits';

  @override
  String get onboardingThirdDescription =>
      'Collect points on every visit and redeem them for discounts.';

  @override
  String get onboardingStart => 'Get Started!';

  @override
  String get chooseLoginWelcome => 'Welcome';

  @override
  String get chooseLoginGoogleText => 'Continue with Google';

  @override
  String get chooseLoginDividerOr => 'or';

  @override
  String get chooseLoginWithPasswordText => 'Sign In with Password';

  @override
  String get chooseLoginTextMessage => 'Don\'t have an account yet?';

  @override
  String get chooseLoginTextLink => 'Sign Up';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get registerHeadline => 'Create Your Account';

  @override
  String get registerNameLabel => 'Full Name';

  @override
  String get registerPhoneLabel => 'Phone Number';

  @override
  String get registerBirthDateLabel => 'Date of Birth';

  @override
  String get registerGenderLabel => 'Gender';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerSubmitButton => 'Continue';

  @override
  String get registerHaveAccountQuestion => 'Already have an account?';

  @override
  String get registerLoginAction => 'Sign In';

  @override
  String get registerOtpSentMessage => 'An OTP has been sent to your email.';

  @override
  String get verifyPageBarText => 'Email Verification';

  @override
  String get verifyHeadline => 'Check Your Email';

  @override
  String verifyDescription(String email) {
    return 'We have sent a 6-digit verification code to $email. Please enter the code below.';
  }

  @override
  String get verifySubmitButton => 'Verify';

  @override
  String get verifyResendQuestion => 'Did not receive the code?';

  @override
  String get verifyResendAction => 'Resend code';

  @override
  String verifyResendCountdown(String time) {
    return 'Resend in $time';
  }

  @override
  String get verifyAttemptExhausted =>
      'No attempts left. Please request a new code.';

  @override
  String get verifyResendSending => 'Sending...';

  @override
  String get verifyResendSuccess => 'A new code has been sent to your email.';

  @override
  String get verifySuccessTitle => 'Congratulations!';

  @override
  String get verifySuccessMessage =>
      'Your email has been verified successfully. You can now access all features of our app.';

  @override
  String get verifySuccessButton => 'Continue';

  @override
  String get loginHeadline => 'Sign In to Your Account';

  @override
  String get loginEmailHint => 'Email';

  @override
  String get loginPasswordHint => 'Password';

  @override
  String get loginRememberMe => 'Remember Me';

  @override
  String get loginSubmitButton => 'Sign In';

  @override
  String get loginForgotQuestion => 'Forgot your password?';

  @override
  String get loginForgotAction => 'Click here';

  @override
  String get loginWithGoogle => 'Sign in with Google';

  @override
  String get forgotPageBarText => 'Forgot Password';

  @override
  String get forgotHeadline => 'Forgot Password?';

  @override
  String get forgotDescription =>
      'Enter your account email. We will send a verification code so you can reset your password.';

  @override
  String get forgotSubmitButton => 'Send Code';

  @override
  String get resetPageBarText => 'New Password';

  @override
  String get resetHeadline => 'Create New Password';

  @override
  String get resetDescription =>
      'Your new password must be different from any password you have used before.';

  @override
  String get resetPasswordHint => 'New Password';

  @override
  String get resetConfirmHint => 'Repeat New Password';

  @override
  String get resetSubmitButton => 'Save Password';

  @override
  String get resetSignInFailed =>
      'Your password was changed, but we could not sign you in automatically. Please sign in again.';

  @override
  String get resetSuccessTitle => 'Congratulations!';

  @override
  String get resetSuccessMessage =>
      'Your password has been updated. You will be taken to the home page.';

  @override
  String get resetSuccessButton => 'Go to Home';

  @override
  String get exceptionReceiveTimeout =>
      'Connection timed out. Please check your network.';

  @override
  String get exceptionConnectionError => 'Unable to connect to the server.';

  @override
  String get exceptionDefaultType => 'A server error occurred.';

  @override
  String get exceptionDefault => 'An unexpected error occurred.';

  @override
  String validatorRequired(String label) {
    return '$label is required';
  }

  @override
  String get validatorEmailInvalid => 'Invalid email format';

  @override
  String validatorPasswordMin(int min) {
    return 'Password must be at least $min characters';
  }

  @override
  String validatorPhoneMin(int min) {
    return 'Phone Number must be at least $min digits';
  }

  @override
  String validatorPhoneMax(int max) {
    return 'Phone Number must be at most $max digits';
  }

  @override
  String get validatorPhoneDigits => 'Numbers only';

  @override
  String get validatorPasswordMismatch => 'Passwords do not match';

  @override
  String get googleSignInFailed => 'Google sign-in failed. Please try again.';

  @override
  String get completeProfileTitle => 'Complete Your Profile';

  @override
  String get completeProfileSubtitle =>
      'Almost there. Fill in your details to start using Barberstuff.';

  @override
  String get completeProfileSubmit => 'Continue';

  @override
  String get completeProfileEmailLocked =>
      'Email from Google cannot be changed';

  @override
  String get avatarSheetTitle => 'Profile Photo';

  @override
  String get avatarSheetCamera => 'Take a Photo';

  @override
  String get avatarSheetGallery => 'Choose from Gallery';

  @override
  String get avatarSheetRemove => 'Remove Photo';

  @override
  String get avatarPickFailed =>
      'Could not open the gallery or camera. Please try again.';

  @override
  String get avatarPermissionDenied =>
      'Photo or camera access was denied. Enable it in your device settings.';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name!';
  }

  @override
  String get homeWelcomeBack => 'Welcome back';

  @override
  String homePoints(String points) {
    return '$points Points';
  }

  @override
  String get homeMemberBadge => 'MEMBER';

  @override
  String homePointsToPremium(String points) {
    return '$points more points to premium level';
  }

  @override
  String get homeBirthdayTitle => 'Birthday Special!';

  @override
  String get homeBirthdayDescription =>
      'Haircut discount valid for up to 7 days after your birthday.';

  @override
  String get homeSeePromo => 'See Promo';

  @override
  String get homeBenefitTitle => 'Barberstuff Benefits';

  @override
  String get homeBenefitPoints => 'Reward points on every haircut';

  @override
  String get homeBenefitBirthday => 'Special discounts and birthday offers';

  @override
  String get homeBenefitPriority => 'Priority slots with no long queues';

  @override
  String get homeActiveBookingTitle => 'Active Booking';

  @override
  String get homeBookingUpcoming => 'UPCOMING';

  @override
  String homeBookingOrderId(String id) {
    return 'Order ID #$id';
  }

  @override
  String get homeBookingDetail => 'View Detail';

  @override
  String get homeBookingEmpty => 'No active booking yet.';

  @override
  String get homeNearbyTitle => 'Nearby Branches';

  @override
  String get homeNearbySeeAll => 'See All';

  @override
  String homeNearbyDistance(String distance) {
    return '$distance km';
  }

  @override
  String get homeHistoryTitle => 'Haircut History';

  @override
  String get homeHistorySeeAll => 'See History';

  @override
  String get homeHistoryEmpty => 'No haircut history yet.';

  @override
  String get navHome => 'Home';

  @override
  String get navBooking => 'Booking';

  @override
  String get navHistory => 'History';

  @override
  String get navProfile => 'Profile';

  @override
  String get profileTierNewbie => 'LITE MEMBER';

  @override
  String get profileTierBestie => 'BESTIE MEMBER';

  @override
  String get profileTierRoyal => 'ROYAL MEMBER';

  @override
  String get profileTierCrazy => 'CRAZY MEMBER';

  @override
  String get profileMenuPersonalInfo => 'Personal Information';

  @override
  String get profileMenuLanguage => 'Language';

  @override
  String get profileMenuCard => 'Barberstuff Card';

  @override
  String get profileMenuNotification => 'Notifications';

  @override
  String get profileMenuHelp => 'Help Center';

  @override
  String get profileMenuAbout => 'About the App';

  @override
  String get profileMenuLogout => 'Log out';

  @override
  String get profileLogoutTitle => 'Log out of your account?';

  @override
  String get profileLogoutMessage =>
      'You will need to sign in again to use Barberstuff.';

  @override
  String get languageSheetTitle => 'Choose Language';

  @override
  String get languageIndonesian => 'Indonesia';

  @override
  String get languageEnglish => 'English';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get cardPageTitle => 'Barberstuff Card';

  @override
  String get cardIdLabel => 'User ID';

  @override
  String get personalInfoTitle => 'Personal Information';

  @override
  String get personalInfoChangePhoto => 'Change Profile Photo';

  @override
  String get personalInfoPhotoFormat => 'Supported Format: JPEG, PNG, JPG';

  @override
  String get personalInfoEmailLocked =>
      'Email is used to sign in and cannot be changed';

  @override
  String get personalInfoPasswordTitle => 'My Password';

  @override
  String get personalInfoPasswordSubtitle => 'Change My Password';

  @override
  String get personalInfoPasswordAction => 'Change Now';

  @override
  String get personalInfoSave => 'Save Changes';

  @override
  String get comingSoonMessage => 'Comming soon!';

  @override
  String get commonRetry => 'Try Again';

  @override
  String get commonUnderstood => 'Oke';

  @override
  String get commonLogout => 'Log out';
}
