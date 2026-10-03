import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_detail.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';
import 'package:mobile_barberstuff/shared/widgets/buttons/box_button.dart';

/// Tombol booking yang menempel di bawah layar. Cabang tutup = tombol mati.
class StoreBookBar extends StatelessWidget {
  const StoreBookBar({super.key, required this.detail, required this.onBook});

  final StoreDetail detail;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColor.surface,
        border: Border(top: BorderSide(color: AppColor.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: BoxButton(
            label: detail.isOpen ? l10n.storeBookCta : l10n.storeBookClosed,
            onPressed: detail.isOpen ? onBook : null,
          ),
        ),
      ),
    );
  }
}
