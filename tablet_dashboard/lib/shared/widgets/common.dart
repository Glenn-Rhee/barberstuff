import 'package:flutter/material.dart';

import '../../core/theme/app_color.dart';
import '../../core/theme/app_text_style.dart';
import '../models/person.dart';

class PersonAvatar extends StatelessWidget {
  const PersonAvatar({super.key, required this.name, this.photo, this.size = 36});

  final String name;

  /// Asset path or a photo URL from the API; falls back to initials.
  final String? photo;
  final double size;

  @override
  Widget build(BuildContext context) {
    final photo = this.photo;
    final image = switch (photo) {
      null => null,
      final url when url.startsWith('http') => NetworkImage(url),
      final asset => AssetImage(asset) as ImageProvider,
    };

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColor.surfaceMuted,
      backgroundImage: image,
      // Keeps initials visible while a photo loads or when it fails.
      child: Text(
        initialsOf(name),
        style: AppTextStyle.label.copyWith(
          fontSize: size * 0.3,
          color: image == null ? AppColor.inkSoft : Colors.transparent,
        ),
      ),
    );
  }
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({super.key, required this.hint, required this.onChanged, this.initialValue = ''});

  final String hint;
  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        style: AppTextStyle.body,
        decoration: InputDecoration(
          hintText: hint,
          fillColor: AppColor.surface,
          prefixIcon: const Icon(Icons.search, color: AppColor.inkSoft),
        ),
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  const SummaryRow({super.key, required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: AppTextStyle.caption.copyWith(fontSize: 12)),
          const Spacer(),
          Text(value, style: AppTextStyle.label.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}

/// "Total  Rp 55.000" with the amount in gold; the amount shrinks rather than overflowing.
class TotalRow extends StatelessWidget {
  const TotalRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTextStyle.sectionTitle),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: AppTextStyle.sectionTitle.copyWith(color: AppColor.gold, fontSize: 18)),
            ),
          ),
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(color: AppColor.surfaceMuted, shape: BoxShape.circle),
              child: Icon(icon, color: AppColor.inkFaint),
            ),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyle.bodyStrong, textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(message, style: AppTextStyle.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// Outlined red button ("Tutup Shift Kasir", "Cancel Pesanan").
ButtonStyle dangerOutlinedStyle() => OutlinedButton.styleFrom(
  foregroundColor: AppColor.danger,
  backgroundColor: AppColor.dangerSoft,
  side: const BorderSide(color: AppColor.danger),
);

/// Soft gold button ("+ Tambah", "Tambah Layanan / Paket").
ButtonStyle softGoldStyle() => TextButton.styleFrom(
  foregroundColor: AppColor.gold,
  backgroundColor: AppColor.goldSoft,
  disabledBackgroundColor: AppColor.surfaceMuted,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
);

class AppToast {
  const AppToast._();

  static void show(BuildContext context, String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: AppTextStyle.body.copyWith(color: Colors.white)),
          backgroundColor: error ? AppColor.danger : AppColor.ink,
          width: 480,
        ),
      );
  }
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, style: AppTextStyle.sectionTitle),
      content: Text(message, style: AppTextStyle.body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(foregroundColor: AppColor.inkSoft),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: danger ? FilledButton.styleFrom(backgroundColor: AppColor.danger) : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
