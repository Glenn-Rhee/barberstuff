import 'package:mobile_barberstuff/features/booking/presentation/provider/booking_flow_provider.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

/// Teks yang tampil untuk tiap langkah booking.
extension BookingStepLabels on BookingStep {
  /// Judul besar di atas isi langkah.
  String heading(AppLocalizations l10n) {
    switch (this) {
      case BookingStep.terms:
      case BookingStep.branch:
        return l10n.bookingBranchTitle;
      case BookingStep.schedule:
        return l10n.bookingScheduleTitle;
      case BookingStep.capster:
        return l10n.bookingBarberTitle;
      case BookingStep.service:
        return l10n.bookingServiceTitle;
      case BookingStep.confirm:
        return l10n.bookingConfirmTitle;
    }
  }

  /// Penjelasan singkat di bawah judul.
  String subtitle(AppLocalizations l10n) {
    switch (this) {
      case BookingStep.terms:
      case BookingStep.branch:
        return l10n.bookingBranchSubtitle;
      case BookingStep.schedule:
        return l10n.bookingScheduleSubtitle;
      case BookingStep.capster:
        return l10n.bookingBarberSubtitle;
      case BookingStep.service:
        return l10n.bookingServiceSubtitle;
      case BookingStep.confirm:
        return l10n.bookingConfirmSubtitle;
    }
  }

  /// Label tombol utama di bawah layar.
  String cta(AppLocalizations l10n) {
    switch (this) {
      case BookingStep.terms:
        return l10n.commonContinue;
      case BookingStep.branch:
        return l10n.bookingNextSchedule;
      case BookingStep.schedule:
        return l10n.bookingNextBarber;
      case BookingStep.capster:
        return l10n.bookingNextService;
      case BookingStep.service:
        return l10n.bookingNextConfirm;
      case BookingStep.confirm:
        return l10n.bookingConfirmCta;
    }
  }
}
