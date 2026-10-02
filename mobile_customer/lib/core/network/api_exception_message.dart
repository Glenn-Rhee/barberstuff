import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

extension ApiExceptionMessage on ApiException {
  String message(AppLocalizations l10n) {
    final String raw = rawMessage?.trim() ?? '';
    if (raw.isNotEmpty) return raw;

    switch (type) {
      case ApiErrorType.timeout:
        return l10n.exceptionReceiveTimeout;
      case ApiErrorType.connection:
        return l10n.exceptionConnectionError;
      case ApiErrorType.server:
        return l10n.exceptionDefaultType;
      case ApiErrorType.google:
        return l10n.googleSignInFailed;
      case ApiErrorType.unknown:
        return l10n.exceptionDefault;
    }
  }
}
