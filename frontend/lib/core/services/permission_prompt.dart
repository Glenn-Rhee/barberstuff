import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_barberstuff/core/services/local_notification_service.dart';
import 'package:mobile_barberstuff/core/services/location_service.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

class PermissionPrompt {
  const PermissionPrompt._();

  static Future<void> askNotification(BuildContext context) async {
    final LocalNotificationService? service = _read<LocalNotificationService>(
      context,
    );
    if (service == null) return;

    if (await service.isEnabled()) return;

    await service.requestPermission();
    if (await service.isEnabled()) return;
    if (!context.mounted) return;

    final AppLocalizations l10n = AppLocalizations.of(context);
    await _showSettingsDialog(
      context,
      title: l10n.permissionNotificationTitle,
      message: l10n.permissionNotificationMessage,
    );
  }

  static Future<void> askLocation(BuildContext context) async {
    final LocationService? service = _read<LocationService>(context);
    if (service == null) return;

    await service.current(prompt: true);

    final LocationPermission permission = await _permission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return;
    }
    if (!context.mounted) return;

    final AppLocalizations l10n = AppLocalizations.of(context);
    await _showSettingsDialog(
      context,
      title: l10n.permissionLocationTitle,
      message: l10n.permissionLocationMessage,
    );
  }

  static Future<LocationPermission> _permission() async {
    try {
      return await Geolocator.checkPermission();
    } on Object catch (_) {
      return LocationPermission.denied;
    }
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
              style: AppTextStyle.labelMedium.copyWith(
                color: AppColor.inkSoft,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.permissionOpenSettings,
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
      await Geolocator.openAppSettings();
    } on Object catch (_) {
      return;
    }
  }
}
