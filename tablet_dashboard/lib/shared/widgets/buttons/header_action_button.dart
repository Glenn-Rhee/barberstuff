import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/shared/widgets/display/app_icon.dart';

// Tombol emas muda di header halaman ("Scan Barcode", "Histori Pelanggan")
class HeaderActionButton extends StatelessWidget {
  const HeaderActionButton({
    super.key,
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
        backgroundColor: AppColor.goldSoft,
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      icon: AppIcon(icon, size: 16),
      label: Text(label),
    );
  }
}
