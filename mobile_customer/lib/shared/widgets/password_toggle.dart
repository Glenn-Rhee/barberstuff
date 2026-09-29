import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/shared/widgets/app_field_decoration.dart';

class PasswordToggle extends StatelessWidget {
  const PasswordToggle({
    super.key,
    required this.obscured,
    required this.onPressed,
  });

  final bool obscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Image.asset(
        obscured ? AppAssets.eyeOffIcon : AppAssets.eyeIcon,
        width: AppField.iconSize,
        height: AppField.iconSize,
        filterQuality: FilterQuality.medium,
        color: AppColor.inkFaint,
      ),
    );
  }
}
