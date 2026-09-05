import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/localization/local_controller.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:provider/provider.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String? _selected;

  String _labelOf(String code, AppLocalizations l10n) =>
      code == 'id' ? l10n.languageIndonesian : l10n.languageEnglish;

  Future<void> _apply(LocalController controller) async {
    final NavigatorState navigator = Navigator.of(context);
    await controller.setLocale(_selected!);
    if (mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LocalController controller = context.watch<LocalController>();
    final String selected = _selected ?? controller.locale.languageCode;

    return Scaffold(
      backgroundColor: AppColor.surface,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: const BackButton(color: AppColor.ink),
        title: Text(
          l10n.languagePageTitle,
          style: AppTextStyle.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                l10n.languagePageDescription,
                textAlign: TextAlign.justify,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: AppColor.inkFaint,
                ),
              ),
              const SizedBox(height: 26),
              for (final String code in LocalController.supported) ...<Widget>[
                _LanguageOption(
                  code: code,
                  label: _labelOf(code, l10n),
                  selected: selected == code,
                  onTap: () => setState(() => _selected = code),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 14),
              BoxButton(
                label: l10n.languageSelectAction,
                radius: 12,
                onPressed: () => _apply(controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.code,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const double _badge = 52;

  final String code;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: <Widget>[
            _Radio(selected: selected),
            const SizedBox(width: 18),
            Container(
              width: _badge,
              height: _badge,
              decoration: const BoxDecoration(
                color: AppColor.orange,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  code.toUpperCase(),
                  style: AppTextStyle.titleMedium.copyWith(
                    color: AppColor.surface,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  static const double _size = 24;

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColor.orangeLight : AppColor.inkSoft,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColor.orangeLight,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
