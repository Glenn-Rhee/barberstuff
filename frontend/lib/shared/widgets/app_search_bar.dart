import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';

/// Kolom cari dengan tombol emas menyatu di ujung kanan.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    required this.hint,
    this.onSubmit,
  });

  static const double _height = 46;
  static const double _radius = 10;

  final TextEditingController controller;
  final String hint;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: AppColor.border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (String _) => onSubmit?.call(),
              style: AppTextStyle.bodySmall.copyWith(fontSize: 13),
              cursorColor: AppColor.goldDeep,
              decoration: InputDecoration(
                isDense: true,
                hintText: hint,
                hintStyle: AppTextStyle.bodySmall.copyWith(
                  fontSize: 13,
                  color: AppColor.inkFaint,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          Material(
            color: AppColor.goldDeep,
            child: InkWell(
              onTap: onSubmit,
              child: SizedBox(
                width: _height,
                height: _height,
                child: Center(
                  child: Image.asset(
                    AppAssets.searchBookingIcon,
                    width: 18,
                    height: 18,
                    fit: BoxFit.contain,
                    color: AppColor.surface,
                    filterQuality: FilterQuality.medium,
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
