import 'package:flutter/foundation.dart';
import 'package:tablet_dashboard/core/network/api_client.dart';
import 'package:tablet_dashboard/core/network/api_exception.dart';
import 'package:tablet_dashboard/core/storage/token_storage.dart';
import 'package:tablet_dashboard/features/auth/login/data/auth_api.dart';
import 'package:tablet_dashboard/features/auth/login/domain/entities/staff_profile.dart';

// Sesi login: token, profil, dan toko tempat staff bekerja
class SessionController extends ChangeNotifier {
  SessionController(
    this._auth,
    this._client, [
    this._storage = const TokenStorage(),
  ]);

  static const noAccessMessage = 'Akun ini tidak punya akses ke tablet';

  final AuthApi _auth;

  // Semua API pakai client ini, jadi token di sini dipakai di semua request
  final ApiClient _client;
  final TokenStorage _storage;

  StaffProfile? profile;
  String? role;

  // true selama cek token lama saat aplikasi dibuka
  bool restoring = true;
  bool busy = false;

  bool get signedIn => profile != null;
  String get storeId => profile?.storeId ?? '';
  StaffRole? get staffRole => profile?.staffRole;

  // Pakai token sesi sebelumnya supaya tidak login ulang tiap buka aplikasi
  Future<void> restore() async {
    try {
      final token = await _storage.read();
      if (token != null && token.isNotEmpty) {
        _client.token = token;
        final fetched = await _auth.profile();
        if (fetched.staffRole == null) {
          await _clear();
        } else {
          profile = fetched;
          role = fetched.role;
        }
      }
    } on ApiException {
      // Token kadaluarsa / dicabut, minta login ulang
      _client.token = null;
    } finally {
      restoring = false;
      notifyListeners();
    }
  }

  // Balikin pesan error, atau null kalau berhasil login
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    busy = true;
    notifyListeners();
    try {
      final login = await _auth.login(email: email, password: password);
      _client.token = login.token;
      final fetched = await _auth.profile();
      if (fetched.staffRole == null) {
        await _clear();
        return noAccessMessage;
      }
      profile = fetched;
      role = fetched.role;
      await _storage.save(login.token);
      return null;
    } on ApiException catch (e) {
      _client.token = null;
      profile = null;
      return e.message;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  // Reset password tanpa OTP lewat PATCH /staff/{id}. Balikin error, null = berhasil
  Future<String?> resetPassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final login = await _auth.login(email: email, password: oldPassword);
      _client.token = login.token;
      final staff = await _auth.profile();
      if (staff.staffRole == null) return noAccessMessage;
      await _auth.updateAccount(
        staffId: staff.id,
        name: staff.name,
        password: newPassword,
      );
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      // Token sementara, staff tetap harus login ulang pakai password baru
      _client.token = null;
    }
  }

  // hapus token, profile, role, dan storage saat sign out
  Future<void> signOut() async {
    await _clear();
    notifyListeners();
  }

  Future<void> _clear() async {
    _client.token = null;
    profile = null;
    role = null;
    await _storage.delete();
  }
}
