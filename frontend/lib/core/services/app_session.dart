import 'package:shared_preferences/shared_preferences.dart';

class AppSession {
  static const String _emailKey = 'remembered_email';

  String? _rememberedEmail;

  String? get rememberedEmail => _rememberedEmail;

  Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _rememberedEmail = prefs.getString(_emailKey);
  }

  Future<void> rememberEmail(String? email) async {
    _rememberedEmail = email;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (email == null || email.isEmpty) {
      await prefs.remove(_emailKey);
      return;
    }
    await prefs.setString(_emailKey, email);
  }
}
