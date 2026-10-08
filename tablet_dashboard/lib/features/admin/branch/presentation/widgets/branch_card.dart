import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/admin/branch/domain/entities/branch.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/branch_banner.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';

// Kartu cabang: foto, alamat, jam, ringkasan, tombol Detail / Edit
class BranchCard extends StatelessWidget {
  const BranchCard({
    super.key,
    required this.branch,
    required this.onDetail,
    required this.onEdit,
  });

  // Tinggi diatur grid supaya 2 baris pas layar, foto mengisi sisanya
  static const minHeight = 290.0;
  static const maxHeight = 360.0;

  final Branch branch;
  final VoidCallback onDetail;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    const buttonSize = Size(0, 36);
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );

    return Material(
      color: AppColor.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColor.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDetail,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: BranchBanner(url: branch.bannerUrl)),
            Padding(
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
                  const SizedBox(height: 8),
                  _InfoLine(
                    icon: AppAsset.mapPinIcon,
                    text: branch.address ?? 'Alamat belum diisi',
                  ),
                  const SizedBox(height: 4),
                  _InfoLine(icon: AppAsset.clockIcon, text: branch.hours),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _Stat(
                          icon: AppAsset.employeeIcon,
                          label: '${branch.totalCapster} Karyawan',
                        ),
                        _Stat(
                          icon: AppAsset.chairIcon,
                          label: '${branch.totalService} Service',
                        ),
                        _Stat(
                          icon: AppAsset.starOutlineIcon,
                          label: branch.ratingLabel,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onDetail,
                          style: OutlinedButton.styleFrom(
                            minimumSize: buttonSize,
                            shape: buttonShape,
                          ),
                          child: const Text('Lihat Detail'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: onEdit,
                          style: FilledButton.styleFrom(
                            foregroundColor: AppColor.ink,
                            minimumSize: buttonSize,
                            shape: buttonShape,
                          ),
                          child: const Text('Edit'),
                        ),
                      ),
                    ],
                  ),
                ],
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

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIcon(icon, size: 15, tint: false),
        const SizedBox(width: 8),
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

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon, size: 14, tint: false),
          const SizedBox(width: 6),
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
