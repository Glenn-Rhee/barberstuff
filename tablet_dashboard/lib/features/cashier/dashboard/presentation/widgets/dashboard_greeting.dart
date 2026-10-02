import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/cashier/store/presentation/widgets/store_selector.dart';
import 'package:tablet_dashboard/shared/widgets/layout/app_card.dart';

// Header dashboard: "Dashboard > Ringkasan", sapaan, lokasi toko, status toko
class DashboardGreeting extends StatelessWidget {
  const DashboardGreeting({super.key, required this.title, required this.name});

  // Judul kecil di atas sapaan, mis. "Dashboard"
  final String title;
  final String name;

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
                  style: AppTextStyle.caption.copyWith(color: AppColor.inkSoft),
                ),
                Text(
                  'Selamat Datang, ${name.split(' ').first}!',
                  style: AppTextStyle.h2,
                ),
              ],
            ),
          ),
          const StoreSelector(),
          const SizedBox(width: 12),
          const StoreOpenChip(),
        ],
      ),
    );
  }
}
