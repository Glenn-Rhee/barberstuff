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

// Profil cabang di atas tab detail, foto di kanan
class BranchProfileCard extends StatelessWidget {
  const BranchProfileCard({super.key});

  // Tinggi tetap, kalau ikut foto kartunya memanjang sesuai ukuran gambar
  static const height = 220.0;

  // "081234567890" -> "0812-3456-7890"
  static String phoneLabel(String? phone) {
    if (phone == null || phone.isEmpty) return '-';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return [
      for (var i = 0; i < digits.length; i += 4)
        digits.substring(i, (i + 4).clamp(0, digits.length)),
    ].join('-');
  }

  @override
  Widget build(BuildContext context) {
    final branch = context.watch<BranchDetailController>().branch;
    final services = context.watch<ServiceListController>();

    // total_service backend ikut hitung yang terhapus, pakai daftar asli
    final serviceCount = services.loading || services.error != null
        ? branch.totalService
        : services.activeCount;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: AppCard(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profil Cabang',
                    style: AppTextStyle.title.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _ProfileField(
                                label: 'ALAMAT',
                                value: branch.address,
                                maxLines: 2,
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
                          child: Column(
                            children: [
                              _ProfileField(
                                label: 'TELEPON',
                                value: phoneLabel(branch.phone),
                              ),
                              _ProfileField(
                                label: 'DESKRIPSI',
                                value: branch.description,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ProfileField(
                                label: 'JUMLAH SERVICE',
                                value: '$serviceCount Service Operasional',
                              ),
                              _Rating(
                                label: branch.reviewCount == 0
                                    ? 'Belum ada'
                                    : branch.rating.toStringAsFixed(1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: BranchBanner(
              url: branch.bannerUrl,
              radius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  final String label;
  final String? value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
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
              fontSize: 10,
              letterSpacing: 0.5,
              color: AppColor.inkSoft,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value ?? '-',
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.bodyMedium.copyWith(fontSize: 13, height: 1.3),
          ),
        ],
      ),
    );
  }
}

// "Rating Cabang: ★ 4.9"
class _Rating extends StatelessWidget {
  const _Rating({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Rating Cabang: ',
            style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
          ),
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: AppIcon(AppAsset.fullStarIcon, size: 14, tint: false),
          ),
          TextSpan(
            text: ' $label',
            style: AppTextStyle.bodyBold.copyWith(fontSize: 13),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
