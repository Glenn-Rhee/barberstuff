import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalController extends ChangeNotifier {
  static const _prefsKey = 'app_locale';
  static const supported = ['id', 'en'];

  Locale _locale = const Locale('id');
  Locale get locale => _locale;

  // Dipanggil sekali saat app start, membaca pilihan yang tersimpan.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null && supported.contains(saved)) {
      _locale = Locale(saved);
      notifyListeners();
    }
  }

  // Dipanggil saat user milih bahasa
  Future<void> setLocale(String code) async {
    if (!supported.contains(code)) return;
    if (_locale.languageCode == code) return;

    _locale = Locale(code);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, code);
  }
}
