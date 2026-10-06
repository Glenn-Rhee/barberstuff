import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/shared/widgets/form/field_label.dart';

// Format nomor yang diterima backend: 08xx / 628xx / +628xx
final phonePattern = RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,10}$');

String? validatePhone(String value) => phonePattern.hasMatch(value.trim())
    ? null
    : 'No telepon tidak valid, gunakan format 08xxxx atau +62xxxx';

// Buka jam pilihan 24 jam, balikin "09:00" atau null kalau batal
Future<String?> pickClock(BuildContext context, String? current) async {
  final parts = (current ?? '09:00').split(':');
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(
      hour: int.tryParse(parts.first) ?? 9,
      minute: int.tryParse(parts.last) ?? 0,
    ),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
  );
  if (picked == null) return null;
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(picked.hour)}:${two(picked.minute)}';
}

// Kotak jam (Jam Buka / Jam Tutup), tap = pilih jam
class ClockField extends StatelessWidget {
  const ClockField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.required = false,
    this.busy = false,
    this.icon = Icons.schedule,
  });

  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool required;
  final bool busy;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(label, required: required),
        Material(
          color: AppColor.surfaceSubtle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColor.borderStrong),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: busy ? null : onTap,
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value ?? '--:--',
                      style: AppTextStyle.body.copyWith(
                        color: value == null ? AppColor.inkFaint : null,
                      ),
                    ),
                  ),
                  if (busy)
                    const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(icon, size: 18, color: AppColor.inkSoft),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Area foto bergaris putus-putus. Sudah ada foto = tampil pratinjau
class PhotoDropZone extends StatelessWidget {
  const PhotoDropZone({
    super.key,
    required this.bytes,
    required this.onTap,
    this.height = 140,
  });

  final Uint8List? bytes;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bytes = this.bytes;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: CustomPaint(
        painter: const _DashedBorder(),
        child: SizedBox(
          height: height,
          child: bytes != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(bytes, fit: BoxFit.cover),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.ink.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Ganti Foto',
                          style: AppTextStyle.label.copyWith(
                            color: AppColor.surface,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppColor.gold,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ketuk untuk memilih foto dari galeri',
                      style: AppTextStyle.body.copyWith(
                        color: AppColor.inkSoft,
                      ),
                    ),
                    Text(
                      'JPG, PNG, WEBP, maks. 5 MB',
                      style: AppTextStyle.caption.copyWith(
                        color: AppColor.inkFaint,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  const _DashedBorder();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(10),
    );
    canvas.drawRRect(rect, Paint()..color = AppColor.goldSoft);
    final paint = Paint()
      ..color = AppColor.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final metric in (Path()..addRRect(rect)).computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 10) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder oldDelegate) => false;
}

// Field halaman Edit Cabang: tampil terkunci dengan ikon pensil,
// tap pensil = bisa diketik lalu Simpan / Batal per field
class InlineEditField extends StatefulWidget {
  const InlineEditField({
    super.key,
    required this.label,
    required this.value,
    required this.onSave,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.allowEmpty = false,
  });

  final String label;
  final String? value;

  // Balikin pesan error, atau null kalau tersimpan
  final Future<String?> Function(String value) onSave;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String value)? validator;

  // Boleh dikosongkan (mis. deskripsi)
  final bool allowEmpty;

  @override
  State<InlineEditField> createState() => _InlineEditFieldState();
}

class _InlineEditFieldState extends State<InlineEditField> {
  late final _controller = TextEditingController(text: widget.value);
  final _focus = FocusNode();
  bool _editing = false;
  bool _busy = false;
  String? _error;

  @override
  void didUpdateWidget(InlineEditField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && widget.value != oldWidget.value) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _editing = true;
      _error = null;
    });
    _focus.requestFocus();
  }

  void _cancel() => setState(() {
    _editing = false;
    _error = null;
    _controller.text = widget.value ?? '';
  });

  Future<void> _save() async {
    final value = _controller.text.trim();
    final error = value.isEmpty && !widget.allowEmpty
        ? '${widget.label} wajib diisi'
        : widget.validator?.call(value);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    if (value == (widget.value ?? '')) {
      _cancel();
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final failed = await widget.onSave(value);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = failed;
      if (failed == null) _editing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(widget.label),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                readOnly: !_editing,
                enabled: !_busy,
                minLines: 1,
                maxLines: widget.maxLines,
                keyboardType: widget.keyboardType,
                style: AppTextStyle.body,
                decoration: InputDecoration(
                  hintText: widget.hint ?? '-',
                  fillColor: _editing
                      ? AppColor.surface
                      : AppColor.surfaceSubtle,
                  suffixIcon: _editing
                      ? null
                      : IconButton(
                          tooltip: 'Ubah ${widget.label}',
                          onPressed: _start,
                          icon: const Icon(
                            Icons.edit,
                            size: 18,
                            color: AppColor.inkSoft,
                          ),
                        ),
                ),
                onTap: _editing ? null : _start,
                onSubmitted: widget.maxLines == 1 ? (_) => _save() : null,
              ),
            ),
            if (_editing) ...[
              const SizedBox(width: 10),
              FilledButton(
                onPressed: _busy ? null : _save,
                style: FilledButton.styleFrom(minimumSize: const Size(80, 46)),
                child: _busy
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColor.gold,
                        ),
                      )
                    : const Text('Simpan'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _busy ? null : _cancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColor.inkSoft,
                  side: const BorderSide(color: AppColor.borderStrong),
                  minimumSize: const Size(72, 46),
                ),
                child: const Text('Batal'),
              ),
            ],
          ],
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _error!,
              style: AppTextStyle.caption.copyWith(color: AppColor.danger),
            ),
          ),
      ],
    );
  }
}
