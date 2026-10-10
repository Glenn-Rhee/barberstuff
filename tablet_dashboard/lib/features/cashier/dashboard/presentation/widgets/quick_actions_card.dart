import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/constants/app_asset.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/cashier/attendance/presentation/pages/attendance_screen.dart';
<<<<<<< HEAD
import 'package:tablet_dashboard/features/cashier/reservation/presentation/pages/scan_booking_screen.dart';
=======
import 'package:tablet_dashboard/features/cashier/order_scan/presentation/pages/scan_booking_screen.dart';
>>>>>>> 7d13d7e32679190728e118598f013051b3289112
import 'package:tablet_dashboard/features/cashier/shift/presentation/widgets/cash_entry_dialog.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Tombol pintas: scan QR booking, catat kas keluar, absensi karyawan
class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AKSI CEPAT', style: AppTextStyle.bodyBold),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: AppAsset.scanIcon,
                  label: 'Scan Barcode',
                  onTap: () => openScanBooking(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: AppAsset.graphicIcon,
                  label: 'Catat Kas Keluar',
                  onTap: () => showCashEntryDialog(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: AppAsset.personIcon,
                  label: 'Absensi Karyawan',
                  onTap: () => openAttendance(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  // Path asset ikon
  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        backgroundColor: AppColor.surface,
      ),
      icon: AppIcon(icon, size: 18),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
