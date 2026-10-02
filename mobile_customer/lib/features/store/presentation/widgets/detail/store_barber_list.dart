import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';
import 'package:mobile_barberstuff/features/store/domain/entities/store_detail.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/detail/barber_cards.dart';
import 'package:mobile_barberstuff/features/store/presentation/widgets/detail/store_detail_layout.dart';
import 'package:mobile_barberstuff/l10n/app_localization.dart';

/// Barisan barber cabang yang bisa digeser ke samping.
class StoreBarberList extends StatelessWidget {
  const StoreBarberList({super.key, required this.capsters});

  final List<CapsterItem> capsters;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (capsters.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: StoreDetailLayout.sidePadding,
        ),
        child: Text(
          l10n.storeNoBarber,
          style: AppTextStyle.bodySmall.copyWith(color: AppColor.inkFaint),
        ),
      );
    }

    return SizedBox(
      height: 52 * StoreDetailLayout.textScale(context),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: StoreDetailLayout.sidePadding,
        ),
        itemCount: capsters.length,
        separatorBuilder: (BuildContext _, int _) => const SizedBox(width: 10),
        itemBuilder: (BuildContext context, int index) =>
            BarberChip(capster: capsters[index]),
      ),
    );
  }
}
