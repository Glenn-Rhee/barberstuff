import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';

/// Pesan gagal muat yang tetap bisa ditarik ke bawah untuk coba lagi,
/// jadi pengguna tidak perlu keluar masuk halaman.
class ErrorRetryView extends StatelessWidget {
  const ErrorRetryView({
    super.key,
    required this.message,
    required this.onRetry,
    this.showButton = true,
  });

  final String message;
  final Future<void> Function() onRetry;
  final bool showButton;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: onRetry,
      color: AppColor.goldDeep,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          return SingleChildScrollView(
            // Wajib, kalau tidak isinya terlalu pendek untuk bisa ditarik.
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 40,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.bodyMedium.copyWith(
                          color: AppColor.inkSoft,
                        ),
                      ),
                      if (showButton) ...<Widget>[
                        const SizedBox(height: 20),
                        BoxButton(label: l10n.commonRetry, onPressed: onRetry),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
