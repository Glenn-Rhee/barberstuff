import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

/// Sisa waktu kunci slot di pojok AppBar. Berubah merah di menit terakhir.
class BookingLockCountdown extends StatelessWidget {
  const BookingLockCountdown({super.key, required this.remaining});

  final Duration remaining;

  /// mm:ss, misalnya 04:59.
  static String format(Duration value) {
    final String m = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String s = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool urgent = remaining.inSeconds <= 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: urgent
            ? AppColor.danger.withValues(alpha: 0.1)
            : AppColor.goldSoft.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        l10n.bookingLockRemaining(format(remaining)),
        style: AppTextStyle.labelSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: urgent ? AppColor.danger : AppColor.ink,
        ),
      ),
    );
  }
}
