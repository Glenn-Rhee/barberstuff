import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/branch_detail_controller.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/service_list_controller.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/branch_banner.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Profil cabang di atas tab detail: alamat, jam, telepon, deskripsi,
// jumlah layanan aktif, rating, lalu foto di kanan setinggi kartunya
class BranchProfileCard extends StatelessWidget {
  const BranchProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final branch = context.watch<BranchDetailController>().branch;
    final services = context.watch<ServiceListController>();
    final packages = context.watch<PackageListController>();

    // total_service backend ikut menghitung yang sudah dihapus,
    // jadi pakai daftar aslinya kalau sudah dimuat
    String count(ServiceListController list, int fallback, String label) =>
        list.loading || list.error != null
        ? '$fallback $label'
        : '${list.activeCount} $label Aktif';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Profil Cabang', style: AppTextStyle.title),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _ProfileColumn(
                          children: [
                            _ProfileField(
                              label: 'ALAMAT',
                              value: branch.address,
                              maxLines: 3,
                            ),
                            _ProfileField(
                              label: 'JAM OPERASIONAL',
                              value: branch.hours,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _ProfileColumn(
                          children: [
                            _ProfileField(
                              label: 'TELEPON',
                              value: branch.phone,
                            ),
                            _ProfileField(
                              label: 'DESKRIPSI',
                              value: branch.description,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _ProfileColumn(
                          children: [
                            _ProfileField(
                              label: 'JUMLAH LAYANAN',
                              value:
                                  '${count(services, branch.totalService, 'Service')}\n'
                                  '${count(packages, branch.totalPackage, 'Paket')}',
                              maxLines: 2,
                            ),
                            _ProfileField(
                              label: 'STATUS',
                              value:
                                  '${branch.open ? 'Buka' : 'Tutup'} · '
                                  '${branch.type.label}',
                            ),
                            _ProfileField(
                              label: 'RATING CABANG',
                              value: branch.reviewCount == 0
                                  ? 'Belum ada ulasan'
                                  : '${branch.rating.toStringAsFixed(1)} '
                                        '(${branch.reviewCount} ulasan)',
                              leading: const AppIcon(
                                AppAsset.starIcon,
                                size: 14,
                                tint: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 220),
              child: BranchBanner(
                url: branch.bannerUrl,
                radius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileColumn extends StatelessWidget {
  const _ProfileColumn({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.value,
    this.maxLines = 1,
    this.leading,
  });

  final String label;
  final String? value;
  final int maxLines;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      value ?? '-',
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyle.bodyMedium.copyWith(height: 1.3),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.only(bottom: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.caption.copyWith(
              fontSize: 11,
              letterSpacing: 0.5,
              color: AppColor.inkSoft,
            ),
          ),
          const SizedBox(height: 2),
          if (leading == null)
            text
          else
            Row(
              children: [
                leading!,
                const SizedBox(width: 4),
                Flexible(child: text),
              ],
            ),
        ],
      ),
    );
  }
}
