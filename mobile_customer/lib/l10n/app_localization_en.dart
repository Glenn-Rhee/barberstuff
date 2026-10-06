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
  String get exceptionRequestRejected =>
      'Your request couldn\'t be processed. Please check your data and try again.';

  @override
  String get serverNoAccess => 'You don\'t have access.';

  @override
  String get serverReadFailed => 'Failed to read the data.';

  @override
  String get serverBadFormat => 'Invalid data format.';

  @override
  String get serverSessionCheckFailed =>
      'Something went wrong while checking your session.';

  @override
  String get serverAccountGone => 'Account not found or has been deleted.';

  @override
  String get serverTokenExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get serverTokenInvalid =>
      'Your session is invalid. Please sign in again.';

  @override
  String get serverBadHeader => 'Invalid request header.';

  @override
  String get serverSystemError => 'A system error occurred.';

  @override
  String get serverDataNotFound => 'Data not found.';

  @override
  String get serverDataGone => 'Data not found or has been deleted.';

  @override
  String get serverDataInvalid => 'Invalid data.';

  @override
  String get serverDataInvalidRelogin => 'Invalid data. Please sign in again.';

  @override
  String get serverDataInvalidContact =>
      'Invalid data. Please contact headquarters.';

  @override
  String get serverLoadFailed => 'Something went wrong while loading the data.';

  @override
  String get serverPhoneFormat =>
      'Invalid phone number, use the format +62xxxx or 08xxxx.';

  @override
  String get serverMinAge => 'You must be at least 6 months old to register.';

  @override
  String get serverOtpSent =>
      'An OTP has been sent to your email. Please check your inbox or spam folder.';

  @override
  String get serverOtpDigitsOnly => 'The OTP may only contain digits 0-9.';

  @override
  String get serverRegisterFailed =>
      'Something went wrong during registration. Please try again later.';

  @override
  String get serverEmailVerifiedBySystem =>
      'This email is already registered and verified.';

  @override
  String get serverEmailVerifiedUsePassword =>
      'This email is already registered and verified. Please sign in with your password.';

  @override
  String get serverEmailVerified =>
      'This email is already registered and verified.';

  @override
  String get serverRegisterAgain =>
      'Your data is no longer valid. Please register again.';

  @override
  String get serverMembershipFailed =>
      'Something went wrong while loading membership data.';

  @override
  String get serverPhoneTaken => 'This phone number is already registered.';

  @override
  String get serverLoginFailed =>
      'Something went wrong while signing in. Please try again later.';

  @override
  String get serverOtpWait => 'Please wait before requesting another OTP.';

  @override
  String get serverOtpExpiredResend =>
      'The OTP has expired. Please resend the OTP.';

  @override
  String get serverOtpExpiredRegister =>
      'The OTP has expired. Please register again or resend the OTP.';

  @override
  String get serverOtpFiveWrong =>
      'You entered a wrong OTP 5 times. Please resend the OTP.';

  @override
  String get serverOtpFiveTries =>
      'You have tried 5 times. Please try again later.';

  @override
  String get serverResetFailed =>
      'Something went wrong while resetting your password.';

  @override
  String get serverResetFailedLater =>
      'Something went wrong while resetting your password. Please try again later.';

  @override
  String get serverEmailNotRegistered => 'This email is not registered.';

  @override
  String get serverEmailUnverifiedReset =>
      'This email isn\'t verified yet, so the password can\'t be reset.';

  @override
  String get serverEmailGoogleReset =>
      'This email signs in with Google, so the password can\'t be reset.';

  @override
  String get serverTooManyAttempts =>
      'Too many attempts. Please try again later.';

  @override
  String get serverEmailUnverifiedLogin =>
      'This email isn\'t verified yet. Please verify it first.';

  @override
  String get serverWrongPassword => 'The password you entered is incorrect.';

  @override
  String get serverAuthFailed => 'Something went wrong during sign-in.';

  @override
  String get serverProviderUnavailable =>
      'This sign-in method is not available.';

  @override
  String get serverGoogleUnverified =>
      'Your email hasn\'t been verified by Google. Please verify it first.';

  @override
  String get serverResetTokenInvalid =>
      'The link or code is invalid or has expired.';

  @override
  String get serverAccountNotFound => 'Your account was not found.';

  @override
  String get serverProfileLoadFailed =>
      'Something went wrong while loading your profile.';

  @override
  String get serverProfileUpdateFailed =>
      'Something went wrong while updating your profile.';

  @override
  String get serverRelogin => 'Your data is invalid. Please sign in again.';

  @override
  String get serverProfileNoChange => 'Change at least one profile field.';

  @override
  String get serverStoreLoadFailed =>
      'Something went wrong while loading the stores.';

  @override
  String get serverBranchNotFound =>
      'The branch you\'re looking for was not found.';

  @override
  String get serverStoreNotFound => 'Store not found.';

  @override
  String get serverStoreGone => 'Store not found or has been deleted.';

  @override
  String get serverStoreDataGone => 'Store not found or has been deleted.';

  @override
  String get serverStoreDataInvalid => 'Invalid store data.';

  @override
  String get serverStoreIdInvalid => 'Invalid store ID.';

  @override
  String get serverCapsterLoadFailed =>
      'Something went wrong while loading the capsters.';

  @override
  String get serverBookingFailed =>
      'Something went wrong while creating the booking.';

  @override
  String get serverBookingFailedLater =>
      'Something went wrong while creating the booking. Please try again later.';

  @override
  String get serverStoreInvalid => 'Invalid store.';

  @override
  String get serverCapsterIdInvalid => 'Invalid capster.';

  @override
  String get serverStoreNotReady => 'This store isn\'t accepting bookings yet.';

  @override
  String get serverBookingPast =>
      'The booking date and time can\'t be in the past.';

  @override
  String get serverBookingMinLead =>
      'Bookings must be at least 30 minutes from now.';

  @override
  String get serverUserInvalid => 'Invalid user.';

  @override
  String get serverUserDataInvalid => 'Invalid user data.';

  @override
  String get serverCapsterGone => 'Capster not found or has been removed.';

  @override
  String get serverCapsterOtherStore =>
      'This capster doesn\'t work at the store you selected.';

  @override
  String get serverBookingExists =>
      'You already have a booking, so you can\'t book again.';

  @override
  String get serverBookingSlotMismatch =>
      'The booking time doesn\'t match the available slots.';

  @override
  String get serverBookingInProgress =>
      'You still have a booking being processed.';

  @override
  String get serverNoCapsterLeft => 'No capsters are available anymore.';

  @override
  String get serverCapsterReserved =>
      'This capster is being reserved for another customer.';

  @override
  String get serverCapsterBusy => 'This capster isn\'t available at that time.';

  @override
  String get serverSlotLocked =>
      'This slot is already being held by someone else.';

  @override
  String get serverLockFirst =>
      'Your slot isn\'t held yet. Please hold a slot first.';

  @override
  String get serverNoLock => 'You haven\'t held a slot yet.';

  @override
  String get serverLockExpired =>
      'Booking not found or the hold time has run out.';

  @override
  String get serverBookingNotYours => 'This booking doesn\'t belong to you.';

  @override
  String get serverCapsterWalkIn =>
      'This capster is reserved for a walk-in customer. Please choose another capster.';

  @override
  String get serverServiceInvalid => 'Invalid service data.';

  @override
  String get serverServiceGone => 'Service not found or has been removed.';

  @override
  String get serverServiceNotInStore =>
      'This store doesn\'t offer that service.';

  @override
  String get serverServiceUnavailable =>
      'This service is no longer available. Please choose again.';

  @override
  String get serverPromoUsed => 'This promo has already been used.';

  @override
  String get serverPromoInvalidNow => 'This promo is no longer valid.';

  @override
  String get serverPromoExpired => 'This promo has expired.';

  @override
  String get serverPromoNotFound => 'Your promo was not found.';

  @override
  String get serverPromoInvalid => 'Invalid promo.';

  @override
  String get serverScheduleLoadFailed =>
      'Something went wrong while loading the store\'s schedule. Please try again later.';

  @override
  String get serverBookingLoadFailed =>
      'Something went wrong while loading your bookings.';

  @override
  String get serverIdentityInvalid => 'Your identity is invalid.';

  @override
  String get serverRatingFailed =>
      'Something went wrong while saving your rating.';

  @override
  String get serverBookingInvalid => 'Invalid booking.';

  @override
  String get serverRatingNeedOne =>
      'Please rate at least one of our store, capster, or staff.';

  @override
  String get serverBookingNotFound => 'Booking not found.';

  @override
  String get serverRatingCashierOnly => 'Only the cashier can be rated.';

  @override
  String get serverFileType => 'This file type isn\'t supported.';

  @override
  String get serverFileMismatch =>
      'The file extension doesn\'t match its content.';

  @override
  String get serverFileEmpty => 'The file is empty.';

  @override
  String get serverFileTooBig => 'The file must be 5 MB or smaller.';

  @override
  String get serverUploadUrlFailed => 'Failed to prepare the upload.';

  @override
  String get serverImageTooBig => 'The image is too large.';

  @override
  String get serverImageKey => 'Invalid image reference.';

  @override
  String get serverImageSaveFailed => 'Failed to save, please check the image.';

  @override
  String serverFieldRequired(String field) {
    return '$field is required.';
  }

  @override
  String serverFieldEmail(String field) {
    return '$field must be a valid email.';
  }

  @override
  String serverFieldNumeric(String field) {
    return '$field must be a number.';
  }

  @override
  String serverFieldMin(String field, String count) {
    return '$field must be at least $count characters.';
  }

  @override
  String serverFieldMax(String field, String count) {
    return '$field must be at most $count characters.';
  }

  @override
  String serverFieldGreater(String field, String count) {
    return '$field must be more than $count characters.';
  }

  @override
  String serverFieldInvalid(String field) {
    return '$field is invalid.';
  }

  @override
  String serverOtpAttemptsLeft(String count) {
    return 'Invalid OTP, please try again. Attempts left: $count.';
  }

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
  String get homeActionPackage => 'Store';

  @override
  String get homeActionPromo => 'Promo';

  @override
  String get homeActionHistory => 'History';

  @override
  String get bookingBranchNewBadge => 'NEW';

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
  String get storeListTitle => 'All Branches';

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
  String get historyTitle => 'Booking History';

  @override
  String get storeDetailTitle => 'Store Detail';

  @override
  String get storeOpen => 'OPEN';

  @override
  String get storeClosed => 'CLOSED';

  @override
  String storeReviewCount(String count) {
    return '($count reviews)';
  }

  @override
  String get storeActionCall => 'Call';

  @override
  String get storeActionRoute => 'Route';

  @override
  String get storeActionShare => 'Share';

  @override
  String get storeBarbers => 'Our Barbers';

  @override
  String get storeSeeAll => 'See All';

  @override
  String get storeTabAbout => 'About Us';

  @override
  String get storeTabService => 'Services';

  @override
  String get storeTabPackage => 'Packages';

  @override
  String get storeTabReview => 'Reviews';

  @override
  String get storeDescription => 'Description';

  @override
  String get storeHours => 'Opening Hours';

  @override
  String get storeHoursEveryday => 'Every day';

  @override
  String get storeAddressTitle => 'Our Address';

  @override
  String get storeSeeMap => 'View on Map';

  @override
  String get storeServicesTitle => 'Our Services';

  @override
  String get storePackagesTitle => 'Our Packages';

  @override
  String get storeReviewsTitle => 'Customer Reviews';

  @override
  String get storeBookNow => 'Book Now';

  @override
  String storeTypeCount(int count) {
    return '$count types';
  }

  @override
  String get storeShareCopied => 'Store info copied to clipboard';

  @override
  String storeShareMessage(String name, String address, String link) {
    return '$name\n$address\n\nSee details & book on BarberStuff:\n$link';
  }

  @override
  String get storeBookCta => 'Book Now';

  @override
  String get storeBookClosed => 'Branch Is Closed';

  @override
  String get storeNoBarber => 'No barber at this branch yet.';

  @override
  String get storeNoService => 'No service yet.';

  @override
  String get storeNoPackage => 'No package yet.';

  @override
  String get storeNoReview => 'No review yet.';

  @override
  String get historyTabUpcoming => 'Upcoming';

  @override
  String get historyTabDone => 'Completed';

  @override
  String get historyTabCanceled => 'Canceled';

  @override
  String get historyBadgeProgress => 'PROGRESS';

  @override
  String get historyBadgeDone => 'DONE';

  @override
  String get historyBadgeCancel => 'CANCEL';

  @override
  String get historyNotReviewed => 'Not reviewed yet';

  @override
  String get historyWriteReview => 'Write Review';

  @override
  String get historySeeReview => 'See Review';

  @override
  String get historyYourReview => 'Your review';

  @override
  String get historyEmpty => 'No booking in this list yet.';

  @override
  String get reviewTitle => 'How was your experience?';

  @override
  String get reviewSubtitle => 'your experience matters a lot to us';

  @override
  String get reviewCapster => 'Capster Service';

  @override
  String get reviewCashier => 'Cashier Service';

  @override
  String get reviewStore => 'Outlet Quality';

  @override
  String get reviewMessageLabel => 'Tell Us About Your Experience';

  @override
  String get reviewMessageHint => 'Write your review here!';

  @override
  String get reviewSubmit => 'Send';

  @override
  String get reviewNeedStars => 'Please rate every category first.';

  @override
  String get reviewThanks => 'Thanks for your review!';

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
  String get notificationChannelName => 'Barberstuff Updates';

  @override
  String get notificationChannelDescription =>
      'Booking, points, and promo updates from Barberstuff.';

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
  String get profileTierSilver => 'Silver Member Barberstuff';

  @override
  String get profileTierGold => 'Gold Member ';

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
  String get personalInfoBirthDateLocked =>
      'Date of birth follows your registration data and cannot be changed';

  @override
  String get personalInfoPasswordTitle => 'My Password';

  @override
  String get personalInfoPasswordSubtitle => 'Change My Password';

  @override
  String get personalInfoPasswordAction => 'Change Now';

  @override
  String get personalInfoSave => 'Save Changes';

  @override
  String get personalInfoSaved => 'Changes saved';

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
  String get bookingTitle => 'Booking';

  @override
  String get bookingBranchTitle => 'Choose Branch';

  @override
  String bookingStepLabel(int current, int total) {
    return 'STEP $current OF $total';
  }

  @override
  String get bookingBranchSubtitle =>
      'Pick the barbershop branch nearest to you';

  @override
  String get bookingScheduleSubtitle => 'Pick an available date and time';

  @override
  String get bookingBarberSubtitle =>
      'Pick your favourite barber or let us choose';

  @override
  String get bookingServiceSubtitle => 'Pick the service you want';

  @override
  String get bookingConfirmTitle => 'Booking Confirmation';

  @override
  String get bookingDetailTitle => 'Booking Details';

  @override
  String get bookingConfirmSubtitle => 'Please review your order details';

  @override
  String get bookingNextSchedule => 'Next: Pick Schedule';

  @override
  String get bookingNextBarber => 'Next: Pick Barber';

  @override
  String get bookingNextService => 'Next: Pick Service';

  @override
  String get bookingNextConfirm => 'Next: Confirm Booking';

  @override
  String get bookingConfirmCta => 'Confirm Order';

  @override
  String get bookingSlotFullNote => 'Slots you cannot pick are already full';

  @override
  String get bookingSlotEmpty => 'No time slot available on this date.';

  @override
  String get bookingSlotTooSoon =>
      'Booking must be at least 30 minutes from now.';

  @override
  String get bookingTabService => 'Service';

  @override
  String get bookingAvailableToday => 'Available today';

  @override
  String bookingLockRemaining(String time) {
    return 'Time left $time';
  }

  @override
  String get bookingLockExpired =>
      'Your hold expired. Please pick a schedule again.';

  @override
  String get bookingCancelTitle => 'Cancel booking?';

  @override
  String get bookingCancelMessage =>
      'The slot you are holding will be released and someone else can take it.';

  @override
  String get bookingCancelConfirm => 'Yes, cancel';

  @override
  String get bookingReleaseFailed =>
      'The barber slot has not been released yet. Wait a moment, then tap Continue again.';

  @override
  String get bookingCancelKeep => 'Keep booking';

  @override
  String get bookingConfirmBranch => 'BRANCH';

  @override
  String get bookingConfirmService => 'SERVICE';

  @override
  String get bookingConfirmBarber => 'BARBER';

  @override
  String get bookingConfirmSchedule => 'TIME & DATE';

  @override
  String get bookingPaymentTitle => 'Payment Details';

  @override
  String get bookingSubtotal => 'Subtotal';

  @override
  String get bookingAppFee => 'App Service Fee';

  @override
  String get bookingTotal => 'Total Payment';

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
  String get bookingServiceSingleOnly =>
      'We apologize, but we can only accept one service per booking. Please select one first; book the rest separately.';

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
  String get offlineCachedData => 'You are offline — showing saved data';

  @override
  String get permissionNotificationTitle => 'Allow notifications';

  @override
  String get permissionNotificationMessage =>
      'Turn on notifications so you know when a booking is confirmed and points are added.';

  @override
  String get permissionLocationTitle => 'Allow location';

  @override
  String get permissionLocationMessage =>
      'Location is used to sort branches from the nearest to you.';

  @override
  String get permissionOpenSettings => 'Open Settings';

  @override
  String get permissionLater => 'Not now';

  @override
  String get permissionLocationOffTitle => 'Turn on location';

  @override
  String get permissionLocationOffMessage =>
      'Location services are off on your phone. Turn them on so branch distance can be calculated.';

  @override
  String get permissionOpenLocationSettings => 'Turn On Location';

  @override
  String get commonUnderstood => 'Oke';

  @override
  String get commonLogout => 'Log out';

  @override
  String get promoTitle => 'Choose Promo';

  @override
  String get promoGradeTitle => 'This Grade\'s Perks';

  @override
  String get promoTerms => 'T&C Apply';

  @override
  String get promoSectionTitle => 'Promo';

  @override
  String get promoSectionSubtitle => 'Deals from barberstuff, for members';

  @override
  String get promoRedeemTitle => 'Redeem Points';

  @override
  String get promoRedeemSubtitle =>
      'Trade your points for a range of vouchers.';

  @override
  String get promoClaim => 'Claim';

  @override
  String get promoClaimReward => 'Claim Reward';

  @override
  String get promoAboutVoucher => 'About This Voucher';

  @override
  String get promoClaimed => 'Reward claimed.';

  @override
  String get promoNotEnoughPoints => 'Not enough points for this reward yet.';

  @override
  String get promoBenefitPointsTitle => 'Regular A-Points';

  @override
  String get promoBenefitPointsDesc =>
      'Earn regular point cashback of up to 5% on every partner merchant transaction.';

  @override
  String get promoBenefitMerchantTitle => 'Merchant Deals';

  @override
  String get promoBenefitMerchantDesc =>
      'Exclusive discounts of up to 30% at selected restaurants, cafés, and favorite outlets.';

  @override
  String get promoBenefitVoucherTitle => 'Holiday Special Voucher';

  @override
  String get promoBenefitVoucherDesc =>
      'Get a shopping voucher worth Rp100,000 on special occasions.';

  @override
  String get promoBannerCashbackTitle => '20% Cashback';

  @override
  String get promoBannerCashbackSubtitle => 'For all services';

  @override
  String get promoBannerCashbackFootnote => 'Min. transaction Rp150,000';

  @override
  String get promoBannerBundleTitle => 'Value Bundle';

  @override
  String get promoBannerBundleSubtitle => '5x Haircut';

  @override
  String get promoBannerBundleFootnote => 'Save up to 15%';

  @override
  String get promoRewardHalfOffTitle => '50% Off Haircut';

  @override
  String get promoRewardHalfOffDesc =>
      'Get exclusive access to discounts on selected haircut and beard care services. Enjoy the best cuts straight from our professional barbers, with premium service standards.';

  @override
  String get promoRewardPriorityTitle => 'Priority Haircut Queue';

  @override
  String get promoRewardPriorityDesc =>
      'Skip the queue and get served right away at your chosen branch. Valid for one visit during regular opening hours.';

  @override
  String get promoRewardWashTitle => 'Free Hair Wash & Hair Tonic';

  @override
  String get promoRewardWashDesc =>
      'A free hair wash and hair tonic with every haircut. Valid at all Barberstuff branches.';

  @override
  String promoPoints(String count) {
    return '$count Points';
  }

  @override
  String promoXp(String count) {
    return '$count XP';
  }

  @override
  String promoProgress(String owned, String needed) {
    return '$owned/$needed';
  }
}
