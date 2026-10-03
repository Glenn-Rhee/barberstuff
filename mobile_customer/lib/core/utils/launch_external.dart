import 'package:url_launcher/url_launcher.dart';

/// Buka [uri] di aplikasi lain (telepon, peta, browser). Gagal membuka
/// tidak dianggap error: user cukup tidak dibawa ke mana-mana.
Future<void> launchExternal(Uri uri) async {
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Object catch (_) {
    return;
  }
}
