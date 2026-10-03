import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';

// Kerangka modal form sesuai desain: judul + tombol tutup, isi form,
// centang "Saya memastikan data sudah benar", lalu Batal / Simpan.
// [onSubmit] balikin pesan error (dialog tetap terbuka) atau null (dialog tutup)
class AppFormDialog extends StatefulWidget {
  const AppFormDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.canSubmit,
    required this.onSubmit,
    this.submitLabel = 'Simpan',
    this.danger = false,
    this.width = 440,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool canSubmit;
  final Future<String?> Function() onSubmit;
  final String submitLabel;
  final bool danger;
  final double width;

  @override
  State<AppFormDialog> createState() => _AppFormDialogState();
}

class _AppFormDialogState extends State<AppFormDialog> {
  bool _confirmed = false;
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await widget.onSubmit();
    if (!mounted) return;
    if (error == null) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.canSubmit && _confirmed && !_busy;

    return Dialog(
      child: SizedBox(
        width: widget.width,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: AppTextStyle.h2),
                        Text(
                          widget.subtitle,
                          style: AppTextStyle.caption.copyWith(
                            color: AppColor.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup',
                    onPressed: _busy ? null : () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: AppColor.inkSoft,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 16),
              ...widget.children,
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: AppTextStyle.label.copyWith(color: AppColor.danger),
                ),
              ],
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: _busy
                    ? null
                    : () => setState(() => _confirmed = !_confirmed),
                child: Row(
                  children: [
                    Checkbox(
                      value: _confirmed,
                      activeColor: AppColor.gold,
                      visualDensity: VisualDensity.compact,
                      onChanged: _busy
                          ? null
                          : (value) => setState(() => _confirmed = value!),
                    ),
                    Expanded(
                      child: Text(
                        'Saya memastikan data sudah benar',
                        style: AppTextStyle.caption,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy ? null : () => Navigator.pop(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColor.surfaceMuted,
                        foregroundColor: AppColor.ink,
                        side: const BorderSide(color: AppColor.borderStrong),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: enabled ? _submit : null,
                      style: widget.danger
                          ? FilledButton.styleFrom(
                              backgroundColor: AppColor.danger,
                            )
                          : null,
                      child: _busy
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColor.surface,
                              ),
                            )
                          : Text(widget.submitLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
