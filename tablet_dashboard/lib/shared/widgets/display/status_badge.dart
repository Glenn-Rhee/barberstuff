import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

// Label kecil bulat berwarna, mis. status booking
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyle.label.copyWith(color: color, fontSize: 11),
      ),
    );
  }
}
