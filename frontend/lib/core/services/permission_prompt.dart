import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_barberstuff/core/services/local_notification_service.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
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

  static Future<void> askLocation(BuildContext context) async {
    LocationPermission permission;

    try {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
    } on Object catch (error) {
      debugPrint('PermissionPrompt lokasi gagal: $error');
      return;
    }

    final bool granted =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    if (!granted) {
      if (_locationDialogShown) return;
      if (!context.mounted) return;

      _locationDialogShown = true;
      final AppLocalizations l10n = AppLocalizations.of(context);
      await _showSettingsDialog(
        context,
        title: l10n.permissionLocationTitle,
        message: l10n.permissionLocationMessage,
        actionLabel: l10n.permissionOpenSettings,
        target: _SettingsTarget.app,
      );
      return;
    }

    bool serviceOn = true;
    try {
      serviceOn = await Geolocator.isLocationServiceEnabled();
    } on Object catch (error) {
      debugPrint('PermissionPrompt cek GPS gagal: $error');
    }

    if (!serviceOn) {
      if (!context.mounted) return;
      final AppLocalizations l10n = AppLocalizations.of(context);
      await _showSettingsDialog(
        context,
        title: l10n.permissionLocationOffTitle,
        message: l10n.permissionLocationOffMessage,
        actionLabel: l10n.permissionOpenLocationSettings,
        target: _SettingsTarget.location,
      );
      return;
    }

    if (!context.mounted) return;
    await _read<LocationService>(context)?.current();
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

  static Future<void> _showSettingsDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String actionLabel,
    required _SettingsTarget target,
  }) async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool? openSettings = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: AppColor.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: AppTextStyle.titleMedium),
        content: Text(
          message,
          style: AppTextStyle.bodyMedium.copyWith(color: AppColor.inkSoft),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n.permissionLater,
              style: AppTextStyle.labelMedium.copyWith(color: AppColor.inkSoft),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              actionLabel,
              style: AppTextStyle.labelMedium.copyWith(
                color: AppColor.goldDeep,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (openSettings != true) return;

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
