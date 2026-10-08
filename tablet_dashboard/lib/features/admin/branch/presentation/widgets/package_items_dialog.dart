import 'package:flutter/material.dart';
import 'package:tablet_dashboard/core/theme/app_color.dart';
import 'package:tablet_dashboard/core/theme/app_text_style.dart';
import 'package:tablet_dashboard/features/cashier/catalog/domain/entities/service_item.dart';
import 'package:tablet_dashboard/shared/widgets/buttons/dialog_cancel_button.dart';

// Susun isi paket dari service cabang ke deskripsi (backend tanpa relasi).
// Balikin teks baru, null = batal
Future<String?> showPackageItemsDialog(
  BuildContext context, {
  required List<ServiceItem> services,
  required String current,
}) {
  final chosen = {
    for (final part in current.split('+'))
      if (part.trim().isNotEmpty) part.trim().toLowerCase(),
  };
  return showDialog<String>(
    context: context,
    builder: (_) => _PackageItemsDialog(
      services: services,
      initial: {
        for (final service in services)
          if (chosen.contains(service.name.toLowerCase())) service.id,
      },
    ),
  );
}

class _PackageItemsDialog extends StatefulWidget {
  const _PackageItemsDialog({required this.services, required this.initial});

  final List<ServiceItem> services;
  final Set<String> initial;

  @override
  State<_PackageItemsDialog> createState() => _PackageItemsDialogState();
}

class _PackageItemsDialogState extends State<_PackageItemsDialog> {
  late final _selected = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Isi Paket', style: AppTextStyle.title),
      content: SizedBox(
        width: 360,
        child: widget.services.isEmpty
            ? Text(
                'Cabang ini belum punya service. Tambah dulu di tab Service.',
                style: AppTextStyle.body.copyWith(color: AppColor.inkSoft),
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final service in widget.services)
                    CheckboxListTile(
                      value: _selected.contains(service.id),
                      activeColor: AppColor.gold,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(service.name, style: AppTextStyle.body),
                      onChanged: (value) => setState(
                        () => value == true
                            ? _selected.add(service.id)
                            : _selected.remove(service.id),
                      ),
                    ),
                ],
              ),
      ),
      actions: [
        const DialogCancelButton(),
        FilledButton(
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.pop(
                  context,
                  [
                    for (final service in widget.services)
                      if (_selected.contains(service.id)) service.name,
                  ].join(' + '),
                ),
          child: Text('Pakai ${_selected.length} Service'),
        ),
      ],
    );
  }
}
