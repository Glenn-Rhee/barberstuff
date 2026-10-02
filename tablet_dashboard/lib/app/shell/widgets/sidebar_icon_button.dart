import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';

// Tombol ikon kecil abu-abu di dalam sidebar
class SidebarIconButton extends StatelessWidget {
  const SidebarIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: AppColor.sidebarMuted),
        ),
      ),
    );
  }
}
