import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';
import 'package:mobile_barberstuff/core/theme/app_text_style.dart';

/// Label + tombol kurang/tambah, untuk menyetel angka di panel debug.
class DebugCounterRow extends StatelessWidget {
  const DebugCounterRow({
    super.key,
    required this.label,
    required this.count,
    required this.onAdd,
    required this.onRemove,
  });

  final String label;
  final int count;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(label, style: AppTextStyle.bodyMedium)),
        _StepButton(icon: Icons.remove_rounded, onTap: onRemove),
        SizedBox(
          width: 44,
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            style: AppTextStyle.titleSmall,
          ),
        ),
        _StepButton(icon: Icons.add_rounded, onTap: onAdd),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColor.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: AppColor.ink),
        ),
      ),
    );
  }
}

/// Chip pilihan di panel debug; [selected] menandai pilihan yang aktif.
class DebugChip extends StatelessWidget {
  const DebugChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color tint = color ?? AppColor.inkSoft;

    return Material(
      color: selected ? tint.withValues(alpha: 0.22) : AppColor.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: selected ? tint : AppColor.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: AppTextStyle.bodySmall.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
