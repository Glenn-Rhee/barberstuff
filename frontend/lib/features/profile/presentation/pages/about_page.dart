import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String lastUpdated = '03/02/2026';
  static const double _gap = 20;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColor.surface,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: const BackButton(color: AppColor.ink),
        title: Text(
          l10n.aboutTitle,
          style: AppTextStyle.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          children: <Widget>[
            Text(
              l10n.aboutLastUpdated(lastUpdated),
              style: AppTextStyle.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.aboutIntro,
              textAlign: TextAlign.justify,
              style: AppTextStyle.bodyLarge,
            ),
            const SizedBox(height: _gap),

            _Section(
              title: l10n.aboutAcceptanceTitle,
              body: l10n.aboutAcceptanceBody,
            ),
            _Section(
              title: l10n.aboutEligibilityTitle,
              body: l10n.aboutEligibilityBody,
            ),
            _Section(
              title: l10n.aboutAccountTitle,
              bullets: <String>[
                l10n.aboutAccountPoint1,
                l10n.aboutAccountPoint2,
                l10n.aboutAccountPoint3,
              ],
            ),
            _Section(
              title: l10n.aboutUsageTitle,
              body: l10n.aboutUsageIntro,
              bullets: <String>[
                l10n.aboutUsagePoint1,
                l10n.aboutUsagePoint2,
                l10n.aboutUsagePoint3,
              ],
            ),
            _Section(title: l10n.aboutIpTitle, body: l10n.aboutIpBody),
            _Section(
              title: l10n.aboutTerminationTitle,
              body: l10n.aboutTerminationBody,
            ),
            _Section(
              title: l10n.aboutDisclaimerTitle,
              body: l10n.aboutDisclaimerBody,
            ),
            _Section(
              title: l10n.aboutChangesTitle,
              body: l10n.aboutChangesBody,
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, this.body, this.bullets});

  final String title;
  final String? body;
  final List<String>? bullets;

  @override
  Widget build(BuildContext context) {
    final String? paragraph = body;
    final List<String> points = bullets ?? const <String>[];

    return Padding(
      padding: const EdgeInsets.only(bottom: AboutPage._gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: AppTextStyle.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (paragraph != null)
            Text(
              paragraph,
              textAlign: TextAlign.justify,
              style: AppTextStyle.bodyLarge,
            ),
          if (paragraph != null && points.isNotEmpty) const SizedBox(height: 8),
          for (final String point in points) _Bullet(text: point),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 10),
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColor.ink,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.justify,
              style: AppTextStyle.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
