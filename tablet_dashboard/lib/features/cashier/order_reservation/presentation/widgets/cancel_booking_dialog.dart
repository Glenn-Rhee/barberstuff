import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/shared/dialogs/app_form_dialog.dart';
import 'package:tablet_dashboard/shared/widgets/form/field_label.dart';

// Modal "Alasan Cancel Pesanan", [onSubmit] balikin error atau null (berhasil)
Future<bool> showCancelBookingDialog(
  BuildContext context, {
  required Future<String?> Function(String reason) onSubmit,
}) async {
  final cancelled = await showDialog<bool>(
    context: context,
    builder: (_) => _CancelBookingDialog(onSubmit: onSubmit),
  );
  return cancelled ?? false;
}

class _CancelBookingDialog extends StatefulWidget {
  const _CancelBookingDialog({required this.onSubmit});

  final Future<String?> Function(String reason) onSubmit;

  @override
  State<_CancelBookingDialog> createState() => _CancelBookingDialogState();
}

class _CancelBookingDialogState extends State<_CancelBookingDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      title: 'Alasan Cancel Pesanan',
      subtitle: 'Masukan keterangan cancel pesanan',
      width: 520,
      canSubmit: _reason.text.trim().isNotEmpty,
      onSubmit: () => widget.onSubmit(_reason.text.trim()),
      children: [
        const FieldLabel('Keterangan', required: true),
        TextField(
          controller: _reason,
          autofocus: true,
          minLines: 3,
          maxLines: 3,
          style: AppTextStyle.body,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Contoh: customer tidak jadi datang',
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
}
