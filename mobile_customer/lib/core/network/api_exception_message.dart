import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/core/network/server_message.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

extension ApiExceptionMessage on ApiException {
  String message(AppLocalizations l10n) {
    final String raw = rawMessage?.trim() ?? '';
    if (raw.isNotEmpty) {
      // Pesan backend selalu bahasa Indonesia
      if (l10n.localeName.startsWith('id')) return raw;
      final String? translated = ServerMessage.translate(raw, l10n);
      if (translated != null) return translated;
      // Pesan belum dikenal: jangan tampilkan bahasa Indonesia
      final int code = statusCode ?? 0;
      if (code >= 400 && code < 500) return l10n.exceptionRequestRejected;
    }

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
