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
    final photo = this.photo;
    final image = switch (photo) {
      null => null,
      final url when url.startsWith('http') => NetworkImage(url),
      final asset => AssetImage(asset) as ImageProvider,
    };

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColor.surfaceMuted,
      backgroundImage: image,
      // Inisial tetap ada di bawah foto, jadi kelihatan saat foto gagal dimuat
      child: Text(
        initialsOf(name),
        style: AppTextStyle.label.copyWith(
          fontSize: size * 0.3,
          color: image == null ? AppColor.inkSoft : Colors.transparent,
        ),
      ),
    );
  }
}
