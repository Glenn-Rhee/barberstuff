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
  String get homeMembershipLevel => 'Membership level';

  @override
  String get homeRedeemPoints => 'Redeem your points';

  @override
  String get homeBirthdayTitle => 'Birthday Special!';

  @override
  String get homeBirthdayDescription =>
      'Haircut discount valid for up to 7 days after your birthday.';

  @override
  String get homeSeePromo => 'See Promo';

  @override
  String get homeBirthdayBadge => 'Look your best every day';

  @override
  String get homeBookingNow => 'Book Now';

  @override
  String get homeActionBooking => 'Booking';

  @override
  String get homeActionPackage => 'Packages';

  @override
  String get homeActionPromo => 'Promo';

  @override
  String get homeActionHistory => 'History';

  @override
  String get homeBenefitTitle => 'Barberstuff Benefits';

  @override
  String get homeBenefitPoints => 'Reward points on every haircut';

  @override
  String get homeBenefitBirthday => 'Special discounts and birthday offers';

  @override
  String get homeBenefitPriority => 'Priority slots with no long queues';

  @override
  String get homeBenefitDiscountTitle => 'More Haircut Discounts!';

  @override
  String get homeBenefitPointsTitle => 'Points on Every Cut';

  @override
  String get homeBenefitPriorityTitle => 'Priority Without Queueing';

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
  String homeBookingCapster(String name) {
    return 'Capster $name';
  }

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
  String get homeHistoryRebook => 'Book Again';

  @override
  String homeHistoryBy(String name) {
    return 'by $name';
  }

  @override
  String homeNearbyLocation(String city, String distance) {
    return '$city • $distance km';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navBooking => 'Booking';

  @override
  String get navHistory => 'History';

  @override
  String get navProfile => 'Profile';

  @override
  String get notificationTitle => 'Notifications';

  @override
  String get notificationSearchHint => 'Search notifications...';

  @override
  String get notificationFilterAll => 'All';

  @override
  String get notificationFilterUnread => 'Unread';

  @override
  String get notificationMarkAllRead => 'Mark all as read';

  @override
  String get notificationToday => 'Today';

  @override
  String get notificationYesterday => 'Yesterday';

  @override
  String get notificationEmpty => 'No notifications yet';

  @override
  String get notificationTimeNow => 'Just now';

  @override
  String notificationTimeMinute(int count) {
    return '$count min ago';
  }

  @override
  String notificationTimeHour(int count) {
    return '$count hr ago';
  }

  @override
  String notificationTimeDay(int count) {
    return '$count d ago';
  }

  @override
  String get notificationBookingTitle => 'Booking Confirmed!';

  @override
  String get notificationBookingBody =>
      'Your haircut booking at the Jati Asih branch has been confirmed by the barber.';

  @override
  String get notificationPointsTitle => 'Member Points Added!';

  @override
  String get notificationPointsBody =>
      'You earned 150 bonus points from your latest haircut. Keep levelling up!';

  @override
  String get notificationMembershipTitle => 'Congrats, Member Level Up!';

  @override
  String get notificationMembershipBody =>
      'You have reached Premium level! Enjoy exclusive perks with no queueing.';

  @override
  String get notificationRecommendationTitle => 'New Hairstyle Recommendation';

  @override
  String get notificationRecommendationBody =>
      'Discover this year latest men hairstyle trends that suit your face shape.';

  @override
  String get profileTierSilver => 'Silver Member';

  @override
  String get profileTierGold => 'Gold Member';

  @override
  String get profileTierPlatinum => 'Platinum Member';

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
  String get languagePageTitle => 'Choose Language';

  @override
  String get languagePageDescription =>
      'Please choose the language you are most comfortable with so you can get the best experience with us.';

  @override
  String get languageIndonesian => 'Indonesian';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSelectAction => 'Select';

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
  String get helpTitle => 'Help Center';

  @override
  String get helpHeadline => 'Need Help? Tell Us What\'s Going On';

  @override
  String get helpSubtitle =>
      'Fill out the form below and our team will get back to you as soon as possible.';

  @override
  String get helpNameLabel => 'Name';

  @override
  String get helpProblemLabel => 'Tell Us Your Problem';

  @override
  String get helpProblemHint => 'Tell us what\'s your problem';

  @override
  String get helpSubmit => 'Submit';

  @override
  String get aboutTitle => 'About the App';

  @override
  String aboutLastUpdated(String date) {
    return 'Last Updated: $date';
  }

  @override
  String get aboutIntro =>
      'By accessing or using the Barberstuff application, you agree to be bound by these Terms of Use.';

  @override
  String get aboutAcceptanceTitle => '1. Acceptance of Terms';

  @override
  String get aboutAcceptanceBody =>
      'By using Barberstuff, you confirm that you have read, understood, and agreed to these Terms of Use.';

  @override
  String get aboutEligibilityTitle => '2. Eligibility';

  @override
  String get aboutEligibilityBody =>
      'You must be at least 17 years old or have legal permission from a parent or guardian to use Barberstuff.';

  @override
  String get aboutAccountTitle => '3. User Accounts';

  @override
  String get aboutAccountPoint1 =>
      'You are responsible for maintaining the confidentiality of your account';

  @override
  String get aboutAccountPoint2 =>
      'All information provided must be accurate and up to date';

  @override
  String get aboutAccountPoint3 =>
      'Barberstuff is not responsible for unauthorized access caused by user negligence';

  @override
  String get aboutUsageTitle => '4. Use of Services';

  @override
  String get aboutUsageIntro => 'You agree not to:';

  @override
  String get aboutUsagePoint1 => 'Use Barberstuff for unlawful purposes';

  @override
  String get aboutUsagePoint2 =>
      'Copy, distribute, or exploit platform content without permission';

  @override
  String get aboutUsagePoint3 =>
      'Upload content that violates laws or third-party rights';

  @override
  String get aboutIpTitle => '5. Intellectual Property';

  @override
  String get aboutIpBody =>
      'All platform content, systems, and designs are owned by Barberstuff. Any data or materials created by users remain the user\'s property.';

  @override
  String get aboutTerminationTitle => '6. Account Termination';

  @override
  String get aboutTerminationBody =>
      'Barberstuff reserves the right to suspend or terminate accounts that violate these Terms.';

  @override
  String get aboutDisclaimerTitle => '7. Disclaimer';

  @override
  String get aboutDisclaimerBody =>
      'Barberstuff is provided on an \"as is\" and \"as available\" basis without warranties of any kind.';

  @override
  String get aboutChangesTitle => '8. Changes to Terms';

  @override
  String get aboutChangesBody =>
      'Barberstuff may update these Terms at any time. Continued use of the platform indicates acceptance of the updated Terms.';

  @override
  String get bookingBranchTitle => 'Choose Branch';

  @override
  String get bookingBarberTitle => 'Choose Barber';

  @override
  String get bookingTermsHeadline => '📋 Barberstuff Booking Terms';

  @override
  String get bookingTermsIntro =>
      'To give you the best service and keep our schedule running smoothly, every customer is expected to follow the booking terms below.';

  @override
  String get bookingTermsRulesLabel => '💡 Booking Rules:';

  @override
  String get bookingTermsRule1 =>
      'Book at least 1 hour before your arrival time';

  @override
  String get bookingTermsRule2 => 'Please arrive at the time slot you selected';

  @override
  String get bookingTermsRule3 => 'A maximum of 5 minutes late is tolerated';

  @override
  String get bookingTermsRule4 =>
      'Being more than 5 minutes late may cancel your booking automatically';

  @override
  String get bookingTermsOutro =>
      'Please arrive on time so your service can run comfortably and on schedule. Thank you for understanding! 😊';

  @override
  String get bookingTermsAgree => 'I have read the terms';

  @override
  String get bookingNearbyHeadline => 'Pick the Nearest Barberstuff!';

  @override
  String get bookingSearchHint => 'Type here!';

  @override
  String get bookingViewStore => 'View Store';

  @override
  String get bookingStoreEmpty => 'No branch found.';

  @override
  String get bookingCapsterEmpty => 'No barber available at this branch yet.';

  @override
  String get commonContinue => 'Continue';

  @override
  String get bookingScheduleTitle => 'Choose Schedule';

  @override
  String get bookingServiceTitle => 'Choose Service';

  @override
  String get bookingDateLabel => 'Date';

  @override
  String get bookingTimeLabel => 'Time';

  @override
  String get bookingSingleServiceLabel => 'Single Services';

  @override
  String get bookingPackageLabel => 'Packages';

  @override
  String get bookingServiceEmpty => 'No service available yet.';

  @override
  String get bookingSuccessTitle => 'Booking Confirmed!';

  @override
  String get bookingSuccessMessage => 'Your booking has been made successfully';

  @override
  String get bookingSuccessReceipt => 'View Booking Proof';

  @override
  String get bookingSuccessHome => 'Home';

  @override
  String get receiptTitle => 'E-Receipt';

  @override
  String get receiptStore => 'Barber/Salon';

  @override
  String get receiptAddress => 'Address';

  @override
  String get receiptName => 'Name';

  @override
  String get receiptPhone => 'Phone Number';

  @override
  String get receiptDate => 'Booking Date';

  @override
  String get receiptTime => 'Booking Time';

  @override
  String get receiptSpecialist => 'Specialist';

  @override
  String get receiptTotal => 'Total Price';

  @override
  String get receiptDownload => 'Download E-Receipt';

  @override
  String get comingSoonMessage => 'Comming soon!';

  @override
  String get commonRetry => 'Try Again';

  @override
  String get commonUnderstood => 'Oke';

  @override
  String get commonLogout => 'Log out';
}
