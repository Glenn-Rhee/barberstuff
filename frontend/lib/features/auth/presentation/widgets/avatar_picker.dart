import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';

class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    super.key,
    this.imageUrl,
    this.imageFile,
    required this.onEdit,
  });

  static const double _size = 104;
  static const double _badge = 32;

  final String? imageUrl;
  final File? imageFile;

  final VoidCallback onEdit;

  Widget _preview() {
    final File? file = imageFile;
    if (file != null) {
      return Image.file(file, fit: BoxFit.cover, gaplessPlayback: true);
    }

    final String? url = imageUrl;
    if (url != null) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
            _placeholder(),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return const ColoredBox(
      color: AppColor.border,
      child: Icon(Icons.person_rounded, size: 52, color: AppColor.surface),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        children: <Widget>[
          ClipOval(
            child: SizedBox(width: _size, height: _size, child: _preview()),
          ),
          Positioned(
            right: 0,
            bottom: 4,
            child: GestureDetector(
              onTap: onEdit,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: _badge,
                height: _badge,
                decoration: BoxDecoration(
                  color: AppColor.orangeLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColor.surface, width: 2),
                ),
                child: Center(
                  child: Image.asset(
                    AppAssets.pencilIcon,
                    width: 14,
                    height: 14,
                    filterQuality: FilterQuality.medium,
                    color: AppColor.surface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
