import 'package:flutter/material.dart';

import '../../core/theme/app_color.dart';
import '../../core/theme/app_text_style.dart';

/// ‹ 1 2 3 … 6 › — [page] is zero based.
class PaginationBar extends StatelessWidget {
  const PaginationBar({super.key, required this.page, required this.pageCount, required this.onChanged});

  final int page;
  final int pageCount;
  final ValueChanged<int> onChanged;

  /// Page numbers to show (zero based), `null` marks an ellipsis.
  static List<int?> slots(int page, int pageCount) {
    if (pageCount <= 5) return [for (var i = 0; i < pageCount; i++) i];
    final last = pageCount - 1;
    if (page < 3) return [0, 1, 2, null, last];
    if (page > last - 3) return [0, null, last - 2, last - 1, last];
    return [0, null, page, null, last];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PageBox(icon: Icons.chevron_left, onTap: page > 0 ? () => onChanged(page - 1) : null),
        for (final slot in slots(page, pageCount))
          slot == null
              ? const SizedBox(width: 20, child: Text('…', textAlign: TextAlign.center))
              : _PageBox(label: '${slot + 1}', selected: slot == page, onTap: () => onChanged(slot)),
        _PageBox(icon: Icons.chevron_right, onTap: page < pageCount - 1 ? () => onChanged(page + 1) : null),
      ],
    );
  }
}

class _PageBox extends StatelessWidget {
  const _PageBox({this.label, this.icon, this.selected = false, this.onTap});

  final String? label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : (onTap == null ? AppColor.inkFaint : AppColor.ink);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: selected ? AppColor.gold : AppColor.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: selected ? AppColor.gold : AppColor.borderStrong),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: selected ? null : onTap,
          child: SizedBox.square(
            dimension: 30,
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 18, color: foreground)
                  : Text(label!, style: AppTextStyle.label.copyWith(color: foreground)),
            ),
          ),
        ),
      ),
    );
  }
}
