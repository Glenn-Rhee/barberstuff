import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/cashier/catalog/presentation/provider/catalog_controller.dart';
import 'package:tablet_dashboard/shared/widgets/display/person_avatar.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/error_bar.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Daftar capster aktif di toko (maks 6)
class CapsterListCard extends StatelessWidget {
  const CapsterListCard({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    final capsters = catalog.activeCapsters;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Capster Toko', style: AppTextStyle.title),
              ),
              Text(
                '${capsters.length} aktif',
                style: AppTextStyle.label.copyWith(color: AppColor.success),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (catalog.loadingCapsters)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (catalog.capsterError != null)
            ErrorBar(
              message: catalog.capsterError!,
              onRetry: catalog.loadCapsters,
            )
          else
            for (final capster in capsters.take(6))
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor.surfaceSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    PersonAvatar(name: capster.name, photo: capster.photoUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        capster.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.bodyBold,
                      ),
                    ),
                    if (capster.rating > 0) ...[
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColor.gold,
                      ),
                      Text(
                        capster.rating.toStringAsFixed(1),
                        style: AppTextStyle.caption.copyWith(
                          color: AppColor.inkSoft,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
