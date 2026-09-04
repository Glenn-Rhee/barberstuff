import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.surface,
      body: Center(
        child: Text(
          AppLocalizations.of(context).comingSoonTitle,
          style: AppTextStyle.headlineMedium.copyWith(color: AppColor.inkSoft),
        ),
      ),
    );
  }
}
