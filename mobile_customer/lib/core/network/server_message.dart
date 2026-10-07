import 'package:flutter/widgets.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

/// Terjemahan pesan error dari backend untuk bahasa selain Indonesia.
///
/// Backend selalu mengirim bahasa Indonesia. Tiap pesan punya key `server*`
/// di ARB: teks di app_id.arb harus sama dengan kalimat backend (dibandingkan
/// tanpa beda huruf besar dan tanda baca di akhir), app_en.arb berisi
/// terjemahannya. Kalau backend mengubah kalimat, perbarui app_id.arb.
class ServerMessage {
  const ServerMessage._();

  /// Terjemahan [raw] ke bahasa [l10n], null kalau pesan belum dikenal.
  static String? translate(String raw, AppLocalizations l10n) {
    final String Function(AppLocalizations)? exact =
        _exactIndex[_normalize(raw)];
    if (exact != null) return exact(l10n);

    final String text = _trimEnd(raw);
    for (final _Pattern pattern in _patterns) {
      final String? translated = pattern.translate(text, l10n);
      if (translated != null) return translated;
    }
    return null;
  }

  // Teks backend diambil dari app_id.arb
  static final AppLocalizations _id = lookupAppLocalizations(
    const Locale('id'),
  );

  static final Map<String, String Function(AppLocalizations)> _exactIndex =
      <String, String Function(AppLocalizations)>{
        for (final String Function(AppLocalizations) message in _exact)
          _normalize(message(_id)): message,
      };

  // Huruf kecil, spasi rapi, tanpa tanda baca di akhir
  static String _normalize(String text) => _trimEnd(text).toLowerCase();

  static String _trimEnd(String text) => text
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceFirst(RegExp(r'[\s.!?]+$'), '');

  static final List<String Function(AppLocalizations)> _exact =
      <String Function(AppLocalizations)>[
        (l) => l.serverNoAccess,
        (l) => l.serverReadFailed,
        (l) => l.serverBadFormat,
        (l) => l.serverSessionCheckFailed,
        (l) => l.serverAccountGone,
        (l) => l.serverTokenExpired,
        (l) => l.serverTokenInvalid,
        (l) => l.serverBadHeader,
        (l) => l.serverSystemError,
        (l) => l.serverDataNotFound,
        (l) => l.serverDataGone,
        (l) => l.serverDataInvalid,
        (l) => l.serverDataInvalidRelogin,
        (l) => l.serverDataInvalidContact,
        (l) => l.serverLoadFailed,
        (l) => l.serverPhoneFormat,
        (l) => l.serverMinAge,
        (l) => l.serverOtpSent,
        (l) => l.serverOtpDigitsOnly,
        (l) => l.serverRegisterFailed,
        (l) => l.serverEmailVerifiedBySystem,
        (l) => l.serverEmailVerifiedUsePassword,
        (l) => l.serverEmailVerified,
        (l) => l.serverRegisterAgain,
        (l) => l.serverMembershipFailed,
        (l) => l.serverPhoneTaken,
        (l) => l.serverLoginFailed,
        (l) => l.serverOtpWait,
        (l) => l.serverOtpExpiredResend,
        (l) => l.serverOtpExpiredRegister,
        (l) => l.serverOtpFiveWrong,
        (l) => l.serverOtpFiveTries,
        (l) => l.serverResetFailed,
        (l) => l.serverResetFailedLater,
        (l) => l.serverEmailNotRegistered,
        (l) => l.serverEmailUnverifiedReset,
        (l) => l.serverEmailGoogleReset,
        (l) => l.serverTooManyAttempts,
        (l) => l.serverEmailUnverifiedLogin,
        (l) => l.serverWrongPassword,
        (l) => l.serverAuthFailed,
        (l) => l.serverProviderUnavailable,
        (l) => l.serverGoogleUnverified,
        (l) => l.serverResetTokenInvalid,
        (l) => l.serverAccountNotFound,
        (l) => l.serverProfileLoadFailed,
        (l) => l.serverProfileUpdateFailed,
        (l) => l.serverRelogin,
        (l) => l.serverProfileNoChange,
        (l) => l.serverStoreLoadFailed,
        (l) => l.serverBranchNotFound,
        (l) => l.serverStoreNotFound,
        (l) => l.serverStoreGone,
        (l) => l.serverStoreDataGone,
        (l) => l.serverStoreDataInvalid,
        (l) => l.serverStoreIdInvalid,
        (l) => l.serverCapsterLoadFailed,
        (l) => l.serverBookingFailed,
        (l) => l.serverBookingFailedLater,
        (l) => l.serverStoreInvalid,
        (l) => l.serverCapsterIdInvalid,
        (l) => l.serverStoreNotReady,
        (l) => l.serverBookingPast,
        (l) => l.serverBookingMinLead,
        (l) => l.serverUserInvalid,
        (l) => l.serverUserDataInvalid,
        (l) => l.serverCapsterGone,
        (l) => l.serverCapsterOtherStore,
        (l) => l.serverBookingExists,
        (l) => l.serverBookingSlotMismatch,
        (l) => l.serverBookingInProgress,
        (l) => l.serverNoCapsterLeft,
        (l) => l.serverCapsterReserved,
        (l) => l.serverCapsterBusy,
        (l) => l.serverSlotLocked,
        (l) => l.serverLockFirst,
        (l) => l.serverNoLock,
        (l) => l.serverLockExpired,
        (l) => l.serverBookingNotYours,
        (l) => l.serverCapsterWalkIn,
        (l) => l.serverServiceInvalid,
        (l) => l.serverServiceGone,
        (l) => l.serverServiceNotInStore,
        (l) => l.serverServiceUnavailable,
        (l) => l.serverPromoUsed,
        (l) => l.serverPromoInvalidNow,
        (l) => l.serverPromoExpired,
        (l) => l.serverPromoNotFound,
        (l) => l.serverPromoInvalid,
        (l) => l.serverScheduleLoadFailed,
        (l) => l.serverBookingLoadFailed,
        (l) => l.serverIdentityInvalid,
        (l) => l.serverRatingFailed,
        (l) => l.serverBookingInvalid,
        (l) => l.serverRatingNeedOne,
        (l) => l.serverBookingNotFound,
        (l) => l.serverRatingCashierOnly,
        (l) => l.serverFileType,
        (l) => l.serverFileMismatch,
        (l) => l.serverFileEmpty,
        (l) => l.serverFileTooBig,
        (l) => l.serverUploadUrlFailed,
        (l) => l.serverImageTooBig,
        (l) => l.serverImageKey,
        (l) => l.serverImageSaveFailed,
      ];

  // Pesan dengan bagian dinamis (nama field, angka)
  static final List<_Pattern> _patterns = <_Pattern>[
    _Pattern((l, a, _) => l.serverFieldRequired(a), <_Arg>[_Arg.field]),
    _Pattern((l, a, _) => l.serverFieldEmail(a), <_Arg>[_Arg.field]),
    _Pattern((l, a, _) => l.serverFieldNumeric(a), <_Arg>[_Arg.field]),
    _Pattern((l, a, b) => l.serverFieldMin(a, b), <_Arg>[
      _Arg.field,
      _Arg.number,
    ]),
    _Pattern((l, a, b) => l.serverFieldMax(a, b), <_Arg>[
      _Arg.field,
      _Arg.number,
    ]),
    _Pattern((l, a, b) => l.serverFieldGreater(a, b), <_Arg>[
      _Arg.field,
      _Arg.number,
    ]),
    _Pattern((l, a, _) => l.serverFieldInvalid(a), <_Arg>[_Arg.field]),
    _Pattern((l, a, _) => l.serverOtpAttemptsLeft(a), <_Arg>[_Arg.number]),
  ];
}

enum _Arg {
  // Nama field struct Go, mis. PhoneNumber
  field(r'([A-Z][A-Za-z0-9_]*)'),
  number(r'(\d+)');

  const _Arg(this.regex);

  final String regex;
}

/// Satu pesan dinamis. Polanya dibuat dari teks app_id.arb dengan penanda
/// di tempat argumen [build] (a = argumen pertama, b = kedua).
class _Pattern {
  _Pattern(this.build, this.kinds);

  static const String _a = '\u0001';
  static const String _b = '\u0002';

  final String Function(AppLocalizations l10n, String a, String b) build;
  final List<_Arg> kinds;

  // Regex + urutan argumen (0 = a, 1 = b) untuk tiap grup
  late final (RegExp, List<int>) _compiled = _compile();

  (RegExp, List<int>) _compile() {
    final String template = ServerMessage._trimEnd(
      build(ServerMessage._id, _a, _b),
    );
    final StringBuffer pattern = StringBuffer('^');
    final StringBuffer literal = StringBuffer();
    final List<int> order = <int>[];
    for (final String char in template.split('')) {
      final int index = char == _a ? 0 : (char == _b ? 1 : -1);
      if (index < 0) {
        literal.write(char);
        continue;
      }
      pattern
        ..write(RegExp.escape(literal.toString()))
        ..write(kinds[index].regex);
      literal.clear();
      order.add(index);
    }
    pattern
      ..write(RegExp.escape(literal.toString()))
      ..write(r'$');
    return (RegExp(pattern.toString()), order);
  }

  String? translate(String text, AppLocalizations l10n) {
    final (RegExp regex, List<int> order) = _compiled;
    final RegExpMatch? match = regex.firstMatch(text);
    if (match == null) return null;
    final List<String> args = <String>['', ''];
    for (int group = 0; group < order.length; group++) {
      final int index = order[group];
      final String value = match.group(group + 1) ?? '';
      args[index] = kinds[index] == _Arg.field ? _humanize(value) : value;
    }
    return build(l10n, args[0], args[1]);
  }

  // PhoneNumber -> Phone number
  static String _humanize(String field) {
    final List<String> words = field.split(RegExp(r'(?<=[a-z0-9])(?=[A-Z])'));
    return <String>[
      words.first,
      for (final String word in words.skip(1)) word.toLowerCase(),
    ].join(' ');
  }
}
