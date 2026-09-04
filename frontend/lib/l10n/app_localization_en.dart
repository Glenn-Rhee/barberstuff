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
  String get commonProcessing => 'Processing...';

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
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonMessage =>
      'We are still working on this feature. In the meantime, feel free to use the available features. Thank you.';

  @override
  String get commonUnderstood => 'Got it';
}
