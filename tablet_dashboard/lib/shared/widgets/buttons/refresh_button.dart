import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';

// Tombol muat ulang, berputar selama dimuat
class RefreshButton extends StatefulWidget {
  const RefreshButton({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  State<RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<RefreshButton> {
  bool _busy = false;

  Future<void> _run() async {
    setState(() => _busy = true);
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      tooltip: 'Muat ulang',
      onPressed: _busy ? null : _run,
      style: IconButton.styleFrom(
        side: const BorderSide(color: AppColor.borderStrong),
      ),
      icon: _busy
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColor.gold,
              ),
            )
          : const Icon(Icons.refresh, size: 20, color: AppColor.ink),
    );
  }
}
