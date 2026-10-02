import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  const TokenStorage();

  static const _key = 'access_token';

  // Membaca token dari SharedPreferences
  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(_key);

  // Menyimpan token ke SharedPreferences
  Future<void> save(String token) async =>
      (await SharedPreferences.getInstance()).setString(_key, token);

  // Menghapus token dari SharedPreferences
  Future<void> delete() async =>
      (await SharedPreferences.getInstance()).remove(_key);
}
