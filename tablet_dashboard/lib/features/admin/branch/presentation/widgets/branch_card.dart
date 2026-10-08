import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/admin/branch/domain/entities/branch.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/branch_banner.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/display/status_badge.dart';

// Kartu cabang: foto, alamat, jam, ringkasan, tombol Detail / Edit
class BranchCard extends StatelessWidget {
  const BranchCard({
    super.key,
    required this.branch,
    required this.onDetail,
    required this.onEdit,
  });

  static const height = 340.0;

  final Branch branch;
  final VoidCallback onDetail;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColor.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDetail,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                BranchBanner(url: branch.bannerUrl, height: 130),
                Positioned(
                  left: 10,
                  top: 10,
                  child: branch.open
                      ? StatusBadge(
                          label: 'Buka',
                          color: AppColor.success,
                          background: AppColor.successSoft,
                        )
                      : StatusBadge(
                          label: 'Tutup',
                          color: AppColor.danger,
                          background: AppColor.dangerSoft,
                        ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: StatusBadge(
                    label: branch.type.label,
                    color: AppColor.surface,
                    background: AppColor.ink.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      branch.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.title.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _InfoLine(
                      icon: Icons.location_on_outlined,
                      text: branch.address ?? 'Alamat belum diisi',
                    ),
                    const SizedBox(height: 2),
                    _InfoLine(icon: Icons.schedule, text: branch.hours),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _Stat(
                            icon: const Icon(
                              Icons.person_outline,
                              size: 15,
                              color: AppColor.inkSoft,
                            ),
                            label: '${branch.totalCapster} Capster',
                          ),
                          const SizedBox(width: 8),
                          _Stat(
                            icon: const Icon(
                              Icons.chair_outlined,
                              size: 15,
                              color: AppColor.inkSoft,
                            ),
                            label: '${branch.totalService} Service',
                          ),
                          const SizedBox(width: 8),
                          _Stat(
                            icon: const AppIcon(
                              AppAsset.starIcon,
                              size: 14,
                              tint: false,
                            ),
                            label: branch.ratingLabel,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onDetail,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 38),
                            ),
                            child: const Text('Lihat Detail'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: onEdit,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 38),
                            ),
                            child: const Text('Edit'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColor.gold),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});

  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.label.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
