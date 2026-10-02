import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/cashier/shift/presentation/widgets/shift_status_chip.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// "Selamat Datang, Budi!" + tombol muat ulang + status shift
class DashboardGreeting extends StatelessWidget {
  const DashboardGreeting({
    super.key,
    required this.title,
    required this.name,
    required this.onRefresh,
  });

  // Judul kecil di atas sapaan, mis. "Dashboard Kasir"
  final String title;
  final String name;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title > Ringkasan',
                  style: AppTextStyle.caption.copyWith(
                    color: AppColor.inkSoft,
                  ),
                ),
                Text(
                  'Selamat Datang, ${name.split(' ').first}!',
                  style: AppTextStyle.h2,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Muat ulang data',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, size: 20),
          ),
          const SizedBox(width: 8),
          const ShiftStatusChip(filled: true),
        ],
      ),
    );
  }
}
