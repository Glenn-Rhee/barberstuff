import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/core/utils/name_format.dart';

// Foto bulat orang, kalau tidak ada foto tampil inisial
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.name,
    this.photo,
    this.size = 36,
  });

  final String name;

  // Path asset atau URL foto dari API
  final String? photo;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColor.surfaceMuted,
        shape: BoxShape.circle,
      ),
      child: Text(
        initialsOf(name),
        style: AppTextStyle.label.copyWith(
          fontSize: size * 0.3,
          color: AppColor.inkSoft,
        ),
      ),
    );

    final photo = this.photo;
    if (photo == null) return initials;

    return ClipOval(
      child: Image(
        image: photo.startsWith('http')
            ? NetworkImage(photo)
            : AssetImage(photo) as ImageProvider,
        width: size,
        height: size,
        fit: BoxFit.cover,
        // Inisial selama foto dimuat, atau kalau gagal
        // (link presigned dari backend kedaluwarsa 30 menit)
        frameBuilder: (_, child, frame, loadedSync) =>
            frame == null && !loadedSync ? initials : child,
        errorBuilder: (_, _, _) => initials,
      ),
    );
  }
}
