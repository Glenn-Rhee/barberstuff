import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/provider/branch_detail_controller.dart';
import 'package:tablet_dashboard/features/admin/branch/presentation/widgets/branch_map.dart';
import 'package:tablet_dashboard/shared/widgets/feedback/empty_state.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Tab Maps Toko: titik GPS cabang yang dipakai aplikasi pelanggan
class MapTab extends StatelessWidget {
  const MapTab({super.key, required this.onEdit});

  // Buka halaman Edit Cabang untuk memindah titik
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final branch = context.watch<BranchDetailController>().branch;
    final lat = branch.latitude, long = branch.longitude;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Lokasi Toko', style: AppTextStyle.h3),
              ),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                label: const Text('Ubah Titik'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            branch.address ?? 'Alamat belum diisi',
            style: AppTextStyle.body,
          ),
          Text(
            lat == null || long == null
                ? 'Titik GPS belum diatur'
                : 'Koordinat: ${lat.toStringAsFixed(6)}, '
                      '${long.toStringAsFixed(6)}',
            style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
          ),
          const SizedBox(height: 16),
          if (branch.hasCoordinate)
            BranchMapView(latitude: lat, longitude: long, height: 380)
          else
            const EmptyState(
              icon: Icons.location_off_outlined,
              title: 'Titik peta belum diatur',
              message: 'Tandai lokasi cabang lewat tombol Ubah Titik.',
            ),
        ],
      ),
    );
  }
}
