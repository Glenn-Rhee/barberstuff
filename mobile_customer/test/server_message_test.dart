import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_barberstuff/core/network/api_exception.dart';
import 'package:mobile_barberstuff/core/network/api_exception_message.dart';
import 'package:mobile_barberstuff/core/network/server_message.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

void main() {
  final AppLocalizations en = lookupAppLocalizations(const Locale('en'));
  final AppLocalizations id = lookupAppLocalizations(const Locale('id'));

  test('pesan backend yang dikenal diterjemahkan', () {
    expect(
      ServerMessage.translate('Booking minimal 30 menit dari sekarang.', en),
      'Bookings must be at least 30 minutes from now.',
    );
    // Beda tanda baca / huruf besar tetap cocok
    expect(
      ServerMessage.translate('anda tidak memiliki akses', en),
      "You don't have access.",
    );
  });

  test('pesan dinamis: nama field dan angka', () {
    expect(
      ServerMessage.translate('PhoneNumber wajib diisi', en),
      'Phone number is required.',
    );
    expect(
      ServerMessage.translate('Password minimal 8 karakter', en),
      'Password must be at least 8 characters.',
    );
    expect(
      ServerMessage.translate(
        'OTP tidak valid, silahkan coba lagi. Sisa percobaan 2 kali',
        en,
      ),
      'Invalid OTP, please try again. Attempts left: 2.',
    );
  });

  test('pesan belum dikenal tidak ditebak', () {
    expect(ServerMessage.translate('Pesan baru dari backend', en), isNull);
    // Bukan nama field (ada spasi), jangan jadi "Format id toko is invalid"
    expect(ServerMessage.translate('Format id toko tidak valid!', en), isNull);
  });

  test('semua key server* di ARB ada di daftar terjemahan', () {
    final Map<String, dynamic> idArb = _arb('lib/l10n/app_id.arb');
    final Map<String, dynamic> enArb = _arb('lib/l10n/app_en.arb');
    final Iterable<String> keys = idArb.keys.where(
      (String k) => k.startsWith('server') && !idArb.containsKey('@$k'),
    );
    expect(keys, isNotEmpty);
    for (final String key in keys) {
      expect(
        ServerMessage.translate(idArb[key] as String, en),
        enArb[key],
        reason: key,
      );
    }
  });

  test('ApiException: Indonesia apa adanya, English diterjemahkan', () {
    const ApiException known = ApiException(
      ApiErrorType.server,
      statusCode: 400,
      rawMessage: 'Password yang anda masukkan salah.',
    );
    expect(known.message(id), 'Password yang anda masukkan salah.');
    expect(known.message(en), 'The password you entered is incorrect.');

    const ApiException unknown = ApiException(
      ApiErrorType.server,
      statusCode: 400,
      rawMessage: 'Pesan baru dari backend',
    );
    expect(unknown.message(id), 'Pesan baru dari backend');
    expect(unknown.message(en), en.exceptionRequestRejected);
  });
}

Map<String, dynamic> _arb(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
