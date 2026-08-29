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
  String get bookingTitle => 'Book a Service';

  @override
  String greeting(String name) {
    return 'Hi, $name!';
  }

  @override
  String queueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people in queue',
      one: '1 person in queue',
      zero: 'No one in queue',
    );
    return '$_temp0';
  }

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
  String get commonSuccess => 'Success';

  @override
  String get commonRetry => 'Try again';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get registerPageBarText => 'Sign Up';

  @override
  String get registerHeadline => 'Create Your Account';

  @override
  String get registerSubheadline =>
      'Fill in your details to become a Barberstuff.';

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
  String get registerSubmitButton => 'Sign Up';

  @override
  String get registerHaveAccountQuestion => 'Already have an account?';

  @override
  String get registerLoginAction => 'Sign In';

  @override
  String get registerOtpSentMessage => 'An OTP has been sent to your email.';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonMessage =>
      'We are still working on this feature. In the meantime, feel free to use the available features. Thank you.';

  @override
  String get commonUnderstood => 'Got it';
}
