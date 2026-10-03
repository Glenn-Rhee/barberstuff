import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/constants/app_assets.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/history/domain/entities/booking_history.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/buttons/box_button.dart';

Future<ReviewDraft?> showReviewSheet(
  BuildContext context, {
  required bool readOnly,
  ReviewDraft? initial,
}) {
  return showModalBottomSheet<ReviewDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColor.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) =>
        ReviewSheet(readOnly: readOnly, initial: initial),
  );
}

class ReviewSheet extends StatefulWidget {
  const ReviewSheet({super.key, this.readOnly = false, this.initial});

  final bool readOnly;

  final ReviewDraft? initial;

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  final TextEditingController _message = TextEditingController();

  late int _capster = widget.initial?.capster ?? 0;
  late int _cashier = widget.initial?.cashier ?? 0;
  late int _store = widget.initial?.store ?? 0;

  @override
  void initState() {
    super.initState();
    _message.text = widget.initial?.message ?? '';
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void _submit() {
    final ReviewDraft draft = ReviewDraft(
      capster: _capster,
      cashier: _cashier,
      store: _store,
      message: _message.text,
    );

    if (!draft.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).reviewNeedStars),
          backgroundColor: AppColor.ink,
        ),
      );
      return;
    }

    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
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
              const SizedBox(height: 22),
              Text(
                l10n.reviewTitle,
                style: AppTextStyle.titleMedium.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 3),
              Text(
                l10n.reviewSubtitle,
                style: AppTextStyle.bodySmall.copyWith(
                  fontSize: 11.5,
                  color: AppColor.goldDeep,
                ),
              ),
              const SizedBox(height: 18),
              _RatingRow(
                label: l10n.reviewCapster,
                value: _capster,
                enabled: !widget.readOnly,
                onChanged: (int v) => setState(() => _capster = v),
              ),
              _RatingRow(
                label: l10n.reviewCashier,
                value: _cashier,
                enabled: !widget.readOnly,
                onChanged: (int v) => setState(() => _cashier = v),
              ),
              _RatingRow(
                label: l10n.reviewStore,
                value: _store,
                enabled: !widget.readOnly,
                onChanged: (int v) => setState(() => _store = v),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.reviewMessageLabel,
                style: AppTextStyle.titleSmall.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _message,
                enabled: !widget.readOnly,
                maxLines: 4,
                style: AppTextStyle.bodySmall.copyWith(fontSize: 12.5),
                cursorColor: AppColor.goldDeep,
                decoration: InputDecoration(
                  hintText: l10n.reviewMessageHint,
                  hintStyle: AppTextStyle.bodySmall.copyWith(
                    fontSize: 12.5,
                    color: AppColor.inkFaint,
                  ),
                  contentPadding: const EdgeInsets.all(14),
                  border: _border(AppColor.border),
                  enabledBorder: _border(AppColor.border),
                  disabledBorder: _border(AppColor.border),
                  focusedBorder: _border(AppColor.goldDeep),
                ),
              ),
              const SizedBox(height: 20),
              if (!widget.readOnly)
                BoxButton(label: l10n.reviewSubmit, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color),
  );
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.labelMedium.copyWith(fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (int star = 1; star <= 5; star++)
                    GestureDetector(
                      onTap: enabled ? () => onChanged(star) : null,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Image.asset(
                          star <= value
                              ? AppAssets.starHistoryFilled
                              : AppAssets.starHistoryEmpty,
                          width: 22,
                          height: 22,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColor.border),
      ],
    );
  }
}
