import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';

class StoreActionButton extends StatelessWidget {
  const StoreActionButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Material(
          color: AppColor.surface,
          clipBehavior: Clip.antiAlias,
          shape: const CircleBorder(side: BorderSide(color: AppColor.goldDeep)),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 46,
              height: 46,
              child: Center(
                child: Image.asset(
                  iconPath,
                  width: 19,
                  height: 19,
                  fit: BoxFit.contain,
                  color: AppColor.goldDeep,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          style: AppTextStyle.bodySmall.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
