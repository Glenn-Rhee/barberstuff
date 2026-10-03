import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';

// Tombol "Batal" abu-abu di tiap dialog, tutup dialog dengan [result]
class DialogCancelButton extends StatelessWidget {
  const DialogCancelButton({super.key, this.result});

  final Object? result;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context, result),
      style: TextButton.styleFrom(foregroundColor: AppColor.inkSoft),
      child: const Text('Batal'),
    );
  }
}
