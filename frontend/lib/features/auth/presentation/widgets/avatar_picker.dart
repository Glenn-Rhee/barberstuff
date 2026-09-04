import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';

class AvatarPicker extends StatelessWidget {
  const AvatarPicker({super.key, this.imageUrl, required this.onEdit});

  static const double _size = 104;
  static const double _badge = 32;

  final String? imageUrl;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final String? url = imageUrl;

    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        children: <Widget>[
          ClipOval(
            child: SizedBox(
              width: _size,
              height: _size,
              child: url == null
                  ? const ColoredBox(
                      color: AppColor.border,
                      child: Icon(
                        Icons.person_rounded,
                        size: 52,
                        color: AppColor.surface,
                      ),
                    )
                  : Image.network(url, fit: BoxFit.cover),
            ),
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
