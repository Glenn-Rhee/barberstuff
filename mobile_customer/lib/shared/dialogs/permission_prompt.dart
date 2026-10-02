import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_barberstuff/core/services/local_notification_service.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/dialogs/confirm_dialog.dart';
import 'package:provider/provider.dart';

enum _SettingsTarget { app, location }

class PermissionPrompt {
  const PermissionPrompt._();

  static bool _notificationDialogShown = false;
  static bool _locationDialogShown = false;

  static Future<void> askNotification(BuildContext context) async {
    final LocalNotificationService? service = _read<LocalNotificationService>(
      context,
    );
    if (service == null) return;

    if (await service.isEnabled()) return;

    await service.requestPermission();
    if (await service.isEnabled()) return;
    if (_notificationDialogShown) return;
    if (!context.mounted) return;

    _notificationDialogShown = true;
    final AppLocalizations l10n = AppLocalizations.of(context);
    await _showSettingsDialog(
      context,
      title: l10n.permissionNotificationTitle,
      message: l10n.permissionNotificationMessage,
      actionLabel: l10n.permissionOpenSettings,
      target: _SettingsTarget.app,
    );
  }

  /// Sapaan sekali di awal: minta izin lokasi, lalu cek GPS. Dialog
  /// "buka setelan" untuk izin yang ditolak cuma muncul sekali per sesi.
  static Future<void> askLocation(BuildContext context) async {
    final bool? granted = await _requestLocationPermission();
    if (granted == null) return;

    if (!granted) {
      if (_locationDialogShown || !context.mounted) return;
      _locationDialogShown = true;
      await _showLocationDeniedDialog(context);
      return;
    }

    if (!await _isGpsOn()) {
      if (!context.mounted) return;
      await _showGpsOffDialog(context);
      return;
    }

    if (!context.mounted) return;
    await _read<LocationService>(context)?.current();
  }

  /// Dipakai fitur yang memang butuh lokasi, misalnya pintasan Paket.
  /// Beda dengan [askLocation] yang cuma menyapa sekali di awal: ini
  /// bertanya setiap kali dipanggil sampai izinnya benar-benar diberi,
  /// dan mengembalikan true kalau lokasi sudah siap dipakai.
  static Future<bool> ensureLocation(BuildContext context) async {
    final bool? granted = await _requestLocationPermission();
    if (granted == null) return false;

    if (!granted) {
      // Sengaja tidak dikunci _locationDialogShown: pengguna menekan fitur
      // yang mustahil jalan tanpa lokasi, jadi wajar ditanya lagi.
      if (context.mounted) await _showLocationDeniedDialog(context);
      return false;
    }

    if (await _isGpsOn()) return true;

    if (context.mounted) await _showGpsOffDialog(context);
    return false;
  }

  static void allowDialogsAgain() {
    _notificationDialogShown = false;
    _locationDialogShown = false;
  }

  static T? _read<T>(BuildContext context) {
    try {
      return context.read<T>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  /// true = izin lokasi diberi, false = ditolak, null = plugin gagal
  /// (misalnya perangkat tanpa layanan lokasi).
  static Future<bool?> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } on Object catch (error) {
      debugPrint('PermissionPrompt izin lokasi gagal: $error');
      return null;
    }
  }

  /// Kalau pengecekan gagal, anggap GPS menyala supaya tidak ada dialog palsu.
  static Future<bool> _isGpsOn() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } on Object catch (error) {
      debugPrint('PermissionPrompt cek GPS gagal: $error');
      return true;
    }
  }

  static Future<void> _showLocationDeniedDialog(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _showSettingsDialog(
      context,
      title: l10n.permissionLocationTitle,
      message: l10n.permissionLocationMessage,
      actionLabel: l10n.permissionOpenSettings,
      target: _SettingsTarget.app,
    );
  }

  static Future<void> _showGpsOffDialog(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _showSettingsDialog(
      context,
      title: l10n.permissionLocationOffTitle,
      message: l10n.permissionLocationOffMessage,
      actionLabel: l10n.permissionOpenLocationSettings,
      target: _SettingsTarget.location,
    );
  }

  static Future<void> _showSettingsDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String actionLabel,
    required _SettingsTarget target,
  }) async {
    final bool openSettings = await showConfirmDialog(
      context,
      title: title,
      message: message,
      cancelLabel: AppLocalizations.of(context).permissionLater,
      confirmLabel: actionLabel,
    );

    if (!openSettings) return;

    try {
      if (target == _SettingsTarget.location) {
        await Geolocator.openLocationSettings();
      } else {
        await Geolocator.openAppSettings();
      }
    } on Object catch (error) {
      debugPrint('PermissionPrompt buka setelan gagal: $error');
    }
  }
}
