import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/services/image_picker_service.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/auth/presentation/provider/avatar_form_mixin.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/app_toast.dart';
import 'package:provider/provider.dart';

enum _SheetAction { camera, gallery, remove }

/// Alur lengkap saat badge pensil pada avatar ditekan: pilih sumber, ambil
/// gambar, lalu simpan ke [state]. Dipakai halaman registrasi maupun
/// lengkapi profil supaya perilakunya persis sama di keduanya.
Future<void> editAvatar(BuildContext context, AvatarFormMixin state) async {
  final ImagePickerService picker = context.read<ImagePickerService>();
  final _SheetAction? action = await _showSourceSheet(
    context,
    canRemove: state.hasAvatar,
  );

  if (action == null || !context.mounted) return;

  if (action == _SheetAction.remove) {
    state.clearImage();
    return;
  }

  final AppLocalizations l10n = AppLocalizations.of(context);

  try {
    final File? file = await picker.pick(
      action == _SheetAction.camera
          ? AvatarSource.camera
          : AvatarSource.gallery,
    );
    if (file != null) state.setImageFile(file);
  } on ImagePickerFailure catch (e) {
    if (!context.mounted) return;
    AppToast.show(
      context,
      message: e.permissionDenied
          ? l10n.avatarPermissionDenied
          : l10n.avatarPickFailed,
    );
  }
}

Future<_SheetAction?> _showSourceSheet(
  BuildContext context, {
  required bool canRemove,
}) {
  final AppLocalizations l10n = AppLocalizations.of(context);

  return showModalBottomSheet<_SheetAction>(
    context: context,
    backgroundColor: AppColor.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.avatarSheetTitle,
                style: AppTextStyle.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            _SheetTile(
              icon: Icons.photo_camera_rounded,
              label: l10n.avatarSheetCamera,
              onTap: () => Navigator.of(sheetContext).pop(_SheetAction.camera),
            ),
            _SheetTile(
              icon: Icons.photo_library_rounded,
              label: l10n.avatarSheetGallery,
              onTap: () => Navigator.of(sheetContext).pop(_SheetAction.gallery),
            ),
            if (canRemove)
              _SheetTile(
                icon: Icons.delete_outline_rounded,
                label: l10n.avatarSheetRemove,
                color: AppColor.danger,
                onTap: () =>
                    Navigator.of(sheetContext).pop(_SheetAction.remove),
              ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color tint = color ?? AppColor.ink;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 22, color: tint),
            const SizedBox(width: 16),
            Text(label, style: AppTextStyle.bodyMedium.copyWith(color: tint)),
          ],
        ),
      ),
    );
  }
}
