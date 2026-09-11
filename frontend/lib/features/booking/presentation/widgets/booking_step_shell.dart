import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/services/api_exception.dart';
import 'package:mobile_barberstuff/core/services/api_exception_message.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/box_button.dart';
import 'package:mobile_barberstuff/shared/widgets/box_loader.dart';

class BookingStepState extends StatelessWidget {
  const BookingStepState({
    super.key,
    required this.loading,
    required this.error,
    required this.isEmpty,
    required this.emptyMessage,
    required this.onRetry,
    required this.child,
  });

  final bool loading;
  final ApiException? error;
  final bool isEmpty;
  final String emptyMessage;
  final VoidCallback onRetry;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (loading) return const Center(child: BoxLoader());

    final ApiException? failure = error;
    if (failure != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                failure.message(l10n),
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: AppColor.inkSoft,
                ),
              ),
              const SizedBox(height: 18),
              BoxButton(label: l10n.commonRetry, onPressed: onRetry),
            ],
          ),
        ),
      );
    }

    if (isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: AppTextStyle.bodyMedium.copyWith(color: AppColor.inkFaint),
          ),
        ),
      );
    }

    return child;
  }
}

class BookingSelectCard extends StatelessWidget {
  const BookingSelectCard({
    super.key,
    required this.selected,
    required this.enabled,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(14, 12, 12, 12),
  });

  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: selected
            ? AppColor.goldSoft.withValues(alpha: 0.18)
            : AppColor.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? AppColor.goldDeep : AppColor.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class BookingRadioDot extends StatelessWidget {
  const BookingRadioDot({super.key, required this.selected});

  static const double _size = 20;

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColor.goldDeep : AppColor.surface,
        border: Border.all(
          color: selected ? AppColor.goldDeep : AppColor.inkFaint,
          width: 1.5,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.surface,
                ),
              ),
            )
          : null,
    );
  }
}

String formatRupiah(num value) {
  final String digits = value.round().toString();
  final StringBuffer out = StringBuffer();

  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write('.');
    out.write(digits[i]);
  }

  return 'Rp$out';
}
