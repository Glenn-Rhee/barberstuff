import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/localization/local_controller.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:provider/provider.dart';

Future<void> showLanguageSheet(BuildContext context) {
  final LocalController controller = context.read<LocalController>();
  final AppLocalizations l10n = AppLocalizations.of(context);

  final Map<String, String> options = <String, String>{
    'id': l10n.languageIndonesian,
    'en': l10n.languageEnglish,
  };

  return showModalBottomSheet<void>(
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
                l10n.languageSheetTitle,
                style: AppTextStyle.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            for (final MapEntry<String, String> option in options.entries)
              _LanguageTile(
                label: option.value,
                selected: controller.locale.languageCode == option.key,
                onTap: () {
                  controller.setLocale(option.key);
                  Navigator.of(sheetContext).pop();
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: AppTextStyle.bodyMedium.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_rounded,
                size: 20,
                color: AppColor.orangeLight,
              ),
          ],
        ),
      ),
    );
  }
}
