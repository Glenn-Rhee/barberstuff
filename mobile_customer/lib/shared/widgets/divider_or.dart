import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

class DividerOr extends StatelessWidget {
  const DividerOr({super.key, this.spacing = 20});

  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Divider(color: AppColor.border, thickness: 1, height: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppLocalizations.of(context).chooseLoginDividerOr,
              style: AppTextStyle.bodyMedium.copyWith(color: AppColor.inkFaint),
            ),
          ),
          const Expanded(
            child: Divider(color: AppColor.border, thickness: 1, height: 1),
          ),
        ],
      ),
    );
  }
}
